function Import-ConfigVMHostGroup {
    <#
    .SYNOPSIS
        Import configured vMHostGroups and their associated roles.
    
    .DESCRIPTION
        Import configured vMHostGroups and their associated roles.
    
    .PARAMETER ImportRoot
        The root folder under which all configuraion to import is stored.
    
    .EXAMPLE
        PS C:\> Import-ConfigVMHostGroup -ImportRoot $importRoot

        Imports all configured vMHostGroups under the defined import root path.
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
        $configData = Read-ConfigGeneric -ImportRoot $ImportRoot -Type VMHostGroup -ErrorAction Stop
        $contentPath = Get-PSFConfigValue -FullName 'VMDeploy.Management.ContentPath'
        $configFile = Join-Path -Path $contentPath -ChildPath 'VMHostGroup.clidat'
        $configData | Export-PSFClixml -Path $configFile
    }
}