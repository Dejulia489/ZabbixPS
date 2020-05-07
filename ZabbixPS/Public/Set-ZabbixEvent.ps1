Function Set-ZabbixEvent
{ 
	<#
	.Synopsis
		Set events
	.Example
		Get-ZabbixEvent -EventID 445749 | Set-ZabbixEvent -ackMessage "TKT-2516: Resolved"
		Acknowledge event
	.Example
		Get-ZabbixEvent -TimeFrom (convertTo-epoch (get-date).addhours(-5)) -TimeTill (convertTo-epoch (get-date).addhours(0)) | ? alerts | ? {$_.hosts.name -match "web" } | select eventid,@{n="Time UTC+2";e={(convertfrom-epoch $_.clock).addhours(2)}},@{n="Server";e={$_.hosts.name}},@{n="alerts";e={$_.alerts.subject[0]}} | Set-ZabbixEvent -ackMessage TKT-2516: Resolved"
		Acknowledge events for last 5 hours for servers match name "web"
	#>
	
	[cmdletbinding()]
	[Alias("sze")]
	Param (
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)]$EventID,
		$ackMessage,
		$HostID,
		[array] $SortBy = "clock",
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
			method  = "event.acknowledge"
			params  = @{
				eventids = $EventID
				message  = $ackMessage
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

