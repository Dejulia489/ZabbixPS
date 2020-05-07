Function Remove-ZabbixHostInterface
{ 
	<#
	.Synopsis
		Remove host interface
	.Description
		Remove host interface
	.Example
		Get-ZabbixHost | ? name -match "host02" | Get-ZabbixHostInterface | ? port -Match 31021 | Remove-ZabbixHostInterface
		Remove single host interface
	.Example	
		Remove-ZabbixHostInterface -interfaceid (Get-ZabbixHost | ? name -match "host02" | Get-ZabbixHostInterface).interfaceid
		Remove all interfaces from host
	.Example	
		Get-ZabbixHost | ? name -match hostName | ? name -notmatch otherHostName | Get-ZabbixHostInterface | ? port -match 31021 | Remove-ZabbixHostInterface
		Remove interfaces by port
	#>
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
	[Alias("rzhsti")]
	Param (
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$HostID,
		[Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)][array]$InterfaceId,
		[Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)][string]$Port,
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
			method  = "hostinterface.delete"
			params  = @($interfaceid)

			jsonrpc = $jsonrpc
			id      = $id
			auth    = $session
		}
		
		$BodyJSON = ConvertTo-Json $Body
		write-verbose $BodyJSON
		
		if ([bool]$WhatIfPreference.IsPresent) { }
		if ($PSCmdlet.ShouldProcess($Port, "Delete"))
		{  
			$a = Invoke-RestMethod "$URL/api_jsonrpc.php" -ContentType "application/json" -Body $BodyJSON -Method Post
		}
		
		if ($a.result) { $a.result } else { $a.error }
	}
}

