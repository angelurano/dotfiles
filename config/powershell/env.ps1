# FZF Config
$env:FZF_DEFAULT_COMMAND = "fd --hidden --strip-cwd-prefix --exclude .git"
$env:FZF_ALT_C_COMMAND = 'fd --type=d --hidden --strip-cwd-prefix --exclude .git'

$env:FZF_DEFAULT_OPTS = "--height 40% --layout=reverse --border"
$env:FZF_CTRL_T_OPTS = "--height 40% --border --layout=reverse --preview 'bat --color=always -n --line-range :250 {}'"
$env:FZF_ALT_C_OPTS = "--height 40% --border --layout=reverse --preview ''"

# Yazi
$env:YAZI_FILE_ONE = "$HOME\scoop\apps\git\current\usr\bin\file.exe"
$env:YAZI_CONFIG_HOME = "$env:XDG_CONFIG_HOME\yazi"

# Default shell for multiplexers (e.g., herdr)
$env:SHELL = "pwsh"

# Node & NPM (XDG Compliance)
$env:NPM_CONFIG_USERCONFIG = "$env:XDG_CONFIG_HOME\npm\npmrc"
$env:NPM_CONFIG_CACHE      = "$env:XDG_CACHE_HOME\npm"
$env:NPM_CONFIG_PREFIX     = "$env:XDG_DATA_HOME\npm"
$env:NODE_REPL_HISTORY     = "$env:XDG_STATE_HOME\node\node_repl_history"

# Ensure XDG directories exist
$nodeDirs = @(
    "$env:XDG_CONFIG_HOME\npm",
    "$env:XDG_CACHE_HOME\npm",
    "$env:XDG_DATA_HOME\npm",
    "$env:XDG_STATE_HOME\node"
)
foreach ($dir in $nodeDirs) {
    if (-not (Test-Path -Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

# Create default npmrc if it doesn't exist
if (-not (Test-Path -Path $env:NPM_CONFIG_USERCONFIG)) {
    Set-Content -Path $env:NPM_CONFIG_USERCONFIG -Value "ignore-scripts=true" -Encoding UTF8
}

# Add NPM global binaries to PATH
$npmGlobalPath = "$env:XDG_DATA_HOME\npm"
if (-not $env:PATH.Split(';').Contains($npmGlobalPath)) {
    $env:PATH = "$npmGlobalPath;$env:PATH"
}

