function Import-ConfigHardwareProfile {
    <#
    .SYNOPSIS
        Import configured hardwareProfiles and their associated roles.
    
    .DESCRIPTION
        Import configured hardwareProfiles and their associated roles.
    
    .PARAMETER ImportRoot
        The root folder under which all configuraion to import is stored.
    
    .EXAMPLE
        PS C:\> Import-ConfigHardwareProfile -ImportRoot $importRoot

        Imports all configured hardwareProfiles under the defined import root path.
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
        $configData = Read-ConfigGeneric -ImportRoot $ImportRoot -Type HardwareProfile -ErrorAction Stop
        $contentPath = Get-PSFConfigValue -FullName 'VMDeploy.Management.ContentPath'
        $configFile = Join-Path -Path $contentPath -ChildPath 'HardwareProfile.clidat'
        $configData | Export-PSFClixml -Path $configFile
    }
}