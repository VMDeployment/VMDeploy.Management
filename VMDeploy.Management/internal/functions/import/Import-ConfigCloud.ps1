function Import-ConfigCloud {
    <#
    .SYNOPSIS
        Import configured Clouds and their associated roles.
    
    .DESCRIPTION
        Import configured Clouds and their associated roles.
    
    .PARAMETER ImportRoot
        The root folder under which all configuraion to import is stored.
    
    .EXAMPLE
        PS C:\> Import-ConfigCloud -ImportRoot $importRoot

        Imports all configured clouds under the defined import root path.
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
        $configData = Read-ConfigGeneric -ImportRoot $ImportRoot -Type Cloud -ErrorAction Stop
        $contentPath = Get-PSFConfigValue -FullName 'VMDeploy.Management.ContentPath'
        $configFile = Join-Path -Path $contentPath -ChildPath 'Cloud.clidat'
        $configData | Export-PSFClixml -Path $configFile
    }
}