# Roles

Roles map permissions to entities.
Each resource can be assigned to a role (if not, only admins can access the resource).
Multiple roles can be grouped together, and nested to any depth (but be sure to avoid recursive memberships!)

Example psd1 files:

```powershell
@{
    Name = "Global_DeploymentOperators"
    Description = "Advanced users that can perform any VM deployment task"
    ADMembers = @(
        "Contoso\VMDeploy Global_DeploymentOperators"
    )
}
```

```powershell
@{
    Name = "DeploymentUsers"
    Description = "Regular users for common VM deployment tasks"
    ADMembers = @(
        "Contoso\VMDeploy DeploymentUsers"
    )
    RoleMember = @(
        'Global_DeploymentOperators'
    )
}
```

```powershell
@{
    Name = "Network_Contoso"
    Description = "Permission to deploy VMs into the Contoso Network zone"
    RoleMember = @(
        'DeploymentUsers'
    )
}
```
