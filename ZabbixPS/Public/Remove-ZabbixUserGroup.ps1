Function Remove-ZabbixUserGroup
{ 
	<#
	.Synopsis
		Remove/Delete user group
	.Description
		Remove/Delete user group
	.Parameter UserGroupID
		UserGroupID
	.Example
		Get-ZabbixUserGroup | ? name -match "group" | Remove-ZabbixUserGroup -WhatIf
		Whatif on delete multiple user groups
	.Example
		Get-ZabbixUserGroup | ? name -eq "UserGroup" | Remove-ZabbixUserGroup
		Delete user group
	.Example
		Remove-ZabbixUserGroup -UserGroupID (Get-ZabbixUserGroup | ? name -Match "UserGroup").usrgrpid -WhatIf
		Delete multiple user groups
	#>
	
	[cmdletbinding(SupportsShouldProcess, ConfirmImpact = 'High')]
	[Alias("rzug", "Delete-ZabbixUserGroup")]
	Param (
		[Alias("usrgrpid")][Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)][array]$UserGroupID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$UserGroupName,
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
			method  = "usergroup.delete"
			params  = @($UserGroupID)

			jsonrpc = $jsonrpc
			id      = $id
			auth    = $session
		}

		$BodyJSON = ConvertTo-Json $Body
		write-verbose $BodyJSON
		
		if ($UserGroupID.count -gt 0)
		{
			if ([bool]$WhatIfPreference.IsPresent) { }
			if ($PSCmdlet.ShouldProcess("$((Get-ZabbixUserGroup | ? usrgrpid -match ($UserGroupID -join "|")).name)", "Delete"))
			{  
				$a = Invoke-RestMethod "$URL/api_jsonrpc.php" -ContentType "application/json" -Body $BodyJSON -Method Post
			}
		}
		else
		{
			if ([bool]$WhatIfPreference.IsPresent) { }
			if ($PSCmdlet.ShouldProcess("$(Get-ZabbixUserGroup | ? usrgrpid -eq $UserGroupID | select usrgrpid,name)", "Delete"))
			{  
				$a = Invoke-RestMethod "$URL/api_jsonrpc.php" -ContentType "application/json" -Body $BodyJSON -Method Post
			}
		}
		
		if ($a.result) { $a.result } else { $a.error }
	}
}



