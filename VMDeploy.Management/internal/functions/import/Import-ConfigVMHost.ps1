function Import-ConfigVMHost {
    <#
    .SYNOPSIS
        Import configured VM Hosts and their associated roles.
    
    .DESCRIPTION
        Import configured VM Hosts and their associated roles.
    
    .PARAMETER ImportRoot
        The root folder under which all configuraion to import is stored.
    
    .EXAMPLE
        PS C:\> Import-ConfigVMHost -ImportRoot $importRoot

        Imports all configured VM Hosts and their associated roles.
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
		$configData = Read-ConfigGeneric -ImportRoot $ImportRoot -Type VMHost -ErrorAction Stop
		$contentPath = Get-PSFConfigValue -FullName 'VMDeploy.Management.ContentPath'
		$configFile = Join-Path -Path $contentPath -ChildPath 'VMHost.clidat'
		$configData | Export-PSFClixml -Path $configFile
	}
}