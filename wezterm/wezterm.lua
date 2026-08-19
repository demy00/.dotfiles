-- ~/.wezterm.lua
-- Deliberately minimal: no tabs, no title bar, no status line.
-- tmux owns sessions, windows, panes and status. WezTerm is just a fast, correct
-- surface to draw them on. Every feature below that isn't "render text well" is off.

local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- ---------- the frameless single window ----------
config.window_decorations = "RESIZE" -- no title bar, still resizable/draggable
config.enable_tab_bar = false        -- tmux handles tabs
config.use_fancy_tab_bar = false
config.window_padding = { left = 8, right = 8, top = 6, bottom = 0 }
config.adjust_window_size_when_changing_font_size = false
config.window_close_confirmation = "NeverPrompt" -- tmux sessions survive anyway

-- ---------- font ----------
-- Install one first, e.g.:  brew install --cask font-jetbrains-mono-nerd-font
-- A Nerd Font matters: oil.nvim, neogit and snacks.nvim all use glyph icons.
config.font = wezterm.font_with_fallback({
  { family = "JetBrainsMono Nerd Font", weight = "Regular" },
  { family = "Symbols Nerd Font Mono" },
  { family = "Apple Color Emoji" },
})
config.font_size = 14.0
config.line_height = 1.1
config.freetype_load_target = "Light"

-- ---------- colours ----------
config.color_scheme = "Tokyo Night"
config.force_reverse_video_cursor = true

-- ---------- performance ----------
config.max_fps = 120
config.animation_fps = 60
config.front_end = "WebGpu"
config.scrollback_lines = 0 -- tmux keeps scrollback; two buffers is confusing

-- ---------- behaviour ----------
config.audible_bell = "Disabled"
config.check_for_updates = false
config.term = "wezterm" -- pairs with terminal-overrides in tmux.conf for truecolor

-- ---------- keys ----------
-- Almost nothing bound, so Ctrl-a and friends reach tmux untouched.
config.keys = {
  -- keep the muscle-memory basics
  { key = "v", mods = "CMD", action = wezterm.action.PasteFrom("Clipboard") },
  { key = "c", mods = "CMD", action = wezterm.action.CopyTo("Clipboard") },
  { key = "+", mods = "CMD", action = wezterm.action.IncreaseFontSize },
  { key = "-", mods = "CMD", action = wezterm.action.DecreaseFontSize },
  { key = "0", mods = "CMD", action = wezterm.action.ResetFontSize },
  { key = "Enter", mods = "CMD", action = wezterm.action.ToggleFullScreen },
  -- explicitly kill WezTerm's own tab/pane keys so they never shadow tmux
  { key = "t", mods = "CMD", action = wezterm.action.DisableDefaultAssignment },
  { key = "w", mods = "CMD", action = wezterm.action.DisableDefaultAssignment },
  { key = "d", mods = "CMD", action = wezterm.action.DisableDefaultAssignment },
}

-- ---------- start straight into tmux ----------
-- Left off deliberately: WezTerm lands in a plain shell, and the `t` alias
-- starts or attaches tmux when you want it. Uncomment to have every window
-- attach to the 'main' session automatically.
-- config.default_prog = { "/bin/zsh", "-l", "-c", "tmux new-session -A -s main" }

return config
