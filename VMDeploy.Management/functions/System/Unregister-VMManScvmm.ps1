function Unregister-VMManScvmm {
	<#
	.SYNOPSIS
		Deletes a SCVMM connection configuration.
	
	.DESCRIPTION
		Deletes a SCVMM connection configuration.
	
	.PARAMETER Name
		The name of the SCVMM configuration to delete.
	
	.EXAMPLE
		PS C:\> Unregister-VMManScvmm -Name test
		
		Deletes the "test" SCVMM configuration.
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[string[]]
		$Name
	)
	begin {
		Assert-Role -Role ConfigOperators -RemoteOnly -Cmdlet $PSCmdlet
	}
	process {
		foreach ($entry in $Name) {
			Get-PSFConfig -FullName "VMDeploy.Management.VMMServer.$entry.*" -Persisted | Unregister-PSFConfig
			if (Get-PSFConfig -FullName "VMDeploy.Management.VMMServer.$entry.Server") {
				Set-PSFConfig -FullName "VMDeploy.Management.VMMServer.$entry.Server" -Value '<deleted>'
			}
		}
	}
}