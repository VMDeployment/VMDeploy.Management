# Guest Configuration

Folder containing the available configuration definitions.
These should be defined as psd1 files and can be sorted into any number of subfolders.

## Layout

```powershell
@{
    Identity = '<name of setting>'
    Weight = 50
    Action = '<name of action>'
    Parameters = @{

    }
    DependsOn = @(

    )
    Resources = @(

    )
}
```

## Settings

### Identity

The identity of a guest configuration is a unique name.
Defining multiple settings with the same name will cause the last one loaded to win.
Use this name if you want to include this guest config in a template.

### Weight

The weight of a guest config determines the order, in which they are processed.
Lower numbers will be attempted first before higher numbers are.

Defaults to 50.

Keep in mind that lower numbers do not need to succeed for guest configurations with a higher weight number to be attempted.
Use the `DependsOn` setting to require a guest config to have succeeded before applying this guest config.

### Action

Name of the action that executes the setting.
Actions are the code plugins actually executing logic within the guest OS.

### Parameters

A hashtable containing the parameters provided to the action.
Example setting for a certificate request:

```powershell
@{
    CA = 'vmdf1dc.contoso.com\contoso-VMDF1DC-CA'
    Template = 'SRV-R-WebServer'
    Name = 'WebServer-CEF'
}
```

### DependsOn

List of guest configurations that must have successfully completed for the current Guest Config to be applied.

### Resources

Additional resources that must exist.
Specify the file-name (including subfolders under resources, if any).

### Persistent

This setting is set to true by default and is purely optional.
By default, a Guest Config will be attempted until it was once considered successfully completed.
Thereafter it will be skipped, even if later test runs would cause the verification to fail.

Setting this to `$false` will cause the Guest Deployment to keep testing on each attempt to apply settings.
