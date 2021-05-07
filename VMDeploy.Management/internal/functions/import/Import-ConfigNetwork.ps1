function Import-ConfigNetwork {
    <#
    .SYNOPSIS
        Import configured networks and their associated roles.
    
    .DESCRIPTION
        Import configured networks and their associated roles.
    
    .PARAMETER ImportRoot
        The root folder under which all configuraion to import is stored.
    
    .EXAMPLE
        PS C:\> Import-ConfigNetwork -ImportRoot $importRoot

        Imports all configured networks under the defined import root path.
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
        $configData = Read-ConfigGeneric -ImportRoot $ImportRoot -Type Network -ErrorAction Stop
        $contentPath = Get-PSFConfigValue -FullName 'VMDeploy.Management.ContentPath'
        $configFile = Join-Path -Path $contentPath -ChildPath 'Network.clidat'
        $configData | Export-PSFClixml -Path $configFile
    }
}