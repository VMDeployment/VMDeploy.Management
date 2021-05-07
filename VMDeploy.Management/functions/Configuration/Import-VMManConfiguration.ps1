function Import-VMManConfiguration {
    <#
	.SYNOPSIS
		Imports the VMDeployment configuration from the defined source.
	
	.DESCRIPTION
		Imports the VMDeployment configuration from the defined source.
		Use Set-VMManConfigurationSource to define the configuration source.
	
		Role Prerequisite: ConfigOperators
	
	.EXAMPLE
		PS C:\> Import-VMManConfiguration
	
		Imports the VMDeployment configuration from the defined source.
#>
    [CmdletBinding()]
    param (
		
    )
	
    begin {
        Assert-Role -Role ConfigOperators -RemoteOnly -Cmdlet $PSCmdlet
    }
    process {
        #region Prepare Configuration import
        $contentPath = Get-PSFConfigValue -FullName 'VMDeploy.Management.ContentPath'
        $sourceFilePath = Join-Path -Path $contentPath -ChildPath source.cfg
        if (-not (Test-Path -Path $sourceFilePath)) {
            Stop-PSFFunction -String 'Import-VMManConfiguration.NoSource' -EnableException $true -Cmdlet $PSCmdlet -Category ObjectNotFound
        }
        Invoke-PSFProtectedCommand -ActionString 'Import-VMManConfiguration.Source.Config.Loading' -ActionStringValues $sourceFilePath -ScriptBlock {
            $sourceCfg = Import-PSFClixml -Path $sourceFilePath -ErrorAction Stop
        } -Target $sourceFilePath -EnableException $true -PSCmdlet $PSCmdlet
		
        $providerObject = Get-VMManConfigurationProvider -Name $sourceCfg.Provider
        $parameters = $sourceCfg.Parameters
        if (-not $parameters) { $parameters = @{ } }
		
        $tempFolder = Join-Path -Path (Get-PSFPath -Name Temp) -ChildPath "VMDeploy-$(Get-Random)"
        Invoke-PSFProtectedCommand -ActionString 'Import-VMManConfiguration.WorkingDirectory.Create' -ActionStringValues $tempFolder -ScriptBlock {
            $null = New-Item -Path $tempFolder -ItemType Directory -Force -ErrorAction Stop
        } -Target $tempFolder -EnableException $true -PSCmdlet $PSCmdlet
		
        $parameters.OutPath = $tempFolder
        #endregion Prepare Configuration import
		
        # Execute Configuration Provider
        Invoke-PSFProtectedCommand -ActionString 'Import-VMManConfiguration.ConfigurationProvider.Execute' -ActionStringValues $providerObject.Name -ScriptBlock {
            try { $null = & $providerObject.Code $parameters }
            catch {
                Remove-Item -Path $tempFolder -Recurse -Force -ErrorAction Ignore
                throw
            }
        } -Target $providerObject.Name -EnableException $true -PSCmdlet $PSCmdlet
        # Result: $tempFolder contains configuration data
		
        #region Validate & Import
        $testResults = foreach ($command in Get-Command -Name Test-Config* -Module VMDeploy.Management) {
            & $command -ImportRoot $tempFolder
        }
        if ($failedTests = $testResults | Where-Object Success -EQ $false) {
            $testResults | Out-Host
            Remove-Item -Path $tempFolder -Recurse -Force -ErrorAction Ignore
            Stop-PSFFunction -String 'Import-VMManConfiguration.Configuration.TestFailed' -StringValues @($failedTests).Count -EnableException $true -Category InvalidData -Cmdlet $PSCmdlet -Target $testResults
        }
		
        Import-ConfigRole -ImportRoot $tempFolder
        foreach ($command in Get-Command -Name Import-Config* -Module VMDeploy.Management) {
            if ($command.Name -eq 'Import-ConfigRole') { continue }
            & $command -ImportRoot $tempFolder
        }
        Remove-Item -Path $tempFolder -Recurse -Force -ErrorAction Ignore
        #endregion Validate & Import
    }
}
