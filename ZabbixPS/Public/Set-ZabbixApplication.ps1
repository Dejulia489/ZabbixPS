Function Set-ZabbixApplication
{
	<# 
	.Synopsis
		Set/Update application
	.Description
		Set/Update application
	.Example
		Get-ZabbixTemplate | ? name -match "templateName" | Get-ZabbixApplication | ? name -match appName | Set-ZabbixApplication -Name newAppName
		Rename application in the template
	#>
    
	[CmdletBinding()]
	[Alias("szapp")]
	Param (
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$Name,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$applicationid,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$HostID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$TemplateID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$jsonrpc = ($global:zabSessionParams.jsonrpc),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$session = ($global:zabSessionParams.session),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$id = ($global:zabSessionParams.id),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$URL = ($global:zabSessionParams.url)
	)
    
	process
 {

		if (!(Get-ZabbixSession)) { return }
		elseif (!$psboundparameters.count) { Write-MissingParamsMessage; return }

		$boundparams = $PSBoundParameters | out-string
		write-verbose "($boundparams)"
		
		$Body = @{
			method  = "application.update"
			params  = @{
				applicationid = $applicationid
				name          = $Name
				# hostid = $HostID
				# templateids = $TemplateID
			}

			jsonrpc = $jsonrpc
			id      = $id
			auth    = $session
		}

		$BodyJSON = ConvertTo-Json $Body
		write-verbose $BodyJSON
		
		$a = Invoke-RestMethod "$URL/api_jsonrpc.php" -ContentType "application/json" -Body $BodyJSON -Method Post
		if ($a.result) { $a.result } else { $a.error }
	}
}

