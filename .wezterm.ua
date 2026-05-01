-- ~/.wezterm.lua  (place at C:\Users\ysthe\.wezterm.lua)
-- Sessions: dev-box, au5y-serv (also known as Miller / 192.168.50.115), media

local wezterm = require 'wezterm'
local act = wezterm.action

-- ─────────────────────────────────────────────
--  THEME MAP  (hostname/label → color scheme)
-- ─────────────────────────────────────────────
-- WezTerm exact scheme names (case-sensitive):
--   "Catppuccin Mocha"
--   "Solarized Osaka Night (Gogh)"   ← closest built-in match; see note below
--   "Ryuuko (terminal.sexy)"

local HOST_THEMES = {
  -- dev-box
  ["dev-box"]  = "Catppuccin Mocha",
  -- au5y-serv
  ["au5y-serv"]       = "Gruvbox dark, hard (base16)",
  -- media server
  ["media"]           = "Bamboo Multiplex",
}

-- ─────────────────────────────────────────────
--  BACKGROUND IMAGE MAP  (optional – uncomment when ready)
--  Drop your images into C:\Users\ysthe\Pictures\wezterm-bg\
-- ─────────────────────────────────────────────
-- local HOST_BACKGROUNDS = {
--   ["100.112.223.82"] = "C:\\Users\\ysthe\\Pictures\\wezterm-bg\\dev-box.png",
--   ["au5y-serv"]      = "C:\\Users\\ysthe\\Pictures\\wezterm-bg\\au5y-serv.png",
--   ["media"]          = "C:\\Users\\ysthe\\Pictures\\wezterm-bg\\media.png",
--   ["192.168.50.115"] = "C:\\Users\\ysthe\\Pictures\\wezterm-bg\\miller.png",
-- }

-- ─────────────────────────────────────────────
--  HELPER: extract hostname from tab title/pane
-- ─────────────────────────────────────────────
-- WezTerm sets the pane title to something like "austin@hostname: ~"
-- after SSH connects. We pull the hostname out of that string.
local function get_host_from_title(title)
  -- Match "user@hostname" pattern
  local host = title:match("@([%w%-%._]+)")
  if host then return host end
  -- Fallback: match bare hostname at start
  return title:match("^([%w%-%._]+)")
end

-- ─────────────────────────────────────────────
--  CUSTOM SCHEMES
--  Solarized Osaka Night inline definition
--  (used if not already in your WezTerm build)
-- ─────────────────────────────────────────────
local custom_color_schemes = {
  ["Solarized Osaka Night (Gogh)"] = {
    foreground    = "#cdd6f4",
    background    = "#1e2030",
    cursor_bg     = "#f5e0dc",
    cursor_border = "#f5e0dc",
    cursor_fg     = "#1e2030",
    selection_bg  = "#585b70",
    selection_fg  = "#cdd6f4",
    ansi = {
      "#45475a", "#f38ba8", "#a6e3a1", "#f9e2af",
      "#89b4fa", "#f5c2e7", "#94e2d5", "#bac2de",
    },
    brights = {
      "#585b70", "#f38ba8", "#a6e3a1", "#f9e2af",
      "#89b4fa", "#f5c2e7", "#94e2d5", "#a6adc8",
    },
  },
}

-- ─────────────────────────────────────────────
--  DYNAMIC THEME SWITCHING on tab title change
-- ─────────────────────────────────────────────
wezterm.on("update-right-status", function(window, pane)
  local title = pane:get_title()
  local host  = get_host_from_title(title)
  local scheme = HOST_THEMES[host]

  if scheme then
    local overrides = window:get_config_overrides() or {}
    if overrides.color_scheme ~= scheme then
      overrides.color_scheme = scheme
      -- ── Uncomment when you have background images ready ──
      -- local bg = HOST_BACKGROUNDS and HOST_BACKGROUNDS[host]
      -- if bg then
      --   overrides.background = {
      --     { source = { File = bg }, opacity = 0.15 },
      --   }
      -- else
      --   overrides.background = nil
      -- end
      window:set_config_overrides(overrides)
    end
  else
    -- No match – clear any previous override so default theme shows
    local overrides = window:get_config_overrides() or {}
    if overrides.color_scheme then
      overrides.color_scheme = nil
      overrides.background = nil
      window:set_config_overrides(overrides)
    end
  end
end)

-- ─────────────────────────────────────────────
--  MAIN CONFIG
-- ─────────────────────────────────────────────
local config = wezterm.config_builder()

-- Default theme (used for local shell / unknown hosts)
config.color_scheme = "Catppuccin Mocha"
config.color_schemes = custom_color_schemes

-- Font  (matches your PuTTY setup: JetBrains Mono NF Light, size 10)
config.font = wezterm.font("JetBrainsMono NFM", { weight = "Light" })
config.font_size = 12.0

-- Window size (PuTTY had 80×24 = TermWidth 0x50, TermHeight 0x18)
config.initial_cols = 100
config.initial_rows = 30

-- Scrollback (PuTTY had 0x7d0 = 2000 lines)
config.scrollback_lines = 2000

-- Cursor  (PuTTY had BlinkCur=1, CurType=0 = block)
config.default_cursor_style = "BlinkingBlock"

-- Bell off  (PuTTY had Beep=0)
config.audible_bell = "Disabled"

-- Window chrome
config.window_decorations = "RESIZE"
config.window_padding = { left = 4, right = 4, top = 4, bottom = 4 }

-- Tab bar
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = true

-- Reload last session
config.default_prog = {"ssh", "au5y-serv"}

config.launch_menu = {
  {
    label = "dev-box",
    args  = { "ssh", "dev-box" },
  },
  {
    label = "au5y-serv",
    args  = { "ssh", "au5y-serv" },
  },
  {
    label = "media",
    args  = { "ssh", "media" },
  },
}

-- ─────────────────────────────────────────────
--  KEY BINDINGS
-- ─────────────────────────────────────────────
config.keys = {
  -- Open launch menu: Alt+L
  { key = "l", mods = "ALT", action = act.ShowLauncherArgs { flags = "LAUNCH_MENU_ITEMS" } },
  -- New tab: Ctrl+Shift+T
  { key = "t", mods = "CTRL|SHIFT", action = act.SpawnTab "CurrentPaneDomain" },
  -- Split horizontal: Ctrl+Shift+D
  { key = "d", mods = "CTRL|SHIFT", action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },
  -- Split vertical: Ctrl+Shift+E
  { key = "e", mods = "CTRL|SHIFT", action = act.SplitVertical { domain = "CurrentPaneDomain" } },
  -- Close tab: Ctrl+Shift+W
  { key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentTab { confirm = true } },
  -- Paste: Ctrl+Shift+V  (matches your PuTTY CtrlShiftCV=none, CtrlShiftIns=explicit)
  { key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom "Clipboard" },
  -- Copy: Ctrl+Shift+C
  { key = "c", mods = "CTRL|SHIFT", action = act.CopyTo "Clipboard" },
}
config.mouse_bindings = {
  {
    event  = { Down = { streak = 1, button = "Right" } },
    mods   = "NONE",
    action = act.PasteFrom "Clipboard",
  },
  -- Middle-click pastes from selection buffer (Linux-style, optional)
  {
    event  = { Down = { streak = 1, button = "Middle" } },
    mods   = "NONE",
    action = act.PasteFrom "PrimarySelection",
  },
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = wezterm.action.CompleteSelection 'Clipboard',
  },
}

-- Select-to-copy (highlight any text and it's instantly in clipboard)
config.selection_word_boundary = " \t\n{}[]()\"'`,;:@│"


return config
