function Set-VMManShieldingOwner {
	<#
	.SYNOPSIS
		Configures the owner to use when generating shielding data.
	
	.DESCRIPTION
		Configures the owner to use when generating shielding data.
		The certificates used/generated here will always be able to decrypt the shielding data.
	
	.PARAMETER GenerateCertificates
		Generate the certificates to use for decrypting shielding data.
		The certificates will be stored in the local machine certificate store.
	
	.PARAMETER SigningCertificateThumbprint
		The thumbprint of the certificate to use to sign the shielding data.
		The certificate must be installed on the VMDeploy machine separately.
	
	.PARAMETER EncryptionCertificateThumbprint
		The thumbprint of the certificate to use to encrypt the shielding data.
		The certificate must be installed on the VMDeploy machine separately.
	
	.PARAMETER AllowExpired
		Whether expired certificates may be used as owner.
	
	.PARAMETER AllowUntrustedRoot
		Whether untrusted certificates may be used as owner.
	
	.EXAMPLE
		PS C:\> Set-VMManShieldingOwner -GenerateCertificates
		
		Creates a new shielding owner with self-created certificates.
	#>
	[CmdletBinding(DefaultParameterSetName = 'Thumbprint')]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = 'Generate')]
		[switch]
		$GenerateCertificates,

		[Parameter(Mandatory = $true, ParameterSetName = 'Thumbprint')]
		[string]
		$SigningCertificateThumbprint,

		[Parameter(Mandatory = $true, ParameterSetName = 'Thumbprint')]
		[string]
		$EncryptionCertificateThumbprint,

		[switch]
		$AllowExpired,

		[switch]
		$AllowUntrustedRoot
	)
	begin {
		Assert-Role -Role Admins -RemoteOnly -Cmdlet $PSCmdlet
		
		Import-Module HgsClient -Scope Global
	}
	process {
		Invoke-PSFProtectedCommand -ActionString 'Set-VMManShieldingOwner.RemovingPrevious' -Target Owner -ScriptBlock {
			Remove-HgsGuardian -Name Owner -ErrorAction SilentlyContinue
		} -EnableException $true -PSCmdlet $PSCmdlet
	
		$parameters = $PSBoundParameters | ConvertTo-PSFHashtable -Include GenerateCertificates, SigningCertificateThumbprint, EncryptionCertificateThumbprint, AllowExpired, AllowUntrustedRoot
	
		Invoke-PSFProtectedCommand -ActionString 'Set-VMManShieldingOwner.Applying' -Target Owner -ScriptBlock {
			New-HgsGuardian -Name Owner @parameters -ErrorAction Stop
		} -EnableException $true -PSCmdlet $PSCmdlet
	}
}