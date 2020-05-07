Function Remove-ZabbixApplication
{
	<# 
	.Synopsis
		Remove/Delete applications
	.Description
		Remove/Delete applications
	.Example
		Get-ZabbixTemplate | ? name -match "templateName" | Get-ZabbixApplication | ? name -match "appName" | Delete-ZabbixApplication
		Delete application from the template
	#>
    
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
	[Alias("Delete-ZabbixApplication", "rzapp")]
	Param (
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$Name,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$applicationId,
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
			method  = "application.delete"
			params  = @($applicationId)

			jsonrpc = $jsonrpc
			id      = $id
			auth    = $session
		}

		$BodyJSON = ConvertTo-Json $Body
		write-verbose $BodyJSON
		
		if ([bool]$WhatIfPreference.IsPresent) { }
		if ($PSCmdlet.ShouldProcess("$($Name+"@"+(Get-ZabbixApplication | ? name -eq "$Name" | ? hostid -eq $HostID).host.host)", "Delete"))
		{  
			$a = Invoke-RestMethod "$URL/api_jsonrpc.php" -ContentType "application/json" -Body $BodyJSON -Method Post
		}

		if ($a.result) { $a.result } else { $a.error }
	}
}
