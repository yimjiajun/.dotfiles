local wezterm = require 'wezterm'
local mux = wezterm.mux
local config = {}

wezterm.on("gui-startup", function()
	local tab, pane, window = mux.spawn_window{}
	window:gui_window():toggle_fullscreen()
	window:set_title 'Terminal'
end)

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages

if wezterm.config_builder then
  config = wezterm.config_builder()
end

local function is_windows()
    return package.config:sub(1, 1) == "\\"
end

local function is_unix()
    return package.config:sub(1, 1) == "/"
end-- Pull in the wezterm API

config.color_scheme = 'GruvboxDarkHard'
config.font =
  wezterm.font('JetBrains Mono', { weight = 'Regular'})

config.keys = {
	{ key = 'f',
		mods = 'ALT|CTRL',
		action = wezterm.action.ToggleFullScreen,
	},
}

config.window_background_gradient = {
  orientation = 'Vertical',

  colors = {
    '#0d0e0f',
    '#171a1a',
    '#1d2021',
	'#202020',
	'#242424',
	'#282828',
	'#32302f',
	'#3c3a39',
  },

  interpolation = 'Linear',
  blend = 'Rgb',
}

config.window_background_opacity = 0.9
config.window_background_image = nil
config.window_background_image_hsb = nil
if is_windows() then
	config.font = wezterm.font_with_fallback({
		'JetBrains Mono',
		'Cascadia Code',
		'Consolas',
	})

	config.default_prog = {'wsl'}

	table.insert(config.keys, {
		key = '1',
			mods = 'CTRL|ALT',
			action = wezterm.action.SpawnCommandInNewTab {
				args = { 'wsl.exe --cd ~' },
			},
	})
	table.insert(config.keys, {
		key = '2',
		mods = 'CTRL|ALT',
		action = wezterm.action.SpawnCommandInNewTab {
			args = { 'powershell.exe' },
			},
	})
	table.insert(config.keys, {
		key = '3',
		mods = 'CTRL|ALT',
		action = wezterm.action.SpawnCommandInNewTab {
			args = { 'cmd.exe' },
			},
	})

elseif is_unix() then
	config.default_prog = { 'bash' }
end

config.initial_cols = 80
config.initial_rows = 30
config.font_size = 9.0
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}


config.enable_tab_bar = false
config.enable_scroll_bar = false
config.scrollback_lines = 1000

return config
