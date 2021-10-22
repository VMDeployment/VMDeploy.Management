# Modules

Define which module to provide to the VMDeploy Guest Config workflow.
Only modules provided this way will be available for the module installation Action.

Each entry supports common parameters associated with the Save-Module command.

It is not necessary to define PSFramework or VMDeploy.Guest so long as you want the
latest versions - these are implicitly and always provided, as they are a prerequisite for the Guest configuration workflow.

Examples:

```powershell
@{
	Name = "dbatools"
}
```

Provides the latest version of dbatools.

```powershell
@{
	Name = "PoshRSJob"
	MinimumVersion = "2.0.0"
}
```

Provides at least version 2.0.0 of the PoshRSJob module

```powershell
@{
	Name = "PSModuleDevelopment"
	RequiredVersion = "2.2.10.123"
}

Provides exactly version 2.2.10.123 of PSModuleDevelopment