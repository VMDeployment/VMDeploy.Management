function Unregister-VMManGuardedFabric {
	<#
	.SYNOPSIS
		Removes a guarded fabric from the list of guarded fabrics shielded VMs can be deployed to.
	
	.DESCRIPTION
		Removes a guarded fabric from the list of guarded fabrics shielded VMs can be deployed to.
	
	.PARAMETER Name
		Name of the guarded fabric to remove

	.PARAMETER WhatIf
		If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.

	.PARAMETER Confirm
		If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.
	
	.EXAMPLE
		PS C:\> Get-VMManGuardedFabric | Unregister-VMManGuardedFabric
		
		Clears all registered guarded fabrics
	#>
	[CmdletBinding(SupportsShouldProcess = $true)]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[PsfValidateScript('VMDeploy.Management.NotOwner', ErrorString = 'VMDeploy.Management.Validate.NotOwner')]
		[string[]]
		$Name
	)

	begin {
		Assert-Role -Role Admins -RemoteOnly -Cmdlet $PSCmdlet

		Import-Module HgsClient -Scope Global
	}

	process {
		foreach ($guardianName in $Name) {
			Invoke-PSFProtectedCommand -ActionString 'Unregister-VMManGuardedFabric.Removing' -ActionStringValues $guardianName -ScriptBlock {
				Remove-HgsGuardian -Name $guardianName -ErrorAction Stop -Confirm:$false
			} -Target $guardianName -EnableException $true -PSCmdlet $PSCmdlet
		}
	}
}