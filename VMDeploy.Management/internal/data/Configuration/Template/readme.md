# Templates

## Description

Templates - or deployment templates - group together other components into one predefined group, avoiding the need to always repetitively specifying each component.

Templates can be assigned permissions, but unless the user is authorized to use the individual components, access is still denied.

Each template is defined as a psd1 file.
Example file content:

```powershell
@{
    Name = 'Contoso'
    Description = 'Default Contoso VM Deployment'
    Visible = $true
    HardwareProfile = 'default'
    GuestOSProfile = 'default'
    Cloud = 'TestCloud'
    VirtualHardDisk = 'Server2019.vhdx'
    Network = 'Contoso_Network'
    Role = 'Template_Contoso'
    ChildTemplates = @()
    GuestConfig = @()
    # DynamicHardwareProfile = $true
    # DynamicGuestOSProfile = $true
    # Shielding = 'empty'
}
```

## Settings

> Name

The name of the template must be unique and is used by the user to select it.
Mandatory for each template.

> Description

A description so that a user may know what the template does.
Mandatory for each template

> Visible

Whether the template should show in intellisense / tab completion.
Setting this to $false has no effect on the user's ability to use the template, it is merely hidden from discovery.
Intended for component templates that should only be selected through selecting a parent template including it.

> Role

The role able to access the template.
If this is undefined, only admins will be able to use it.
Role assignment to a template has no effect on permissions to use a given resource - being able to select a template does not grant permissions on resources referenced in the template.

> HardwareProfile

The hardware profile to include in the deployment.
Used to determine hardware characteristics of the deployed VM.
Hardware Profiles are defined in SCVMM.

> GuestOSProfile

The Guest OS profile to include in the deployment.
Used to determine OS characteristics of the guest operating system of the deployed VM.
Guest OS Profiles are defined in SCVMM

> Cloud / VMHostGroup / VMHost

Where to deploy the generated VM to?
Only specify one of the three options

> VirtualHardDisk

The name of the VHDX hosting to operating system.
Will be assigned LUN 0.

> Network

The network profile to assign.
This defines subnet, DNS Servers, etc.
Each setting can be overridden from within New-VmoVirtualMachine.

> ChildTemplates

The names of additional templates to include.
These will be processed in the order they are defined:

+ The previous values for a given setting will be overwritten if defined.
+ Guest Configurations (see below) are merged, with settings of the same name being overwritten.

> GuestConfig

List of guest configurations to include.
These will be deployed to the guest and applied from within, including all required resources.

> DynamicHardwareProfile

Whether the hardware profile should be determined dynamically.
This is a tri-state boolean similar to GPO settings: True, False or undefined.
The last template that defines this setting wins.
If at final resolution a value of true is detected, the configured dynamic hardware profiles will be evaluated and tested, and the highest priority applicable dynamic hardware profile will be applied and overwrite static hardware profiles be overwritten.
If no dynamic hardware profile is applicable, the resolved static hardware profile is applied.

> DynamicGuestOSProfile

Whether the GuestOSProfile should be determined dynamically.
This is a tri-state boolean similar to GPO settings: True, False or undefined.
The last template that defines this setting wins.
If at final resolution a value of true is detected, the configured dynamic GuestOSProfiles will be evaluated and tested, and the highest priority applicable dynamic GuestOSProfile will be applied and overwrite static GuestOSProfiles be overwritten.
If no dynamic GuestOSProfile is applicable, the resolved static GuestOSProfile is applied.

> Shielding

Any shielding configuration will cause the deployment of the VM as a Shielded VM (or fail if the necessary configuration and infrastructure are missing).
To manage shielding, provide an unattend file under the `ShieldingUnattend` folder and reference it here by name.
The unattend file `empty` (which defines no settings at all) is available by default to admins.
To enable other roles, either provide a custom unattend file with a role configuration or override the default configuration for the `empty` unattend file.
