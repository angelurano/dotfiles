$OnceDir = Join-Path $env:LOCALAPPDATA 'Temp'
$BootId  = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime.ToFileTime()
$Lock    = Join-Path $OnceDir ".winfetch.$BootId"

if (-not (Test-Path $Lock)) {
    if (Get-Command winfetch -ErrorAction SilentlyContinue) {
        winfetch
        New-Item -ItemType File -Force -Path $Lock | Out-Null
    }
}
