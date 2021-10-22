function Get-VMManConfiguration {
    <#
    .SYNOPSIS
        Read the deployed configuration of the VMDeployment system.
    
    .DESCRIPTION
        Read the deployed configuration of the VMDeployment system.
        This specifically includes all the resource lists and role mappings.
    
    .PARAMETER Type
        The type of configuration to retrieve.
    
    .EXAMPLE
        PS C:\> Get-VMManConfiguration -Type Cloud

        Returns the current scvmm cloud configuration.
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ConfigType[]]
        $Type
    )
	
    begin {
        $contentPath = Get-PSFConfigValue -FullName 'VMDeploy.Management.ContentPath'
    }
    process {
        foreach ($typeName in $Type) {
            $configFile = Join-Path -Path $contentPath -ChildPath "$typeName.clidat"
            Import-PSFClixml -Path $configFile -ErrorAction SilentlyContinue
        }
    }
}