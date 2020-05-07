Function Remove-ZabbixMaintenance
{
	<# 
	.Synopsis
		Remove maintenance
	.Description
		Remove maintenance
	.Parameter MaintenanceID
		To filter by ID/IDs of the maintenance
	.Example
		Remove-ZabbixMaintenance -MaintenanceID "3","4" 
		Remove maintenance by IDs
	.Example
		Remove-ZabbixMaintenance -MaintenanceID (Get-ZabbixMaintenance | ? name -match "Maintenance|Name").maintenanceid -WhatIf
		Remove multiple maintenances (check only: -WhatIf)
    .Example
		Remove-ZabbixMaintenance -MaintenanceID (Get-ZabbixMaintenance | ? name -match "Maintenance|Name").maintenanceid
		Remove multiple maintenances
	.Example
		Get-ZabbixMaintenance | ? name -eq name | Remove-ZabbixMaintenance
		Remove single maintenance by name
	#>
    
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
	[Alias("rzm")]
	Param (
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$Name,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$MaintenanceID,
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
			method  = "maintenance.delete"
			params  = @($MaintenanceID)
			
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

