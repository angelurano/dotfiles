# Eza (modern ls alternative)
Function l { eza --icons --group-directories-first --git @args }
Function la { l -Ah @args }
Function ll { l -lAg @args }
Set-Alias -Name ls -Value l

# Neovim
function nvim {
    & "$HOME\scoop\apps\neovim\current\bin\nvim.exe" @args
}
Set-Alias -Name vim -Value nvim

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
		& $global:CodeCli $Args &
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

    # Folders to symlink from dotfiles/config to ~/.config
    $folders = @("nvim", "wezterm", "ohmyposh", "powershell")

    foreach ($folder in $folders) {
        $destination = "$ConfigDir\$folder"
        $source = "$RepoDir\config\$folder"

        if (Test-Path -Path $destination) { 
            Remove-Item -Recurse -Force $destination 
        }

        Write-Host "Enlazando: $destination -> $source" -ForegroundColor Cyan
        New-Item -ItemType SymbolicLink -Path $destination -Target $source | Out-Null
    }

    # Copy the profile loader script from dotfiles/config/powershell/Microsoft.PowerShell_profile.ps1 to the OneDrive $PROFILE path
    if ($PROFILE) {
        $profileDir = Split-Path -Parent $PROFILE
        if (-not (Test-Path -Path $profileDir)) { 
            New-Item -ItemType Directory -Path $profileDir | Out-Null 
        }

        $repoProfilePath = "$RepoDir\config\powershell\Microsoft.PowerShell_profile.ps1"
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

