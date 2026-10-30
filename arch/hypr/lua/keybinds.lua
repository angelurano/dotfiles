-- Keybindings

local T           = _G.YoRHa
local mainMod     = "SUPER"

-- Commands wrapped for UWSM compatibility
local termPlain   = T.uwsm_cmd("kitty --single-instance")
local termHerdr   = T.uwsm_cmd('kitty --single-instance -e herdr')
local fileManager = T.uwsm_cmd("kitty --class floating_tui -e yazi")
local browserCmd  = T.uwsm_cmd(os.getenv("BROWSER") or "brave-origin")
local appLauncher =
'if command -v uwsm >/dev/null 2>&1 && uwsm check is-active hyprland.desktop >/dev/null 2>&1; then exec rofi -show drun -run-command "uwsm app -- {cmd}"; else exec rofi -show drun; fi'
local winSwitcher = "rofi -show window"
local clipPicker  =
'sh -c \'cliphist list | rofi -dmenu -p "Clipboard" -theme-str "mode-switcher { enabled: false; }" | cliphist decode | wl-copy\''
local sysMenu     = "~/.config/hypr/scripts/yorha-sysmenu.sh"
local themeToggle = "~/.config/hypr/scripts/theme.sh toggle"
local shotArea    =
'sh -c \'grim -g "$(slurp -b 24222055 -c 57544aff -w 2)" - | wl-copy && notify-send -a "System" "Capture Complete" "Selection copied to clipboard."\''
local shotFull    =
'sh -c \'mkdir -p "$HOME/downloads/screenshots"; f="$HOME/downloads/screenshots/yorha-$(date +%Y%m%d-%H%M%S).png"; grim "$f" && wl-copy < "$f" && notify-send -a "System" "Capture Saved" "Screen saved to downloads/screenshots."\''
local exitSession =
"if command -v uwsm >/dev/null 2>&1 && uwsm check is-active hyprland.desktop >/dev/null 2>&1; then uwsm stop; else hyprctl dispatch 'hl.dsp.exit()'; fi"

-- --- Core Applications & System Controls ---
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(termPlain), { description = "Terminal Kitty (zsh)" })
hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.exec_cmd(termHerdr), { description = "Terminal Kitty + Herdr" })
hl.bind(mainMod .. " + Q", hl.dsp.window.close(), { description = "Close active window" })
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd(appLauncher), { description = "Applications Menu (Rofi)" })
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(appLauncher), { description = "Applications Menu (Rofi)" })
hl.bind(mainMod .. " + Tab", hl.dsp.exec_cmd(winSwitcher), { description = "Windows Switcher (Rofi)" })
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd(sysMenu), { description = "System Menu (Rofi)" })
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd(themeToggle), { description = "Toggle Day / Night Mode" })
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager), { description = "File Manager (Yazi)" })
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browserCmd), { description = "Web Browser" })
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd(clipPicker), { description = "Clipboard History" })
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd(exitSession), { description = "Exit Session" })

-- --- Screenshots (grim + slurp + wl-copy) ---
hl.bind("Print", hl.dsp.exec_cmd(shotArea), { description = "Area screenshot to clipboard" })
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd(shotFull), { description = "Full screenshot to disk & clipboard" })

-- --- Window States & Layout ---
hl.bind(mainMod .. " + T", hl.dsp.window.float({ action = "toggle" }), { description = "Toggle floating window" })
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo(), { description = "Toggle pseudotiling" })
hl.bind(mainMod .. " + U", hl.dsp.layout("togglesplit"), { description = "Toggle split orientation" })
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized" }), { description = "Maximize keeping Waybar" })
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }), { description = "True fullscreen" })

-- --- Directional Focus (SUPER + hjkl & Arrows) ---
local dirs = {
    h     = "left",
    l     = "right",
    k     = "up",
    j     = "down",
    left  = "left",
    right = "right",
    up    = "up",
    down  = "down",
}

for key, dir in pairs(dirs) do
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ direction = dir }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ direction = dir }))
end

-- --- Direct Window Resize (SUPER + ALT + hjkl / Arrows) ---
hl.bind(mainMod .. " + ALT + l", hl.dsp.window.resize({ x = 36, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + ALT + h", hl.dsp.window.resize({ x = -36, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + ALT + k", hl.dsp.window.resize({ x = 0, y = -36, relative = true }), { repeating = true })
hl.bind(mainMod .. " + ALT + j", hl.dsp.window.resize({ x = 0, y = 36, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.resize({ x = 36, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + left", hl.dsp.window.resize({ x = -36, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + up", hl.dsp.window.resize({ x = 0, y = -36, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + down", hl.dsp.window.resize({ x = 0, y = 36, relative = true }), { repeating = true })

-- --- Modal Resize Submap (SUPER + R -> displayed in Waybar) ---
hl.bind(mainMod .. " + R", hl.dsp.submap("RESIZE"), { description = "Modal resize mode" })

hl.define_submap("RESIZE", function()
    hl.bind("l", hl.dsp.window.resize({ x = 28, y = 0, relative = true }), { repeating = true })
    hl.bind("h", hl.dsp.window.resize({ x = -28, y = 0, relative = true }), { repeating = true })
    hl.bind("k", hl.dsp.window.resize({ x = 0, y = -28, relative = true }), { repeating = true })
    hl.bind("j", hl.dsp.window.resize({ x = 0, y = 28, relative = true }), { repeating = true })
    hl.bind("right", hl.dsp.window.resize({ x = 28, y = 0, relative = true }), { repeating = true })
    hl.bind("left", hl.dsp.window.resize({ x = -28, y = 0, relative = true }), { repeating = true })
    hl.bind("up", hl.dsp.window.resize({ x = 0, y = -28, relative = true }), { repeating = true })
    hl.bind("down", hl.dsp.window.resize({ x = 0, y = 28, relative = true }), { repeating = true })

    hl.bind("escape", hl.dsp.submap("reset"))
    hl.bind("Return", hl.dsp.submap("reset"))
    hl.bind(mainMod .. " + R", hl.dsp.submap("reset"))
end)

-- --- Workspaces (SUPER + [0-9], SHIFT moves window) ---
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- --- Scratchpad Special Workspace ---
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("bunker"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:bunker" }))

-- --- Mouse & Scroll Workspace Bindings ---
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- --- Hardware Multimedia & Backlight Keys ---
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
    { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -n2 set +5%"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -n2 set 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
