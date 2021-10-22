function Register-VMManRepository {
<#
	.SYNOPSIS
		Register a PowerShell repository to use for providing PowerShell modules to the guest configuration workflow.
	
	.DESCRIPTION
		Register a PowerShell repository to use for providing PowerShell modules to the guest configuration workflow.
		
		Requires Admin rights to the VMDeployment system.
	
	.PARAMETER Name
		Name of the repository to use.
		Defaults to VMDeploy.
	
	.PARAMETER Location
		Path or weblink to the repository to use.
	
	.PARAMETER Confirm
		If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.
	
	.PARAMETER WhatIf
		If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.
	
	.EXAMPLE
		PS C:\> Register-VMManRepository -Location '\\server\share\repository'
	
		Registers the SMB path '\\server\share\repository' as repository named VMDeploy.
		All PowerShell module configuration settings will be served from there.
#>
	[CmdletBinding(SupportsShouldProcess = $true)]
	param (
		[string]
		$Name = 'VMDeploy',
		
		[Parameter(Mandatory = $true)]
		[string]
		$Location
	)
	
	begin {
		Assert-Role -Role Admins -RemoteOnly -Cmdlet $PSCmdlet
		
		Import-Module PackageManagement -Scope Global
		Import-Module PowerShellGet -Scope Global
	}
	process {
		if (Get-PSRepository -Name $Name -ErrorAction SilentlyContinue) {
			Invoke-PSFProtectedCommand -ActionString 'Register-VMManRepository.Unregistering' -ActionStringValues $Name -Target $env:USERNAME -ScriptBlock {
				Unregister-PSRepository -Name $Name -ErrorAction Stop
			} -EnableException $true -PSCmdlet $PSCmdlet
		}
		Invoke-PSFProtectedCommand -ActionString 'Register-VMManRepository.Registering' -ActionStringValues $Name, $Location -Target $env:USERNAME -ScriptBlock {
			Register-PSRepository -Name $Name -SourceLocation $Location -InstallationPolicy Trusted -ErrorAction Stop
		} -EnableException $true -PSCmdlet $PSCmdlet
		Invoke-PSFProtectedCommand -ActionString 'Register-VMManRepository.Config' -ActionStringValues $Name -Target $env:USERNAME -ScriptBlock {
			Set-PSFConfig -FullName 'VMDeploy.Management.PSRepository' -Value $Name -PassThru -EnableException | Register-PSFConfig -Scope SystemDefault -ErrorAction Stop -EnableException
		} -EnableException $true -PSCmdlet $PSCmdlet
	}
}