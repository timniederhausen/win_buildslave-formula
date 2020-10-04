function AddPath($folder) {
    if ($Env:Path | Select-String -SimpleMatch $folder) { return }
    $Env:Path += ';' + $folder
    Set-ItemProperty 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name 'PATH' -Value $Env:Path
}
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
#Write-Output $localPython

$pyHome = Split-Path $localPython -Parent
$Env:PYTHONHOME = $pyHome
AddPath(Join-Path $pyHome "Scripts")

$sitePackages = (Join-Path (Join-Path $pyHome 'Lib') 'site-packages')
if (!(Test-Path $sitePackages)) {
    Write-Output "No site-packages"
    Exit -1
}

&"$localPython" -m pip install pywin32
if ($LastExitCode) { throw "Installing pywin32 failed" }

&"$localPython" (Join-Path (Join-Path $pyHome 'Scripts') 'pywin32_postinstall.py') -install
if ($LastExitCode) { throw "pywin32_postinstall failed" }

Write-Output 'Installed Successful'
exit 0
