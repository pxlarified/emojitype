$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

& .\gradlew.bat :fabric:build
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

$targetDir = Join-Path $root '.mizius\target'
New-Item -ItemType Directory -Force -Path $targetDir | Out-Null

$jar = Get-ChildItem -Path (Join-Path $root 'fabric\build\libs') -Filter '*.jar' |
    Where-Object { $_.Name -notlike '*-sources.jar' -and $_.Name -notlike '*-dev.jar' } |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

if (-not $jar) {
    throw 'No Fabric mod jar found in fabric\build\libs.'
}

Copy-Item -Path $jar.FullName -Destination $targetDir -Force
Write-Host "Copied $($jar.Name) to $targetDir"
