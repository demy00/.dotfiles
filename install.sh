#!/usr/bin/env bash
# install.sh - link every config in this repo into place.
#
# Safe to run repeatedly. Existing real files are backed up once to
# ~/.dotfiles-backup/<timestamp>/ before being replaced. Existing symlinks that
# already point here are left alone.
#
#   ./install.sh          link everything
#   ./install.sh --check  report what's linked, change nothing
#   ./install.sh --brew   also run `brew bundle` against the Brewfile

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
CHECK_ONLY=false
RUN_BREW=false

for arg in "$@"; do
  case "$arg" in
    --check) CHECK_ONLY=true ;;
    --brew)  RUN_BREW=true ;;
    *) echo "unknown flag: $arg" >&2; exit 1 ;;
  esac
done

# ---------- the link table ----------
# "<path in repo>:<path in home>"
# Add a line here whenever you add a config. This table IS the documentation of
# what this repo controls.
LINKS=(
  "wezterm/wezterm.lua:$HOME/.wezterm.lua"
  "tmux/tmux.conf:$HOME/.tmux.conf"
  "nvim:$HOME/.config/nvim"
  "claude/CLAUDE.md:$HOME/.claude/CLAUDE.md"
  "claude/skills:$HOME/.claude/skills"
  "git/gitconfig:$HOME/.gitconfig"
  "zsh/zshrc:$HOME/.zshrc"
)

green() { printf '\033[32m%s\033[0m\n' "$1"; }
yellow() { printf '\033[33m%s\033[0m\n' "$1"; }
red()   { printf '\033[31m%s\033[0m\n' "$1"; }

link_one() {
  local src="$DOTFILES/$1" dest="$2"

  if [[ ! -e "$src" ]]; then
    yellow "skip     $dest  (no $1 in repo)"
    return
  fi

  # already pointing at us?
  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    green "ok       $dest"
    return
  fi

  if $CHECK_ONLY; then
    if [[ ! -e "$dest" && ! -L "$dest" ]]; then
      yellow "MISSING  $dest  (will be created)"
    elif [[ -L "$dest" ]]; then
      red "RELINK   $dest  (symlink -> $(readlink "$dest"))"
    elif diff -rq "$src" "$dest" >/dev/null 2>&1; then
      # byte-identical: linking loses nothing, no backup needed
      green "SAME     $dest  (identical to repo, safe to link)"
    else
      # the case that needs a human: real content that would be displaced
      red "DIFFERS  $dest  (will be backed up - review before linking)"
    fi
    return
  fi

  # back up anything real that's in the way (but not a stale symlink -
  # backing up a broken link is just noise)
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    mkdir -p "$BACKUP/$(dirname "${dest#$HOME/}")"
    mv "$dest" "$BACKUP/${dest#$HOME/}"
    yellow "backed up $dest -> $BACKUP/${dest#$HOME/}"
  fi

  mkdir -p "$(dirname "$dest")"

  # -s symbolic, -f replace, -n THE IMPORTANT ONE:
  # without -n, if $dest is an existing symlink to a directory, `ln -sf` follows
  # it and creates the new link INSIDE that directory instead of replacing it.
  # That's the classic dotfiles bug that leaves you with ~/.config/nvim/nvim.
  ln -sfn "$src" "$dest"
  green "linked   $dest -> $src"
}

echo "dotfiles: $DOTFILES"
echo

for entry in "${LINKS[@]}"; do
  link_one "${entry%%:*}" "${entry#*:}"
done

if $RUN_BREW; then
  echo
  if command -v brew >/dev/null 2>&1; then
    echo "running brew bundle..."
    brew bundle --file="$DOTFILES/Brewfile"
  else
    red "brew not found - install Homebrew first"
  fi
fi

echo
if $CHECK_ONLY; then
  echo "check complete (nothing modified)"
else
  echo "done. new shell: exec zsh"
  echo "tmux config:     tmux source-file ~/.tmux.conf"
fi
