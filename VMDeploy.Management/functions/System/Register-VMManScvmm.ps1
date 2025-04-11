function Register-VMManScvmm {
	<#
	.SYNOPSIS
		Register a new SCVMM Instance to this deployment.
	
	.DESCRIPTION
		Register a new SCVMM Instance to this deployment.
		This allows deploying to multiple VMM environments from the same VMDeploy endpoint.
	
	.PARAMETER Name
		Name of the VMM Server configuration.
		This is the name by which the VMM environment is configured and called upon.
		It MAY be equal to the SCVMM server name, but it does not have to.
		Must be unique - specifying a name already in use will overwrite.
	
	.PARAMETER VmmServer
		The FQDN of the SCVMM server to interact with.
	
	.PARAMETER LibraryShare
		The path to the library-share used by the SCVMM deployment.
	
	.PARAMETER Description
		A description to include in this configuration.
		Purely cosmetic but shown when using Get-VMManScvmm.

	.PARAMETER Role
		What role is allowed access to this SCVMM server.
		Only Admins and members of this role can deploy VMs into that SCVMM Environment.
		Defaults to: Admins.
	
	.EXAMPLE
		PS C:\> Register-VMManScvmm -Name prod -VmmServer scvmm.contoso.com -LibraryShare \\scvmm.contoso.com\library

		Registers "scvmm.contoso.com" as the prod SCVMM Environment
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Name,

		[Parameter(Mandatory = $true)]
		[string]
		$VmmServer,

		[Parameter(Mandatory = $true)]
		[string]
		$LibraryShare,

		[string]
		$Description,

		[string]
		$Role = 'Admins'
	)
	begin {
		Assert-Role -Role ConfigOperators -RemoteOnly -Cmdlet $PSCmdlet
	}
	process {
		Set-PSFConfig -FullName "VMDeploy.Management.VMMServer.$Name.Server" -Value $VmmServer -PassThru | Register-PSFConfig -Scope SystemDefault -ErrorAction Stop -EnableException
		Set-PSFConfig -FullName "VMDeploy.Management.VMMServer.$Name.Share" -Value $LibraryShare -PassThru | Register-PSFConfig -Scope SystemDefault -ErrorAction Stop -EnableException
		Set-PSFConfig -FullName "VMDeploy.Management.VMMServer.$Name.Description" -Value $Description -PassThru | Register-PSFConfig -Scope SystemDefault -ErrorAction Stop -EnableException
		Set-PSFConfig -FullName "VMDeploy.Management.VMMServer.$Name.Role" -Value $Role -PassThru | Register-PSFConfig -Scope SystemDefault -ErrorAction Stop -EnableException
	}
}