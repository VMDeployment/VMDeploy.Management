function Import-ConfigGuestOSProfile {
    <#
    .SYNOPSIS
        Import configured guestOSProfiles and their associated roles.
    
    .DESCRIPTION
        Import configured guestOSProfiles and their associated roles.
    
    .PARAMETER ImportRoot
        The root folder under which all configuration to import is stored.
    
    .EXAMPLE
        PS C:\> Import-ConfigGuestOSProfile -ImportRoot $importRoot

        Imports all configured guestOSProfiles under the defined import root path.
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
        $configData = Read-ConfigGeneric -ImportRoot $ImportRoot -Type GuestOSProfile -ErrorAction Stop
        $contentPath = Get-PSFConfigValue -FullName 'VMDeploy.Management.ContentPath'
        $configFile = Join-Path -Path $contentPath -ChildPath 'GuestOSProfile.clidat'
        $configData | Export-PSFClixml -Path $configFile
    }
}