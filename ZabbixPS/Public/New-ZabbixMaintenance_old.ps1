
Function New-ZabbixMaintenance
{
	<#
	.SYNOPSIS

	Create new maintenance

	.DESCRIPTION

	Create new maintenance

	.PARAMETER MaintenanceName

	Maintenance name (case sensitive)

	.PARAMETER MaintenanceDescription

	Maintenance Description

	.PARAMETER ActiveSince

	Maintenance start time (epoch time format)

	.PARAMETER ActiveTill

	Maintenance end time (epoch time format)

	.PARAMETER MaintenanceType

	Maintenance maintenance type (0 - (default) with data collection;  1 - without data collection)

	.PARAMETER TimeperiodType

	Maintenance TimeperiodType (0 - (default) one time only; 2 - daily;  3 - weekly;  4 - monthly)

	.PARAMETER TimeperiodStartDate

	Maintenance timeperiod's start date. Required only for one time periods. Default: current date (epoch time format)

	.PARAMETER TimeperiodPeriod

	Maintenance timeperiod's period/duration (seconds)

	.EXAMPLE

	New-ZabbixMaintenance -HostID (Get-ZabbixHost | ? name -match "hosts").hostid -MaintenanceName "NewMaintenance" -ActiveSince (convertTo-epoch ((get-date).addhours(0)).ToUniversalTime()) -ActiveTill (convertTo-epoch ((get-date).addhours(7)).ToUniversalTime()) -TimeperiodPeriod (4*3600)

	Create new maintenance for few hosts (time will be according Zabbix server time). Maintenance will be active for 7 hours from now, with Period 4 hours, which will start immediately

	.EXAMPLE

	New-ZabbixMaintenance -HostID "10109","10110","10111","10112","10113","10114" -MaintenanceName NewMaintenanceName -MaintenanceDescription NewMaintenanceDescription -ActiveSince 1432584300 -ActiveTill 1432605900 -TimeperiodStartTime 1432584300 -TimeperiodPeriod 25200

	Create new maintenance (time (epoch format) will be according your PC (client) local time). Name and Description are case sensitive

	.EXAMPLE

	New-ZabbixMaintenance -HostID (Get-ZabbixHost | ? name -match otherhost).hostid -MaintenanceName NewMaintenanceName -MaintenanceDescription NewMaintenanceDescription -ActiveSince (convertTo-epoch (get-date -date "05/25/2015 07:05")) -ActiveTill (convertTo-epoch (get-date -date "05/25/2015 17:05")) -TimeperiodPeriod (7*3600) -TimeperiodStartDate (convertTo-epoch (get-date -date "05/25/2015 09:05"))

	Create new, future maintenance (case sensitive) (time will be sent in UTC). Will be set on Zabbix server according it's local time.

	.EXAMPLE

	$hosts=Get-Zabbixhost | ? name -match "host|anotherhost"

	$groups=(Get-ZabbixGroup | ? name -match "group")

	New-ZabbixMaintenance -HostID $hosts.hostid -GroupID $groups.groupid -MaintenanceName "NewMaintenanceName" -ActiveSince (convertTo-epoch (convertTo-epoch ((get-date).addhours(0)).ToUniversalTime()) -ActiveTill (convertTo-epoch ((get-date).addhours(+4)).ToUniversalTime()) -TimeperiodPeriod (3*3600)

	Create new maintenance for few hosts (time will be according current Zabbix server time). Maintenance Active from now for 4 hours, and Period with duration of 3 hours, starting immediately
	#>
	[CmdletBinding()]
	[Alias("nzm")]
	Param (
		[Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $False)][string]$MaintenanceName,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][array]$GroupID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][array]$HostID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][string]$MaintenanceDescription,
		# Type of maintenance.  Possible values:  0 - (default) with data collection;  1 - without data collection.
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][int]$MaintenanceType,
		# epoch time
		[Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $False)]$ActiveSince,
		# epoch time
		[Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $False)]$ActiveTill,
		# Possible values: 0 - (default) one time only;  2 - daily;  3 - weekly;  4 - monthly.
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][int]$TimePeriodType = 0,
		# Time of day when the maintenance starts in seconds.  Required for daily, weekly and monthly periods. (epoch time)
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][int]$TimeperiodStartTime,
		# Date when the maintenance period must come into effect.  Required only for one time periods. Default: current date. (epoch time)
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)]$TimeperiodStartDate,
		# Duration of the maintenance period in seconds. Default: 3600 (epoch time)
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][int]$TimeperiodPeriod,
		# For daily and weekly periods every defines day or week intervals at which the maintenance must come into effect.
		# For monthly periods every defines the week of the month when the maintenance must come into effect.
		# Possible values:  1 - first week;  2 - second week;  3 - third week;  4 - fourth week;  5 - last week.
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][int]$TimeperiodEvery,
		# Day of the month when the maintenance must come into effect
		# Required only for monthly time periods
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][int]$TimeperiodDay,
		# Days of the week when the maintenance must come into effect
		# Days are stored in binary form with each bit representing the corresponding day. For EXAMPLE, 4 equals 100 in binary and means, that maintenance will be enabled on Wednesday
		# Used for weekly and monthly time periods. Required only for weekly time periods
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][int]$TimeperiodDayOfWeek,
		# Months when the maintenance must come into effect
		# Months are stored in binary form with each bit representing the corresponding month. For EXAMPLE, 5 equals 101 in binary and means, that maintenance will be enabled in January and March
		# Required only for monthly time periods
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][int]$TimeperiodMonth,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$jsonrpc = ($global:zabSessionParams.jsonrpc),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$session = ($global:zabSessionParams.session),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$id = ($global:zabSessionParams.id),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$URL = ($global:zabSessionParams.url),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][string[]]$Tags

	)

	process
 {

		if (!(Get-ZabbixSession)) { return }
		elseif (!$psboundparameters.count) { Write-MissingParamsMessage; return }

		$boundparams = $PSBoundParameters | out-string
		write-verbose "($boundparams)"

		if (!($GroupID -or $HostID)) { write-host "`nYou need to provide GroupID or HostID as parameter`n" -f red; return }

		if ($GroupID)
		{
			$Body = @{
				method  = "maintenance.create"
				params  = @{
					name             = $MaintenanceName
					description      = $MaintenanceDescription
					active_since     = $ActiveSince
					active_till      = $ActiveTill
					maintenance_type = $MaintenanceType
					timeperiods      = @(
						@{
							timeperiod_type = $TimeperiodType
							start_date      = $TimeperiodStartDate
							period          = $TimeperiodPeriod

							start_time      = $TimeperiodStartTime
							month           = $TimeperiodMonth
							dayofweek       = $TimeperiodDayOfWeek
							day             = $TimeperiodDay
						}
					)
					groupids         = @($GroupID)
				}

				jsonrpc = $jsonrpc
				id      = $id
				auth    = $session
			}
		}
		if ($HostID)
		{
			$Body = @{
				method  = "maintenance.create"
				params  = @{
					name             = $MaintenanceName
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
					hostids          = @($HostID)
				}

				jsonrpc = $jsonrpc
				id      = $id
				auth    = $session
			}
		}

		if ($Tags)
		{
			$formattedTags = Foreach ($tag in $Tags)
			{
				$split = $tag.split(':')
				@{
					tag      = $split[0]
					operator = 0
					value    = $split[-1]
				}
			}
			$Body.params.tags = $formattedTags
		}

		$BodyJSON = ConvertTo-Json $Body -Depth 4
		write-verbose $BodyJSON

		$a = Invoke-RestMethod "$URL/api_jsonrpc.php" -ContentType "application/json" -Body $BodyJSON -Method Post
		if ($a.result) { $a.result } else { $a.error }
	}
}