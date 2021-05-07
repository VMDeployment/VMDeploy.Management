function Register-JeaEndpoint_JEA_VMDeployment
{
<#
	.SYNOPSIS
		Registers the module's JEA session configuration in WinRM.
	
	.DESCRIPTION
		Registers the module's JEA session configuration in WinRM.
		This effectively enables the module as a remoting endpoint.
	
	.EXAMPLE
		PS C:\> Register-JeaEndpoint_JEA_VMDeployment
	
		Register this module in WinRM as a remoting target.
#>
	[CmdletBinding()]
	param (
		
	)
	
	process
	{
		try { Register-JeaEndpoint -ErrorAction Stop }
		catch { throw }
	}
}