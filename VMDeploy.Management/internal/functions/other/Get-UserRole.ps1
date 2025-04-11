function Get-UserRole {
    <#
    .SYNOPSIS
        Return the list of roles the current user is a member in.
    
    .DESCRIPTION
        Return the list of roles the current user is a member in.
    
    .PARAMETER NoCache
        Disable caching and reload the role membership list from file.
        By default, this list will be cached the first time and read from memory afterwrads for performance reasons.
        It should however be refreshed before actually deploying something.
    
    .EXAMPLE
        PS C:\> Get-UserRole

        Get list of role names the user is a member in.
    #>
    [CmdletBinding()]
    param (
        [switch]
        $NoCache
    )

    if ($NoCache -or -not $script:currentUserRoles) {
        $script:currentUserRoles = (Get-Role | Where-Object { Test-RoleMembership -Role $_.Name }).Name
    }
    $script:currentUserRoles
}