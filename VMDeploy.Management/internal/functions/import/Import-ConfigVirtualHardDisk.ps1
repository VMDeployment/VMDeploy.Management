function Import-ConfigVirtualHardDisk {
    <#
    .SYNOPSIS
        Import configured virtualHardDisks and their associated roles.
    
    .DESCRIPTION
        Import configured virtualHardDisks and their associated roles.
    
    .PARAMETER ImportRoot
        The root folder under which all configuraion to import is stored.
    
    .EXAMPLE
        PS C:\> Import-ConfigVirtualHardDisk -ImportRoot $importRoot

        Imports all configured virtualHardDisks under the defined import root path.
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
        $configData = Read-ConfigGeneric -ImportRoot $ImportRoot -Type VirtualHardDisk -ErrorAction Stop
        $contentPath = Get-PSFConfigValue -FullName 'VMDeploy.Management.ContentPath'
        $configFile = Join-Path -Path $contentPath -ChildPath 'VirtualHardDisk.clidat'
        $configData | Export-PSFClixml -Path $configFile
    }
}