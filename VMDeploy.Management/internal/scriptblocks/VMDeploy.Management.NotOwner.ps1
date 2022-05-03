Set-PSFScriptblock -Name 'VMDeploy.Management.NotOwner' -Scriptblock {
	$_ -ne 'Owner'
} -Global -Description 'Validates that he input string is not "Owner"'