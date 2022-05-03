function Import-ConfigShieldingUnattendFile {
	<#
    .SYNOPSIS
        Import configured unattend files for shielding and their associated roles.
    
    .DESCRIPTION
        Import configured unattend files for shielding and their associated roles.
    
    .PARAMETER ImportRoot
        The root folder under which all configuraion to import is stored.
    
    .EXAMPLE
        PS C:\> Import-ConfigShieldingUnattendFile -ImportRoot $importRoot

        Imports all configured unattend files for shielding under the defined import root path.
    #>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$ImportRoot
	)
	
	begin {
		Assert-Role -Role ConfigOperators -RemoteOnly -Cmdlet $PSCmdlet
	}
	process {
		# Import defined configuration data
		$configData = Read-ConfigGeneric -ImportRoot $ImportRoot -Type ShieldingUnattend -ErrorAction Stop
		
		#region Copy Unattend XML files
		$contentPath = Get-PSFConfigValue -FullName 'VMDeploy.Management.ContentPath'
		$unattendFolder = Join-Path -Path $contentPath -ChildPath ShieldingUnattend
		If (-not (Test-Path -Path $unattendFolder)) {
			$null = New-Item -Path $unattendFolder -ItemType Directory -Force
		}
		Remove-Item -Path "$unattendFolder\*" -ErrorAction Ignore

		$sourceFolder = Join-Path -Path $ImportRoot -ChildPath ShieldingUnattend
		if (Test-Path -Path $sourceFolder) {
			foreach ($file in Get-ChildItem -Path $sourceFolder -Recurse -File -Filter *.xml) {
				Copy-Item -LiteralPath $file.FullName -Destination $unattendFolder -Force
			}
		}
		$unattendFiles = Get-ChildItem -Path $unattendFolder
		#endregion Copy Unattend XML files

		#region Process Configuration Files
		foreach ($datum in $configData) {
			$unattendFile = $null
			# Match by FileName, then by Name if not defined
			if ($datum.FileName) { $unattendFile = $unattendFiles | Where-Object Name -EQ $datum.FileName }
			else { $unattendFile = $unattendFiles | Where-Object BaseName -EQ $datum.Name }
			# Custom Implementation for the builtin default empty template
			if (-not $unattendFile -and $datum.Name -eq 'empty') { $unattendFile = Get-Item "$script:ModuleRoot\internal\data\unattendfiles\empty.xml" }
			if (-not $unattendFile) {
				Write-PSFMessage -Level Warning -String 'Import-ConfigShieldingUnattendFile.File.Missing' -StringValues $datum.Name
				continue
			}
			Add-Member -InputObject $datum -MemberType NoteProperty -Name FileName -Value $unattendFile.Name -Force
			Add-Member -InputObject $datum -MemberType NoteProperty -Name FilePath -Value $unattendFile.FullName -Force
		}
		#endregion Process Configuration Files
		
		#region Process Unattend Files without configuration
		$configFromFile = foreach ($unattendFile in $unattendFiles) {
			if ($configData.FilePath -contains $unattendFile.FullName) { continue }
			[PSCustomObject]@{
				ConfigType = 'ShieldingUnattend'
				Name       = $unattendFile.BaseName
				FileName   = $unattendFile.Name
				FilePath   = $unattendFile.FullName
				Role       = 'Admins'
			}
		}
		#endregion Process Unattend Files without configuration

		$configData = @($configData) + @($configFromFile) | Remove-PSFNull | Where-Object FilePath
		#region Process Default Empty Unattend File (if not defined)
		if ($configData.Name -notcontains 'empty') {
			$unattendFile = Get-Item "$script:ModuleRoot\internal\data\unattendfiles\empty.xml" 
			$configData = @($configData) + @([PSCustomObject]@{
				ConfigType = 'ShieldingUnattend'
				Name       = $unattendFile.BaseName
				FileName   = $unattendFile.Name
				FilePath   = $unattendFile.FullName
				Role       = 'Admins'
			})
		}
		#endregion Process Default Empty Unattend File (if not defined)
		
		$configFile = Join-Path -Path $contentPath -ChildPath 'ShieldingUnattend.clidat'
		$configData | Export-PSFClixml -Path $configFile
	}
}