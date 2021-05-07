function Get-VMManConfigurationProvider {
<#
	.SYNOPSIS
		Get a list of registered configuration providers.
	
	.DESCRIPTION
		Get a list of registered configuration providers.
	
	.PARAMETER Name
		Name by which to filter the results.
		Defaults to '*'
	
	.EXAMPLE
		PS C:\> Get-VMManConfigurationProvider
	
		Lists all registered configuration providers.
#>
	[CmdletBinding()]
	param (
		[string]
		$Name = '*'
	)
	
	process {
		$($script:configurationSources.Values | Where-Object Name -Like $Name)
	}
}
