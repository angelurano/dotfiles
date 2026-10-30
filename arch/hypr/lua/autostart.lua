-- Session Autostart (UWSM + Standalone Compatible)

local T = _G.YoRHa

hl.on("hyprland.start", function()
    -- If running standalone (outside UWSM), ensure D-Bus env and core daemons are up
    hl.exec_cmd(
        "if ! (command -v uwsm >/dev/null 2>&1 && uwsm check is-active hyprland.desktop >/dev/null 2>&1); then "
        .. "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE; "
        .. "systemctl --user start hyprpolkitagent.service mako.service hypridle.service 2>/dev/null || true; "
        .. "pgrep -x waybar >/dev/null || (waybar >/dev/null 2>&1 &); "
        .. "pgrep -x mako >/dev/null || (mako >/dev/null 2>&1 &); "
        .. "pgrep -x hypridle >/dev/null || (hypridle >/dev/null 2>&1 &); "
        .. "fi"
    )

    -- Wallpaper daemon (hyprpaper)
    hl.exec_cmd(
        T.uwsm_cmd("hyprpaper", "b")
    )

    -- Initialize theme state, token symlinks, system theme, and wallpaper
    hl.exec_cmd(
        T.uwsm_cmd("~/.config/hypr/scripts/theme.sh init", "b")
    )

    -- Clipboard history watchers (cliphist)
    hl.exec_cmd(
        T.uwsm_cmd(
            "sh -c 'command -v cliphist >/dev/null 2>&1 && exec wl-paste --type text --watch cliphist store'",
            "b"
        )
    )
    hl.exec_cmd(
        T.uwsm_cmd(
            "sh -c 'command -v cliphist >/dev/null 2>&1 && exec wl-paste --type image --watch cliphist store'",
            "b"
        )
    )
end)
