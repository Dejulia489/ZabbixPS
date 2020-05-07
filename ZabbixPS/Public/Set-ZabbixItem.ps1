Function Set-ZabbixItem
{
	<# 
	.Synopsis
		Set item properties
	.Description
		Set item properties
	.Parameter status
		status: 0 (enabled), 1 (disabled)
	.Parameter TemplateID
		Get by TemplateID
	.Example
		Get-ZabbixItem -TemplateID (Get-ZabbixTemplate | ? name -match "template").templateid | Set-ZabbixItem -status 1
		Disable items in the template(s)
	.Example
		Get-ZabbixItem -TemplateID (Get-ZabbixTemplate | ? name -match "template").templateid | sort name | select itemid,name,status | ? name -match name | select -first 1 | Set-ZabbixItem -status 0 -verbose
		Enable items in the template
	.Example
		Get-ZabbixItem -TemplateID (Get-ZabbixTemplate | ? name -match "template").templateid | sort name | select itemid,name,status | ? name -match name | ? status -match 0 | Set-ZabbixItem -status 1
		Disable items in the template
	.Example
		Get-ZabbixItem -TemplateID (Get-ZabbixTemplate | ? name -match "template").templateid | sort name | ? name -match name | Set-ZabbixItem -applicationid (Get-ZabbixApplication | ? name -match "application").applicationid -verbose
		Set application(s) for the items
	.Example
		Get-ZabbixHost | ? name -match "host" | Get-ZabbixItem | ? key_ -match "key" | ? status -match 0 | select hostid,itemid,key_,status | sort hostid,key_ | Set-ZabbixItem -status 1
		Disable host items (set status to 1)
	#>
    
	[CmdletBinding()]
	[Alias("szi")]
	Param (
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
				method  = "item.update"
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
				method  = "item.update"
				params  = @{
					itemid = $itemid
					status = $status
				}

				jsonrpc = $jsonrpc
				id      = $id
				auth    = $session
			}
		}

		$BodyJSON = ConvertTo-Json $Body
		write-verbose $BodyJSON
		
		$a = Invoke-RestMethod "$URL/api_jsonrpc.php" -ContentType "application/json" -Body $BodyJSON -Method Post
		if ($a.result) { $a.result } else { $a.error }
	}
}