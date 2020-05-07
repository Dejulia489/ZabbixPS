Function Get-ZabbixHistory
{ 
	<#
	.Synopsis
		Get History
	.Description
		Get History
	.Example
		Get-ZabbixHistory -ItemID (get-zabbixhost | ? name -match "server" | Get-ZabbixItem | ? name -match "system information").itemid
		Get history for item "system information", for server "server" for last 48 hours (default) present time in UTC/GMT (default)
	.Example
		Get-ZabbixHistory -ItemID (get-zabbixhost | ? name -match "server" | Get-ZabbixItem | ? name -match "system information").itemid | select itemid,@{n="clock(UTC-5)";e={(convertfrom-epoch $_.clock).addhours(-5)}},value
		Get history for item "system information", for server "server" for last 48 hours (default) present time in UTC/GMT-5
	.Example
        Get-ZabbixHistory -ItemID (get-zabbixhost -hostname  "server" | Get-ZabbixItem -webitems -ItemKey web.test.error -ea silent).itemid -TimeFrom (convertTo-epoch (get-date).adddays(-10)) | select itemid,@{n="clock(UTC-5)";e={(convertfrom-epoch $_.clock).addhours(-5)}},value
		Get history for web/http test errors for host "server" for last 10 days. present time in UTC/GMT-5
	#>
	[cmdletbinding()]
	[Alias("gzhist")]
	Param (
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$HostID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$ItemID,
		#epoch time
		#TimeFrom to display the history. Default: -48, form 48 hours ago. Time is in UTC/GMT+0
		$TimeFrom = (convertTo-epoch ((get-date).addhours(-48)).ToUniversalTime()),
		#epoch time
		#TimeTil to display the history. Default: till now. Time is in UTC/GMT+0
		$TimeTill = (convertTo-epoch ((get-date).addhours(0)).ToUniversalTime()),
		#Limit output to #lines. Default: 50
		$Limit = 50,
		#can sort by: itemid and clock. Default: by clock.
		[array] $SortBy = "clock",
		#History object type to return: 0 - float; 1 - string; 2 - log; 3 - integer; 4 - text. Default: 1
		$History = 1,
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
			method  = "history.get"
			params  = @{
				output    = "extend"
				history   = $History
				itemids   = $ItemID
				sortfield = $SortBy
				sortorder = "DESC"
				limit     = $Limit
				hostids   = $HostID
				time_from = $TimeFrom
				time_till = $TimeTill
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

