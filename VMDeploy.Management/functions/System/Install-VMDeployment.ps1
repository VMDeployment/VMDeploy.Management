function Install-VMDeployment {
<#
	.SYNOPSIS
		Install the VMDeployment system.
	
	.DESCRIPTION
		Install the VMDeployment system.
		This executes all the preparatory steps to get the entire system operational.
	
		Specific steps:
		- Configure roles for core access
		- Prepare the path used by the JEA endpoint to store all operational data
		- Install the JEA endpoint configuration.
	
	.PARAMETER AdminPrincipal
		The core admin principal.
		This identity is granted membership in the Admins role.
		Defaults to the current user.
	
	.PARAMETER JeaGMSA
		The group Managed Service Account under which to operate the JEA endpoint.
	
	.PARAMETER JeaGroup
		The group allowed to connect to the VMDeployment JEA endpoint.
		Keep in mind, actual privileges within the system depends on Riles assigned, not membership in this group.

    .PARAMETER VmmServer
        The FQDN of the SCVMM Server to connect to.
	
	.EXAMPLE
		PS C:\> Install-VMDeployment -JeaGMSA 's_jeaVMDeploy$' -JeaGroup 'contoso\r-VMDeploy-Users' -VmmServer scvmm.contoso.com
	
		Set up all the prerequisites to operate the VMDeployment system on the local computer.
		Will set up the JEA endpoint to run under the account 's_jeaVMDeploy$' and grant access to connect to it to all members of 'contoso\r-VMDeploy-Users'.
		The current user will be added to the admins role and able to further configure the system for post-setup configuration.
#>
	[CmdletBinding(SupportsShouldProcess = $true)]
	param (
		[string]
		$AdminPrincipal = [System.Security.Principal.WindowsIdentity]::GetCurrent().User,
		
		[Parameter(Mandatory = $true)]
		[string]
		$JeaGMSA,
		
		[Parameter(Mandatory = $true)]
		[string]
		$JeaGroup,

        [Parameter(Mandatory = $true)]
		[string]
        $VmmServer
	)
	
	begin {
		$roles = Get-Module -Name Roles
		$resolveADEntityCommand = & $roles { Get-Command -Name Resolve-ADEntity }
		$gmsaSID = (& $resolveADEntityCommand -Name $JeaGMSA).SID -as [System.Security.Principal.SecurityIdentifier]
		if (-not $gmsaSID) { Stop-PSFFunction -String 'Install-VMDeployment.JeaGmsa.NotFound' -StringValues $JeaGMSA -EnableException $true -Cmdlet $PSCmdlet -Category ObjectNotFound }
	}
	process {
		Invoke-PSFProtectedCommand -ActionString 'Install-VMDeployment.Roles' -Target $env:COMPUTERNAME -ScriptBlock {
			Install-VmmRoles -AdminPrincipal $AdminPrincipal -GmsaSID $gmsaSID -ErrorAction Stop
		} -EnableException $true -PSCmdlet $PSCmdlet
		
		Invoke-PSFProtectedCommand -ActionString 'Install-VMDeployment.ContentPath' -ActionStringValues (Get-PSFConfigValue -FullName 'VMDeploy.Management.ContentPath') -Target $env:COMPUTERNAME -ScriptBlock {
			Install-VmmContentPath -GmsaSID $gmsaSID -ErrorAction Stop
		} -EnableException $true -PSCmdlet $PSCmdlet
		
		Invoke-PSFProtectedCommand -ActionString 'Install-VMDeployment.JeaEndpoint' -Target $env:COMPUTERNAME -ScriptBlock {
			Install-VmmJeaEndpoint -GmsaSID $gmsaSID -JeaGroup $JeaGroup -VmmServer $VmmServer -ErrorAction Stop
		} -EnableException $true -PSCmdlet $PSCmdlet
		
		Invoke-PSFProtectedCommand -ActionString 'Install-VMDeployment.RolesConfig' -Target $env:COMPUTERNAME -ScriptBlock {
			Set-PSFConfig -FullName Roles.Validation.SkipElevationTest -Value $true -PassThru -EnableException | Register-PSFConfig -Scope SystemDefault -ErrorAction Stop -EnableException
		} -EnableException $true -PSCmdlet $PSCmdlet
	}
}
