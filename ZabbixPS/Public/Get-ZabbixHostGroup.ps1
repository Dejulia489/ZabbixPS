Function Get-ZabbixHostGroup
{
	<#
	.Synopsis
		Get host group
	.Description
		Get host group
	.Parameter GroupName
		Filter by name of the group
	.Parameter GroupID
		Filter by id of the group
	.Example
		Get-ZabbixHostGroup
		Get host groups
	.Example
		(Get-ZabbixHostGroup -GroupName somegroup).hosts
		Get hosts from host group (case sensitive)
	.Example
		(Get-ZabbixHostGroup | ? name -match somegroup).hosts
		Get host group and hosts (case insensitive)
	.Example
		Get-ZabbixHostGroup | ? name -match somegroup | select name -ExpandProperty hosts | sort host | ft -a
		Get host group and it's hosts
	.Example
		Get-ZabbixHostGroup -GroupID 10001 | select name -ExpandProperty hosts
		Get group and it's hosts
	.Example
		Get-ZabbixHostGroup | ? name -match templates | select -ExpandProperty templates
		Get group of templates	
	#>

	[CmdletBinding()]
	[Alias("gzhg", "Get-ZabbixGroup")]
	Param (
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)]$GroupName,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)]$GroupID,
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
			method  = "hostgroup.get"
			params  = @{
				output          = "extend"
				selectHosts     = @(
					"hostid",
					"host"
				)
				selectTemplates = @(
					"templateid",
					"name"
				)
				filter          = @{
					name = $GroupName
				}
				groupids        = $GroupID
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
