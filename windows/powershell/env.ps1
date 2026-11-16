# FZF Config
$env:FZF_DEFAULT_COMMAND = "fd --hidden --strip-cwd-prefix --exclude .git"
$env:FZF_ALT_C_COMMAND = 'fd --type=d --hidden --strip-cwd-prefix --exclude .git'

$env:FZF_DEFAULT_OPTS = "--height 40% --layout=reverse --border"
$env:FZF_CTRL_T_OPTS = "--height 40% --border --layout=reverse --preview 'bat --color=always -n --line-range :250 {}'"
$env:FZF_ALT_C_OPTS = "--height 40% --border --layout=reverse --preview ''"

# Yazi
$env:YAZI_FILE_ONE = "$HOME\scoop\apps\git\current\usr\bin\file.exe"
$env:YAZI_CONFIG_HOME = "$env:XDG_CONFIG_HOME\yazi"

# Default shell and CLI editor (used by herdr, Antigravity CLI Ctrl+G, git, yazi, etc.)
$env:SHELL  = "pwsh"
$env:EDITOR = "nvim"
$env:VISUAL = "nvim"

# Node & NPM (XDG Compliance)
$env:NPM_CONFIG_USERCONFIG = "$env:XDG_CONFIG_HOME\npm\npmrc"
$env:NPM_CONFIG_CACHE      = "$env:XDG_CACHE_HOME\npm"
$env:NPM_CONFIG_PREFIX     = "$env:XDG_DATA_HOME\npm"
$env:NODE_REPL_HISTORY     = "$env:XDG_STATE_HOME\node\node_repl_history"

# Ensure XDG directories and default npmrc exist (checked via single sentinel file)
if (-not [System.IO.File]::Exists($env:NPM_CONFIG_USERCONFIG)) {
    $nodeDirs = @(
        "$env:XDG_CONFIG_HOME\npm",
        "$env:XDG_CACHE_HOME\npm",
        "$env:XDG_DATA_HOME\npm",
        "$env:XDG_STATE_HOME\node"
    )
    foreach ($dir in $nodeDirs) {
        if (-not (Test-Path -LiteralPath $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
    }
    [System.IO.File]::WriteAllText($env:NPM_CONFIG_USERCONFIG, "ignore-scripts=true", [System.Text.UTF8Encoding]::new($false))
}

# Add NPM global binaries to PATH
$npmGlobalPath = "$env:XDG_DATA_HOME\npm"
if (-not $env:PATH.Split(';').Contains($npmGlobalPath)) {
    $env:PATH = "$npmGlobalPath;$env:PATH"
}

