function Get-VMManGuardedFabric {
	<#
	.SYNOPSIS
		List the registered guarded fabrics.
	
	.DESCRIPTION
		List the registered guarded fabrics.

		Note: Due to technical limitations, this command is quite a bit slower than one would expect.
	
	.PARAMETER Name
		Filter the results by name.
		Defaults to '*'
	
	.EXAMPLE
		PS C:\> Get-VMManGuardedFabric
		
		List all guarded fabrics.
	#>
	[CmdletBinding()]
	param (
		[string]
		$Name = '*'
	)

	begin {
		Assert-Role -Role Admins -RemoteOnly -Cmdlet $PSCmdlet

		Import-Module CimCmdlets -Scope Global
		Import-Module HgsClient -Scope Global
	}

	process {
		try {
			Get-HgsGuardian -ErrorAction Stop | Where-Object {
				$_.Name -Like $Name -and
				$_.Name -ne 'Owner'
			}
		}
		catch { throw }
	}
}