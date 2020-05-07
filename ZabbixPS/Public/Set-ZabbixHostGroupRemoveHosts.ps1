Function Set-ZabbixHostGroupRemoveHosts
{
	<# 
	.Synopsis
		Set host group: remove hosts from multiple groups 
	.Description
		Set host group: remove hosts from multiple groups
	.Parameter GroupName
		To filter by name of the group
	.Parameter GroupID
		To filter by id of the group
	.Example
		Get-ZabbixHostGroup | ? name -eq hostGroup | select groupid -ExpandProperty hosts | ? host -match hostsToRemove | Set-ZabbixHostGroupRemoveHosts
		Remove hosts from the host group
	.Example
		Get-ZabbixHostGroup | ? name -eq hostGroup | Set-ZabbixHostGroupRemoveHosts -HostID (Get-ZabbixHost | ? name -match hostsToRemove).hostid
		Remove hosts from the host group 
	.Example
		Set-ZabbixHostGroupRemoveHosts -GroupID ( Get-ZabbixHostGroup | ? name -match "hostGroup-0[1-6]").groupid -HostID (Get-ZabbixHost | ? name -match "hostname-10[1-9]").hostid -hostName (Get-ZabbixHost | ? name -match "hostname-10[1-9]").name -verbose
		Remove hosts from the host groups with extra verbosity and validation
	.Example
		Get-ZabbixHost | ? name -match hostsToRemove | Set-ZabbixHostGroupRemoveHosts -GroupID (Get-ZabbixHostGroup | ? name -match hostGroup).groupid
		Get-ZabbixHostGroup -GroupID 25 | select -ExpandProperty hosts
		Get-ZabbixHostGroup | select groupid,name,hosts
		1.Remove hosts from the host group 2.Validate the change 3.Validate the change
	.Example 
		Set-ZabbixHostGroupRemoveHosts -GroupID 25 -TemplateID (Get-ZabbixTemplate | ? name -match "template1|template2").templateid
		Remove templates from host group
	.Example
		Set-ZabbixHostGroupRemoveHosts -GroupID 25 -TemplateID (Get-ZabbixTemplate | ? name -match "template1|template2").templateid -HostID (Get-ZabbixHost | ? name -match "host").hostid
		Get-ZabbixHostGroup -GroupID 25
		1.Remove hosts and templates from the host group 2.Validate the change
	#>
    
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
	[Alias("szhgrh")]
	Param (
		[Alias("name")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$GroupName,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][array]$GroupID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][array]$HostID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][array]$TemplateID,
		[Alias("host")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][array]$HostName,
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
			method  = "hostgroup.massremove"
			params  = @{
				groupids = @($GroupID)
				# hostids = @($HostID)
				# templateids = @($TemplateID)
			}
			
			jsonrpc = $jsonrpc
			id      = $id
			auth    = $session
		}

		if ($HostID) { $Body.params.hostids = @($HostID) }
		if ($TemplateID) { $Body.params.templateids = @($TemplateID) }

		$BodyJSON = ConvertTo-Json $Body
		write-verbose $BodyJSON
		
		try
		{
			if ([bool]$WhatIfPreference.IsPresent) { }

			if ($PSCmdlet.ShouldProcess((@($HostID) + @($hostName) + (@($TemplateID))), "Delete"))
			{  
				$a = Invoke-RestMethod "$URL/api_jsonrpc.php" -ContentType "application/json" -Body $BodyJSON -Method Post
				if ($a.result) { $a.result } else { $a.error }
			}
		}
		catch
		{
			Write-Host "$_"
			Write-Host "Too many entries to return from Zabbix server. Check/reduce the filters." -f cyan
		}
	}
}


