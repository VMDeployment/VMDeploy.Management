function Import-ConfigGuestConfiguration {
	<#
    .SYNOPSIS
        Import configured Guest Configurations and their associated roles.
    
    .DESCRIPTION
        Import configured Guest Configurations and their associated roles.
    
    .PARAMETER ImportRoot
        The root folder under which all configuration to import is stored.
    
    .EXAMPLE
        PS C:\> Import-ConfigGuestConfiguration -ImportRoot $importRoot

        Imports all configured Guest Configurations under the defined import root path.
    #>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $true)]
		[string]
		$ImportRoot
	)
	
	begin {
		Assert-Role -Role ConfigOperators -RemoteOnly -Cmdlet $PSCmdlet
	}
	process {
		$configData = Read-ConfigGeneric -ImportRoot $ImportRoot -Type GuestConfig -ErrorAction Stop
		$contentPath = Get-PSFConfigValue -FullName 'VMDeploy.Management.ContentPath'
		$configFile = Join-Path -Path $contentPath -ChildPath 'GuestConfig.clidat'
		$configData | Export-PSFClixml -Path $configFile
	}
}