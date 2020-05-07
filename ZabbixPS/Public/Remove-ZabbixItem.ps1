Function Remove-ZabbixItem
{
	<# 
	.Synopsis
		Remove item
	.Description
		Remove item
	.Parameter status
		status: 0 (enabled), 1 (disabled)
	.Parameter TemplateID
		Get by TemplateID
	.Example
		Get-ZabbixHost | ? name -match "host" | Get-ZabbixItem | ? key_ -match 'key1|key2|key3' | Remove-ZabbixItem
		Delete items from the host configuration
	#>
    
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
	[Alias("rzi")]
	Param (
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$Name,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$applicationid,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$status,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$itemid,
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
		
		if ($applicationid)
		{
			$Body = @{
				method  = "item.delete"
				params  = @{
					itemid       = $itemid
					applications = $applicationid
				}

				jsonrpc = $jsonrpc
				id      = $id
				auth    = $session
			}
		}
		else
		{
			$Body = @{
				method  = "item.delete"
				params  = @{
					itemid = $itemid
				}

				jsonrpc = $jsonrpc
				id      = $id
				auth    = $session
			}
		}

		$BodyJSON = ConvertTo-Json $Body
		write-verbose $BodyJSON
		
		if ([bool]$WhatIfPreference.IsPresent) { }
		if ($PSCmdlet.ShouldProcess($Name, "Delete"))
		{  
			$a = Invoke-RestMethod "$URL/api_jsonrpc.php" -ContentType "application/json" -Body $BodyJSON -Method Post
		}
		$a = Invoke-RestMethod "$URL/api_jsonrpc.php" -ContentType "application/json" -Body $BodyJSON -Method Post
		if ($a.result) { $a.result } else { $a.error }
	}
}

