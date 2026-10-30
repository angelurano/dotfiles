hl.config({
    animations = {
        enabled = true,
    },
})

hl.curve("yHEase", { type = "bezier", points = { { 0.15, 0.79 }, { 0.0, 1.0 } } })
hl.curve("yHLinear", { type = "bezier", points = { { 0.0, 0.0 }, { 1.0, 1.0 } } })

hl.animation({ leaf = "global", enabled = true, speed = 2.8, bezier = "yHEase" })
hl.animation({ leaf = "border", enabled = true, speed = 2.0, bezier = "yHLinear" })
hl.animation({ leaf = "windows", enabled = true, speed = 2.6, bezier = "yHEase", style = "slide" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 2.6, bezier = "yHEase", style = "popin 94%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.8, bezier = "yHLinear", style = "popin 96%" })
hl.animation({ leaf = "fade", enabled = true, speed = 2.0, bezier = "yHLinear" })
hl.animation({ leaf = "layers", enabled = false })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2.4, bezier = "yHEase", style = "slide" })
