# This is where the strings go, that are written by
# Write-PSFMessage, Stop-PSFFunction or the PSFramework validation scriptblocks
@{
	'Import-ConfigRole.Starting'                              = 'Importing roles: {0} defined roles, {1} currently existing roles' # @($configData).Count, @($allRoles).Count
	'Import-ConfigRole.ADMember.ResolutionError'              = 'Failed to resolve AD Identity: {0}' # $adMember
	'Import-ConfigRole.Remove.Role'                           = 'Removing role: {0} (no longer required)' # $role.Name
	
	'Import-VMManConfiguration.Configuration.TestFailed'      = 'Configuration validation failed in {0} instance(s). Skipping configuration import.' # @($failedTests).Count
	'Import-VMManConfiguration.ConfigurationProvider.Execute' = 'Importing configuration from source type {0}' # $providerObject.Name
	'Import-VMManConfiguration.NoSource'                      = 'No configuration source defined yet! Run Set-VMManConfigurationSource to define from where to load the configuration data!' # 
	'Import-VMManConfiguration.Source.Config.Loading'         = 'Reading the configuration file from {0}' # $sourceFilePath
	'Import-VMManConfiguration.WorkingDirectory.Create'       = 'Creating temporary work folder in {0}' # $tempFolder
	
	'Install-VMDeployment.ContentPath'                        = 'Setting up the content path from which VMDeployment will operate in {0}' # (Get-PSFConfigValue -FullName 'VMDeploy.Management.ContentPath')
	'Install-VMDeployment.JeaEndpoint'                        = 'Setting up the JEA Endpoint used to operate VMDeployment from' # 
	'Install-VMDeployment.JeaGmsa.NotFound'                   = 'Unable to resolve the group Managed Service Account under which the JEA endpoint operating VMDeployment is intended to run.' # $JeaGMSA
	'Install-VMDeployment.RepositoryConfig'                   = 'Configuring the repository to use for downloading PowerShell modules.' #
	'Install-VMDeployment.Roles'                              = 'Setting up initial roles for VMDeployment.' # 
	'Install-VMDeployment.RolesConfig'                        = 'Configuring the Roles module to ignore the elevation validation' # 
	
	'Install-VmmJeaEndpoint.Error.CopyJeaEndpoint'            = 'Failed to copy the JEA Endpoint to program files' # 
	'Install-VmmJeaEndpoint.Error.GmsaSidTranslation'         = 'Failed to translate SID of gMSA {0}' # $GmsaSID
	'Install-VmmJeaEndpoint.Error.InsertGmsaName'             = 'Failed to modify the session configuration file, adding the gMSA {0}' # $gmsaNT
	'Install-VmmJeaEndpoint.Error.RegisterScvmm'              = 'Failed to register SCVMM Server name "{0}" in configuration' # $VmmServer
	'Install-VmmJeaEndpoint.Error.RegisterJeaEndpoint'        = 'Failed to register the JEA endpoint as a PowerShell Session Configuration' # 
	
	'Register-VMManRepository.Registering'                    = 'Registering the PowerShell repository {0} in {1}' # $Name, $Location
	'Register-VMManRepository.Config'                         = 'Configuring the repository {0} as the repository to use when updating the modules provided to the guest configturation' # $Name
	'Register-VMManRepository.Unregistering'                  = 'Removing the previously configured {0} repository before registering the new one.' # $Name
	
	'Set-VMManConfigurationSource.Parameters.Invalid'         = 'Invalid Parameters provided: THe configuration provider {0} does not understand "{1}". Legal parameters: "{2}"' # $ProviderName, ($badParameterNames -join ","), ($providerObject.Parameters -join ",")
	'Set-VMManConfigurationSource.Updating'                   = 'Setting configuration source to use {0} with the following parameters specified: {1}' # $ProviderName, ($Parameters.Keys -join ",")
	
	'Test-ConfigRole.Reading.ConfigError'                     = 'Invalid Configuration - {0} errors found.' # @($findings).Count
	'Test-ConfigRole.Reading.Error'                           = 'Error accessing config data' # 
	'Test-ConfigRole.Reading.NoData'                          = 'No configuration data found' # 


	'Validate.NotOwner'                                       = 'A guarded fabric cannot be labeled "Owner"'
}