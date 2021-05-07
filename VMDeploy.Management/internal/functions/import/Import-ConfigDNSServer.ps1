function Import-ConfigDNSServer {
    <#
    .SYNOPSIS
        Import configured DNS Servers and their associated roles.
    
    .DESCRIPTION
        Import configured DNS Servers and their associated roles.
    
    .PARAMETER ImportRoot
        The root folder under which all configuraion to import is stored.
    
    .EXAMPLE
        PS C:\> Import-ConfigDNSServer -ImportRoot $importRoot

        Imports all configured DNS Servers under the defined import root path.
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
        $configData = Read-ConfigGeneric -ImportRoot $ImportRoot -Type DNSServer -ErrorAction Stop
        $contentPath = Get-PSFConfigValue -FullName 'VMDeploy.Management.ContentPath'
        $configFile = Join-Path -Path $contentPath -ChildPath 'DNSServer.clidat'
        $configData | Export-PSFClixml -Path $configFile
    }
}