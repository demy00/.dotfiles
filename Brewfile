# Brewfile — `brew bundle` installs everything listed here.
# Regenerate a snapshot of your current machine with: brew bundle dump --force

# --- terminal base ---
brew "tmux"
brew "neovim"
brew "mosh"                 # resilient SSH for phone -> tmux
cask "wezterm"
cask "font-jetbrains-mono-nerd-font"

# --- core CLI ---
brew "git"
brew "gh"                   # no-mistakes needs this authed for PRs + CI
brew "node"                 # >= 20, required by gnhf and the npx tools
brew "ripgrep"              # snacks.nvim grep backend
brew "fd"
brew "jq"

# --- remote access ---
cask "tailscale"

# Not in Homebrew — install separately, see docs/setup-guide.md:
#   claude-code    npm i -g @anthropic-ai/claude-code
#   gnhf           npm i -g gnhf
#   no-mistakes    curl -fsSL https://raw.githubusercontent.com/kunchenguid/no-mistakes/main/docs/install.sh | sh
#   treehouse      curl -fsSL https://kunchenguid.github.io/treehouse/install.sh | sh
#   lavish         no install, run via npx lavish-axi
