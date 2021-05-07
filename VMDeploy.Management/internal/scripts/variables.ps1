# Store for configuration providers
$script:configurationSources = @{ }

# The global roles definition needed for VMDeployment
$script:rolesIndex = @{
	'Admins' = 'Global VMDeployment Administrators, can do everything'
	'ConfigOperators' = 'Can trigger configuration resyncs and check configuration status'
}