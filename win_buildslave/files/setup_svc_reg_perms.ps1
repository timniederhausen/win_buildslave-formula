$serviceKey = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\BuildBot"

# Grant our buildslave user full access
$acl = Get-Acl "Registry::$serviceKey"
$rule = New-Object System.Security.AccessControl.RegistryAccessRule(
    "$env:computername\$($args[0])",
    "FullControl",
    "ObjectInherit,ContainerInherit",
    "None",
    "Allow"
)
$acl.SetAccessRule($rule)
$acl | Set-Acl "Registry::$serviceKey"

if (-Not (Test-Path "Registry::$serviceKey\Parameters")) {
    New-Item -path "Registry::$serviceKey\Parameters"
}
