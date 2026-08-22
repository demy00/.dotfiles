#!/usr/bin/env python3
"""Cross-family spec gate.

Sends a spec to a model from a DIFFERENT family than the one that wrote it, and
derives a verdict from a closed set of four blocking reasons.

The decorrelation is the whole mechanism. A model reviewing its own family's
output shares its blind spots, so a same-family verdict is refused rather than
trusted.

Fails closed. Missing key, unreachable model, unparseable response, or a
same-family model all exit non-zero. A gate that degrades silently is worse
than no gate, because it still reports approval.

    ./gate.py <spec.md>                  gate a spec
    ./gate.py <spec.md> --author openai  the spec was written by a non-Anthropic model
    ./gate.py --check                    verify configuration, call nothing

Environment:
    OPENROUTER_API_KEY   required
    GATE_MODEL           default: google/gemini-2.5-flash
    AUTHOR_FAMILY        default: anthropic
    GATE_BYPASS          break-glass reason; logged, never silent
"""

from __future__ import annotations

import json
import os
import sys
import urllib.error
import urllib.request
from pathlib import Path

API_URL = "https://openrouter.ai/api/v1/chat/completions"
DEFAULT_MODEL = "google/gemini-2.5-flash"
TIMEOUT_S = 120

# The closed set. Nothing outside this blocks; everything else is a note.
BLOCKING = ("missing_requirement", "contradiction", "untestable_criterion", "unhandled_edge_case")

# Which family a model id belongs to. An unknown vendor is a loud refusal, not a
# guess - guessing here would silently defeat the decorrelation.
VENDORS = {
    "anthropic": "anthropic",
    "openai": "openai",
    "google": "google",
    "deepseek": "deepseek",
    "meta-llama": "meta",
    "mistralai": "mistral",
    "qwen": "qwen",
    "x-ai": "xai",
}

PROMPT = """You are reviewing a specification before implementation begins.

Report EVERYTHING you notice. You have no verdict to give - a separate step
derives it. Do not soften findings and do not decide what is important.

Classify each finding as exactly one of:
  missing_requirement  - behaviour the goal implies but no requirement covers
  contradiction        - two statements that cannot both hold
  untestable_criterion - an acceptance criterion nobody could check objectively
  unhandled_edge_case  - a critical edge case with no stated handling
  note                 - anything else at all: style, naming, scope, doubts

Only the first four block. `note` never blocks, so use it freely rather than
inflating something into a blocking category to make it visible.

Return ONLY minified JSON, no markdown fence:
{"findings":[{"kind":"<one of the five>","requirement":"<id or null>",
"detail":"<one sentence>"}]}

SPEC:
---
%s
---"""


def die(msg: str, code: int = 2) -> None:
    print(f"gate: {msg}", file=sys.stderr)
    sys.exit(code)


def family_of(model: str) -> str:
    vendor = model.split("/", 1)[0] if "/" in model else model
    if vendor not in VENDORS:
        die(f"unknown vendor {vendor!r} in GATE_MODEL - add it to VENDORS rather than guessing")
    return VENDORS[vendor]


def check_config(model: str, author: str) -> str:
    """Returns the gate family. Refuses same-family, which is the point."""
    if not os.environ.get("OPENROUTER_API_KEY"):
        die("OPENROUTER_API_KEY is not set - the gate fails closed rather than skipping")
    gate_family = family_of(model)
    if gate_family == author:
        die(
            f"gate model family {gate_family!r} matches the author family {author!r}. "
            "Cross-family decorrelation IS the mechanism; a same-family verdict is not a gate."
        )
    return gate_family


def call_model(model: str, spec_text: str) -> str:
    body = json.dumps(
        {
            "model": model,
            "messages": [{"role": "user", "content": PROMPT % spec_text}],
            "temperature": 0,
        }
    ).encode()
    req = urllib.request.Request(
        API_URL,
        data=body,
        headers={
            "Authorization": f"Bearer {os.environ['OPENROUTER_API_KEY']}",
            "Content-Type": "application/json",
        },
    )
    try:
        with urllib.request.urlopen(req, timeout=TIMEOUT_S) as resp:
            payload = json.loads(resp.read())
    except urllib.error.HTTPError as e:
        die(f"provider returned HTTP {e.code}: {e.read()[:300].decode(errors='replace')}")
    except Exception as e:  # unreachable model, DNS, timeout, malformed JSON
        die(f"provider call failed ({type(e).__name__}: {e})")
    try:
        return payload["choices"][0]["message"]["content"]
    except (KeyError, IndexError):
        die(f"unexpected response shape: {json.dumps(payload)[:300]}")


def parse_findings(raw: str) -> list[dict]:
    text = raw.strip()
    if text.startswith("```"):  # strip a fence the model added anyway
        text = text.split("\n", 1)[1].rsplit("```", 1)[0]
    try:
        data = json.loads(text)
    except json.JSONDecodeError:
        die(f"model did not return parseable JSON: {text[:300]}")
    findings = data.get("findings")
    if not isinstance(findings, list):
        die("response JSON has no 'findings' list")
    return findings


def main() -> None:
    args = [a for a in sys.argv[1:]]
    model = os.environ.get("GATE_MODEL", DEFAULT_MODEL)
    author = os.environ.get("AUTHOR_FAMILY", "anthropic")

    if "--author" in args:
        i = args.index("--author")
        author = args[i + 1]
        del args[i : i + 2]

    if "--check" in args:
        fam = check_config(model, author)
        print(f"gate ok: model={model} family={fam} author={author}")
        return

    if not args:
        die("usage: gate.py <spec.md> [--author <family>] | --check")

    spec_path = Path(args[0])
    if not spec_path.is_file():
        die(f"no such spec: {spec_path}")

    bypass = os.environ.get("GATE_BYPASS")
    if bypass:
        # Never silent: visible on stderr and stamped into the verdict.
        print(f"gate: BREAK-GLASS BYPASS - {bypass}", file=sys.stderr)
        print(json.dumps({"verdict": "bypassed", "reason": bypass, "spec": str(spec_path)}))
        return

    check_config(model, author)
    findings = parse_findings(call_model(model, spec_path.read_text()))

    blocking = [f for f in findings if f.get("kind") in BLOCKING]
    notes = [f for f in findings if f.get("kind") not in BLOCKING]

    # No model decides this. The verdict is derived from the closed set.
    verdict = "blocked" if blocking else "approved"
    print(
        json.dumps(
            {
                "verdict": verdict,
                "spec": str(spec_path),
                "model": model,
                "blocking": blocking,
                "notes": notes,
            },
            indent=2,
        )
    )
    sys.exit(1 if blocking else 0)


if __name__ == "__main__":
    main()
