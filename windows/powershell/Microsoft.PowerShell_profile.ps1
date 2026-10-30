# Redirect to the local XDG dotfiles configuration
$LocalProfile = "$HOME\.config\powershell\entry.ps1"
if (Test-Path -Path $LocalProfile) {
    . $LocalProfile
}
