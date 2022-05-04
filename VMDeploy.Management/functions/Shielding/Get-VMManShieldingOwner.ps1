function Get-VMManShieldingOwner {
	<#
	.SYNOPSIS
		Returns the currently configured shielding owner.
	
	.DESCRIPTION
		Returns the currently configured shielding owner.
		Throws a terminating error if none is configured.
	
	.EXAMPLE
		PS C:\> Get-VMManShieldingOwner
		
		Returns the currently configured shielding owner.
	#>
	[CmdletBinding()]
	param ()

	begin {
		Assert-Role -Role Admins -RemoteOnly -Cmdlet $PSCmdlet
		
		Import-Module CimCmdlets -Scope Global
		Import-Module HgsClient -Scope Global
	}

	process {
		try { Get-HgsGuardian -Name Owner -ErrorAction Stop }
		catch {
			Write-PSFMessage -Level Warning -String 'Get-VMManShieldingOwner.NoOwner'
			$PSCmdlet.ThrowTerminatingError($_)
		}
	}
}