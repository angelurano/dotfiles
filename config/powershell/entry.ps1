# 1. Establish XDG Environment Paths (for other tools like neovim, wezterm, ohmyposh)
$env:XDG_CONFIG_HOME = "$HOME\.config"
$env:XDG_DATA_HOME   = "$HOME\.local\share"
$env:XDG_CACHE_HOME  = "$HOME\.cache"
$env:XDG_STATE_HOME  = "$HOME\.local\state"

# 2. Load Modular Scripts (dot-sourcing files relative to this script's directory)
if (Test-Path -Path "$PSScriptRoot\env.ps1") {
    . "$PSScriptRoot\env.ps1"
}
if (Test-Path -Path "$PSScriptRoot\aliases.ps1") {
    . "$PSScriptRoot\aliases.ps1"
}
if (Test-Path -Path "$PSScriptRoot\options.ps1") {
    . "$PSScriptRoot\options.ps1"
}

# 3. Initialize Shell Integrations / Modules
# Oh My Posh Prompt
$ompConfFile = "$env:XDG_CONFIG_HOME\ohmyposh\conf.toml"
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    oh-my-posh init pwsh --config $ompConfFile | Invoke-Expression
}

# Terminal Icons (Fast direct import, avoiding slow -ListAvailable)
Import-Module Terminal-Icons -ErrorAction SilentlyContinue

# PSFzf (Fast direct import, avoiding slow -ListAvailable)
Import-Module PSFzf -ErrorAction SilentlyContinue

# Zoxide (Smart cd command)
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell --cmd z | Out-String) })
}

# Chocolatey Tab Completion (if choco is installed)
if ($env:ChocolateyInstall) {
    $ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
    if (Test-Path $ChocolateyProfile) {
        Import-Module $ChocolateyProfile -ErrorAction SilentlyContinue
    }
}

# 4. Run Winfetch Once (only first startup per boot)
if (Test-Path -Path "$PSScriptRoot\scripts\winfetch-once.ps1") {
    . "$PSScriptRoot\scripts\winfetch-once.ps1"
}
