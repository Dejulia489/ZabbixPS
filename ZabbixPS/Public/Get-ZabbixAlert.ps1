Function Get-ZabbixAlert
{ 
	<#
	.Synopsis
		Get alerts
	.Parameter HostID
		HostID
	.Example
		Get-ZabbixAlert | ? sendto -match email | select @{n="Time(UTC)";e={convertfrom-epoch $_.clock}},alertid,sendto,subject 
		Get alerts from last 5 hours (default). Time display in UTC/GMT (default) 
	.Example
		Get-ZabbixAlert | ? sendto -match email | select @{n="Time(UTC+1)";e={(convertfrom-epoch $_.clock).addhours(+1)}},alertid,subject
		Get alerts from last 5 hours (default). Time display in UTC+1
	.Example
		Get-ZabbixAlert | ? sendto -match email | select @{n="Time(UTC-5)";e={(convertfrom-epoch $_.clock).addhours(-5)}},alertid,subject
		Get alerts from last 5 hours (default). Time display in UTC-5
	.Example
		Get-ZabbixAlert | ? sendto -match email | ? subject -match OK | select @{n="Time(UTC)";e={convertfrom-epoch $_.clock}},alertid,sendto,subject 
		Get alerts with OK status
	.Example	
		Get-ZabbixAlert -TimeFrom (convertTo-epoch (((get-date).ToUniversalTime()).addhours(-10))) -TimeTill (convertTo-epoch (((get-date).ToUniversalTime()).addhours(-2))) | ? sendto -match mail | ? subject -match "" | select @{n="Time(UTC)";e={convertfrom-epoch $_.clock}},alertid,sendto,subject 
		Get alerts within custom timewindow of 8 hours (-timeFrom, -timeTill in UTC/GMT). Time display in UTC/GMT (default)  
	.Example	
		Get-ZabbixAlert -TimeFrom (convertTo-epoch (((get-date).ToUniversalTime()).addhours(-5))) -TimeTill (convertTo-epoch ((get-date).ToUniversalTime()).addhours(0)) | ? sendto -match mail | select @{n="Time UTC";e={convertfrom-epoch $_.clock}},alertid,sendto,subject 
		Get alerts for last 5 hours
	.Example
		Get-ZabbixHost | ? name -match "hosts" | Get-ZabbixAlert | ? sendto -match mail | select @{n="Time(UTC-5)";e={(convertfrom-epoch $_.clock).addhours(-5)}},alertid,subject
		Get alerts for hosts from last 5 hours (default). Display time in UTC-5 
	.Example
		Get-ZabbixHost -HostName "Server-01" | Get-ZabbixAlert -ea silent | ? sendto -match email | select @{n="Time(UTC-5)";e={(convertfrom-epoch $_.clock).addhours(-5)}},alertid,subject
		Works for single host (name case sensitive). Get alerts for host from last 5 hours (default). Display time in UTC-5
	.Example
		Get-ZabbixAlert -HostID (Get-ZabbixHost | ? name -match "Host|OtherHost").hostid | ? sendto -match email | select @{n="Time(UTC-5)";e={(convertfrom-epoch $_.clock).addhours(-5)}},alertid,subject
		Works for multiple hosts. Get alerts for hosts from last 5 hours (default). Display time in UTC-5
	.Example
		Get-ZabbixAlert -TimeFrom (convertTo-epoch ((get-date -date "05/25/2015 9:00").ToUniversalTime()).addhours(0)) -TimeTill (convertTo-epoch ((get-date -date "05/25/2015 14:00").ToUniversalTime()).addhours(0)) | ? sendto -match mail | select @{n="Time(UTC)";e={(convertfrom-epoch $_.clock).addhours(0)}},alertid,subject
		Get alerts between two dates (in UTC), present time in UTC
	#>
	
	[cmdletbinding()]
	[Alias("gzal")]
	Param (
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$HostID,
		#epoch time
		#TimeFrom to display the alerts. Default: -5, from five hours ago. Time is in UTC/GMT"
		$TimeFrom = (convertTo-epoch ((get-date).addhours(-5)).ToUniversalTime()),
		#epoch time
		#TimeTill to display the alerts. Default: till now. Time is in UTC/GMT"
		$TimeTill = (convertTo-epoch ((get-date).addhours(0)).ToUniversalTime()),
		[array] $SortBy = "clock",
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
			method  = "alert.get"
			params  = @{
				output           = "extend"
				time_from        = $timeFrom
				time_till        = $timeTill
				selectMediatypes = "extend"
				selectUsers      = "extend"
				selectHosts      = @(
					"hostid",
					"name"
				)
				hostids          = $HostID
				sortfield        = @($sortby)
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



