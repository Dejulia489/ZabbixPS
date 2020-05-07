Function New-ZabbixHostInterface
{ 
	<#
	.Synopsis
		Create host interface
	.Description
		Create host interface
	.Parameter HostID
		HostID
	.Parameter IP
		Interface IP address
	.Parameter DNS
		Interface DNS name
	.Parameter Port
		Interface Port
	.Parameter main
		Interface Main: Possible values are:  0 - not default;  1 - default
	.Parameter type
		Interface Type: Possible values are:  1 - agent;  2 - SNMP;  3 - IPMI;  4 - JMX
	.Parameter useIP
		Interface UseIP: Possible values are:  0 - connect using host DNS name;  1 - connect using host IP address for this host interface
	.Example
		Get-ZabbixHost | ? name -match host | New-ZabbixHostInterface -IP 10.20.10.15 -port 31721
		Create new interface for host
	.Example	
		Get-ZabbixHost | ? name -match "host01" | New-ZabbixHostInterface -Port 31721 -type 4 -main 1 -ip (Get-ZabbixHost | ? name -match "host01").interfaces.ip
		Create new interface for host
	.Example	
		Get-ZabbixHost | ? name -match hosts | select hostid,name,@{n="ip";e={$_.interfaces.ip}} | New-ZabbixHostInterface -Port 31001 -type 4 -main 1 -verbose
		Get-ZabbixHost | ? name -match hosts | select name,*error* | ft -a
		Create new JMX (-type 4) interface to hosts and check if interface has no errors 
	.Example	
		(1..100) | %{Get-ZabbixHost | ? name -match "host0$_" | New-ZabbixHostInterface -Port 31721 -type 4 -main 0 -ip (Get-ZabbixHost | ? name -match "host0$_").interfaces.ip[0]}
		Create new interface for multiple hosts 
	.Example
		(1..100) | %{Get-ZabbixHost | ? name -match "host0$_" | Get-ZabbixHostInterface | ? port -match 31751 | Set-ZabbixHostInterface -main 0}
		Make existing JMX port not default
	.Example		
		(1..100) | %{Get-ZabbixHost | ? name -match "host0$_" | New-ZabbixHostInterface -Port 31771 -type 4 -main 1 -ip (Get-ZabbixHost | ? name -match "host0$_").interfaces.ip[0]}
		Create new JMX interface and set it default
	.Example	
		Get-ZabbixItem -HostId (Get-ZabbixHost | ? name -match "one|two|three|four").hostid | ? key_ -match "version" | ? key_ -notmatch "VmVersion" | ? lastvalue -ne 0 | ? applications -match "app1|app2|app3|app3" | select @{n="host";e={$_.hosts.name}},@{n="Application";e={$_.applications.name}},lastvalue,key_,interfaces | sort host,application | ft -a
		Check whether new settings are working
	.Example
		Get-ZabbixHost | ? name -match hostname | Get-ZabbixHostInterface | ? port -match 31021 | Set-ZabbixHostInterface -main 0
		Get-ZabbixHost | ? name -match hostname | Get-ZabbixHostInterface | ? port -match 31021 | ft -a
		Get-ZabbixHost | ? name -match hostname | select hostid,name,@{n="ip";e={$_.interfaces.ip[0]}} | New-ZabbixHostInterface -Port 31001 -type 4 -main 1 -verbose
		Get-ZabbixHost | ? name -match hostname | Get-ZabbixHostInterface | ft -a
		Manually add new template for created interface 
		Run the checks: 
		Get-ZabbixHost | ? name -match hostname | select name,*error* | ft -a
		Get-ZabbixHost | ? name -match hostname | select name,*jmx* | ft -a
		Get-ZabbixItem -HostId (Get-ZabbixHost | ? name -match hostname).hostid | ? key_ -match "Version|ProductName|HeapMemoryUsage.used" | ? key_ -notmatch "vmver" | select  @{n="lastclock";e={(convertfrom-epoch $_.lastclock).addhours(+1)}},@{n="host";e={$_.hosts.name}},@{n="Application";e={$_.applications.name}},lastvalue,key_ | sort host,application,key_ | ft -a 
		Add new JMX interface with matching new JMX template, step by step	
	#>
	[cmdletbinding()]
	[Alias("nzhsti")]
	Param (
		[Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)][string]$HostID,
		[Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)][string]$IP,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$DNS = "",
		[Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)][string]$Port,
		#Main: Possible values are:  0 - not default;  1 - default. 
		[Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)][string]$main = "0",
		#Type: Possible values are:  1 - agent;  2 - SNMP;  3 - IPMI;  4 - JMX. 
		[Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)][string]$type = "4",
		#UseIP: Possible values are:  0 - connect using host DNS name;  1 - connect using host IP address for this host interface. 
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$useIP = "1",
		#[Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$true)][string]$InterfaceID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][string]$jsonrpc = ($global:zabSessionParams.jsonrpc),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][string]$session = ($global:zabSessionParams.session),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][string]$id = ($global:zabSessionParams.id),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][string]$URL = ($global:zabSessionParams.url)
	)
	
	process
 {

		if (!(Get-ZabbixSession)) { return }
		elseif (!$psboundparameters.count) { Write-MissingParamsMessage; return }

		$boundparams = $PSBoundParameters | out-string
		write-verbose "($boundparams)"

		$Body = @{
			method  = "hostinterface.create"
			params  = @{
				hostid = $HostID
				main   = $main
				dns    = $dns
				port   = $Port
				ip     = $IP
				useip  = $useIP
				type   = $type
			}

			jsonrpc = $jsonrpc
			id      = $id
			auth    = $session
		}

		$BodyJSON = ConvertTo-Json $Body
		write-verbose $BodyJSON
		
		$a = Invoke-RestMethod "$URL/api_jsonrpc.php" -ContentType "application/json" -Body $BodyJSON -Method Post
		if ($a.result) { $a.result } else { $a.error }
	}
}

