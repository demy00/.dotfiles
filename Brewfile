# Brewfile - `brew bundle` installs everything listed here.
# Regenerate a snapshot of your current machine with: brew bundle dump --force
#
# Rule for this file: it lists what the setup actually uses today. Anything
# sitting behind a trigger in docs/plan.md stays in the deferred block at the
# bottom, commented out. A Brewfile that installs deferred tools turns
# `brew bundle` into a way of adopting things without deciding to.

# --- terminal base ---
brew "tmux"
brew "neovim"
cask "wezterm"
cask "font-jetbrains-mono-nerd-font"

# --- core CLI ---
brew "git"
brew "gh"                   # no-mistakes needs this authed for PRs + CI
brew "node"                 # >= 20, required by gnhf and the npx tools
brew "ripgrep"              # snacks.nvim grep backend
brew "fd"
brew "jq"

# Not in Homebrew - install separately, see docs/setup-guide.md:
#   claude-code    npm i -g @anthropic-ai/claude-code
#   lavish-axi     no install, run via `npx lavish-axi` (D16, critical path)

# ---------------------------------------------------------------------------
# Deferred - do not uncomment until the trigger in docs/plan.md has fired.
# ---------------------------------------------------------------------------
#
# cask "tailscale"          # trigger: you want to check on agents from your
# brew "mosh"               #   phone. Both halves of one deferred item.
#                           #   NOTE: mosh is already installed on this machine
#                           #   from before the plan existed. Left commented so
#                           #   the file states intent, not accident.
#
#   gnhf         npm i -g gnhf
#                           # trigger: a finished plan too large to babysit, on
#                           # a solo repo. Bill it with a hard --max-tokens
#                           # first - non-interactive usage may not draw on
#                           # subscription capacity (D9, still unverified).
#
#   no-mistakes  curl -fsSL https://raw.githubusercontent.com/kunchenguid/no-mistakes/main/docs/install.sh | sh
#                           # Phase 4b, after Phase 1 exists to review against.
#                           # Installer line 80 starts a background daemon.
#
#   treehouse    curl -fsSL https://kunchenguid.github.io/treehouse/install.sh | sh
#                           # Phase 7, not before Phases 1, 4 and 5.
