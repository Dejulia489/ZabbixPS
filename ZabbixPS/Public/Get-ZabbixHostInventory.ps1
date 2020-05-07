Function Get-ZabbixHostInventory
{
	<# 
	.Synopsis
		Get host's inventory
	.Description
		Get host's inventory
	.Parameter HostName
		To filter by HostName of the host (case sensitive)
	.Parameter HostID
		To filter by HostID of the host
	.Example
		Get-ZabbixHostInventory -HostName HostName1,HostName2 
		Get full inventory for host (HostName is case sensitive)
	.Example
		Get-ZabbixHost | ? name -match host | ? inventory | Get-ZabbixHostInventory
		Get hosts with inventory
	.Example  
		Get-ZabbixHostInventory HostName1,HostName2 | ? os | select name,os,tag | ft -a
		Get inventory for hosts (HostName is case sensitive)
	.Example  
		(gc server-HostNames.txt) | %{Get-ZabbixHostInventory $_ | select name,os,tag } | ft -a
		Get inventory for hosts (HostName is case sensitive))
	.Example
		Get-ZabbixHostInventory -HostID (gc server-hostids.txt | Out-String -Stream) | select hostid,name,location,os,os_* | ft -a
		Get inventory
	.Example
		Get-ZabbixHostInventory -GroupID 15 | select name,os,os_full,os_short,location
		Get inventory for host in host group 15
    .Example
        Get-ZabbixHostInventory -GroupID 15 | ? inventory_mode -eq 0 | select hostid,@{n='hostname';e={(Get-ZabbixHost -HostID $_.hostid).host}},inventory_mode,name | ft -a
        Get Inventory for hosts in specific host group with GroupID 15
	.Example
		(Get-ZabbixHostGroup | ? name -eq HostGroup) | Get-ZabbixHostInventory | select hostid,name,os
		Get inventory for hosts in HostGroup
	.Example
		(Get-ZabbixHostGroup | ? name -eq HostGroup) | Get-ZabbixHostInventory | Set-ZabbixHostInventory -OSName OSName
		Set hosts' OSName to all hosts in HostGroup
	.Example
		(Get-ZabbixHostGroup | ? groupid -eq 16) | Get-ZabbixHostInventory | select hostid,name,os,os_full
		(Get-ZabbixHostGroup | ? groupid -eq 16) | Get-ZabbixHostInventory | Set-ZabbixHostInventory -OSFullName "OSFullName"
		Set hosts' OSName to all hosts in HostGroup
	.Example
		Get-ZabbixHostInventory | ? os -match linux | select hostid,name,os,tag | sort os | ft -a
		Get only linux hosts
	.Example
		Get-ZabbixHostInventory | ? os | group os -NoElement | sort count -desc
		Get quantity of hosts for each OS
	
	#>
	
	[CmdletBinding()]
	[Alias("gzhstinv")]
	Param (
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][array]$HostName,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][array]$HostID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][array]$GroupID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][array]$InventoryMode,
		[string]$SortBy = "name",
		# [Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$true)][string]$hostids,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$status,
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
		write-verbose "$($hostname | out-string)"

		# for ($i=0; $i -lt $HostName.length; $i++) {[array]$hstn+=$(@{host = $($HostName[$i])})}
		if ($hostname.length -gt 3) { $HostName = $HostName.host }

		$Body = @{
			method  = "host.get"
			params  = @{
				selectInventory = "extend"
				# host = $HostName
				hostid          = $HostID
				groupids        = $GroupID
				# filter = @($hstn.host)
				inventory_mode  = $InventoryMode
				filter          = @{
					host    = $HostName
					hostid  = $HostID
					groupid = $GroupID
					# host = @($hstn)
				}
				sortfield       = $SortBy
			}
			
			jsonrpc = $jsonrpc
			id      = $id
			auth    = $session
		}

		$BodyJSON = ConvertTo-Json $Body -Depth 4
		write-verbose $BodyJSON
		
		try
		{
			$a = Invoke-RestMethod "$URL/api_jsonrpc.php" -ContentType "application/json" -Body $BodyJSON -Method Post
			# if ($a.result) {$a.result} else {$a.error}
			if ($a.result) { $a.result.inventory } else { $a.error }
		}
		catch
		{
			Write-Host "$_"
			Write-Host "Too many entries to return from Zabbix server. Check/reduce the filters." -f cyan
		}
	}
}