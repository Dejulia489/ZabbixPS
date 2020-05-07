Function New-ZabbixTrigger
{
	<# 
	.Synopsis
		Create new trigger settings
	.Description
		Create new trigger settings
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
	[Alias("nztr")]
	Param (
		# [Parameter(ValueFromPipelineByPropertyName=$true)]$TriggerID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)]$TriggerDescription,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)]$TriggerExpression,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)]$status,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$TemplateID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$triggertags,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$dependencies,
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

		write-verbose ("dependencies: " + $dependencies.length)

		for ($i = 0; $i -lt $dependencies.length; $i++) { [array]$depnds += $(@{triggerid = $($dependencies[$i]) })
  }

		$Body = @{
			method  = "trigger.create"
			params  = @{
				description  = $TriggerDescription
				expression   = $TriggerExpression
				# triggerid = $TriggerID
				status       = $status
				dependencies = @($depnds)
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