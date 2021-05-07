function Install-VmmContentPath {
<#
	.SYNOPSIS
		Installs the VMDeployment content path.
	
	.DESCRIPTION
		Installs the VMDeployment content path.
		This ensures the existence of the path where VMDeployment looks for applied configuration data.
		The path is defined under 'VMDeploy.Management.ContentPath' but defaults to "VMDeployment" in ProgramData
	
	.PARAMETER GmsaSID
		The SID of the gMSA to grant full control over the folder.
		The same gMSA that is used to operate the JEA endpoint used to manage configuration.
	
	.EXAMPLE
		PS C:\> Install-VmmContentPath -GmsaSID $GmsaSID
	
		Installs the VMDeployment content path.
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[System.Security.Principal.SecurityIdentifier]
		$GmsaSID
	)
	
	process {
		$vmDeployContentPath = Get-PSFConfigValue -FullName 'VMDeploy.Management.ContentPath'
		if (-not (Test-Path -Path $vmDeployContentPath)) {
			$null = New-Item -Path $vmDeployContentPath -ItemType Directory -Force -ErrorAction Stop -WhatIf:$false -Confirm:$false
		}
		
		$rule = [System.Security.AccessControl.FileSystemAccessRule]::new($GmsaSID, 'FullControl', 'ContainerInherit, ObjectInherit', 'None', 'Allow')
		$acl = Get-Acl -Path $vmDeployContentPath -ErrorAction Stop
		$acl.AddAccessRule($rule)
		$acl | Set-Acl -Path $vmDeployContentPath -ErrorAction Stop
	}
}