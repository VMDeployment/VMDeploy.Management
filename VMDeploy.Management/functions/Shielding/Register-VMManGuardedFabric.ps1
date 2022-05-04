function Register-VMManGuardedFabric {
	<#
	.SYNOPSIS
		Registers a new guarded fabric as a platform that may operate shielded VMs.
	
	.DESCRIPTION
		Registers a new guarded fabric as a platform that may operate shielded VMs.
		Only thus registered guarded fabrics can run any shielded VMs deployed via VMDeployment.
	
	.PARAMETER Name
		Name of the guarded fabric to deploy.
		Must be unique, may not be "owner"
		To register a shielding owner, see Set-VMManShieldingOwner.
	
	.PARAMETER HostName
		Name of the HGS to download its fabric config metadata from.
		May be either the DNS name or a full http/s link to the config file.
	
	.PARAMETER UseSSL
		Whether the download of the metadata file from HGS should use https.
		Only used when specifying a DNS name, ignored with a full link.
	
	.PARAMETER Path
		Path to the XML metadata/configuration file describing the guarded fabric to authorize operating shielded VMs.
		If running this command via JEA, keep in mind that the path must be visible to the service account running the endpoint, not the connected user.
	
	.PARAMETER Xml
		Full XML string with the metadata describing the guarded fabric to authorize operating shielded VMs.
	
	.PARAMETER AllowExpired
		Whether expired guarded fabric certificates are acceptable.
	
	.PARAMETER AllowUntrustedRoot
		Whether the guarded fabric certificate may be untrusted.

	.PARAMETER WhatIf
		If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.

	.PARAMETER Confirm
		If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.
	
	.EXAMPLE
		PS C:\> Register-VMManGuardedFabric -Name ContosoFabric -HostName hgs.contoso.com

		Registers the ContosoFabric guarded fabric, after downloading the metadata file from hgs.contoso.com
	#>
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
	[CmdletBinding(DefaultParameterSetName = 'Hostname', SupportsShouldProcess = $true)]
	param (
		[PsfValidateScript('VMDeploy.Management.NotOwner', ErrorString = 'VMDeploy.Management.Validate.NotOwner')]
		[Parameter(Mandatory = $true)]
		[string]
		$Name,

		[Parameter(Mandatory = $true, ParameterSetName = 'Hostname')]
		[string]
		$HostName,

		[Parameter(ParameterSetName = 'Hostname')]
		[switch]
		$UseSSL,

		[Parameter(Mandatory = $true, ParameterSetName = 'Path')]
		[PsfValidateScript('PSFramework.Validate.FSPath.File', ErrorString = 'PSFramework.Validate.FSPath.File')]
		[string]
		$Path,

		[Parameter(Mandatory = $true, ParameterSetName = 'Xml')]
		[string]
		$Xml,

		[switch]
		$AllowExpired,
		
		[switch]
		$AllowUntrustedRoot
	)

	begin {
		Assert-Role -Role Admins -RemoteOnly -Cmdlet $PSCmdlet

		Import-Module CimCmdlets -Scope Global
		Import-Module HgsClient -Scope Global
	}

	process {
		$existingGuardian = Get-HgsGuardian -Name $Name -ErrorAction SilentlyContinue
		if ($existingGuardian) {
			Stop-PSFFunction -String 'Register-VMManGuardedFabric.Exists' -StringValues $Name -EnableException $true -Category ResourceExists -Target $Name -Cmdlet $PSCmdlet
		}

		$guardianXml = $Xml
		if ($Path) {
			Invoke-PSFProtectedCommand -ActionString 'Register-VMManGuardedFabric.Reading.File' -ActionStringValues $Path -Target $Path -ScriptBlock {
				$guardianXml = (Get-Content -LiteralPath (Resolve-PSFPath -Path $Path) -ErrorAction Stop) -join "`n"
			} -EnableException $true -PSCmdlet $PSCmdlet
		}
		if ($HostName) {
			$uri = [uri]$HostName
			switch -Regex ($uri.Scheme) {
				'http|https' {
					$link = $HostName
				}
				default {
					$link = "http://$HostName/KeyProtection/service/metadata/2014-07/metadata.xml"
					if ($UseSSL) { $link = "https://$HostName/KeyProtection/service/metadata/2014-07/metadata.xml" }
				}
			}
			$webClient = [System.Net.WebClient]::new()
			$webClient.Encoding = [System.Text.Encoding]::UTF8
			Invoke-PSFProtectedCommand -ActionString 'Register-VMManGuardedFabric.Reading.Uri' -ActionStringValues $link -Target $link -ScriptBlock {
				$guardianXml = $webClient.DownloadString($link)
			} -EnableException $true -PSCmdlet $PSCmdlet
		}
		$tempFilePath = Join-Path -Path (Get-PSFPath -Name temp) -ChildPath "guardian-$(Get-Random).xml"
		$guardianXml | Set-Content -Path $tempFilePath
		$param = $PSBoundParameters | ConvertTo-PSFHashtable -Include Name, AllowExpired, AllowUntrustedRoot
		Invoke-PSFProtectedCommand -ActionString 'Register-VMManGuardedFabric.Importing' -Target $tempFilePath -ScriptBlock {
			Import-HgsGuardian @param -Path $tempFilePath -ErrorAction Stop
		} -EnableException $true -PSCmdlet $PSCmdlet
		Remove-Item -Path $tempFilePath -Force -ErrorAction Ignore
	}
}