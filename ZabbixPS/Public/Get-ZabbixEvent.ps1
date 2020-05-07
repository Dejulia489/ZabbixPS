Function Get-ZabbixEvent
{ 
	<#
	.Synopsis
		Get events
	.Example
		Get-ZabbixEvent -EventID 445750
		Get Event
	.Example
		Get-ZabbixEvent -TimeFrom (convertTo-epoch (get-date).addhours(-24)) | select @{n="Time UTC";e={convertfrom-epoch $_.clock}},@{n="Server";e={$_.hosts.name}},@{n="alerts";e={$_.alerts.subject[0]}}
		Get events for last 24 hours. According UTC/GMT+0 time. TimeTill is now in UTC/GMT+0 time
	.Example
		Get-ZabbixProblem | Get-ZabbixEvent | ft -a
		Get events
	.Example
		Get-ZabbixProblem | Get-ZabbixEvent | select @{n="clock(UTC+1)";e={(convertfrom-epoch $_.clock).addhours(1)}},* | ft -a 
		Get events. Time in UTC+1 
	.Example
		Get-ZabbixEvent -TimeFrom (convertTo-epoch (get-date).addhours(-24)) -TimeTill (convertTo-epoch (get-date).addhours(0)) | select @{n="Time UTC";e={convertfrom-epoch $_.clock}},@{n="Server";e={$_.hosts.name}},@{n="alerts";e={$_.alerts.subject[0]}}
		Get events for last 24 hours
	.Example
		Get-ZabbixEvent -TimeFrom (convertTo-epoch (get-date).addhours(-24*25)) -TimeTill (convertTo-epoch (get-date).addhours(0)) | ? alerts | ? {$_.hosts.name -match "webserver" } | select @{n="Time UTC";e={convertfrom-epoch $_.clock}},@{n="Server";e={$_.hosts.name}},@{n="alerts";e={$_.alerts.subject[0]}}
		Get events for last 25 days for servers with name match webserver
	.Example
		Get-ZabbixEvent -TimeFrom (convertTo-epoch (get-date).addhours(-5)) -TimeTill (convertTo-epoch (get-date).addhours(0)) | ? alerts | ? {$_.hosts.name -match "DB" } | select eventid,@{n="Time UTC+2";e={(convertfrom-epoch $_.clock).addhours(1)}},@{n="Server";e={$_.hosts.name}},@{n="alerts";e={$_.alerts.subject[0]}} | ft -a
		Get events from 5 days ago for servers with name match "DB", and display time in UTC+1
	.Example
		Get-ZabbixEvent -TimeFrom (convertTo-epoch (get-date).AddDays(-180)) -TimeTill (convertTo-epoch (get-date).AddDays(-150)) | ? alerts | ? {$_.hosts.name -match "host" } | select @{n="Time UTC";e={convertfrom-epoch $_.clock}},@{n="Server";e={$_.hosts.name}},@{n="alerts";e={$_.alerts.subject[0]}}
		Get past (180-150 days ago) events for host
    #>
	
	[cmdletbinding()]
	[Alias("gze")]
	Param (
		# epoch time
		$TimeFrom,
		# epoch time
		# Time until to display alerts. Default: till now. Time is in UTC/GMT
		$TimeTill = (convertTo-epoch ((get-date).addhours(0)).ToUniversalTime()),
		$HostID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$EventID,
		[array] $SortBy = "clock",
		# Possible values for trigger events: 0 - trigger; 1 - discovered host; 2 - discovered service; 3 - auto-registered host
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)]$source, 
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$jsonrpc = ($global:zabSessionParams.jsonrpc),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$session = ($global:zabSessionParams.session),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$id = ($global:zabSessionParams.id),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$URL = ($global:zabSessionParams.url)
	)
	
	process
 {

		if (!(Get-ZabbixSession)) { return }

		$boundparams = $PSBoundParameters | out-string
		write-verbose "($boundparams)"

		$Body = @{
			method  = "event.get"
			params  = @{
				output              = "extend"
				select_acknowledges = "extend"
				time_from           = $timeFrom
				time_till           = $timeTill
				sortorder           = "desc"
				select_alerts       = "extend"
				eventids            = $EventID
				selectHosts         = @(
					"hostid",
					"name"
				)
				sortfield           = @($sortby)
				filter              = @{
					hostids = $HostID
				}
			}
			
			jsonrpc = $jsonrpc
			id      = $id
			auth    = $session
		}

		$BodyJSON = ConvertTo-Json $Body
		write-verbose $BodyJSON
		
		try
		{
			$a = Invoke-RestMethod "$URL/api_jsonrpc.php" -ContentType "application/json" -Body $BodyJSON -Method Post
			if ($a.result) { $a.result } else { $a.error }
		}
		catch
		{
			Write-Host "$_"
			Write-Host "Too many entries to return from Zabbix server. Check/reduce the filters." -f cyan
		}
	}
}
