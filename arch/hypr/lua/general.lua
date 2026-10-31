-- =============================================================================
-- Monitors, Input, Cockpit Geometry (0px Radius + 5px Hard Offset Shadow)
-- =============================================================================

local T = _G.YoRHa

-- Primary internal panel + external monitor fallback
hl.monitor({
    output   = "eDP-1",
    mode     = "1366x768@59.99500",
    position = "0x0",
    scale    = 1,
})

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

-- Fallback environment variables when Hyprland is started outside UWSM
if not os.getenv("UWSM_FINALIZE_VARNAMES") then
    hl.env("XCURSOR_SIZE", "22")
    hl.env("HYPRCURSOR_SIZE", "22")
    hl.env("QT_QPA_PLATFORM", "wayland;xcb")
    hl.env("GDK_BACKEND", "wayland,x11,*")
    hl.env("SDL_VIDEODRIVER", "wayland")
end

hl.config({
    general = {
        gaps_in          = 7,
        gaps_out         = 14,
        border_size      = 3,
        col              = {
            active_border   = { colors = { T.rgba.active_start, T.rgba.active_end }, angle = 45 },
            inactive_border = T.rgba.inactive,
        },
        resize_on_border = true,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    -- Strict 0px YoRHa geometry + crisp 7px non-blurred hard offset shadow (bottom & right)
    decoration = {
        rounding         = 0,
        rounding_power   = 2,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,
        dim_inactive     = true,
        dim_strength     = 0.08,
        shadow           = {
            enabled        = true,
            sharp          = true,
            range          = 2,
            offset         = { 7, 7 },
            color          = T.rgba.shadow_hard,
            color_inactive = T.rgba.shadow_inactive,
        },
        blur             = {
            enabled = false,
        },
    },

    debug = {
        vfr = true,
    },

    dwindle = {
        preserve_split = true,
        smart_resizing = true,
    },

    master = {
        new_status = "master",
    },

    scrolling = {
        fullscreen_on_one_column = true,
    },

    misc = {
        force_default_wallpaper      = 0,
        disable_hyprland_logo        = true,
        disable_splash_rendering     = true,
        background_color             = T.bg_hex_int,
        animate_manual_resizes       = false,
        animate_mouse_windowdragging = false,
        key_press_enables_dpms       = true,
        mouse_move_enables_dpms      = true,
    },

    input = {
        kb_layout    = "es",
        follow_mouse = 1,
        sensitivity  = 0,
        touchpad     = {
            natural_scroll       = true,
            tap_to_click         = true,
            disable_while_typing = true,
        },
    },

    binds = {
        workspace_back_and_forth = true,
        allow_workspace_cycles   = true,
    },
})

-- 3-finger horizontal swipe between workspaces
hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})
