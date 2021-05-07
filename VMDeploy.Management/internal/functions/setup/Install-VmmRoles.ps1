function Install-VmmRoles {
<#
	.SYNOPSIS
		Prepare the core roles needed to grant operational permissions on VMDeploy configuration management itself.
	
	.DESCRIPTION
		Prepare the core roles needed to grant operational permissions on VMDeploy configuration management itself.
	
	.EXAMPLE
		PS C:\> Install-VmmRoles
	
		Prepares the core roles needed to grant operational permissions on VMDeploy configuration management itself.
#>
	[CmdletBinding()]
	param (
		[string]
		$AdminPrincipal = [System.Security.Principal.WindowsIdentity]::GetCurrent().User,
		
		[Parameter(Mandatory = $true)]
		[System.Security.Principal.SecurityIdentifier]
		$GmsaSID
	)
	
	process {
		if (-not (Get-RoleSystem -Name VMDeployment)) {
			New-RoleSystem -Name VMDeployment -ErrorAction Stop
		}
		
		foreach ($role in Get-Role) {
			if ($role.Name -in $script:rolesIndex.Keys) { continue }
			
			Remove-Role -Name $role.Name -ErrorAction Stop
		}
		
		foreach ($roleName in $script:rolesIndex.Keys) {
			if (Get-Role -Name $roleName) {
				Set-Role -Name $roleName -Description $script:rolesIndex[$roleName] -ErrorAction Stop
				continue
			}
			New-Role -Name $roleName -Description $script:rolesIndex[$roleName] -ErrorAction Stop
		}
		Add-RoleMember -Role Admins -ADMember $AdminPrincipal -ErrorAction Stop
		
		foreach ($roleName in $script:rolesIndex.Keys) {
			if ($roleName -eq 'Admins') { continue }
			Add-RoleMember -RoleMember Admins -Role $roleName -ErrorAction Stop
		}
		
		$rule = [System.Security.AccessControl.FileSystemAccessRule]::new($GmsaSID, 'FullControl', 'ContainerInherit, ObjectInherit', 'None', 'Allow')
		$acl = Get-Acl -Path 'C:\ProgramData\PowerShell\Roles' -ErrorAction Stop
		$acl.AddAccessRule($rule)
		$acl | Set-Acl -Path 'C:\ProgramData\PowerShell\Roles' -ErrorAction Stop
	}
}