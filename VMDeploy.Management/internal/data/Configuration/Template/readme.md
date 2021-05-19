# Templates

Templates - or deployment templates - group together other components into one predefined group, avoiding the need to always repetitively specifying each component.
Included Components:

+ Hardware Profile
+ Guest OS Profile
+ Cloud or VM Host Group to deploy to
+ Virtual Hard Disk(s)
+ Network

Templates can be assigned permissions, but unless the user is authorized to use the individual components, access is still denied.

Each template is defined as a psd1 file.
Example file content:

```powershell
@{
    Name = 'Contoso'
    Description = 'Default Contoso VM Deployment'
    HardwareProfile = 'default'
    GuestOSProfile = 'default'
    Cloud = 'TestCloud'
    VirtualHardDisk = 'Server2019.vhdx'
    Network = 'Contoso_Network'
    Role = 'Template_Contoso'
}
```
