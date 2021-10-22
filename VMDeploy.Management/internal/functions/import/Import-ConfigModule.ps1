function Import-ConfigModule {
<#
	.SYNOPSIS
		Provides all modules defined as required
	
	.DESCRIPTION
		Provides all modules defined as required.
		Uses the repository defined in VMDeploy.Management.PSRepository as source.
		Stores the module content in the "modules" subfolder of the defined content path.
	
		Always provides PSFramework and VMDeploy.Guest in the latest version available.
	
	.PARAMETER ImportRoot
		The root folder under which all configuraion to import is stored.
    
    .EXAMPLE
        PS C:\> Import-ConfigModule -ImportRoot $importRoot

        Downloads and provides all configured modules under the defined import root path.
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$ImportRoot
	)
	
	begin {
		Assert-Role -Role ConfigOperators -RemoteOnly -Cmdlet $PSCmdlet
		
		$coreModules = @(
			@{ Name = 'PSFramework' }
			@{ Name = 'VMDeploy.Guest' }
		)
		
		Import-Module PackageManagement -Scope Global
		Import-Module PowerShellGet -Scope Global
	}
	process {
		$configData = Read-ConfigGeneric -ImportRoot $ImportRoot -Type Modules -ErrorAction Stop
		$contentPath = Get-PSFConfigValue -FullName 'VMDeploy.Management.ContentPath'
		$savePath = Join-Path -Path $contentPath -ChildPath 'modules'
		$repository = Get-PSFConfigValue -FullName 'VMDeploy.Management.PSRepository'
		
		foreach ($module in $coreModules) {
			Save-Module -Path $savePath -Repository $repository @module -Force -ErrorAction Continue
		}
		foreach ($entry in $configData | ConvertTo-PSFHashtable -Include Name, MinimumVersion, MaximumVersion, RequiredVersion, AcceptLicense) {
			Save-Module -Path $savePath -Repository $repository @entry -Force -ErrorAction Continue
		}
	}
}