local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::: appearance

config.font = wezterm.font("Inconsolata Nerd Font Mono")
config.font_size = 16

config.color_scheme = "Apple System Colors"
-- config.color_scheme = 'Flatland'
-- config.color_scheme = 'Colors (base16)'
-- config.color_scheme = 'Desert (Gogh)'
-- config.color_scheme = 'Monokai Remastered'
-- config.color_scheme = 'Lab Fox'
-- config.color_scheme = 'Orangish (terminal.sexy)'

config.front_end = "OpenGL"
config.term = "xterm-256color"

config.max_fps = 45

config.initial_cols = 120
config.initial_rows = 28

config.window_decorations = "RESIZE"
config.window_padding = {
	top = 10,
	right = 0,
	bottom = 0,
	left = 0,
}

config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.colors = {
	tab_bar = {
		background = "#0f0c29",

		active_tab = {
			bg_color = "#331717",
			fg_color = "#e5c7aa",
			intensity = "Normal",
			underline = "None",
			italic = false,
			strikethrough = false,
		},

		inactive_tab = {
			bg_color = "#1e1a2a",
			fg_color = "#777777",
			intensity = "Normal",
			italic = false,
		},

		inactive_tab_hover = {
			bg_color = "#3b2f3b",
			fg_color = "#aaaaaa",
			italic = false,
			intensity = "Normal",
		},

		new_tab = {
			bg_color = "#1e1a2a",
			fg_color = "#777777",
		},

		new_tab_hover = {
			bg_color = "#3b2f3b",
			fg_color = "#aaaaaa",
			italic = false,
		},
	},
}

config.window_background_opacity = 1
config.window_background_gradient = {
	orientation = "Vertical",
	colors = {
		"#0f0c29",
		-- '#452B63',
		"#331717",
	},
	interpolation = "Basis",
	blend = "Rgb",
}

-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::: format tab title

local SOLID_LEFT_ARROW = wezterm.nerdfonts.pl_right_hard_divider
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.pl_left_hard_divider

local function tab_title(tab_info)
	return (tab_info.tab_title ~= "" and tab_info.tab_title) or tab_info.active_pane.title
end

-- params: tab, tabs, panes, config, hover, max_width
wezterm.on("format-tab-title", function(tab, _, _, _, hover, max_width)
	local edge_background = "#0f0c29"
	local background = "#1e1a2a"
	local foreground = "#777777"

	if tab.is_active then
		background = "#331717"
		foreground = "#e5c7aa"
	elseif hover then
		background = "#3b2f3b"
		foreground = "#aaaaaa"
	end

	local edge_foreground = background

	local title = " " .. tab_title(tab) .. " "

	title = wezterm.truncate_right(title, max_width - 2)

	return {
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
		{ Text = SOLID_LEFT_ARROW },
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = title },
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
		{ Text = SOLID_RIGHT_ARROW },
	}
end)

-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::: launch menu

config.ssh_domains = wezterm.default_ssh_domains()

config.launch_menu = {
	{
		label = "PowerShell",
		args = { "pwsh.exe", "-NoLogo" },
		domain = { DomainName = "local" },
	},
	{
		label = "zsh (WSL:Debian)",
		cwd = "~",
		domain = { DomainName = "WSL:Debian" },
	},
	{
		label = "zsh (WSL:Ubuntu)",
		-- args = { "zsh", "-l" },
		cwd = "~",
		domain = { DomainName = "WSL:Ubuntu" },
	},
	{
		label = "yazi (SSH:wsl.ubuntu)",
		domain = { DomainName = "SSH:wsl.ubuntu" },
		args = { "zsh", "-c", "yazi" },
	},
	{
		label = "Git bash",
		args = { "C:\\Users\\angel\\scoop\\shims\\bash.exe", "-i", "-l" },
		domain = { DomainName = "local" },
	},
}
config.default_prog = { "pwsh.exe" }
config.default_domain = "local"

-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::: key bindings

config.treat_left_ctrlalt_as_altgr = false

config.keys = {
	{
		key = "w",
		mods = "CTRL",
		action = wezterm.action.CloseCurrentPane({ confirm = true }),
	},
	{
		key = "w",
		mods = "CTRL|SHIFT",
		action = wezterm.action.CloseCurrentPane({ confirm = false }),
	},
}

for i = 1, 8 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = "CTRL",
		action = wezterm.action.ActivateTab(i - 1),
	})
end
table.insert(config.keys, {
	key = "9",
	mods = "CTRL",
	action = wezterm.action.ActivateTab(-1),
})

for i, entry in ipairs(config.launch_menu) do
	if i <= 9 then
		table.insert(config.keys, {
			key = tostring(i),
			mods = "CTRL|ALT",
			action = wezterm.action.SpawnCommandInNewTab(entry),
		})
	else
		break
	end
end

return config
