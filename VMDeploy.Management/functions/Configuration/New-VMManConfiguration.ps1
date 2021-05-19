function New-VMManConfiguration {
    <#
    .SYNOPSIS
        Create a new configuration set folder structure
    
    .DESCRIPTION
        Create a new configuration set folder structure
    
    .PARAMETER Path
        The folder in which to create the configuration set.
    
    .EXAMPLE
        PS C:\> New-VMManConfiguration -Path .
        
        Creates a new configuration set in the current folder
    #>
    [CmdletBinding()]
    param (
        [PsfValidateScript('PSFramework.Validate.FSPath.Folder', ErrorString = 'PSFramework.Validate.FSPath.Folder')]
        [Parameter(Mandatory = $true)]
        [string]
        $Path
    )

    Copy-Item -Path "$script:ModuleRoot\internal\data\Configuration\*" -Destination $Path -Recurse -Force
}