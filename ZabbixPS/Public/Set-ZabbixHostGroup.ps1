Function Set-ZabbixHostGroup
{
	<# 
	.Synopsis
		Set host group
	.Description
		Set host group
	.Parameter GroupName
		To filter by name of the group
	.Parameter GroupID
		To filter by id of the group
	.Example
		Get-ZabbixHostGroup | ? name -eq oldName | Set-ZabbixHostGroup -name newName
		Rename host group 
	#>
    
	[CmdletBinding()]
	[Alias("szhg", "Set-ZabbixGroup")]
	Param (
		[Alias("name")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$GroupName,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$GroupID,
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
			method  = "hostgroup.update"
			params  = @{
				groupid = $GroupID
				name    = $GroupName
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

