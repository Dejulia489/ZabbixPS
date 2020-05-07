Function Set-ZabbixHostInterface
{ 
	<#
	.Synopsis
		Set host interface
	.Description
		Set host interface
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
		Get-ZabbixHost | ? name -match host | Get-ZabbixHostInterface | %{Set-ZabbixHostInterface -IP 10.20.10.10 -InterfaceID $_.interfaceid -HostID $_.hostid -Port $_.port}
		Set new IP to multiple host interfaces
	.Example
		Get-ZabbixHost | ? name -match host | Get-ZabbixHostInterface | ? port -notmatch "10050|31001" | ? main -match 1 | Set-ZabbixHostInterface -main 0
		Set interfaces on multiple hosts to be not default 	
	.Example
		Get-ZabbixHost | ? name -match host | Get-ZabbixHostInterface | ? port -match 31021 | Set-ZabbixHostInterface -main 0
		Set interface matches port 31021 on multiple hosts to default
	.Example
		Get-ZabbixHost -HostName MyHost | Get-ZabbixHostInterface | Set-ZabbixHostInterface -dns MyHost.example.com -useIP 0
		Set interface DNS name and order to connect to host by DNS name and not by IP address
	.Example
		Get-ZabbixHost | ? name -match host | Get-ZabbixHostInterface | ? type -eq 4 | Remove-ZabbixHostInterface
		Remove all JMX (type 4) interfaces from host
	#>
	[cmdletbinding()]
	[Alias("szhsti")]
	Param (
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$HostID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$InterfaceID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$IP,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$DNS = "",
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$Port,
		#Main: Possible values are:  0 - not default;  1 - default. 
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$main,
		#Type: Possible values are:  1 - agent;  2 - SNMP;  3 - IPMI;  4 - JMX. 
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$type = "4",
		#UseIP: Possible values are:  0 - connect using host DNS name;  1 - connect using host IP address for this host interface. 
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$useIP = "1",
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
			method  = "hostinterface.update"
			params  = @{
				hostid      = $HostID
				interfaceid = $InterfaceID
				port        = $Port
				ip          = $IP
				main        = $main
				dns         = $DNS
				useip       = $useIP
				type        = $type
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
######### --> This should be checked ---> end

