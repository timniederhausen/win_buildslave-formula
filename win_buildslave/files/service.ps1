function Which([string]$cmd) {
    Get-Command -ErrorAction "SilentlyContinue" $cmd | Select -ExpandProperty Definition
}

$localPython = Which "python.exe"
if ("$localPython" -eq "") {
    Write-Output "Default Python"
    $localPython = "C:\Program Files\Python37\python.exe"
}

if (!(Test-Path $localPython)) {
    Write-Output "Missing Python!"
    Exit -1
}

$pyHome = Split-Path $localPython -Parent
$scriptsPath = Join-Path $pyHome "Scripts"

&"$scriptsPath\buildbot_worker_windows_service.exe" "--startup" "auto" "--user" ".\$($args[0])" "--password" "$($args[1])" "install"
exit $LASTEXITCODE
