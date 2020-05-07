
Function Get-ZabbixMaintenance
{
	<# 
	.Synopsis
		Get maintenance
	.Description
		Get maintenance
	.Parameter MaintenanceName
		To filter by name of the maintenance (case sensitive)
	.Parameter MaintenanceID
		To filter by id of the maintenance
	.Example
		Get-ZabbixMaintenance | select maintenanceid,name
		Get maintenance
	.Example
		Get-ZabbixMaintenance -MaintenanceName MaintenanceName
		Get maintenance by name (case sensitive)
	.Example 
		Get-ZabbixMaintenance | ? name -match maintenance
		Get maintenance by name match (case insensitive)
    .Example
        Get-ZabbixMaintenance | ? name -match "" | select @{n="MaintenanceName";e={$_.name}} -ExpandProperty groups | ft -a
        Get maintenance by name match (case insensitive)   
	.Example
		Get-ZabbixMaintenance -MaintenanceID 10123
		Get maintenance by ID
	.Example
        Get-ZabbixMaintenance | select maintenanceid,name,@{n="Active_since(UTC-5)";e={(convertFrom-epoch $_.active_since).addhours(-5)}},@{n="Active_till(UTC-5)";e={(convertFrom-epoch $_.active_till).addhours(-5)}},@{n="TimeperiodStart(UTC-5)";e={(convertfrom-epoch $_.timeperiods.start_date).addhours(-5)}},@{n="Duration(hours)";e={$_.timeperiods.period/3600}} | ft -a
        Get maintenance and it's timeperiod
	.Example
		(Get-ZabbixMaintenance -MaintenanceName MaintenanceName).timeperiods
		Get timeperiods from maintenance (case sensitive)
    .Example
        Get-ZabbixMaintenance | select -Property @{n="MaintenanceName";e={$_.name}} -ExpandProperty timeperiods | ft -a
        Get timeperiods from maintenance
	.Example
        Get-ZabbixMaintenance | select -Property @{n="MaintenanceName";e={$_.name}} -ExpandProperty timeperiods | select MaintenanceName,timeperiodid,timeperiod_type,@{n="start_date(UTC)";e={convertfrom-epoch $_.start_date}},@{n="period(Hours)";e={$_.period/3600}} | ft -a
        Get timeperiods maintenance and timeperiods (Time in UTC)
    .Example
		(Get-ZabbixMaintenance -MaintenanceName MaintenanceName).hosts.host
		Get hosts from maintenance (case sensitive)
	.Example
		(Get-ZabbixMaintenance -MaintenanceName MaintenanceName).hostid  
		Get HostIDs of hosts from maintenance (case sensitive)
	.Example
		Get-ZabbixMaintenance | ? name -match maintenance | select Name,@{n="TimeperiodStart";e={(convertfrom-epoch $_.timeperiods.start_date).addhours(-5)}},@{n="Duration(hours)";e={$_.timeperiods.period/3600}}
		Get timeperiods from maintenance (case insensitive), display name, timeperiod (according UTC-5) and duration
	#>
    
	[CmdletBinding()]
	[Alias("gzm")]
	Param (
		$MaintenanceName,
		$MaintenanceID,
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
			method  = "maintenance.get"
			params  = @{
				output            = "extend"
				selectGroups      = "extend"
				selectHosts       = "extend"
				selectTimeperiods = "extend"
				filter            = @{
					name = $MaintenanceName
				}
				maintenanceids    = $MaintenanceID
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

