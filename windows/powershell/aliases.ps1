# Eza (modern ls alternative)
Function l { eza --icons --group-directories-first --git @args }
Function la { l -Ah @args }
Function ll { l -lAg @args }
Function lA { l -lbA @args }
Function tree { eza --tree --icons --git --group-directories-first @args }
Remove-Item Alias:\ls -Force -ErrorAction SilentlyContinue
Set-Alias -Name ls -Value l

# Bat (modern cat alternative)
Function cat { bat --paging=never @args }

# Neovim
function nvim {
    & "$HOME\scoop\apps\neovim\current\bin\nvim.exe" @args
}
Set-Alias -Name vim -Value nvim
Set-Alias -Name vi -Value nvim
Set-Alias -Name v -Value nvim

# Herdr
function h { herdr @args }

# Yazi
function y {
	$tmp = (New-TemporaryFile).FullName
	& "$HOME\scoop\shims\yazi.exe" @args --cwd-file="$tmp"
	$cwd = Get-Content -Path $tmp -Encoding UTF8
	if ($cwd -and $cwd -ne $PWD.Path -and (Test-Path -LiteralPath $cwd -PathType Container)) {
		Set-Location -LiteralPath (Resolve-Path -LiteralPath $cwd).Path
	}
	Remove-Item -Path $tmp
}

# Environment viewer helper
Function env { Get-ChildItem Env: }

# VS Code Integration (asynchronous helper)
$global:CodeCli = (Get-Command code.cmd -CommandType Application).Source
function code {
	param(
		[Parameter(ValueFromRemainingArguments = $true)]
		[string[]] $Args
	)
	if ($PSVersionTable.PSVersion -ge [Version]'7.4') {
		Start-Process -FilePath $global:CodeCli -ArgumentList $Args
		return
	}

	if ($Args.Count -eq 0) {
		Start-Process -FilePath $global:CodeCli
	}
	else {
		Start-Process -FilePath $global:CodeCli -ArgumentList $Args
	}
}

# Dotfiles Symlink Synchronizer
Function Sync-Dotfiles {
    # Resolve the repository path locally (safe from OneDrive sync conflicts)
    $RepoDir = "$HOME\dotfiles"
    $ConfigDir = $env:XDG_CONFIG_HOME

    if (-not (Test-Path -Path $ConfigDir)) { 
        New-Item -ItemType Directory -Path $ConfigDir | Out-Null 
    }

    # Shared folders to symlink from dotfiles/common to ~/.config
    $commonFolders = @("nvim", "ohmyposh", "yazi")

    foreach ($folder in $commonFolders) {
        $destination = "$ConfigDir\$folder"
        $source = "$RepoDir\common\$folder"

        if (Test-Path -Path $destination) { 
            Remove-Item -Recurse -Force $destination 
        }

        Write-Host "Enlazando (common): $destination -> $source" -ForegroundColor Cyan
        New-Item -ItemType Junction -Path $destination -Target $source | Out-Null
    }

    # Windows-exclusive folders to symlink from dotfiles/windows to ~/.config
    $windowsFolders = @("powershell", "wezterm", "winfetch")

    foreach ($folder in $windowsFolders) {
        $destination = "$ConfigDir\$folder"
        $source = "$RepoDir\windows\$folder"

        if (Test-Path -Path $destination) { 
            Remove-Item -Recurse -Force $destination 
        }

        Write-Host "Enlazando (windows): $destination -> $source" -ForegroundColor Cyan
        New-Item -ItemType Junction -Path $destination -Target $source | Out-Null
    }


    # Also link yazi config in AppData for global Windows support outside PowerShell
    $AppDataYaziConfig = "$env:APPDATA\yazi\config"
    $AppDataYaziParent = "$env:APPDATA\yazi"
    if (-not (Test-Path -Path $AppDataYaziParent)) {
        New-Item -ItemType Directory -Path $AppDataYaziParent | Out-Null
    }
    if (Test-Path -Path $AppDataYaziConfig) {
        Remove-Item -Recurse -Force $AppDataYaziConfig
    }
    Write-Host "Enlazando AppData Yazi: $AppDataYaziConfig -> $ConfigDir\yazi" -ForegroundColor Cyan
    New-Item -ItemType Junction -Path $AppDataYaziConfig -Target "$ConfigDir\yazi" | Out-Null


    # Copy the profile loader script from dotfiles/config/powershell/Microsoft.PowerShell_profile.ps1 to the OneDrive $PROFILE path
    if ($PROFILE) {
        $profileDir = Split-Path -Parent $PROFILE
        if (-not (Test-Path -Path $profileDir)) { 
            New-Item -ItemType Directory -Path $profileDir | Out-Null 
        }

        $repoProfilePath = "$RepoDir\windows\powershell\Microsoft.PowerShell_profile.ps1"
        if (Test-Path -Path $repoProfilePath) {
            Copy-Item -Path $repoProfilePath -Destination $PROFILE -Force
            Write-Host "Perfil copiado de: $repoProfilePath a: $PROFILE" -ForegroundColor Green
        }
        else {
            Write-Warning "No se encontró el archivo de perfil del repositorio: $repoProfilePath"
        }
    }

    Write-Host "¡Sincronización local XDG completada!" -ForegroundColor Green
}

