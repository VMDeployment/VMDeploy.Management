Import-Module PSFramework -Scope Global
Import-Module Roles -Scope Global
Import-Module virtualmachinemanager -Scope Global
Import-Module Storage -Scope Global
Import-Module VHDX -Scope Global
Import-Module VMDeploy.Management -Scope Global
Import-Module VMDeploy.Orchestrator -Scope Global
Import-Module VMDeploy.Guest -Scope Global

$null = Get-VMMServer -ComputerName (Get-PSFConfigValue -FullName 'VMDeployment.SCVMM.Server' -NotNull)