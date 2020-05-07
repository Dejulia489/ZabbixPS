Function Set-ZabbixTrigger
{
	<# 
	.Synopsis
		Set/Update trigger settings
	.Description
		Set/Update trigger settings
	.Parameter TriggerID
		TriggerID
	.Example
		Get-ZabbixHost -HostName HostName | Get-ZabbixTrigger -ea silent | ? status -match 0 | ? expression -match "V:,pfree" | Set-ZabbixTrigger -status 1 -Verbose
        Disable trigger
	.Example
		Get-ZabbixTrigger -TemplateID (Get-zabbixTemplate | ? name -match "Template Name").templateid | ? description -match "trigger description" | Set-ZabbixTrigger -status 1
		Disable trigger
	.Example
		Get-ZabbixHost | ? name -match server0[1-5,7] | Get-ZabbixTrigger -ea silent | ? status -match 0 | ? expression -match "uptime" | select triggerid,expression,status | Set-ZabbixTrigger -status 1
		Disable trigger on multiple hosts
	.Example
		Get-ZabbixTemplate | ? name -match "Template" | Get-ZabbixTrigger | ? description -match triggerDescription | Set-ZabbixTrigger -status 0
		Enable trigger
	#>

	[CmdletBinding()]
	[Alias("sztr")]
	Param (
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)]$TriggerID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)]$status,
		[switch]$ExpandDescription,
		[switch]$ExpandExpression,
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
			method  = "trigger.update"
			params  = @{
				triggerid = $TriggerID
				status    = $status
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

