$username = $args[0]
$password = $args[1]

try {
  $right = Carbon\Test-Privilege -Identity $($username) -Privilege SeServiceLogonRight
  if (-not $right) {
    Carbon\Grant-Privilege -Identity $($username) -Privilege SeServiceLogonRight
    echo "SeServiceLogonRight given"
  }
} catch [System.Exception] {
  echo "Error"
  exit 1
}

<#$command = '[Environment]::SetEnvironmentVariable("HOME", "' + $args[2] + '", "User")'
$command = [System.Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($command))

$credential = New-Object System.Management.Automation.PSCredential -ArgumentList @($username,(ConvertTo-SecureString -String $password -AsPlainText -Force))
Start-Process powershell.exe -Credential $credential -NoNewWindow -Wait -ArgumentList (
    '-NoProfile', '-ExecutionPolicy', 'unrestricted',
    '-EncodedCommand', $command
)
#>
