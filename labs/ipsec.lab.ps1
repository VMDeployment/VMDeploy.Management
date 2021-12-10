Import-Module C:\Code\Github\LabHelper\LabHelper\LabHelper.psd1 -Force

$labname = 'IPSec'
$imageUI = 'Windows Server 2019 Datacenter (Desktop Experience)'

New-LabDefinition -Name $labname -DefaultVirtualizationEngine HyperV

$PSDefaultParameterValues['Add-LabMachineDefinition:Memory'] = 2GB
$PSDefaultParameterValues['Add-LabMachineDefinition:OperatingSystem'] = $imageUI
$PSDefaultParameterValues['Add-LabMachineDefinition:DomainName'] = 'contoso.com'

Add-LabMachineDefinition -Name IpsDC -Roles RootDC
Add-LabMachineDefinition -Name IpsAdminHost
Add-LabMachineDefinition -Name IpsCA -Roles CaRoot
Add-LabMachineDefinition -Name IpsServer1
Add-LabMachineDefinition -Name IpsServer2

Install-Lab

Install-LabWindowsFeature -ComputerName IpsAdminHost -FeatureName NET-Framework-Core, NET-Non-HTTP-Activ, GPMC, RSAT-AD-Tools

Invoke-LabCommand -ActivityName "Setting Keyboard Layout" -ComputerName (Get-LabVM).Name -ScriptBlock {
    Set-WinUserLanguageList -LanguageList 'de-de' -Confirm:$false -Force
}
Restart-LabVM -ComputerName (Get-LabVM).Name