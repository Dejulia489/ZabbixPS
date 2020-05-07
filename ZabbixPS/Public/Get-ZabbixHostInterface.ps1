Function Get-ZabbixHostInterface
{ 
	<#
	.Synopsis
		Get host interface
	.Description
		Get host interface
	.Example
		Get-ZabbixHostInterface -HostID (Get-ZabbixHost -HostName ThisHost).hostid |ft -a
		Get interface(s) for single host (case sensitive)
	.Example	
		Get-ZabbixHostInterface -HostID (Get-ZabbixHost | ? name -match hostName).hostid
		Get interface(s) for multiple hosts (case insensitive)
	.Example
		Get-ZabbixHost -HostName HostName | Get-ZabbixHostInterface | ft -a
		Get interfaces for host
	.Example	
		hGet-ZabbixHost | ? name -match HostName | Get-ZabbixHostInterface | ft -a
		Get interfaces for multiple hosts
	.Example	
		Get-ZabbixHost | ? name -match HostName | Get-ZabbixHostInterface | ? port -match 10050 | ft -a
		Get interface matching port for multiple hosts
	.Example	
		Get-ZabbixHost -HostName HostName | Get-ZabbixHostInterface
		Get interface(s) for single host (case sensitive)
	.Example
		Get-ZabbixHost | ? name -match hostsName | %{$n=$_.name; Get-ZabbixHostInterface -HostID $_.hostid} | select @{n="name";e={$n}},hostid,interfaceid,ip,port | sort name | ft -a
		Get interface(s) for the host(s)
	#>
	[cmdletbinding()]
	[Alias("gzhsti")]
	Param (
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$HostID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][string]$jsonrpc = ($global:zabSessionParams.jsonrpc),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][string]$session = ($global:zabSessionParams.session),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][string]$id = ($global:zabSessionParams.id),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][string]$URL = ($global:zabSessionParams.url)
	)
	
	process
 {
		
		if (!(Get-ZabbixSession)) { return }

		$boundparams = $PSBoundParameters | out-string
		write-verbose "($boundparams)"

		$Body = @{
			method  = "hostinterface.get"
			params  = @{
				output  = "extend"
				hostids = $HostID
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

