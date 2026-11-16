local INTERNAL = "eDP-1"
local SCRIPT   = "~/.config/hypr/scripts/yorha-display.sh"

local function internal_rule()
    return {
        output   = INTERNAL,
        mode     = "1366x768@59.99500",
        position = "0x0",
        scale    = 1,
        disabled = false,
    }
end

-- Primary internal panel + generic fallback for any other output
hl.monitor(internal_rule())

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

--- Picks a safe mode/scale for an external monitor.
--- HD-Ready TVs advertise VESA 1360x768/1366x768 as preferred but often blank out
--- or look blurry over HDMI; prefer standard CEA 1080p60 / 720p60 for them.
---@param m HL.Monitor
---@return string mode
---@return string|number scale
local function pick_smart_mode(m)
    local modes = m.available_modes
    if type(modes) ~= "table" then
        return "preferred", "auto"
    end

    local pref_w, pref_h, pref_rr = nil, nil, 0
    local has_1080p60, has_720p60 = false, false

    for _, mode in ipairs(modes) do
        local near60 = mode.refresh_rate >= 59.5 and mode.refresh_rate <= 60.5
        if mode.preferred then
            pref_w, pref_h, pref_rr = mode.width, mode.height, mode.refresh_rate
        end
        if mode.width == 1920 and mode.height == 1080 and near60 then
            has_1080p60 = true
        elseif mode.width == 1280 and mode.height == 720 and near60 then
            has_720p60 = true
        end
    end

    if m.name:match("^HDMI") and (pref_w == 1360 or pref_w == 1366) and pref_h == 768 then
        if has_1080p60 then
            return "1920x1080@60", 1
        elseif has_720p60 then
            return "1280x720@60", 1
        end
    end

    if pref_w and pref_h then
        local best_rr = pref_rr
        for _, mode in ipairs(modes) do
            if mode.width == pref_w and mode.height == pref_h and mode.refresh_rate > best_rr then
                best_rr = mode.refresh_rate
            end
        end
        local scale = (pref_w >= 3840) and 1.5 or 1
        return string.format("%dx%d@%.2f", pref_w, pref_h, best_rr), scale
    end

    return "preferred", "auto"
end

---@param m HL.Monitor
local function apply_smart_mode(m)
    local mode, scale = pick_smart_mode(m)
    hl.monitor({
        output   = m.name,
        mode     = mode,
        position = "auto",
        scale    = scale,
    })
end

-- Exposed so the display menu can trigger the same auto heuristics via `hyprctl eval`
_G.YoRHaDisplays = {
    auto = function(name)
        local m = hl.get_monitor(name)
        if m then
            apply_smart_mode(m)
        end
    end,
}

hl.on("monitor.added", function(m)
    if m.name == INTERNAL then
        return
    end
    apply_smart_mode(m)
    hl.exec_cmd(SCRIPT .. " hotplug-add " .. m.name)
end)

hl.on("monitor.removed", function(m)
    if m.name == INTERNAL then
        return
    end
    -- Always bring the internal panel back (clamshell / external-only safety net)
    hl.monitor(internal_rule())
    hl.exec_cmd(SCRIPT .. " hotplug-remove " .. m.name)
end)

-- A config reload resets runtime monitor rules; re-apply heuristics and saved profiles
hl.on("config.reloaded", function()
    for _, m in ipairs(hl.get_monitors()) do
        if m.name ~= INTERNAL then
            apply_smart_mode(m)
        end
    end
    hl.exec_cmd(SCRIPT .. " init")
end)
