function Import-ConfigDomain {
    <#
    .SYNOPSIS
        Import configured domains and their associated roles.
    
    .DESCRIPTION
        Import configured domains and their associated roles.
    
    .PARAMETER ImportRoot
        The root folder under which all configuraion to import is stored.
    
    .EXAMPLE
        PS C:\> Import-ConfigDomain -ImportRoot $importRoot

        Imports all configured domains under the defined import root path.
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
        $configData = Read-ConfigGeneric -ImportRoot $ImportRoot -Type Domain -ErrorAction Stop
        $contentPath = Get-PSFConfigValue -FullName 'VMDeploy.Management.ContentPath'
        $configFile = Join-Path -Path $contentPath -ChildPath 'Domain.clidat'
        $configData | Export-PSFClixml -Path $configFile
    }
}