-- ~/.config/nvim/init.lua
--
-- Purpose-built for the agentic workflow, not for writing code by hand.
-- The three jobs this editor has:
--   1. navigate the filesystem fast              -> oil.nvim
--   2. review what an agent just did             -> neogit + gitsigns + diffview
--   3. find/grep across a codebase you didn't write -> snacks.nvim picker
-- Everything else is deliberately absent. No LSP, no completion, no formatters —
-- the agent handles that. Add them later if you find yourself missing them.

-- leader must be set before lazy.nvim loads
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- ---------- options ----------
local o = vim.opt
o.number = true
o.relativenumber = true       -- makes 12j / d5k worth using
o.signcolumn = "yes"          -- stops the gutter jumping when gitsigns loads
o.termguicolors = true
o.cursorline = true
o.scrolloff = 8
o.wrap = false
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.smartindent = true
o.ignorecase = true
o.smartcase = true
o.undofile = true             -- persistent undo across sessions
o.swapfile = false
o.updatetime = 200
o.splitright = true
o.splitbelow = true
o.clipboard = "unnamedplus"   -- yank goes to the macOS clipboard
o.mouse = "a"
o.laststatus = 3              -- one global statusline; tmux shows the rest

-- ---------- core keymaps ----------
local map = vim.keymap.set
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "clear search highlight" })
map("n", "<C-h>", "<C-w>h"); map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k"); map("n", "<C-l>", "<C-w>l")
map("n", "<leader>w", "<cmd>w<CR>", { desc = "write" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "quit" })

-- ---------- lazy.nvim bootstrap ----------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
o.rtp:prepend(lazypath)

require("lazy").setup({

  -- ============ colourscheme ============
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({ style = "night", transparent = true })
      vim.cmd.colorscheme("tokyonight")
    end,
  },

  -- ============ 1. filesystem as a buffer ============
  -- Open a directory and it's just text. Edit the text to rename, delete, create.
  -- `-` opens the parent dir of the current file, which is the motion you'll use
  -- constantly when poking around a codebase an agent has been reshaping.
  {
    "stevearc/oil.nvim",
    lazy = false,
    opts = {
      default_file_explorer = true,
      view_options = { show_hidden = true },
      keymaps = {
        ["q"] = "actions.close",
        ["<C-h>"] = false, -- don't shadow window-left
      },
    },
    keys = {
      { "-", "<cmd>Oil<CR>", desc = "open parent directory" },
      { "<leader>-", "<cmd>Oil .<CR>", desc = "open project root" },
    },
  },

  -- ============ 2. review the agent's work ============
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim", -- the actual diff viewer neogit hands off to
      "folke/snacks.nvim",
    },
    opts = {
      graph_style = "unicode",
      integrations = { diffview = true, snacks = true },
    },
    keys = {
      { "<leader>gg", "<cmd>Neogit<CR>", desc = "neogit status" },
      { "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "diff working tree" },
      { "<leader>gm", "<cmd>DiffviewOpen main...HEAD<CR>", desc = "diff branch vs main" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", desc = "file history" },
      { "<leader>gx", "<cmd>DiffviewClose<CR>", desc = "close diffview" },
    },
  },

  -- inline hunk signs — the fast "what changed in this file" read
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = { current_line_blame = false },
    keys = {
      { "]h", function() require("gitsigns").nav_hunk("next") end, desc = "next hunk" },
      { "[h", function() require("gitsigns").nav_hunk("prev") end, desc = "prev hunk" },
      { "<leader>gp", function() require("gitsigns").preview_hunk() end, desc = "preview hunk" },
      { "<leader>gb", function() require("gitsigns").blame_line() end, desc = "blame line" },
    },
  },

  -- ============ 3. find and grep ============
  {
    "folke/snacks.nvim",
    priority = 900,
    lazy = false,
    opts = {
      picker = { enabled = true },
      bigfile = { enabled = true },   -- don't choke on a generated 20k-line file
      quickfile = { enabled = true },
      indent = { enabled = true },
      notifier = { enabled = true },
      input = { enabled = true },
    },
    keys = {
      { "<leader><space>", function() Snacks.picker.smart() end, desc = "smart find file" },
      { "<leader>ff", function() Snacks.picker.files() end, desc = "find files" },
      { "<leader>fg", function() Snacks.picker.grep() end, desc = "grep project" },
      { "<leader>fw", function() Snacks.picker.grep_word() end, desc = "grep word under cursor", mode = { "n", "x" } },
      { "<leader>fb", function() Snacks.picker.buffers() end, desc = "buffers" },
      { "<leader>fr", function() Snacks.picker.recent() end, desc = "recent files" },
      { "<leader>fh", function() Snacks.picker.help() end, desc = "help tags" },
      -- git-aware pickers: what did this branch touch?
      { "<leader>fs", function() Snacks.picker.git_status() end, desc = "changed files" },
      { "<leader>fl", function() Snacks.picker.git_log() end, desc = "git log" },
    },
  },

  -- ============ syntax ============
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    main = "nvim-treesitter.configs",
    opts = {
      ensure_installed = {
        "lua", "vim", "vimdoc", "bash", "json", "yaml", "toml",
        "markdown", "markdown_inline", "diff", "gitcommit",
        "python", "javascript", "typescript", "tsx", "go", "rust",
      },
      highlight = { enable = true },
      indent = { enable = true },
    },
  },

  -- ============ discoverability ============
  -- Press <leader> and wait: it shows you what's bound. Useful precisely because
  -- you'll be in this editor less often than in the agent pane, so the bindings
  -- won't stay in your fingers.
  { "folke/which-key.nvim", event = "VeryLazy", opts = {} },

}, {
  install = { colorscheme = { "tokyonight" } },
  checker = { enabled = false },
})
