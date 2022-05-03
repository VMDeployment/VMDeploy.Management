function Set-VMManConfigurationSource {
<#
	.SYNOPSIS
		Configures the source of all configuration settings for the VMDeployment system.
	
	.DESCRIPTION
		Configures the source of all configuration settings for the VMDeployment system.
	
	.PARAMETER ProviderName
		The name of the configuration provider to use.
	
	.PARAMETER Parameters
		The parameters to provide to the configuration provider.

	.PARAMETER WhatIf
		If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.

	.PARAMETER Confirm
		If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.
	
	.EXAMPLE
		PS C:\> Set-VMManConfigurationSource -ProviderName 'file' -Parameters @{ Path = '\\server\share\configuration' }
	
		Configures the system to retrieve its configuration using the file provider from the path '\\server\share\configuration'
#>
	[CmdletBinding(SupportsShouldProcess = $true)]
	param (
		[Parameter(Mandatory = $true)]
		[PsfArgumentCompleter('VMDeploy.Management.ConfigurationProvider')]
		[PsfValidateSet(TabCompletion = 'VMDeploy.Management.ConfigurationProvider')]
		[string]
		$ProviderName,
		
		[Parameter(Mandatory = $true)]
		[hashtable]
		$Parameters
	)
	
	begin {
		Assert-Role -Role Admins -RemoteOnly -Cmdlet $PSCmdlet
	}
	process {
		$providerObject = Get-VMManConfigurationProvider -Name $ProviderName
		$badParameterNames = foreach ($key in $Parameters.Key) {
			if ($providerObject.Parameters -notcontains $key) { $key }
		}
		if ($badParameterNames) {
			Stop-PSFFunction -String 'Set-VMManConfigurationSource.Parameters.Invalid' -StringValues $ProviderName, ($badParameterNames -join ","), ($providerObject.Parameters -join ",") -EnableException $true -Category InvalidArgument -Cmdlet $PSCmdlet
		}
		$contentPath = Get-PSFConfigValue -FullName 'VMDeploy.Management.ContentPath'
		$sourceFilePath = Join-Path -Path $contentPath -ChildPath source.cfg
		$sourceCfg = [PSCustomObject]@{
			Provider = $ProviderName
			Parameters = $Parameters
		}
		Invoke-PSFProtectedCommand -ActionString 'Set-VMManConfigurationSource.Updating' -ActionStringValues $ProviderName, ($Parameters.Keys -join ",") -ScriptBlock {
			$sourceCfg | Export-PSFClixml -Path $sourceFilePath -ErrorAction Stop
		} -Target $ProviderName -EnableException $true -PSCmdlet $PSCmdlet
	}
}
