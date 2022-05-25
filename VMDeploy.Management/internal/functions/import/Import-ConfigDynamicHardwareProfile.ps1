function Import-ConfigDynamicHardwareProfile {
    <#
    .SYNOPSIS
        Import configured Dynamic HardwareProfile and their associated roles.
    
    .DESCRIPTION
        Import configured Dynamic HardwareProfile and their associated roles.
    
    .PARAMETER ImportRoot
        The root folder under which all configuration to import is stored.
    
    .EXAMPLE
        PS C:\> Import-ConfigDynamicHardwareProfile -ImportRoot $importRoot

        Imports all configured Dynamic HardwareProfiles under the defined import root path.
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
        $configData = Read-ConfigGeneric -ImportRoot $ImportRoot -Type DynamicHardwareProfile -ErrorAction Stop
        $contentPath = Get-PSFConfigValue -FullName 'VMDeploy.Management.ContentPath'
        $configFile = Join-Path -Path $contentPath -ChildPath 'DynamicHardwareProfile.clidat'
        $configData | Export-PSFClixml -Path $configFile
    }
}