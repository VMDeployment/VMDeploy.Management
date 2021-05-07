function Read-ConfigGeneric {
    <#
        .SYNOPSIS
            Read the specified config type into memory.
        
        .DESCRIPTION
            Read the specified config type into memory.
        
        .PARAMETER ImportRoot
            The root folder under which all configuraion to import is stored.
        
        .EXAMPLE
            PS C:\> Read-ConfigCloud -ImportRoot $tempFolder -Type Cloud
        
            Reads the specified config type into memory.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $ImportRoot,

        [ConfigType]
        $Type
    )
        
    begin {
        Assert-Role -Role ConfigOperators -RemoteOnly -Cmdlet $PSCmdlet
    }
    process {
        $configRootFolder = Join-Path -Path $ImportRoot -ChildPath $Type
        if (-not (Test-Path -Path $configRootFolder)) { return }
            
        foreach ($file in Get-ChildItem -Path $configRootFolder -Filter *.psd1 -Recurse -File) {
            try {
                foreach ($datum in Import-PSFPowerShellDataFile -Path $file.FullName -ErrorAction Stop) {
                    if ($datum -is [hashtable]) {
                        $datum.ConfigType = $Type
                        [PSCustomObject]$datum
                    }
                    else {
                        $datum | Add-Member -MemberType NoteProperty -Name ConfigType -Value $Type -Force -PassThru
                    }
                }
            }
            catch { throw "Error reading file: $($file.Name) : $_" }
        }
    }
}