function Import-ConfigRole {
    <#
	.SYNOPSIS
		Imports and applies the defined roles configuration.
	
	.DESCRIPTION
		Imports and applies the defined roles configuration.
	
	.PARAMETER ImportRoot
		The root folder under which all configuraion to import is stored.
	
	.EXAMPLE
		PS C:\> Import-ConfigRole -ImportRoot $tempFolder
	
		Imports and applies the defined roles configuration.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $ImportRoot
    )
	
    begin {
        Assert-Role -Role ConfigOperators -RemoteOnly -Cmdlet $PSCmdlet
        $rolesModule = Get-Module Roles
    }
    process {
        $configData = Read-ConfigGeneric -ImportRoot $ImportRoot -Type Roles -ErrorAction Stop
		
        $allRoles = Get-Role
        Write-PSFMessage -String 'Import-ConfigRole.Starting' -StringValues @($configData).Count, @($allRoles).Count
        $rolesHash = @{ }
        $definedRolesHash = @{ }
        foreach ($role in $allRoles) { $rolesHash[$role.Name] = $role }
		
        foreach ($role in $script:rolesIndex.Keys) {
            $definedRolesHash[$role] = $script:rolesIndex[$role]
			
            if (-not $rolesHash[$role]) {
                New-Role -Name $role -Description $script:rolesIndex[$role] -ErrorAction Stop
                continue
            }
            if ($rolesHash[$role].Description -ne $script:rolesIndex[$role]) {
                Set-Role -Name $role -Description $script:rolesIndex[$role] -ErrorAction Stop
            }
        }
		
        #region Process Configured Roles
        # Do a pre-run so that membership assignments will always work out
        foreach ($configDatum in $configData) {
            #region Ensure Role exists and description is correct
            if (-not $rolesHash[$configDatum.Name]) {
                New-Role -Name $configDatum.Name -Description $configDatum.Description -ErrorAction Stop
            }
            elseif ($rolesHash[$configDatum.Name].Description -ne $configDatum.Description) {
                Set-Role -Name $configDatum.Name -Description $configDatum.Description -ErrorAction Stop
            }
            #endregion Ensure Role exists and description is correct
        }

        foreach ($configDatum in $configData) {
            $definedRolesHash[$configDatum.Name] = $configDatum
			
            #region Sync Role Memberships
            $currentRole = Get-Role -Name $configDatum.Name
            foreach ($roleMember in $configDatum.RoleMember) {
                if ($currentRole.RoleMember -contains $roleMember) { continue }
                Add-RoleMember -Role $configDatum.Name -RoleMember $roleMember -ErrorAction Stop
            }
            if ($currentRole.Name -ne 'Admins' -and $currentRole.RoleMember -notcontains 'Admins') {
                Add-RoleMember -Role $currentRole.Name -RoleMember 'Admins'
            }
            foreach ($roleMember in $currentRole.RoleMember) {
                if ($roleMember -eq 'Admins') { continue }
                if ($roleMember -in $configDatum.RoleMember) { continue }
                Remove-RoleMember -Role $configDatum.Name -RoleMember $roleMember
            }
            #endregion Sync Role Memberships
			
            #region Sync AD Memberships
            $resolvedDesired = foreach ($adMember in $configDatum.ADMembers) {
                # Include Original Name, so that we can use it as we Add-RoleMember it
                # Otherwise we would be forced to always use SID only, which is not as great from a readability perspective
                try {
                    & $rolesModule {
                        param ($adMember)
                        Resolve-ADEntity -Name $adMember -ErrorAction Stop
                    } $adMember | Add-Member -MemberType NoteProperty -Name OriginalName -Value $adMember -PassThru
                }
                catch { Stop-PSFFunction -String 'Import-ConfigRole.ADMember.ResolutionError' -StringValues $adMember -EnableException $true -ErrorRecord $_ -Cmdlet $PSCmdlet }
            }
            foreach ($desiredMember in $resolvedDesired) {
                if ($currentRole.ADMembers.SID -contains $desiredMember.SID) { continue }
                Add-RoleMember -Role $configDatum.Name -ADMember $desiredMember.OriginalName
            }
            foreach ($currentMember in $currentRole.ADMembers) {
                if ($currentMember.SID -in $resolvedDesired.SID) { continue }
                Remove-RoleMember -Role $configDatum.Name -ADMember $currentMember.SID
            }
            #endregion Sync AD Memberships
        }
        #endregion Process Configured Roles
		
        #region Cleanup Undesired Roles
        foreach ($role in $allRoles) {
            if ($definedRolesHash.ContainsKey($role.Name)) { continue }
            Invoke-PSFProtectedCommand -ActionString 'Import-ConfigRole.Remove.Role' -ActionStringValues $role.Name -Target $role -ScriptBlock {
                Remove-Role -Name $role.Name -ErrorAction Stop
            } -EnableException $false -PSCmdlet $PSCmdlet
        }
        #endregion Cleanup Undesired Roles
    }
}