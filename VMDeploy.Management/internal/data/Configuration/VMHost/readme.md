# VM Hosts

Allows mapping roles to individual VM hosts, allowing members to deploy Virtual Machines to that particular machine.

```powershell
@{
    Name = 'host1.contoso.com'
    Role = 'H_host1_contoso_com'
}
```

Optionally, it is possible to define which paths are available on the target host for deploying VMs to.
If this is configured, a random path from this list is taken when using this host explicitly.
If it is not configured, a random path from all paths configured in the host itself is used instead.

```powershell
@{
    Name = 'host1.contoso.com'
    Role = 'H_host1_contoso_com'
	VMPaths = @(
		'E:\'
		'L:\VMs'
	)
}
```
