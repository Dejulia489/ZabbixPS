Function Remove-ZabbixHost
{
	<# 
	.Synopsis
		Delete/Remove selected host
	.Description
		Delete/Remove selected host
	.Parameter HostID
		To filter by ID/IDs
	.Example 
		Remove-ZabbixHost -HostID (Get-ZabbixHost | ? name -match "RetiredHosts").hostid -WhatIf
		Remove host(s) by name match (case insensitive) (check only: -WhatIf)
     .Example 
		Remove-ZabbixHost -HostID (Get-ZabbixHost | ? name -match "RetiredHosts").hostid
		Remove host(s) by name match (case insensitive)
	.Example
		Remove-ZabbixHost -HostID "10001","10002" 
		Remove hosts by IDs
	.Example
		Remove-ZabbixHost -HostID (Get-ZabbixHost -HostName HostRetired).hostid
		Remove single host by name (exact match, case sensitive)
	.Example
		Get-ZabbixHost | ? name -eq HostName | Remove-ZabbixHost -WhatIf
		Remove hosts (check only: -WhatIf)
     .Example
		Get-ZabbixHost | ? name -eq HostName | Remove-ZabbixHost
		Remove host
	.Example
		Get-ZabbixHost | ? name -match HostName0[1-8] | Remove-ZabbixHost
		Remove multiple hosts 
	.Example
		Get-ZabbixHost | Remove-ZabbixHost
		Will delete ALL hosts from Zabbix 
	#>
	
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
	[Alias("Delete-ZabbixHost", "rzhst", "dzhst")]
	Param (
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$HostID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$Name,
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
			method  = "host.delete"
			params  = @($HostID)
			jsonrpc = $jsonrpc
			id      = $id
			auth    = $session
		}
		
		$BodyJSON = ConvertTo-Json $Body
		write-verbose $BodyJSON
		
		if ([bool]$WhatIfPreference.IsPresent) { }
		if ($PSCmdlet.ShouldProcess($Name, "Delete"))
		{  
			$a = Invoke-RestMethod "$URL/api_jsonrpc.php" -ContentType "application/json" -Body $BodyJSON -Method Post
		}
		
		if ($a.result) { $a.result } else { $a.error }
	}
}