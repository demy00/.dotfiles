---
name: typescript
description: TypeScript discipline for this codebase - strictness, type-level boundaries, and the narrow set of escape hatches that are allowed. Use when writing or reviewing any .ts/.tsx file.
---

# TypeScript

Language-level rules only. Test runners, frameworks and build tools live in their own skills
(`vitest`, `expo`, `playwright-e2e`) - this one is true regardless of which of those a repo uses.

## The one rule that matters

**A type is a claim about runtime behaviour. If the claim is false, the type is worse than none**,
because everything downstream now trusts it. That single idea explains every rule below.

## Strictness

Assume `strict: true`. If a repo doesn't have it, say so rather than working around it.

- **Never `any`.** Use `unknown` and narrow. `any` disables checking for everything it touches, not
  just the expression it's on.
- **Avoid `as`.** A cast asserts the compiler is wrong. Occasionally it is - but prefer a type guard
  (`function isFoo(x: unknown): x is Foo`) so the claim is *checked* rather than asserted.
- **`as const`** is the exception and is encouraged - it narrows rather than widens, so it makes
  claims stronger, not weaker.
- **Never `@ts-ignore`.** If it is genuinely unavoidable use `@ts-expect-error` with a one-line
  reason: it fails the build once the underlying problem is fixed, so it cannot rot silently.
- **No non-null `!`** except immediately after a check the compiler cannot see, with a comment
  saying what that check was.

## Where types come from

Prefer, in this order:

1. **Inferred** - let TypeScript work it out. Annotate parameters and public return types; leave
   locals alone. Over-annotation is noise that drifts from reality.
2. **Derived** - `ReturnType<>`, `Parameters<>`, `keyof`, indexed access. A derived type cannot fall
   out of step with its source.
3. **Generated** - from an OpenAPI schema or database schema. Never hand-write a type that a
   generator owns, and never edit generated files.
4. **Hand-written** - only for genuinely local shapes.

## Validation at the boundary

Types vanish at runtime. Anything crossing a trust boundary - HTTP response, `localStorage`,
`process.env`, URL params, file contents - is `unknown` until proven otherwise.

Parse it with a schema validator (Zod, where available) and derive the static type from the schema
with `z.infer`, so there is exactly one definition. Do not declare an interface *and* a schema for
the same shape; they will diverge.

Inside the boundary, trust the types. Re-validating internally is noise.

## Modelling

- **Make illegal states unrepresentable.** A discriminated union beats a bag of optional fields:
  `{ status: 'loading' } | { status: 'error', error: Error } | { status: 'ok', data: T }` cannot
  express "loading with an error" - the four-optional-booleans version can, and something eventually
  will.
- **`unknown` over `any`** at every entry point.
- **`readonly`** on arrays and props that are not meant to be mutated. It costs nothing and documents
  intent the compiler then enforces.
- **Avoid enums.** Prefer a union of string literals, or `as const` objects - enums have runtime
  emit and awkward nominal behaviour.
- **Narrow function signatures.** Take exactly what is used (`{ id }: { id: string }`) rather than a
  whole entity, so callers are not forced to construct one and the dependency is honest.

## Errors

- Do not type a `catch` binding as `Error` - it is `unknown` and can be anything a library throws.
  Narrow it.
- Prefer returning a result union over throwing for expected failures; reserve throwing for
  genuinely exceptional cases.

## Review checklist

Fastest signals that something is wrong, in the order worth checking:

1. Any `any`, `as`, `!` or `@ts-ignore` added in this diff - each needs a reason
2. A hand-written type duplicating a generated or inferred one
3. External data used without parsing
4. Optional fields that encode a state machine
5. A type that is wider than the values it will ever hold
