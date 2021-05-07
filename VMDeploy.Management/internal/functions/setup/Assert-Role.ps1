function Assert-Role
{
<#
	.SYNOPSIS
		Asserts whether the current user is in the required role.
	
	.DESCRIPTION
		Asserts whether the current user is in the required role.
	
	.PARAMETER Role
		The role the current user must be a member of.
	
	.PARAMETER RemoteOnly
		Whether this assertion is only applied when run in a remote session (such as a JEA endpoint).
	
	.PARAMETER Cmdlet
		The $PSCmdlet variable of the calling command.
	
	.EXAMPLE
		PS C:\> Assert-Role -Role Admins -Cmdlet $PSCmdlet
	
		Asserts that the current user is in the "Admins" role
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Role,
		
		[switch]
		$RemoteOnly,
		
		[Parameter(Mandatory = $true)]
		$Cmdlet
	)
	
	process
	{
		if (-not $PSSenderInfo -and $RemoteOnly) { return }
		if (Test-RoleMembership -Role $Role) { return }
		
		$exception = [System.InvalidOperationException]::new("Membership in role '$Role' is required for this command")
		$record = [System.Management.Automation.ErrorRecord]::new($exception, "NotInRole", 'PermissionDenied', $null)
		$Cmdlet.ThrowTerminatingError($record)
	}
}