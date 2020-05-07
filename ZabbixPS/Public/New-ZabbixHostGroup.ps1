Function New-ZabbixHostGroup
{
	<# 
	.Synopsis
		Create host group
	.Description
		Create host group
	.Parameter GroupName
		To filter by name of the group
	.Parameter GroupID
		To filter by id of the group
	.Example
		New-ZabbixHostGroup -Name newHostGroupName
		Create new host group 
	#>
    
	[CmdletBinding()]
	[Alias("nzhg")]
	Param (
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$Name,
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
			method  = "hostgroup.create"
			params  = @{	
				name = $Name
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

