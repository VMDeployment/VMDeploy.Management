function Import-ConfigAction {
<#
	.SYNOPSIS
        Import configured actions and their associated roles.
    
    .DESCRIPTION
        Import configured actions and their associated roles.
    
    .PARAMETER ImportRoot
        The root folder under which all configuraion to import is stored.
    
    .EXAMPLE
        PS C:\> Import-ConfigAction -ImportRoot $importRoot

        Imports all configured actions under the defined import root path.
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
		$contentPath = Get-PSFConfigValue -FullName 'VMDeploy.Management.ContentPath'
		
		$actionSourcePath = Join-Path -Path $ImportRoot -ChildPath Actions
		$actionDestinationPath = Join-Path -Path $contentPath -ChildPath Actions
		
		$sourceActions = Get-ChildItem -Path $actionSourcePath -Recurse -Filter *.ps1
		foreach ($actionFile in $sourceActions) {
			Copy-Item -LiteralPath $actionFile.FullName -Destination $actionDestinationPath -Force
		}
		
		Get-ChildItem -Path $actionDestinationPath -Filter *.ps1 | Where-Object Name -NotIn $sourceActions.Name | Remove-Item -Force -ErrorAction Ignore
	}
}