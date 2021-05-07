function Register-VMManConfigurationProvider {
<#
	.SYNOPSIS
		Register a scriptblock that handles updates to the current VMDeployment configuration.
	
	.DESCRIPTION
		Register a scriptblock that handles updates to the current VMDeployment configuration.
		
		The scriptblock will receive a hashtable with whatever information it requires to work.
		The one constant input will be "OutPath" which is the destination folder into which to deploy the configuration files.
		This will be a temporary folder that will later be consumed by the import process internals.
		The structure of the output in the OutPath directory needs to adhere to the documented standards for configuration layout.
		
		Additional accepted parameters can be defined during this command's call by specifying "Parameters".
		These will be provided through Set-VMManConfigurationSource.
	
	.PARAMETER Name
		The name of the configuration source.
	
	.PARAMETER Code
		The scriptblock implementing the configuration source processing.
	
	.PARAMETER Parameters
		Additional parameters supported by the source
	
	.EXAMPLE
		PS C:\> Register-VMManConfigurationProvider -Name 'file' -Code $Code -Parameters 'Path'
	
		Implement a configuration source named 'file' that supports a single input parameter (Path).
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Name,
		
		[Parameter(Mandatory = $true)]
		[scriptblock]
		$Code,
		
		[Parameter(Mandatory = $true)]
		[string[]]
		$Parameters
	)
	
	process {
		$script:configurationSources[$Name] = [pscustomobject]@{
			PSTypeName = 'VMDeploy.Management.ConfigurationProvider'
			Name	   = $Name
			Code	   = $Code
			Parameters = $Parameters
		}
	}
}
