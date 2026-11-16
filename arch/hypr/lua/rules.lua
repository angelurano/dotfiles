-- Workspace, Window & Layer Rules (Cockpit Framing + Edge-to-Edge Maximize)

-- 1. Maximized windows (SUPER + F) reclaim 100% of viewport with zero gaps/border/shadow
hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0 })

hl.window_rule({
    name        = "no-gaps-maximized",
    match       = { float = false, workspace = "f[1]" },
    border_size = 0,
    rounding    = 0,
    no_shadow   = true,
})

-- 2. Floating TUIs (wiremix, bluetui, impala, btop, floating yazi)
hl.window_rule({
    name   = "floating-tui",
    match  = { class = "^floating_tui$" },
    float  = true,
    center = true,
    size   = { "monitor_w * 0.76", "monitor_h * 0.78" },
})

-- 3. Common File / Auth Dialogs
hl.window_rule({
    name   = "dialogs-float",
    match  = { title = "^(Open File|Save File|Select a File|Choose wallpaper|Open Folder).*$" },
    float  = true,
    center = true,
    size   = { "monitor_w * 0.72", "monitor_h * 0.74" },
})

-- 4. Suppress unwanted app-initiated maximize requests
hl.window_rule({
    name           = "suppress-maximize-events",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

-- 5. Fix XWayland drag artifacts
hl.window_rule({
    name     = "fix-xwayland-drags",
    match    = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

-- 6. Media playback & image viewing: keep full brightness when unfocused; inhibit idle on fullscreen video
hl.window_rule({
    name         = "vlc-playback",
    match        = { class = "^([Vv]lc|org\\.videolan\\.VLC)$" },
    no_dim       = true,
    idle_inhibit = "fullscreen",
})

hl.window_rule({
    name   = "swayimg-no-dim",
    match  = { class = "^swayimg(_.*)?$" },
    no_dim = true,
})

-- 7. Crisp zero-animation layers for Rofi, Waybar, Mako, and Slurp selection
hl.layer_rule({
    name    = "instant-layers",
    match   = { namespace = "^(rofi|selection|waybar|notifications)$" },
    no_anim = true,
})
