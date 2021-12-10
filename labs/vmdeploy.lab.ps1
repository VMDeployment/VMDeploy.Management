Import-Module C:\Code\Github\LabHelper\LabHelper\LabHelper.psd1 -Force

$labname = 'vmdeploy'
$imageUI = 'Windows Server 2019 Datacenter (Desktop Experience)'


#region Utility Functions
function Install-ScvmmContent {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $ScvmmName
    )

    $scvmmContentCode = {
        param (
            $ScvmmName
        )

        $PSDefaultParameterValues['*-SC*:VMMServer'] = $ScvmmName

        $allHosts = foreach ($vmHost in Get-SCVMHost) {
            # Configure VMHost VM-Path
            Set-SCVMHost -VMHost $vmHost -VMPaths "E:\" -BaseDiskPaths ""
            $vmHost
        }
        # Step 1: Create logical network & network definition
        $logicalNetwork = New-SCLogicalNetwork -Name "TestLogicNet1" -LogicalNetworkDefinitionIsolation $true -EnableNetworkVirtualization $false -UseGRE $false -IsPVLAN $false
        $allHostGroups = Get-SCVMHostGroup
        $allSubnetVlan = New-SCSubnetVLan -Subnet "10.0.42.0/24" -VLanID 0
        $logicalNetworkDefinition = New-SCLogicalNetworkDefinition -Name "TestLogicNet1_0" -LogicalNetwork $logicalNetwork -VMHostGroup $allHostGroups -SubnetVLan $allSubnetVlan

        # Step 2: Create VMNetwork & Subnet
        $vmNetwork = New-SCVMNetwork -Name "TestVMNetwork" -LogicalNetwork $logicalNetwork -IsolationType "VLANNetwork"
        $vmSubnet = New-SCVMSubnet -Name "TestVMNetwork_0" -LogicalNetworkDefinition $logicalNetworkDefinition -SubnetVLan $allSubnetVlan -VMNetwork $vmNetwork

        # Step 3: Create Logical Switch & Network Adapter
        $virtualSwitchExtensions = Get-SCVirtualSwitchExtension -Name "Microsoft Windows Filtering Platform"
        $logicalSwitch = New-SCLogicalSwitch -Name "TestLogicalSwitch1" -EnableSriov $false -SwitchUplinkMode "EmbeddedTeam" -MinimumBandwidthMode "Weight" -VirtualSwitchExtensions $virtualSwitchExtensions

        $portClassification = Get-SCPortClassification -Name 'Host management'
        $nativeProfile = Get-SCVirtualNetworkAdapterNativePortProfile -Name 'Host management'
        $null = New-SCVirtualNetworkAdapterPortProfileSet -Name "Host management" -PortClassification $portClassification -LogicalSwitch $logicalSwitch -VirtualNetworkAdapterNativePortProfile $nativeProfile
        $nativeUppVar = New-SCNativeUplinkPortProfile -Name "TestPortProfile" -LogicalNetworkDefinition $logicalNetworkDefinition -EnableNetworkVirtualization $false -LBFOLoadBalancingAlgorithm "HostDefault" -LBFOTeamMode "SwitchIndependent"
        $uppSetVar = New-SCUplinkPortProfileSet -Name "TestPortProfile" -LogicalSwitch $logicalSwitch -NativeUplinkPortProfile $nativeUppVar
        $null = New-SCLogicalSwitchVirtualNetworkAdapter -Name "VNA_Management" -UplinkPortProfileSet $uppSetVar -VMNetwork $vmNetwork -VMSubnet $vmSubnet -PortClassification $portClassification -IsUsedForHostManagement $true -InheritsAddressFromPhysicalNetworkAdapter $true -IPv4AddressType "Dynamic" -IPv6AddressType "Dynamic"

        # Step 4: Configure Host Logical Switch
        # Get Host 'VmdF1HV.contoso.com'
        foreach ($vmHost in $allHosts) {
            $hostNetworkAdapter = Get-SCVMHostNetworkAdapter -VMHost $vmHost.Name
            Set-SCVMHostNetworkAdapter -VMHostNetworkAdapter $hostNetworkAdapter -UplinkPortProfileSet $uppSetVar
            New-SCVirtualNetwork -VMHost $vmHost -VMHostNetworkAdapters $hostNetworkAdapter -LogicalSwitch $logicalSwitch -DeployVirtualNetworkAdapters -JobGroup "6e45796d-63e2-4fd7-9a8d-531a26ece21e"
        }

        # Step 5: Create Hardware Profile
        $jobGroup = New-Guid
        $null = New-SCVirtualNetworkAdapter -JobGroup $jobGroup -MACAddressType Dynamic -Synthetic -IPv4AddressType Dynamic -IPv6AddressType Dynamic -VMSubnet $VMSubnet -VMNetwork $VMNetwork -PortClassification $PortClassification 
        $null = New-SCVirtualScsiAdapter -JobGroup $jobGroup -AdapterID 7 -ShareVirtualScsiAdapter $false -ScsiControllerType DefaultTypeNoType 
        $null = New-SCVirtualDVDDrive -JobGroup $jobGroup -Bus 0 -LUN 1 
        $cpuType = Get-SCCPUType | Where-Object Name -EQ "3.60 GHz Xeon (2 MB L2 cache)"
        $capabilityProfile = Get-SCCapabilityProfile | Where-Object Name -EQ "Hyper-V"
        $null = New-SCHardwareProfile -Owner '' -CPUType $cpuType -Name "TestHWProfile1" -CPUCount 1 -MemoryMB 1024 -DynamicMemoryEnabled $false -MemoryWeight 5000 -CPUExpectedUtilizationPercent 20 -DiskIops 0 -CPUMaximumPercent 100 -CPUReserve 0 -NumaIsolationRequired $false -NetworkUtilizationMbps 0 -CPURelativeWeight 100 -HighlyAvailable $false -DRProtectionRequired $false -SecureBootEnabled $true -SecureBootTemplate "MicrosoftWindows" -CPULimitFunctionality $false -CPULimitForMigration $false -CheckpointType Disabled -CapabilityProfile $capabilityProfile -Generation 2 -JobGroup $jobGroup

        # Step 6: Create Guest OS Profile
        $operatingSystem = Get-SCOperatingSystem | Where-Object Name -EQ "Windows Server 2019 Standard"
        $null = New-SCGuestOSProfile -Name "TestGuestProfile1" -ComputerName "*" -TimeZone 110 -LocalAdministratorCredential $null  -FullName "" -OrganizationName "" -Workgroup "WORKGROUP" -AnswerFile $null -Owner '' -OperatingSystem $OperatingSystem
    }

    Invoke-LabCommand -ComputerName $ScvmmName -ArgumentList $ScvmmName -ActivityName 'Deploying SCVMM Content Configuration' -ScriptBlock $scvmmContentCode
}
#endregion Utility Functions

