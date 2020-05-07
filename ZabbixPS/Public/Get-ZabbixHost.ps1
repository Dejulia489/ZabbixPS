Function Get-ZabbixHost
{
	<# 
	.Synopsis
		Get hosts
	.Description
		Get hosts
	.Parameter HostName
		To filter by HostName of the host (case sensitive)
	.Parameter HostID
		To filter by HostID of the host
	.Example
		Get-ZabbixHost
		Get all hosts
	.Example  
		Get-ZabbixHost -HostName SomeHost
		Get host by name (case sensitive)
	.Example
		Get-ZabbixHost | ? name -match host | select hostid,host,status,available,httptests
		Get host(s) by name match (case insensitive)
    .Example
        Get-ZabbixHost | ? name -match host | select -ExpandProperty interfaces -Property name | sort name
        Get hosts' interfaces by host name match (case insensitive)        
	.Example
		Get-ZabbixHost  | ? name -match host | Get-ZabbixTemplate | select templateid,name -Unique
		Get templates by name match (case insensitive)
	.Example
		Get-ZabbixHost | ? status -eq 1 | select hostid,name
		Get only disabled hosts
	.Example
		Get-ZabbixHost -sortby name | ? name -match host | select hostid,host,status -ExpandProperty httptests
		Get host(s) by name match (case insensitive), sort by name. Possible values are: hostid, host, name (default), status
	.Example
		Get-ZabbixHost | ? name -match HostName | select name,*error* | ft -a
		Get all errors for hosts
	.Example
		Get-ZabbixHost | ? name -match HostName | select name,*jmx* | ft -a
		Get info regarding JMX connections for hosts
	.Example
		Get-ZabbixHost | ? name -match "" | ? jmx_available -match 1 | select hostid,name,jmx_available
		Get host(s) with JMX interface(s) active
	.Example
		Get-ZabbixHost | ? parentTemplates -match "jmx" | select hostid,name,available,jmx_available
		Get host(s) with JMX Templates and get their connection status
	.Example
		Get-ZabbixHost | ? status -eq 0 | ? available -eq 0 | select hostid,name,status,available,jmx_available | ft -a
		Get hosts, which are enabled, but unreachable
	.Example
		Get-ZabbixHost -GroupID (Get-ZabbixGroup -GroupName "groupName").groupid | ? httpTests | select hostid,host,status,available,httptests | sort host | ft -a
		Get host(s) by host group, match name "GroupName" (case sensitive)
	.Example
		Get-ZabbixHost -hostname HostName | Get-ZabbixItem -WebItems -ItemKey web.test.error -ea silent | select name,key_,lastclock
		Get web tests items for the host (HostName is case sensitive)
	.Example
		(Get-ZabbixHost | ? name -match host).parentTemplates.name
		Get templates, linked to the host by hostname match (case insensitive) 
	.Example
		Get-ZabbixHost | ? name -match hostName | select host -ExpandProperty parentTemplates
		Get templates, linked to the host(s)
	.Example
		Get-ZabbixHost | ? parentTemplates -match "jmx" | select name -Unique
		Get hosts with templates, by template name match
	.Example
		Get-ZabbixHost -HostName HostName | Get-ZabbixItem -WebItems -ItemKey web.test.error -ea silent | select name,key_,@{n='lastclock';e={convertFrom-epoch $_.lastclock}}
		Get Items for the host. Item lastclock (last time it happened in UTC)
	.Example
		Get-ZabbixHost -hostname HostName | Get-ZabbixHttpTest -ea silent | select httptestid,name,steps
		Get host (case sensitive) and it's HttpTests
    .Example
        Get-ZabbixHost -hostname HostName | Get-ZabbixHttpTest -ea silent | select -ExpandProperty steps | ft -a
        Get host (case sensitive) and it's HttpTests
    .Example
        Get-ZabbixHost | ? name -match hostName | select host -ExpandProperty interfaces | ? port -match 10050
        Get interfaces for the host(s)    
    .Example
		Get-ZabbixHost | ? name -match hostname | Get-ZabbixHostInterface | ? port -match 10050 | ft -a
		Get interfaces for the host(s)	
	.Example
		Get-ZabbixHost | ? name -match hostsName | %{$n=$_.name; Get-ZabbixHostInterface -HostID $_.hostid} | select @{n="name";e={$n}},hostid,interfaceid,ip,port | sort name | ft -a
		Get interface(s) for the host(s)
	#>
	
	[CmdletBinding()]
	[Alias("gzhst")]
	Param (
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)]$HostName,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][array]$HostID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][array]$GroupID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][array]$HttpTestID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][string]$SortBy = "name",
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$status,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$jsonrpc = ($global:zabSessionParams.jsonrpc),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$session = ($global:zabSessionParams.session),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$id = ($global:zabSessionParams.id),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$URL = ($global:zabSessionParams.url)
	)
	
	process
 {

		if (!(Get-ZabbixSession)) { return }
		# if (!$psboundparameters.count -and !$global:zabSessionParams) {Get-Help -ex $PSCmdlet.MyInvocation.MyCommand.Name | out-string | Remove-EmptyLines; return}

		$boundparams = $PSBoundParameters | out-string
		write-verbose "($boundparams)"

		$Body = @{
			method  = "host.get"
			params  = @{
				output                = "extend"
				selectGroups          = @(
					"groupid",
					"name"
				)
				selectParentTemplates = @(
					"templateid",
					"name"
				)
				selectInterfaces      = @(
					"interfaceid",
					"ip",
					"port"
				)
				selectHttpTests       = @(
					"httptestid",
					"name",
					"steps"
				)
				selectTriggers        = @(
					"triggerid",
					"description"
				)
				selectApplications    = @(
					"applicationid"
					"name"
				)
				selectGraphs          = @(
					"graphid"
					"name"
				)
				selectMacros          = @(
					"hostmacroid"
					"macro"
					"value"
				)
				selectScreens         = @(
					"screenid"
					"name"
				)
				selectInventory       = @(
					"name"
					"type"
					"os"
				)
				hostids               = $HostID
				groupids              = $GroupID
				httptestid            = $HttpTestID
				filter                = @{
					host = $HostName
				}
				sortfield             = $SortBy
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

