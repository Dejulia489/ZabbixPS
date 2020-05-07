Function Get-ZabbixGraph
{ 
	<#
	.Synopsis
		Get graph
	.Description
		Get graph
	.Example
		Get-ZabbixHost | ? name -eq "singleHost" | Get-ZabbixGraph | select name
		Get graphs for single host
	.Example
		Get-ZabbixHost | ? name -match hosName |  Get-ZabbixGraph | select name
		Get graphs for multiple hosts	
	.Example	
		Get-ZabbixHost | ? name -eq "singleHost" | Get-ZabbixGraph -expandName | ? name -match 'RAM utilization' | select name
        Get graphs for single host     
	.Example
        Get-ZabbixHost | ? name -eq "singleHost" | Get-ZabbixGraph -expandName | ? name -match 'RAM utilization' | select name -ExpandProperty gitems | ft -a
        Get graphs for single host	
	.Example	
		Get-ZabbixHost | ? name -eq "singleHost" | Get-ZabbixGraph -expandName | ? {!$_.graphDiscovery} | select name -ExpandProperty gitems | ft -a
        Get graphs for single host
    .Example
		Get-ZabbixHost | ? name -match "hostName" | Get-ZabbixGraph -expandName | ? {!$_.graphDiscovery} | select name -ExpandProperty gitems | ft -a
		Get graphs for multiple hosts
    .Example
		Get-ZabbixHost | ? name -match "hostName" | Get-ZabbixGraph -expandName | ? {!$_.graphDiscovery} | select name -ExpandProperty gitems -Unique | ft -a
		Get-ZabbixHost | ? name -match "hostName" | Get-ZabbixGraph  -expandName | ? { !$_.graphDiscovery } | select name -Unique
		Get graphs for multiple hosts, sort out duplicates
	.Example
        Get-ZabbixGraph -HostID (Get-ZabbixHost | ? name -match "multipleHosts").hostid | select @{n="host";e={$_.hosts.name}},name | ? host -match "host0[5,6]"| ? name -notmatch Network | sort host
        Get graphs for multiple hosts
	#>
    
	[cmdletbinding()]
	[Alias("gzgph")]
	Param (
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$HostID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$GroupID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$GraphID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$TemplateID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$ItemID,
		[switch]$expandName = $true,
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
			method  = "graph.get"
			params  = @{
				output               = "extend"
				selectTemplates      = "extend"
				selectHosts          = @(
					"hostid",
					"name"
				)
				selectItems          = "extend"
				selectGraphItems     = "extend"
				selectGraphDiscovery = "extend"
				expandName           = $expandName
				hostids              = $HostID
				graphids             = $GraphID
				templateids          = $TemplateID
				itemids              = $ItemID
				sortfield            = "name"
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