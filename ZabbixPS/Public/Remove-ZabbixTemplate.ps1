Function Remove-ZabbixTemplate
{
	<# 
	.Synopsis
		Remove template
	.Description
		Remove template
	.Example
		Get-ZabbixTemplate | ? name -match templateName | Remove-ZabbixTemplate
		Remove template
	.Example
		gzt | ? name -match templateName | Remove-ZabbixTemplate
		Remove templates
	#>
    
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
	[Alias("rzt", "dzt", "Delete-ZabbixTemplate")]
	Param (
		[Alias("Name")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$TemplateName,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$TemplateID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$HostID,
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
			method  = "template.delete"
			params  = @($TemplateID)
			
			jsonrpc = $jsonrpc
			id      = $id
			auth    = $session
		}

		$BodyJSON = ConvertTo-Json $Body
		write-verbose $BodyJSON
		
		if ([bool]$WhatIfPreference.IsPresent) { }
		if ($PSCmdlet.ShouldProcess($TemplateName, "Delete"))
		{  
			$a = Invoke-RestMethod "$URL/api_jsonrpc.php" -ContentType "application/json" -Body $BodyJSON -Method Post
		}
		
		#$a.result | Select-Object Name,TemplateID,@{Name="HostsMembers";Expression={$_.hosts.hostid}}
		if ($a.result) { $a.result } else { $a.error }
	}
}

