Function Set-ZabbixHostGroupAddHosts
{
	<# 
	.Synopsis
		Set host group: add hosts to multiple groups 
	.Description
		Set host group: add hosts to multiple groups
	.Parameter GroupName
		To filter by name of the group
	.Parameter GroupID
		To filter by id of the group
	.Example
		Get-ZabbixHostGroup | ? name -eq hostGroup | Set-ZabbixHostGroupAddHosts -HostID (Get-ZabbixHost | ? name -match "host").hostid
		Add hosts to the host group
	.Example
		Get-ZabbixHostGroup | ? name -match hostGroups | Set-ZabbixHostGroupAddHosts -HostID (Get-ZabbixHost | ? name -match hosts).hostid
		Add hosts to multiple groups
	.Example
		Get-ZabbixHostGroup -GroupID 25 | Set-ZabbixHostGroupAddHosts -TemplateID (get-zabbixtemplate | ? name -match template1|template2).templateid
		Add templates to the host group
	#>
    
	[CmdletBinding()]
	[Alias("szhgah")]
	Param (
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$Name,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$GroupID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$HostID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$TemplateID,
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
			method  = "hostgroup.massadd"
			params  = @{
				groups = @($GroupID)
				# hosts = @($HostID)
				# templates = @($TemplateID)
			}
			
			jsonrpc = $jsonrpc
			id      = $id
			auth    = $session
		}
		
		if ($HostID) { $Body.params.hosts = @($HostID) }
		if ($TemplateID) { $Body.params.templates = @($TemplateID) }

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

