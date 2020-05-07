Function Get-ZabbixTrigger
{
	<# 
	.Synopsis
		Get trigger
	.Description
		Get trigger
	.Parameter TriggerID
		To filter by ID of the trigger
	.Example
        Get-ZabbixTrigger -HostID (Get-ZabbixHost | ? name -match host).hostid | select status,description,expression
        Get triggers from host 
	.Example
		Get-ZabbixTrigger -HostID (Get-ZabbixHost | ? name -match host).hostid | ? expression -match system | select triggerid,status,state,value,expression
		Get triggers from host, matches "system" in expression line
	.Example
		Get-ZabbixTrigger -HostID (Get-ZabbixHost | ? name -match host).hostid | ? value -eq 1 | select @{n='lastchange(UTC)';e={convertFrom-epoch $_.lastchange}},triggerid,status,state,value,expression | ft -a
		Get failed triggers from host: values: 0 is OK, 1 is problem
	.Example
		Get-ZabbixTemplate | ? name -match "TemplateName" | Get-ZabbixTrigger | select status,description,expression
		Get triggers from template
	.Example
		Get-ZabbixTemplate | ? name -match "Template OS Linux" | Get-ZabbixTrigger | ? status -eq 0 | ? expression -match system | select status,description,expression
		Get triggers from template
	.Example
		Get-ZabbixTrigger -TemplateID (Get-ZabbixTemplate | ? name -match Template).templateid -ExpandDescription -ExpandExpression | ft -a status,description,expression
		Get triggers by templateid (-ExpandDescription and -ExpandExpression will show full text instead of ID only)
	.Example 
		Get-ZabbixTrigger -TemplateID (Get-ZabbixTemplate | ? name -eq "Template OS Linux").templateid | select status,description,expression
		Get list of triggers from templates
	.Example
		Get-ZabbixTrigger -ExpandDescription -ExpandExpression | ? description -match "Template" | select description,expression
		Get triggers where description match the string (-ExpandDescription and -ExpandExpression will show full text instead of ID only)
	.Example
		Get-ZabbixHost -HostName HostName | Get-ZabbixTrigger -ea silent | ? status -match 0 | ft -a status,templateid,description,expression
		Get triggers for host (status 0 == enabled, templateid 0 == assigned directly to host, not from template) 
	.Example
		Get-ZabbixHost | ? name -match host | Get-ZabbixTrigger | select description,expression | ft -a -Wrap
		Get triggers for host
	#>
    
	[CmdletBinding()]
	[Alias("gztr")]
	Param (
		[switch]$ExpandDescription,
		[switch]$ExpandExpression,
		[array]$TriggerID,
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

		$boundparams = $PSBoundParameters | out-string
		write-verbose "($boundparams)"

		$Body = @{
			method  = "trigger.get"
			params  = @{
				output              = "extend"
				selectFunctions     = "extend"
				selectLastEvent     = "extend"
				selectGroups        = "extend"
				selectHosts         = "extend"
				selectDependencies  = "extend"
				selectTags          = "extend"
				selectDiscoveryRule = "extend"
				expandDescription   = $ExpandDescription
				expandExpression    = $ExpandExpression
				expandComment       = $ExpandComment
				triggerids          = $TriggerID
				templateids         = $TemplateID
				hostids             = $HostID
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
