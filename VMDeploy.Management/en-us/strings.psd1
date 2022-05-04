# This is where the strings go, that are written by
# Write-PSFMessage, Stop-PSFFunction or the PSFramework validation scriptblocks
@{
	'Get-VMManShieldingOwner.NoOwner'                         = 'No onwer information registered yet! Use Set-VMManShieldingOwner to define an owner (requires admin role).' # 

	'Import-ConfigRole.ADMember.ResolutionError'              = 'Failed to resolve AD Identity: {0}' # $adMember
	'Import-ConfigRole.Remove.Role'                           = 'Removing role: {0} (no longer required)' # $role.Name
	'Import-ConfigRole.Starting'                              = 'Importing roles: {0} defined roles, {1} currently existing roles' # @($configData).Count, @($allRoles).Count
	
	'Import-ConfigShieldingUnattendFile.File.Missing'         = 'No matching unattend file found for the configuration: {0}' # $datum.Name
	
	'Import-VMManConfiguration.Configuration.TestFailed'      = 'Configuration validation failed in {0} instance(s). Skipping configuration import.' # @($failedTests).Count
	'Import-VMManConfiguration.ConfigurationProvider.Execute' = 'Importing configuration from source type {0}' # $providerObject.Name
	'Import-VMManConfiguration.NoSource'                      = 'No configuration source defined yet! Run Set-VMManConfigurationSource to define from where to load the configuration data!' # 
	'Import-VMManConfiguration.Source.Config.Loading'         = 'Reading the configuration file from {0}' # $sourceFilePath
	'Import-VMManConfiguration.WorkingDirectory.Create'       = 'Creating temporary work folder in {0}' # $tempFolder
	
	'Install-VMDeployment.ContentPath'                        = 'Setting up the content path from which VMDeployment will operate in {0}' # (Get-PSFConfigValue -FullName 'VMDeploy.Management.ContentPath')
	'Install-VMDeployment.Feature'                            = 'Installing the required windows features' # 
	'Install-VMDeployment.JeaEndpoint'                        = 'Setting up the JEA Endpoint used to operate VMDeployment from' # 
	'Install-VMDeployment.JeaGmsa.NotFound'                   = 'Unable to resolve the group Managed Service Account under which the JEA endpoint operating VMDeployment is intended to run.' # $JeaGMSA
	'Install-VMDeployment.LibraryShare'                       = 'Registering the System Center: Virtual Machine Manager library share to use for the process.' # 
	'Install-VMDeployment.RepositoryConfig'                   = 'Configuring the repository to use for downloading PowerShell modules.' # 
	'Install-VMDeployment.Roles'                              = 'Setting up initial roles for VMDeployment.' # 
	'Install-VMDeployment.RolesConfig'                        = 'Configuring the Roles module to ignore the elevation validation' # 
	
	'Install-VmmJeaEndpoint.Error.CopyJeaEndpoint'            = 'Failed to copy the JEA Endpoint to program files' # 
	'Install-VmmJeaEndpoint.Error.GmsaSidTranslation'         = 'Failed to translate SID of gMSA {0}' # $GmsaSID
	'Install-VmmJeaEndpoint.Error.InsertGmsaName'             = 'Failed to modify the session configuration file, adding the gMSA {0}' # $gmsaNT
	'Install-VmmJeaEndpoint.Error.RegisterJeaEndpoint'        = 'Failed to register the JEA endpoint as a PowerShell Session Configuration' # 
	'Install-VmmJeaEndpoint.Error.RegisterScvmm'              = 'Failed to register SCVMM Server name "{0}" in configuration' # 
	
	'Install-VmmServerFeature.Installing'                     = 'Installing Windows Feature: {0}' # $feature
	'Install-VmmServerFeature.Installing.Failed'              = 'Failed to install the Windows Feature: {0}' # $feature
	'Install-VmmServerFeature.Installing.NotSuccessful'       = 'Installation of the Windows Feature: {0} was not successful. {1}' # $feature, $result.ExitCode
	
	'Validate.NotOwner'                                       = 'The name "owner" is reserved and cannot be used for guarded fabrics.' # <user input>, <validation item>
	
	'Register-VMManGuardedFabric.Exists'                      = 'The guarded fabric {0} exists already and cannot be registered. Use Unregister-VMManGuardedFabric to remove the current guarded fabric of that name.' # $Name
	'Register-VMManGuardedFabric.Importing'                   = 'Importing the guarded fabric configuration' # 
	'Register-VMManGuardedFabric.Reading.File'                = 'Reading the guarded fabric metadata from file: {0}' # 
	'Register-VMManGuardedFabric.Reading.Uri'                 = 'Downloading the guarded fabric metadata from a weblink: {0}' # 
	
	'Register-VMManRepository.Config'                         = 'Configuring the repository {0} as the repository to use when updating the modules provided to the guest configturation' # $Name
	'Register-VMManRepository.Registering'                    = 'Registering the PowerShell repository {0} in {1}' # $Name, $Location
	'Register-VMManRepository.Unregistering'                  = 'Removing the previously configured {0} repository before registering the new one.' # $Name
	
	'Set-VMManConfigurationSource.Parameters.Invalid'         = 'Invalid Parameters provided: THe configuration provider {0} does not understand "{1}". Legal parameters: "{2}"' # $ProviderName, ($badParameterNames -join ","), ($providerObject.Parameters -join ",")
	'Set-VMManConfigurationSource.Updating'                   = 'Setting configuration source to use {0} with the following parameters specified: {1}' # $ProviderName, ($Parameters.Keys -join ",")
	
	'Set-VMManShieldingOwner.Applying'                        = 'Applying new shielding owner' # 
	'Set-VMManShieldingOwner.RemovingPrevious'                = 'Removing previous shielding owner' # 
	
	'Test-ConfigRole.Reading.ConfigError'                     = 'Invalid Configuration - {0} errors found.' # @($findings).Count
	'Test-ConfigRole.Reading.Error'                           = 'Error accessing config data' # 
	'Test-ConfigRole.Reading.NoData'                          = 'No configuration data found' # 
	
	'Unregister-VMManGuardedFabric.Removing'                  = 'Unregistering / removing guarded fabric: {0}' # $guardianName
}