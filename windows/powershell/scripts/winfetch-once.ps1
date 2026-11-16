$OnceDir = Join-Path $env:LOCALAPPDATA 'Temp'
$Lock    = Join-Path $OnceDir '.winfetch.boot'
$BootUtc = [DateTime]::UtcNow.AddMilliseconds(-[Environment]::TickCount64)

if (-not [System.IO.File]::Exists($Lock) -or ([System.IO.File]::GetLastWriteTimeUtc($Lock) -lt $BootUtc)) {
    if (Get-Command winfetch -ErrorAction SilentlyContinue) {
        winfetch
        New-Item -ItemType File -Force -Path $Lock | Out-Null
    }
}
