# 1. Establish XDG Environment Paths (for other tools like neovim, wezterm, ohmyposh)
$env:XDG_CONFIG_HOME = "$HOME\.config"
$env:XDG_DATA_HOME   = "$HOME\.local\share"
$env:XDG_CACHE_HOME  = "$HOME\.cache"
$env:XDG_STATE_HOME  = "$HOME\.local\state"

# 2. Load Modular Scripts (dot-sourcing files relative to this script's directory)
if ([System.IO.File]::Exists("$PSScriptRoot\env.ps1")) {
    . "$PSScriptRoot\env.ps1"
}
if ([System.IO.File]::Exists("$PSScriptRoot\aliases.ps1")) {
    . "$PSScriptRoot\aliases.ps1"
}
if ([System.IO.File]::Exists("$PSScriptRoot\options.ps1")) {
    . "$PSScriptRoot\options.ps1"
}

# Helper: cache generated init scripts and regenerate when tool binary or dependencies change
function Get-CachedInitScript {
    param(
        [string]$Name,
        [string]$CommandName,
        [string[]]$Dependencies = @(),
        [scriptblock]$Generator
    )
    $cmd = Get-Command $CommandName -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $cmd) { return $null }

    $cacheDir  = "$env:XDG_CACHE_HOME\powershell"
    $cacheFile = "$cacheDir\$Name.ps1"
    $rebuild   = -not [System.IO.File]::Exists($cacheFile)

    if (-not $rebuild) {
        $cacheTime = [System.IO.File]::GetLastWriteTimeUtc($cacheFile)
        if ([System.IO.File]::GetLastWriteTimeUtc($cmd.Source) -gt $cacheTime) {
            $rebuild = $true
        }
        else {
            foreach ($dep in $Dependencies) {
                if ([System.IO.File]::Exists($dep) -and ([System.IO.File]::GetLastWriteTimeUtc($dep) -gt $cacheTime)) {
                    $rebuild = $true
                    break
                }
            }
        }
    }

    if ($rebuild) {
        if (-not (Test-Path -LiteralPath $cacheDir)) {
            New-Item -ItemType Directory -Path $cacheDir -Force | Out-Null
        }
        $script = & $Generator | Out-String
        if ($script) {
            [System.IO.File]::WriteAllText($cacheFile, $script, [System.Text.UTF8Encoding]::new($false))
        }
    }

    if ([System.IO.File]::Exists($cacheFile)) { return $cacheFile }
    return $null
}

# 3. Initialize Shell Integrations / Modules
# Oh My Posh Prompt (cached)
$ompConfFile = "$env:XDG_CONFIG_HOME\ohmyposh\conf.toml"
$ompCache = Get-CachedInitScript -Name 'oh-my-posh' -CommandName 'oh-my-posh' -Dependencies @($ompConfFile) -Generator {
    oh-my-posh init pwsh --config $ompConfFile --print
}
if ($ompCache) { . $ompCache }

# Terminal Icons (PowerShell 7+ only; keeps PS 5.1 clean)
if ($PSVersionTable.PSVersion.Major -ge 7) {
    Import-Module Terminal-Icons -ErrorAction SilentlyContinue
}

# PSFzf (lazy-loaded on first Ctrl+T / Ctrl+R / Alt+C / Alt+A press)
if ($Host.Name -eq 'ConsoleHost' -and (Get-Command Set-PSReadLineKeyHandler -ErrorAction SilentlyContinue)) {
    function global:_Invoke-LazyPsFzf([string]$HandlerName) {
        @('Ctrl+t', 'Ctrl+r', 'Alt+c', 'Alt+a') | ForEach-Object {
            Remove-PSReadLineKeyHandler -Chord $_ -ErrorAction SilentlyContinue
        }
        Import-Module PSFzf -ErrorAction SilentlyContinue
        $mod = Get-Module PSFzf
        if ($mod) {
            & $mod $HandlerName
        }
    }
    Set-PSReadLineKeyHandler -Chord 'Ctrl+t' -BriefDescription 'Fzf Provider Select (Lazy)' -ScriptBlock { _Invoke-LazyPsFzf 'Invoke-FzfPsReadlineHandlerProvider' }
    Set-PSReadLineKeyHandler -Chord 'Ctrl+r' -BriefDescription 'Fzf Reverse History (Lazy)' -ScriptBlock { _Invoke-LazyPsFzf 'Invoke-FzfPsReadlineHandlerHistory' }
    Set-PSReadLineKeyHandler -Chord 'Alt+c'  -BriefDescription 'Fzf Set Location (Lazy)' -ScriptBlock { _Invoke-LazyPsFzf 'Invoke-FzfPsReadlineHandlerSetLocation' }
    Set-PSReadLineKeyHandler -Chord 'Alt+a'  -BriefDescription 'Fzf Reverse History Args (Lazy)' -ScriptBlock { _Invoke-LazyPsFzf 'Invoke-FzfPsReadlineHandlerHistoryArgs' }
}

# Zoxide (Smart cd command, cached)
$zoxideCache = Get-CachedInitScript -Name 'zoxide' -CommandName 'zoxide' -Generator {
    zoxide init powershell --cmd z
}
if ($zoxideCache) { . $zoxideCache }

# FNM (Fast Node Manager)
if (Get-Command fnm -ErrorAction SilentlyContinue) {
    fnm env --use-on-cd | Out-String | Invoke-Expression
}

# Chocolatey Tab Completion (if choco is installed)
if ($env:ChocolateyInstall) {
    $ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
    if ([System.IO.File]::Exists($ChocolateyProfile)) {
        Import-Module $ChocolateyProfile -ErrorAction SilentlyContinue
    }
}

# 4. Run Winfetch Once (only first startup per boot)
if ([System.IO.File]::Exists("$PSScriptRoot\scripts\winfetch-once.ps1")) {
    . "$PSScriptRoot\scripts\winfetch-once.ps1"
}
