function Get-VMManScvmm {
	<#
	.SYNOPSIS
		Lists the registered SCVMM servers.
	
	.DESCRIPTION
		Lists the registered SCVMM servers.
	
	.PARAMETER Name
		Name of the SCVMM to search for.
		Name as it is registered in this system, not the DNS Host Name.
		Defaults to *
	
	.PARAMETER NoCache
        Disable the user role cache.
        This forces a refresh of the current user role resolution and ensure time-exact configurations are applied.
        Note: This has no effect on user AD Groupmembership changes - only changes to role configuration are refreshed.
	
	.EXAMPLE
		PS C:\> Get-VMManScvmm

		Lists all registered SCVMM servers.
	#>
	[CmdletBinding()]
	param (
		[string]
		$Name = '*',

		[switch]
		$NoCache
	)
	begin {
		$userRoles = Get-UserRole -NoCache:$NoCache
	}
	process {
		foreach ($entry in Select-PSFConfig -FullName 'VMDeploy.Management.VMMServer.*') {
			if ($entry.Server -eq '<deleted>') { continue } # Server was unregistered in the current session.
			if ($PSSenderInfo -and $entry.Role -notin $userRoles -and $userRoles -notcontains 'Admins') { continue }
			if ($entry._Name -notlike $Name) { continue }

			[PSCustomObject]@{
				PSTypeName  = 'VMDeploy.Management.VMMServer'
				Name        = $entry._Name
				Server      = $entry.Server
				Share       = $entry.Share
				Description = $entry.Description
				Role        = $entry.Role
			}
		}
	}
}