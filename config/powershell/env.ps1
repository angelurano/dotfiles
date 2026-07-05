# FZF Config
$env:FZF_DEFAULT_COMMAND = "fd --hidden --strip-cwd-prefix --exclude .git"
$env:FZF_ALT_C_COMMAND = 'fd --type=d --hidden --strip-cwd-prefix --exclude .git'

$env:FZF_DEFAULT_OPTS = "--height 40% --layout=reverse --border"
$env:FZF_CTRL_T_OPTS = "--height 40% --border --layout=reverse --preview 'bat --color=always -n --line-range :250 {}'"
$env:FZF_ALT_C_OPTS = "--height 40% --border --layout=reverse --preview ''"

# Yazi
$env:YAZI_FILE_ONE = "$HOME\scoop\apps\git\current\usr\bin\file.exe"
$env:YAZI_CONFIG_HOME = "$env:XDG_CONFIG_HOME\yazi"

