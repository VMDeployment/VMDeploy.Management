function Install-VmmJeaEndpoint
{
<#
	.SYNOPSIS
		Deploys and registers the JEA endpoint used to connect to the VMDeployment service.
	
	.DESCRIPTION
		Deploys and registers the JEA endpoint used to connect to the VMDeployment service.
	
	.PARAMETER GmsaSID
		SID of the gMSA being used to operate the JEA endpoint.
	
	.PARAMETER JeaGroup
		The group allowed to connect to the JEA Endpoint.
		This can be a permissive group, as the actual permissions are distributed via Roles (from configuration).

    .PARAMETER VmmServer
        The FQDN of the SCVMM Server to connect to.
	
	.EXAMPLE
		PS C:\> Install-VmmJeaEndpoint -GmsaSID $gmsaSID -JeaGroup $JeaGroup -VmmServer $VmmServer
	
		Installs the JEA endpoint under $gmsaSID, granting permission to connect to $JeaGroup
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$GmsaSID,
		
		[Parameter(Mandatory = $true)]
		[string]
		$JeaGroup,

        [Parameter(Mandatory = $true)]
		[string]
        $VmmServer
	)
	
	process
	{
		try { $gmsaNT = ([System.Security.Principal.SecurityIdentifier]$GmsaSID).Translate([System.Security.Principal.NTAccount]) }
		catch {
			Write-PSFMessage -Level Warning -String 'Install-VmmJeaEndpoint.Error.GmsaSidTranslation' -StringValues $GmsaSID -ErrorRecord $_
			throw
		}
		
		Remove-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\JEA_VMDeployment' -Force -Recurse -ErrorAction Ignore
		
		try { Copy-Item -Path "$script:ModuleRoot\jea\JEA_VMDeployment" -Destination 'C:\Program Files\WindowsPowerShell\Modules' -Recurse -Force -ErrorAction Stop }
		catch {
			Write-PSFMessage -Level Warning -String 'Install-VmmJeaEndpoint.Error.CopyJeaEndpoint' -ErrorRecord $_
			throw
		}
		
		$encoding = [System.Text.UTF8Encoding]::new($true)
		try {
			$filePath = Join-Path -Path 'C:\Program Files\WindowsPowerShell\Modules' -ChildPath 'JEA_VMDeployment\1.0.0\sessionconfiguration.pssc'
			$text = [System.IO.File]::ReadAllText($filePath, $encoding)
			$text = $text -replace 'þnameþ', ("$gmsaNT".TrimEnd('$')) -replace 'þroleþ', $JeaGroup
			[System.IO.File]::WriteAllText($filePath, $text, $encoding)
		}
		catch {
			Write-PSFMessage -Level Warning -String 'Install-VmmJeaEndpoint.Error.InsertGmsaName' -StringValues $gmsaNT -ErrorRecord $_
			throw
		}

        try { Set-PSFConfig -FullName 'VMDeployment.SCVMM.Server' -Value $VmmServer -PassThru -EnableException | Register-PSFConfig -Scope SystemDefault -EnableException }
        catch {
            Write-PSFMessage -Level Warning -String 'Install-VmmJeaEndpoint.Error.RegisterScvmm' -ErrorRecord $_
			throw
        }
		
		try { $null = Register-JeaEndpoint_JEA_VMDeployment -ErrorAction Stop }
		catch {
			Write-PSFMessage -Level Warning -String 'Install-VmmJeaEndpoint.Error.RegisterJeaEndpoint' -ErrorRecord $_
			throw
		}
	}
}