Function Get-ZabbixItem
{ 
	<#
	.Synopsis
		Retrieve items
	.Description
		Retrieve items
	.Example
		Get-ZabbixItem -HostId (Get-ZabbixHost | ? name -match hostName).hostid | select name,key_,lastvalue
		Get Items for host (case insensitive)
	.Example
		Get-ZabbixItem -ItemName 'RAM Utilization (%)' -HostId (Get-ZabbixHost | ? name -match "dc1").hostid | select @{n="hostname";e={$_.hosts.name}},name,key_,@{n="Time(UTC+1)";e={(convertfrom-epoch $_.lastclock).addhours(+1)}},status,prevvalue,@{n="lastvalue";e={[decimal][math]::Round($_.lastvalue,3)}} | sort lastvalue -desc | ft -a
		Get Items  with name 'RAM Utilization (%)' for hosts by match
	.Example
		Get-ZabbixHost | ? name -match "Hosts" | Get-ZabbixItem -ItemName 'RAM Utilization (%)' | select @{n="hostname";e={$_.hosts.name}},name,key_,@{n="Time(UTC+1)";e={(convertfrom-epoch $_.lastclock).addhours(+1)}},status,prevvalue,@{n="lastvalue";e={[decimal][math]::Round($_.lastvalue,3)}} | sort lastvalue -desc | ft -a
		Get Items  with name 'RAM Utilization (%)' for hosts by match, same as above
	.Example
		Get-ZabbixItem -ItemName 'Memory Total' -HostId (Get-ZabbixHost | ? name -match "").hostid | select @{n="hostname";e={$_.hosts.name}},name,key_,@{n="Time(UTC+1)";e={(convertfrom-epoch $_.lastclock).addhours(+1)}},prevvalue,@{n="lastvalue";e={[decimal][math]::round(($_.lastvalue/1gb),2)}} | sort lastvalue -desc | ft -a
		Get Items  with name 'Memory Total' for hosts by match
	.Example
		Get-ZabbixItem -HostId (Get-ZabbixHost | ? name -NotMatch host | ? name -match host).hostid | ? key_ -match "Processor time" | ? key_ -notmatch "vmver" | select  @{n="lastclock";e={(convertfrom-epoch $_.lastclock).addhours(+1)}},@{n="host";e={$_.hosts.name}},@{n='CPU%';e={[int]$_.lastvalue}},name,key_ | sort 'CPU%' -desc | ft -a
		Get hosts' CPU utilization	
	.Example	
		Get-ZabbixItem -HostId (Get-ZabbixHost | ? name -match host).hostid | ? key_ -match "/mnt/reporter_files,[used,free]" | ? lastvalue -ne 0 | select @{n="Time(UTC+1)";e={(convertfrom-epoch $_.lastclock).addhours(+1)}},@{n="host";e={$_.hosts.name}},@{n="lastvalue";e={[decimal][math]::round(($_.lastvalue/1gb),2)}},key_,description | sort host | ft -a
		Get Items for host(s) with key_ match
	.Example	
		Get-ZabbixItem -TemplateID (Get-ZabbixTemplate | ? name -match "myTemplates").templateid | ? history -ne 7 | select @{n="Template";e={$_.hosts.name}},history,name -Unique | sort Template
		Get Items for templates, where history not 7 days
	.Example
		Get-ZabbixTemplate | ? name -match "myTemplates" | Get-ZabbixItem | select @{n="Template";e={$_.hosts.name}},key_ -Unique | sort Template
		Get item keys for templates
	.Example
		Get-ZabbixItem -HostId (Get-ZabbixHost | ? name -match hostName).hostid | ? key_ -match "Version|ProductName" | ? key_ -notmatch "vmver" | select @{n="Time(UTC+1)";e={(convertfrom-epoch $_.lastclock).addhours(+1)}},@{n="host";e={$_.hosts.name}},lastvalue,name,key_ | sort host,key_ | ft -a
		Get Items by host match, by key_ match/notmatch
	.Example
		Get-ZabbixHost -hostname hostName | Get-ZabbixItem -SortBy status -ItemKey pfree | select name, key_,@{n="Time(UTC)";e={convertfrom-epoch $_.lastclock}},lastvalue,status | ft -a
		Get Items (disk usage(%) information) for single host
	.Example
		Get-ZabbixHost | ? name -match "hosts" | Get-ZabbixItem -ItemName 'RAM Utilization (%)' | select @{n="hostname";e={$_.hosts.name}},name,key_,@{n="Time(UTC+1)";e={(convertfrom-epoch $_.lastclock).addhours(+1)}},prevvalue,lastvalue | sort hostname | ft -a
		Get Items for multiple hosts by match
	.Example
		Get-ZabbixHost | ? name -match "host|host" | Get-ZabbixItem | ? key_ -match HeapMemoryUsage.used | select @{n="lastclock";e={(convertfrom-epoch $_.lastclock).addhours(+1)}},@{n="host";e={$_.hosts.name}},@{n='HeapUsed';e={[int]$_.lastvalue/1mb}},name,key_ | ft -a
		Get java heap used by hosts (JMX)
	.Example
		Get-ZabbixItem -HostId (Get-ZabbixHost @zabSessionParams | ? name -NotMatch host | ? name -match host).hostid | ? name -match "Commit|RAM Utilization" | ? name -notmatch "%" | ? key_ -notmatch "vmver" | select   @{n="lastclock";e={(convertfrom-epoch $_.lastclock).addhours(+1)}},@{n="host";e={$_.hosts.name}},@{n='RAM(GB)';e={[math]::round($_.lastvalue/1gb,2)}},name,key_ | sort host,key_ | ft -a
		Get hosts' RAM utilization
	.Example
		Get-ZabbixItem -SortBy status -ItemKey pfree -HostId (Get-ZabbixHost | ? name -match hostName).hostid | select @{n="hostname";e={$_.hosts.name}},@{n="Time(UTC)";e={convertfrom-epoch $_.lastclock}},status,key_,lastvalue,name | sort hostname,key_ | ft -a
		Get Items (disk usage(%) info) for multiple hosts
	.Example
		Get-ZabbixItem -SortBy status -ItemKey pfree -HostId (Get-ZabbixHost | ? name -match hostName).hostid | ? key_ -match "c:" | select @{n="hostname";e={$_.hosts.name}},@{n="Time(UTC)";e={convertfrom-epoch $_.lastclock}},status,key_,lastvalue,name | sort hostname,key_ | ft -a
		Get Items (disk usage info) according disk match for multiple hosts
	.Example
		(1..8) | %{Get-ZabbixHost hostName-0$_ | Get-ZabbixItem -ItemKey 'java.lang:type=Memory' | ? status -match 0 | select key_,interfaces}
		Get Items and their interface
	.Example
        (1..8) | %{Get-ZabbixHost hostName-0$_ | Get-ZabbixItem -ItemKey 'MemoryUsage.used' | ? status -match 0 | select @{n="Host";e={$_.hosts.name}},@{n="If.IP";e={$_.interfaces.ip}},@{n="If.Port";e={$_.interfaces.port}},@{n="Application";e={$_.applications.name}},key_ } | ft -a
        Get Items and interfaces
	.Example
		Get-ZabbixItem -ItemKey 'version' -ItemName "Version of zabbix_agent(d) running" -HostId (Get-ZabbixHost | ? name -notmatch "DC2").hostid | ? status -match 0 | select @{n="host";e={$_.hosts.name}},@{n="Application";e={$_.applications.name}},key_,lastvalue | sort host
		Get Zabbix agent version
	.Example
		Get-ZabbixItem -HostId (Get-ZabbixHost | ? name -match "hostName").hostid | ? key_ -match "version" | ? key_ -notmatch "VmVersion" | ? lastvalue -ne 0 | ? applications -match "" | select @{n="Time(UTC+1)";e={(convertfrom-epoch $_.lastclock).addhours(+1)}},@{n="host";e={$_.hosts.name}},@{n="Application";e={$_.applications.name}},lastvalue,key_,@{n="If.IP";e={$_.interfaces.ip}},@{n="If.Port";e={$_.interfaces.port}} | sort host | ft -a 
		Get Java application versions via JMX
	.Example
		Get-ZabbixItem -HostId (Get-ZabbixHost | ? name -match "hostName").hostid | ? key_ -match "HeapMemoryUsage.committed" | ? lastvalue -ne 0 | ? applications -match "application" | select @{n="Time(UTC+1)";e={(convertfrom-epoch $_.lastclock).addhours(+1)}},@{n="host";e={$_.hosts.name}},@{n="Application";e={$_.applications.name}},lastvalue,key_,@{n="If.IP";e={$_.interfaces.ip}},@{n="If.Port";e={$_.interfaces.port}} | sort host | ft -a
		Get JVM memory usage via JMX
	.Example
        Cassandra: Get-ZabbixItem -ItemName 'AntiEntropySessions' -HostId (Get-ZabbixHost | ? name -match "cassandraNode").hostid | select  @{n="hostname";e={$_.hosts.name}},name,@{e={(convertfrom-epoch $_.lastclock).addhours(+1)};n="Time"},@{n="lastvalue";e={[math]::round(($_.lastvalue),2)}} | sort hostname | ft -a
        Cassandra: Get-ZabbixItem -ItemName 'Compaction' -HostId (Get-ZabbixHost | ? name -match "cassandraNodes").hostid | ? name -Match "CurrentlyBlockedTasks|Pending|ActiveTasks" | select @{n="hostname";e={$_.hosts.name}},name,@{e={(convertfrom-epoch $_.lastclock).addhours(+1)};n="Time"},@{n="lastvalue";e={[math]::round(($_.lastvalue),2)}} | sort hostname,name | ft -a
        Cassandra: Get-ZabbixItem -ItemName 'disk' -HostId (Get-ZabbixHost | ? name -match "cassandraNodes").hostid | ? key_ -match "cassandra,free" | select @{n="hostname";e={$_.hosts.name}},key_,@{e={(convertfrom-epoch $_.lastclock).addhours(+1)};n="Time"},@{n="prevvalue";e={[math]::round(($_.prevvalue/1gb),2)}},@{n="lastvalue";e={[math]::round(($_.lastvalue/1gb),2)}} | sort hostname | ft -a
        Cassandra: Get-ZabbixItem -ItemName 'byte' -HostId (Get-ZabbixHost | ? name -match "cassandraNodes").hostid | select @{n="hostname";e={$_.hosts.name}},key_,@{e={(convertfrom-epoch $_.lastclock).addhours(+1)};n="Time"},@{n="prevvalue";e={[math]::round(($_.prevvalue/1gb),2)}},@{n="lastvalue";e={[math]::round(($_.lastvalue/1gb),2)}} | sort hostname | ft -a
	#>
	
	[CmdLetBinding(DefaultParameterSetName = "None")]
	[Alias("gzi")]
	Param (
		[String]$SortBy = "name",
		[String]$ItemKey,
		[String]$ItemName,
		[string]$Description,
		[Parameter(ParameterSetName = "hostname", Mandatory = $False, ValueFromPipelineByPropertyName = $true)][String]$HostName,
		[Parameter(ParameterSetName = "hostid", Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$HostId,
		[Parameter(ParameterSetName = "hostid", Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$TemplateID,
		[Parameter(ParameterSetName = "hostid", Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$TriggerID,
		[switch]$WebItems,
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
			method  = "item.get"
			params  = @{
				output             = "extend"
				webitems           = $WebItems
				triggerids         = $TriggerID
				templateids        = $TemplateID
				hostids            = @($HostID)
				groupids           = $GroupID
				
				selectInterfaces   = "extend"
				selectTriggers     = "extend"
				selectApplications = "extend"
				selectHosts        = @(
					"hostid",
					"name"
				)
				sortfield          = $sortby
				
				search             = @{
					key_ = $ItemKey
					name = $ItemName
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

