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

local palettes             = {
    night = {
        bg      = 0xff242220,
        surface = 0xff2c2925,
        muted   = 0xff3a3731,
        border  = 0xff8a9a7b,
        text    = 0xffdedac4,
        text_bg = 0xcc242220,
        chess_a = 0xff2c2925,
        chess_b = 0xff3a3731,
    },
    day = {
        bg      = 0xffd1cdb7,
        surface = 0xffdad4bb,
        muted   = 0xffb4af9a,
        border  = 0xff57544a,
        text    = 0xff3f3d36,
        text_bg = 0xccdad4bb,
        chess_a = 0xffdad4bb,
        chess_b = 0xffc6c0a6,
    },
}

local theme                = palettes[mode]

-- Load sibling images in the same folder when opening a single file (e.g. from Yazi)
swayimg.imagelist.adjacent = true

-- HUD text overlay styling
swayimg.text.font          = "JetBrainsMono Nerd Font Mono"
swayimg.text.size          = 15
swayimg.text.padding       = 12
swayimg.text.timeout       = 8
swayimg.text.color         = theme.text
swayimg.text.background    = theme.text_bg
swayimg.text.shadow        = 0x00000000

-- Viewer appearance & native EXIF/file metadata overlay (missing tags are hidden automatically)
swayimg.viewer.set_window_background(theme.bg)
swayimg.viewer.set_image_chessboard(20, theme.chess_a, theme.chess_b)
swayimg.viewer.text              = {
    topleft = {
        "File:\t{name}",
        "Format:\t{format}",
        "Size:\t{sizehr}",
        "Modified:\t{time}",
        "Date:\t{meta.Exif.Photo.DateTimeOriginal}",
        "Camera:\t{meta.Exif.Image.Make} {meta.Exif.Image.Model}",
        "Lens:\t{meta.Exif.Photo.LensModel}",
        "Focal:\t{meta.Exif.Photo.FocalLength}",
        "Aperture:\tf/{meta.Exif.Photo.FNumber}",
        "Shutter:\t{meta.Exif.Photo.ExposureTime} s",
        "ISO:\t{meta.Exif.Photo.ISOSpeedRatings}",
        "Software:\t{meta.Exif.Image.Software}",
    },
    topright = {
        "Image:\t{list.index} / {list.total}",
        "Frame:\t{frame.index} / {frame.total}",
        "Resolution:\t{frame.width}x{frame.height}",
    },
    bottomleft = {
        "Scale:\t{scale}",
    },
}

swayimg.gallery.window_color     = theme.bg
swayimg.gallery.unselected_color = theme.surface
swayimg.gallery.selected_color   = theme.muted
swayimg.gallery.border_color     = theme.border

swayimg.viewer.on_key("q", function()
    swayimg.exit()
end)

swayimg.viewer.on_key("i", function()
    swayimg.text.visible = not swayimg.text.visible
end)

swayimg.viewer.on_key("n", function()
    swayimg.viewer.open("next")
end)

swayimg.viewer.on_key("p", function()
    swayimg.viewer.open("prev")
end)

swayimg.viewer.on_key("0", function()
    swayimg.viewer.reset()
end)

swayimg.gallery.on_key("q", function()
    swayimg.exit()
end)

swayimg.gallery.on_key("i", function()
    swayimg.text.visible = not swayimg.text.visible
end)
