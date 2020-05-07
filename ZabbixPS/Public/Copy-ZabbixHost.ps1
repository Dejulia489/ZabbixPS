Function Copy-ZabbixHost
{
	<# 
	.Synopsis
		Copy/clone host
	.Description
		Copy/clone host
	.Parameter HostName
		HostName of the host as it will display on zabbix
	.Parameter IP
		IP address to supervise the host
	.Parameter DNSName
		Domain name to supervise the host
	.Parameter Port
		Port to supervise the host
	.Parameter GroupID
		ID of the group where add the host
	.Parameter TemplateID
		ID/IDs of the templates to add to the host
	.Parameter MonitorByDNSName
		If used, domain name of the host will used to contact it
	.Example
		Get-ZabbixHost -HostName SourceHost | Copy-ZabbixHost -HostName NewHost -IP 10.20.10.10
		Full copy of the host with new Hostname and IP
	.Example
		Get-ZabbixHost | ? name -eq sourceHost | Copy-ZabbixHost -HostName NewHost -IP 10.20.10.10
		Full clone of the host with new Hostname and IP
	.Example
		Get-ZabbixHost | ? name -eq SourceHost | Copy-ZabbixHost -HostName NewHost -IP 10.20.10.10 -status 1
		Full clone of the host with new Hostname and IP with status 1 (disabled)
	.Example
		Import-Csv c:\new-servers.csv | %{Get-ZabbixHost | ? name -eq SourceHost | Clone-ZabbixHost -HostName $_.Hostname -IP $_.IP}
		Mass clone new hosts
	#>
	
	[CmdletBinding()]
	[Alias("Clone-ZabbixHost", "czhst")]
	Param (
		[Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $false)][string]$HostName,
		[Parameter(DontShow, Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$HostID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $false)][array]$TemplateID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $false)][string]$IP,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$Port = 10050,
		[Parameter(DontShow, Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$interfaces,
		[Alias("parentTemplates")][Parameter(DontShow, Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$templates,
		[Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)][string]$status,
		[Parameter(DontShow, Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$groups,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $false)][string]$GroupID,
		[Parameter(DontShow, Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$httpTests,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $false)][int]$ProxyHostID,
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
			method  = "host.create"
			params  = @{
				host       = $HostName
				# interfaces = $interfaces
				interfaces = (Get-ZabbixHostInterface -HostID $hostid | select * -ExcludeProperty hostid, interfaceid, bulk)
				templates  = ($templates | select templateid)
				groups     = ($groups | select groupid)
				# proxy_hostid = $ProxyHostID
				status     = $Status
			}
			
			jsonrpc = $jsonrpc
			auth    = $session
			id      = $id
		}

		# if ($IP) {$Body.params.interfaces = }
		if ($httpTests) { $Body.params.httptests = ($httpTests | select httptestid) }
		if ($ProxyHostID) { $Body.params.proxy_hostid = $ProxyHostID }

		$BodyJSON = ConvertTo-Json $Body -Depth 3
		write-verbose $BodyJSON
		
		$a = Invoke-RestMethod "$URL/api_jsonrpc.php" -ContentType "application/json" -Body $BodyJSON -Method Post
		#$a.result.hostids
		if ($a.result)
		{
			$a.result
			write-verbose " --> Going to replace the IP address in cloned interfaces..."
			Get-ZabbixHost -HostName $HostName | Get-ZabbixHostInterface | Set-ZabbixHostInterface -IP $IP
		}
		else { $a.error }
	}
}

