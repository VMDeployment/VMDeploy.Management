Register-PSFTeppScriptblock -Name 'VMDeploy.Management.ConfigurationProvider' -ScriptBlock {
	(Get-VMManConfigurationProvider).Name
}