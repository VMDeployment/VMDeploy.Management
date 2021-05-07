function New-TestResult {
<#
	.SYNOPSIS
		Create a new test result object.
	
	.DESCRIPTION
		Create a new test result object.
		Used by the various configuration test commands, providing a uniform result for all tests.
	
	.PARAMETER Name
		The name of the element the configuration was tested for.
		E.g. "Roles"
	
	.PARAMETER Success
		Whether the test was successful or not.
	
	.PARAMETER Message
		A message to include in the result.
	
	.PARAMETER Data
		Additional data if needed.
		For example, this could be used to pass on error objects.
	
	.EXAMPLE
		PS C:\> New-TestResult -Name 'Roles' -Success $false -Message 'No configuration found' 
	
		Returns a unsuccessful result object.
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Name,
		
		[Parameter(Mandatory = $true)]
		[bool]
		$Success,
		
		[Parameter(Mandatory = $true)]
		[string]
		$Message,
		
		$Data
	)
	
	process {
		[pscustomobject]@{
			PSTypeName = 'VMDeploy.Management'
			Name	   = $Name
			Success    = $Success
			Message    = $Message
			Data	   = $Data
		}
	}
}