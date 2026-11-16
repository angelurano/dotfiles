-- =============================================================================
-- YoRHa Design System Semantic Tokens (Day & Night) & UWSM Session Helpers
-- =============================================================================

local home      = os.getenv("HOME") or ""
local state_dir = os.getenv("XDG_STATE_HOME") or (home .. "/.local/state")
local mode      = "night"

local f         = io.open(state_dir .. "/theme/mode", "r")
if f then
    local raw = f:read("*l")
    f:close()
    if raw and raw:match("day") then
        mode = "day"
    end
end

local palettes = {
    -- Light / Day Mode (Parchment & Olive Charcoal + High-Visibility Active Focus)
    day = {
        hex = {
            bg           = "#d1cdb7",
            bg_surface   = "#dad4bb",
            bg_muted     = "#b4af9a",
            primary      = "#57544a",
            primary_dark = "#4e4b42",
            olive        = "#8A9A7B",
            alert        = "#cd664d",
            text         = "#3f3d36",
        },
        rgba = {
            active_start    = "rgba(3f3d36ff)",
            active_end      = "rgba(8a9a7bff)",
            inactive        = "rgba(b4af9a70)",
            alert           = "rgba(cd664dff)",
            shadow_hard     = "rgba(4e4b4278)",
            shadow_inactive = "rgba(4e4b4224)",
        },
        bg_hex_int = "0xd1cdb7",
    },

    -- Dark / Night Mode (Bunker Charcoal & Bone Parchment)
    night = {
        hex = {
            bg           = "#242220",
            bg_surface   = "#2c2925",
            bg_muted     = "#4e4b42",
            primary      = "#c8c2a9",
            primary_dark = "#dedac4",
            olive        = "#8A9A7B",
            alert        = "#cd664d",
            text         = "#d1cdb7",
        },
        rgba = {
            active_start    = "rgba(dedac4ff)",
            active_end      = "rgba(c8c2a9ff)",
            inactive        = "rgba(4e4b42cc)",
            alert           = "rgba(cd664dff)",
            shadow_hard     = "rgba(060504eb)",
            shadow_inactive = "rgba(06050455)",
        },
        bg_hex_int = "0x242220",
    },
}

local active = palettes[mode]

local M = {
    mode       = mode,
    hex        = active.hex,
    rgba       = active.rgba,
    bg_hex_int = active.bg_hex_int,
}

--- Wraps a command in `uwsm app --` when running inside a UWSM-managed session,
--- falling back gracefully to direct execution in standalone sessions.
---@param cmd string
---@param slice? string Optional uwsm slice ('a' app, 'b' background, 's' session)
---@return string
function M.uwsm_cmd(cmd, slice)
    local slice_flag = slice and (" -s " .. slice) or ""
    return string.format(
        "if command -v uwsm >/dev/null 2>&1 && uwsm check is-active hyprland.desktop >/dev/null 2>&1; then exec uwsm app%s -- %s; else exec %s; fi",
        slice_flag,
        cmd,
        cmd
    )
end

_G.YoRHa = M
return M
