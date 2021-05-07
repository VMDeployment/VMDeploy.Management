function Test-ConfigRole {
<#
	.SYNOPSIS
		Test whether the configured roles are valid.
	
	.DESCRIPTION
		Test whether the configured roles are valid.
	
	.PARAMETER ImportRoot
		The root folder under which all configuraion to import is stored.
	
	.EXAMPLE
		PS C:\> Test-ConfigRole -ImportRoot $tempFolder
	
		Test whether the configured roles are valid.
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$ImportRoot
	)
	
	begin {
		Assert-Role -Role ConfigOperators -RemoteOnly -Cmdlet $PSCmdlet
		
		#region Utility Functions
		function New-Finding {
			[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
			[CmdletBinding()]
			param (
				[string]
				$Type,
				
				[string]
				$Message,
				
				$Datum
			)
			[PSCustomObject][ordered]@{
				Type = $Type
				Message = $Message
				Datum = $Datum
			}
		}
		#endregion Utility Functions
		
		$rolesModule = Get-Module -Name Roles
	}
	process {
		try { $configData = Read-ConfigGeneric -ImportRoot $ImportRoot -Type Roles -ErrorAction Stop }
		catch {
			Write-PSFMessage -Level Warning -String 'Test-ConfigRole.Reading.Error' -ErrorRecord $_ -Tag test, read, error
			New-TestResult -Name Roles -Success $false -Message 'Error accessing config data' -Data $_
			return
		}
		
		if (-not $configData) {
			Write-PSFMessage -Level Warning -String 'Test-ConfigRole.Reading.NoData' -Tag test, read, error
			New-TestResult -Name Roles -Success $false -Message 'No configuration data found'
			return
		}
		
		$configDefined = $script:rolesIndex.Clone()
		$configUsed = @{ }
		$findings = foreach ($configDatum in $configData) {
			if (-not $configDatum.Name) {
				New-Finding -Type 'Bad Data' -Message 'Entry contains no Name property' -Datum $configDatum
				continue
			}
			if ($configDatum.Name -notin $script:rolesIndex.Keys -and -not $configDatum.Description) {
				New-Finding -Type 'Bad Data' -Message "New Role $($configDatum.Name) must also contain a description!" -Datum $configDatum
				continue
			}
			$configDefined[$configDatum.Name] = $true
			foreach ($roleName in $configDatum.RoleMember) {
				$configUsed[$roleName] = $true
			}
			foreach ($adMember in $configDatum.ADMember) {
				try {
					& $rolesModule {
						param ($adMember)
						$null = Resolve-ADEntity -Name $adMember -ErrorAction Stop
					} $adMember
				}
				catch { New-Finding -Type 'Unresolved Member' -Message "Unable to resolve AD Member $adMember for Role $($configDatum.Name)" -Datum $configDatum }
			}
		}
		$unknownRoles = $configUsed.Keys | Where-Object { $_ -notin $configDefined.Keys }
		if ($unknownRoles) {
			$findings = @($findings) + @(New-Finding -Type 'Unknown Role' -Message "Referencing roles as members that do not exist: $($unknownRoles -join ", ")")
		}
		
		if ($findings) {
			Write-PSFMessage -Level Warning -String 'Test-ConfigRole.Reading.ConfigError' -StringValues @($findings).Count -Tag test, parse, data
			New-TestResult -Name Roles -Success $false -Message "Invalid Configuration - $(@($findings).Count) errors found. See Data for details." -Data $findings
			return
		}
		New-TestResult -Name Roles -Success $true -Message 'All is well'
	}
}