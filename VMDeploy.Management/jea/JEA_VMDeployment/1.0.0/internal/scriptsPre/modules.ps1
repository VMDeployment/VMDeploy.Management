Import-Module PSFramework -Scope Global
Import-Module Mutex -Scope Global
Import-Module Roles -Scope Global
Import-Module virtualmachinemanager -Scope Global
Import-Module Storage -Scope Global
Import-Module VHDX -Scope Global
Import-Module VMDeploy.Management -Scope Global
Import-Module VMDeploy.Orchestrator -Scope Global
Import-Module VMDeploy.Guest -Scope Global

$vmmServerObject = Get-VMManSCVMM | Where-Object Name -eq 'Default'
if (-not $vmmServerObject) { $vmmServerObject = Get-VMManSCVMM | Select-PSFObject -First 1 }
if (-not $vmmServerObject) {
	Write-PSFMessage -Level Warning -Message "No SCVMM Server found! Use 'Register-VMManSCVMM' to configure your SCVMM server before trying to deploy virtual machines."
}
else {
	try { $null = Get-SCVMMServer -ComputerName $vmmServerObject.Server -ErrorAction Stop }
	catch {
		Write-PSFMessage -Level Warning -Message "Failed to connect to SCVMM {0} | {1}. Ensure it exists and the account running this endpoint ({2}) has permission to use it!" -StringValues $vmmServerObject.Name, $vmmServerObject.Server, $env:USERNAME -ErrorRecord $_
	}
}