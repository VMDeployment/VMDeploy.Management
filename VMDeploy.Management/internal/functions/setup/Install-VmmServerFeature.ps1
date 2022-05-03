function Install-VmmServerFeature {
	<#
	.SYNOPSIS
		Installs any server features the VMDeployment Endpoint requires.
	
	.DESCRIPTION
		Installs any server features the VMDeployment Endpoint requires.
		No change will be applied if already installed.
		As a result of this step, a restart might be required - this will NOT be done automatically.
	
	.EXAMPLE
		PS C:\> Install-VmmServerFeature

		Installs all required server features
	#>
	[CmdletBinding()]
	param ()

	process {
		$features = @(
			'RSAT-Shielded-VM-Tools'
		)
	
		foreach ($feature in $features) {
			Write-PSFMessage -Level Verbose -String 'Install-VmmServerFeature.Installing' -StringValues $feature
			try { $result = Install-WindowsFeature -Name $feature -ErrorAction Stop }
			catch {
				Write-PSFMessage -Level Warning -String 'Install-VmmServerFeature.Installing.Failed' -StringValues $feature -ErrorRecord $_
				throw
			}

			if (-not $result.Success) {
				Write-PSFMessage -Level Warning -String 'Install-VmmServerFeature.Installing.NotSuccessful' -StringValues $feature, $result.ExitCode
			}
		}
	}
}