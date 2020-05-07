Function Remove-ZabbixHostGroup
{
	<# 
	.Synopsis
		Remove host group
	.Description
		Remove host group
	.Parameter GroupName
		To filter by name of the group
	.Parameter GroupID
		To filter by id of the group
	.Example
		Get-ZabbixHostGroup | ? name -eq hostGroupName | Remove-ZabbixHostGroup -WhatIf
		WhatIf on remove host group (case insensitive)
	.Example
		Get-ZabbixHostGroup ExactGroupName | Remove-ZabbixHostGroup
		Remove host group (case sensitive)
	#>
    
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
	[Alias("rzhg")]
	Param (
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$Name,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][array]$GroupID,
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
			method  = "hostgroup.delete"
			params  = @($GroupID)	

			jsonrpc = $jsonrpc
			id      = $id
			auth    = $session
		}

		$BodyJSON = ConvertTo-Json $Body
		write-verbose $BodyJSON
		
		if ([bool]$WhatIfPreference.IsPresent) { }
		if ($PSCmdlet.ShouldProcess($Name, "Delete"))
		{  
			$a = Invoke-RestMethod "$URL/api_jsonrpc.php" -ContentType "application/json" -Body $BodyJSON -Method Post
		}
		
		if ($a.result) { $a.result } else { $a.error }
	}
}