New-LabDefinition -Name $labname -DefaultVirtualizationEngine HyperV

$PSDefaultParameterValues['Add-LabMachineDefinition:Memory'] = 2GB
$PSDefaultParameterValues['Add-LabMachineDefinition:OperatingSystem'] = $imageUI
$PSDefaultParameterValues['Add-LabMachineDefinition:DomainName'] = 'contoso.com'

Add-LabMachineDefinition -Name VmdF1DC -Roles RootDC
Add-LabMachineDefinition -Name VmdF1AdminHost
Add-LabMachineDefinition -Name VmdF1SCVMM -Roles Scvmm2019 @{
    ConnectHyperVRoleVms = 'VmdF1HV'
}
Add-LabMachineDefinition -Name VmdF1HGS 
Add-LabMachineDefinition -Name VmdF1VMDeploy
Add-LabMachineDefinition -Name VmdF1SQL -Roles SQLServer2017
Add-LabMachineDefinition -Name VmdF1HV -Roles HyperV -Memory 8GB

$PSDefaultParameterValues['Add-LabMachineDefinition:DomainName'] = 'fabrikam.org'
Add-LabMachineDefinition -Name VmdF2DC -Roles RootDC
Add-LabMachineDefinition -Name VmdF2AdminHost
Add-LabMachineDefinition -Name VmdF2HV -Roles HyperV

Install-Lab

New-LabADTrust -ComputerName VmdF1DC -RemoteForest fabrikam.org -Direction Inbound

Install-LabWindowsFeature -ComputerName VmdF1AdminHost, VmdF2AdminHost -FeatureName NET-Framework-Core, NET-Non-HTTP-Activ, GPMC, RSAT-AD-Tools
Install-LabWindowsFeature -ComputerName VmdF1HGS -FeatureName Install-LabWindowsFeature -IncludeManagementTools
Restart-LabVM -ComputerName VmdF1HGS -Wait

Install-ScvmmContent -ScvmmName VmdF1SCVMM

Invoke-LabCommand -ActivityName "Setting Keyboard Layout" -ComputerName (Get-LabVM).Name -ScriptBlock {
    Set-WinUserLanguageList -LanguageList 'de-de' -Confirm:$false -Force
}
Restart-LabVM -ComputerName (Get-LabVM).Name