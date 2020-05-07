Function Set-ZabbixMaintenance
{
	<# 
	.Synopsis
		Set/update maintenance settings
	.Description
		Set/update maintenance settings
	.Parameter MaintenanceName
		Maintenance name (case sensitive)
	.Parameter MaintenanceDescription
		Maintenance Description
	.Parameter ActiveSince
		Maintenance start time (epoch time format)
	.Parameter ActiveTill
		Maintenance end time (epoch time format)
	.Parameter MaintenanceType
		Maintenance maintenance type (0 - (default) with data collection;  1 - without data collection)
	.Parameter TimeperiodType
		Maintenance TimeperiodType (0 - (default) one time only; 2 - daily;  3 - weekly;  4 - monthly)
	.Parameter TimeperiodStartDate
		Maintenance timeperiod's start date. Required only for one time periods. Default: current date (epoch time format)
	.Parameter TimeperiodPeriod
		Maintenance timeperiod's period/duration (seconds)	
	.Example
		Get-ZabbixMaintenance -MaintenanceName 'MaintenanceName' | Set-ZabbixMaintenance -GroupID (Get-ZabbixHostGroup | ? name -eq 'HostGroupName').groupid -TimeperiodPeriod 44400 -HostID (Get-ZabbixHost | ? name -match host).hostid
		Will replace ZabbixHostGroup, hosts and set new duration for selected maintenance (MaintenanceName is case sensitive)
	.Example
		Get-ZabbixMaintenance | ? name -eq 'MaintenanceName' | Set-ZabbixMaintenance -GroupID (Get-ZabbixHostGroup | ? name -match 'homeGroup').groupid -verbose -TimeperiodPeriod 44400 -HostID (Get-ZabbixHost | ? name -match host).hostid
		Same as above (MaintenanceName is case insensitive)
	.Example
		Get-ZabbixMaintenance | ? name -match 'maintenance' | Set-ZabbixMaintenance -GroupID (Get-ZabbixHostGroup | ? name -match 'Name1|Name2').groupid -TimeperiodPeriod 44400 -HostID (Get-ZabbixHost | ? name -match host).hostid
		Replace ZabbixHostGroups, hosts, duration in multiple maintenances 
	#>

	[CmdletBinding()]
	[Alias("szm")]
	Param (
		[Alias("name")][Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)][string]$MaintenanceName,
		[Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)][string]$MaintenanceID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][array]$GroupID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][array]$HostID,
		[Parameter(DontShow, Mandatory = $False, ValueFromPipelineByPropertyName = $True)][array]$groups,
		[Parameter(DontShow, Mandatory = $False, ValueFromPipelineByPropertyName = $True)][array]$hosts,
		[Parameter(DontShow, Mandatory = $False, ValueFromPipelineByPropertyName = $True)][array]$timeperiods,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$MaintenanceDescription,
		#Type of maintenance.  Possible values:  0 - (default) with data collection;  1 - without data collection. 
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][int]$MaintenanceType,
		#epoch time
		[Alias("active_since")][Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]$ActiveSince,
		#epoch time
		[Alias("active_till")][Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]$ActiveTill,
		#epoch time
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][int]$TimeperiodPeriod,
		#Possible values: 0 - (default) one time only;  2 - daily;  3 - weekly;  4 - monthly. 
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][int]$TimePeriodType = 0,
		#Time of day when the maintenance starts in seconds.  Required for daily, weekly and monthly periods. (epoch time)
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][int]$TimeperiodStartTime,
		#Date when the maintenance period must come into effect.  Required only for one time periods. Default: current date. (epoch time)
		# [Alias("timeperiods.start_date")][Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$True,ValueFromRemainingArguments=$true)]$TimeperiodStartDate,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)]$TimeperiodStartDate,
		#For daily and weekly periods every defines day or week intervals at which the maintenance must come into effect. 
		#For monthly periods every defines the week of the month when the maintenance must come into effect. 
		#Possible values:  1 - first week;  2 - second week;  3 - third week;  4 - fourth week;  5 - last week.
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][int]$TimeperiodEvery,
		# Day of the month when the maintenance must come into effect
		# Required only for monthly time periods
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][int]$TimeperiodDay,
		# Days of the week when the maintenance must come into effect
		# Days are stored in binary form with each bit representing the corresponding day. For example, 4 equals 100 in binary and means, that maintenance will be enabled on Wednesday
		# Used for weekly and monthly time periods. Required only for weekly time periods
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][int]$TimeperiodDayOfWeek,
		# Months when the maintenance must come into effect
		# Months are stored in binary form with each bit representing the corresponding month. For example, 5 equals 101 in binary and means, that maintenance will be enabled in January and March
		# Required only for monthly time periods
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][int]$TimeperiodMonth,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$jsonrpc = ($global:zabSessionParams.jsonrpc),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$session = ($global:zabSessionParams.session),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$id = ($global:zabSessionParams.id),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$URL = ($global:zabSessionParams.url)
	)
    
	process
 {

		if (!(Get-ZabbixSession)) { return }
		elseif (!$psboundparameters.count) { Write-MissingParamsMessage; return }

		$boundparams = $PSBoundParameters | out-string
		write-verbose "($boundparams)"

		# for ($i=0; $i -lt $GroupID.length; $i++) {[array]$grp+=$(@{GroupID = $($TemplateID[$i])})}
		# for ($i=0; $i -lt $HostID.length; $i++) {[array]$hst+=$(@{HostID = $($HostID[$i])})}
		# for ($i=0; $i -lt $TemplateID.length; $i++) {[array]$tmpl+=$(@{templateid = $($TemplateID[$i])})}
		
		if ($hosts -and !$HostID) { $HostID = ($hosts).hostid }
		if ($groups -and !$GroupID) { $GroupID = ($groups).groupid }
		if ($timeperiods -and !$TimeperiodType) { $TimeperiodType = ($timeperiods).timeperiod_type }
		if ($timeperiods -and !$TimeperiodStartDate) { $TimeperiodStartDate = ($timeperiods).start_date }
		if ($timeperiods -and !$TimeperiodStartTime) { $TimeperiodStartTime = ($timeperiods).start_time }
		if ($timeperiods -and !$TimeperiodPeriod) { $TimeperiodPeriod = ($timeperiods).period }
		if ($timeperiods -and !$TimeperiodMonth) { $TimeperiodMonth = ($timeperiods).month }
		if ($timeperiods -and !$TimeperiodDayOfWeek) { $TimeperiodDayOfWeek = ($timeperiods).dayofweek }
		if ($timeperiods -and !$TimeperiodDay) { $TimeperiodDay = ($timeperiods).day }
		if ($timeperiods -and !$TimeperiodEvery) { $TimeperiodEvery = ($timeperiods).every }

		$Body = @{
			method  = "maintenance.update"
			params  = @{
				name             = $MaintenanceName
				maintenanceid    = $MaintenanceID
				description      = $MaintenanceDescription
				active_since     = $ActiveSince
				active_till      = $ActiveTill
				maintenance_type = $MaintenanceType
				timeperiods      = @(
					@{
						timeperiod_type = $TimeperiodType
						start_date      = $TimeperiodStartDate
						period          = $TimeperiodPeriod
						
						every           = $TimeperiodEvery
						start_time      = $TimeperiodStartTime
						month           = $TimeperiodMonth
						dayofweek       = $TimeperiodDayOfWeek
						day             = $TimeperiodDay
					}
				)
				groupids         = $GroupID
				# groups = $GroupID
				hostids          = $HostID
				# timeperiods = $timeperiods
				# timeperiods = @($timep)
			}
			
			jsonrpc = $jsonrpc
			id      = $id
			auth    = $session
		}
		
		$BodyJSON = ConvertTo-Json $Body -Depth 4
		write-verbose $BodyJSON
		
		$a = Invoke-RestMethod "$URL/api_jsonrpc.php" -ContentType "application/json" -Body $BodyJSON -Method Post
		if ($a.result) { $a.result } else { $a.error }
	}
}

 