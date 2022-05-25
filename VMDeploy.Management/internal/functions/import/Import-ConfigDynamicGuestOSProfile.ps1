function Import-ConfigDynamicGuestOSProfile {
    <#
    .SYNOPSIS
        Import configured Dynamic GuestOSProfile and their associated roles.
    
    .DESCRIPTION
        Import configured Dynamic GuestOSProfile and their associated roles.
    
    .PARAMETER ImportRoot
        The root folder under which all configuration to import is stored.
    
    .EXAMPLE
        PS C:\> Import-ConfigDynamicGuestOSProfile -ImportRoot $importRoot

        Imports all configured Dynamic GuestOSProfiles under the defined import root path.
    #>
    [CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$ImportRoot
	)
	
	begin {
		Assert-Role -Role ConfigOperators -RemoteOnly -Cmdlet $PSCmdlet
	}
    process {
        $configData = Read-ConfigGeneric -ImportRoot $ImportRoot -Type DynamicGuestOSProfile -ErrorAction Stop
        $contentPath = Get-PSFConfigValue -FullName 'VMDeploy.Management.ContentPath'
        $configFile = Join-Path -Path $contentPath -ChildPath 'DynamicGuestOSProfile.clidat'
        $configData | Export-PSFClixml -Path $configFile
    }
}