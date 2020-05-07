Function Set-ZabbixHost
{
	<# 
	.Synopsis
		Set/update host settings
	.Description
		Set/update host settings
	.Parameter HostID
		HostID
	.Parameter HostName
		Host name
	.Parameter HostVisibleName
		Host visible name: Default: host property value
	.Parameter HostDescription
		Description of the host
	.Parameter status
		Status and function of the host: Possible values are: 0 - (default) monitored host; 1 - unmonitored host
	.Parameter InventoryMode
		InventoryMode: Possible values are: -1 - disabled; 0 - (default) manual; 1 - automatic
	.Parameter IpmiAuthtype
		IPMI: IpmiAuthtype: IPMI authentication algorithm: Possible values are: -1 - (default) default; 0 - none; 1 - MD2; 2 - MD5 4 - straight; 5 - OEM; 6 - RMCP+
	.Parameter IpmiUsername
		IPMI: IpmiUsername: IPMI username
	.Parameter IpmiPassword
		IPMI: IpmiPassword: IPMI password
	.Parameter IpmiPrivilege
		IPMI: IpmiPrivilege: IPMI privilege level: Possible values are: 1 - callback; 2 - (default) user; 3 - operator; 4 - admin; 5 - OEM
	.Parameter GroupID
		GroupID of host group
	.Example
		Get-ZabbixHost | ? name -eq "host" | Set-ZabbixHost -status 0
		Enable host (-status 0)
	.Example
		(1..9) | %{(Get-ZabbixHost | ? name -eq "host0$_") | Set-ZabbixHost -status 1}
		Disable multiple hosts (-status 1)
	.Example
		Get-ZabbixHost | ? name -match "hostName" | Set-ZabbixHost -status 0
		Enable multiple hosts
	.Example
		Get-ZabbixHost | ? name -match hostName | Set-ZabbixHost -GroupID 14,16 -status 0
		Set HostGroups for the host(s) and enable it
	.Example
		Get-ZabbixHost | ? name -eq hostName | Set-ZabbixHost -removeTemplates -WhatIf
		WhatIf on delete and clear of all templates from the host
	.Example
		Get-ZabbixHost | ? name -eq hostName | Set-ZabbixHost -removeTemplates
		Remove and clear all linked templates from the host
	.Example
		Get-ZabbixHost | ? name -eq hostName | Set-ZabbixHost -TemplateID (Get-ZabbixTemplate | ? name -eq "TemplateFromCurrentHost").templateid
		Replace linked templates on the host with new ones (not clear the old ones)
	.Example
		Get-ZabbixHost | ? name -eq hostName | Set-ZabbixHost -removeTemplates -TemplateID (Get-ZabbixTemplate | ? name -eq "TemplateFromCurrentHost").templateid -WhatIf
		WhatIf on remove and clear linked templates from the host
	.Example
		Get-ZabbixHost -HostName HostName | Set-ZabbixHost -removeTemplates -TemplateID (Get-ZabbixHost -HostName "HostName").parentTemplates.templateid
		Unlink(remove) and clear templates from the host (case sensitive)
	.Example
		$templateID=(Get-ZabbixTemplate -HostID (Get-ZabbixHost | ? name -match hostname).hostid).templateid
		Store existing templateIDs
		$templateID+=(Get-ZabbixTemplate | ? name -match "newTemplate").templateid
		Add new templateIDs
		Get-ZabbixHost | ? name -match hosts | Set-ZabbixHost -TemplateID $templateID 
		Link(add) additional template(s) to already existing ones, step by step
	.Example
		$templateID=((Get-ZabbixHost | ? name -eq hostName).parentTemplates.templateid)+((Get-ZabbixTemplate | ? name -match mysql).templateid)
		Get-ZabbixHost | ? name -ew hostName | Set-ZabbixHost -TemplateID $templateID 
		Add new template to existing ones (not replace)
	.Example
		Get-ZabbixHost -HostName HostName | Set-ZabbixHost -TemplateID (Get-ZabbixHost -HostName SourceHost).parentTemplates.templateid
		Link(replace existing) new templates to the host, according config of other host (case sensitive)
	.Example
		(1..9) | %{Get-ZabbixHost -HostName "Host0$_" | Set-ZabbixHost -TemplateID ((Get-ZabbixHost | ? name -match "sourcehost").parenttemplates.templateid)}
		Link(replace existing) new templates to multiple hosts, according config of the other host
	#>	 
    
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
	[Alias("szhst")]
	Param (
		[Alias("host")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$HostName,
		# Visible name of the host. Default: host property value.
		[Alias("name")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$HostVisibleName,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$HostID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][array]$GroupID,
		[Parameter(DontShow, Mandatory = $False, ValueFromPipelineByPropertyName = $True)][array]$groups,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][array]$interfaceID,
		[Parameter(DontShow, Mandatory = $False, ValueFromPipelineByPropertyName = $True)][array]$interfaces,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][array]$TemplateID,
		[Parameter(DontShow, Mandatory = $False, ValueFromPipelineByPropertyName = $True)][array]$parentTemplates,
		# [Alias("parentTemplates")][Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$True)][array]$templates,
		[Parameter(DontShow, Mandatory = $False, ValueFromPipelineByPropertyName = $True)][array]$templates,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)]$Inventory,
		[Alias("description")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$HostDescription,
		# Host inventory population mode: Possible values are: -1 - disabled; 0 - (default) manual; 1 - automatic.
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][int]$InventoryMode,
		# IPMI authentication algorithm: Possible values are: -1 - (default) default; 0 - none; 1 - MD2; 2 - MD5; 4 - straight; 5 - OEM; 6 - RMCP+
		[Alias("ipmi_authtype")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][int]$IpmiAuthtype,
		[Alias("ipmi_username")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$IpmiUsername,
		[Alias("ipmi_password")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$IpmiPassword,
		# IPMI privilege level: Possible values are: 1 - callback; 2 - (default) user; 3 - operator; 4 - admin; 5 - OEM.
		[Alias("ipmi_privilege")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][int]$IpmiPrivilege,
		# [array]$GroupID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][array]$HttpTestID,
		# Status and function of the host: Possible values are: 0 - (default) monitored host; 1 - unmonitored host
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][int]$status,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][int]$ProxyHostID,
		[switch]$removeTemplates,

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

		if ($TemplateID -eq 0) { $TemplateID = "" }

		# if ($TemplateID.count -gt 9) {write-host "`nOnly up to 5 templates are allowed." -f red -b yellow; return}
		for ($i = 0; $i -lt $TemplateID.length; $i++) { [array]$tmpl += $(@{templateid = $($TemplateID[$i]) })
  }
		for ($i = 0; $i -lt $GroupID.length; $i++) { [array]$grp += $(@{groupid = $($GroupID[$i]) })
  }
		for ($i = 0; $i -lt $interfaceID.length; $i++) { [array]$ifc += $(@{interfaceid = $($interfaceID[$i]) })
  }
		
		$Body = @{
			method  = "host.update"
			params  = @{
				hostid         = $HostID
				status         = $status
				host           = $HostName
				name           = $HostVisibleName
				ipmi_authtype  = $IpmiAuthtype
				ipmi_username  = $IpmiUsername
				ipmi_password  = $IpmiPassword
				ipmi_privilege = $IpmiPrivilege
				description    = $HostDescription
				inventory_mode = $InventoryMode
				proxy_hostid   = $ProxyHostID
			}

			jsonrpc = $jsonrpc
			id      = $id
			auth    = $session
		}

		if (!$TemplateID -and $removeTemplates) { $Body.params.templates_clear = $parentTemplates | select templateid }
		if ($TemplateID -and $removeTemplates) { $Body.params.templates_clear = $tmpl | ? { $_ } }
		if ($TemplateID -and !$removeTemplates) { $Body.params.templates = $tmpl | ? { $_ } }
		# if (!($TemplateID -and $removeTemplates)) {$Body.params.parenttemplates=$parentTemplates}
		if ($GroupID) { $Body.params.groups = $grp } else { $Body.params.groups = $groups }
		if ($interfaceID) { $Body.params.interfaces = $ifc } else { $Body.params.interfaces = ($interfaces) }

		$BodyJSON = ConvertTo-Json $Body -Depth 3
		write-verbose $BodyJSON
		
		if (!$removeTemplates)
		{
			$a = Invoke-RestMethod "$URL/api_jsonrpc.php" -ContentType "application/json" -Body $BodyJSON -Method Post
			if ($a.result) { $a.result } else { $a.error }
		}
		elseif ($removeTemplates -and !$TemplateID)
		{
			if ([bool]$WhatIfPreference.IsPresent) { }
			if ($PSCmdlet.ShouldProcess((($parentTemplates).name -join ", "), "Unlink and clear templates from the host"))
			{  
				$a = Invoke-RestMethod "$URL/api_jsonrpc.php" -ContentType "application/json" -Body $BodyJSON -Method Post
				if ($a.result) { $a.result } else { $a.error }
			}
		}
		elseif ($removeTemplates -and $TemplateID)
		{
			if ([bool]$WhatIfPreference.IsPresent) { }
			if ($PSCmdlet.ShouldProcess(($parentTemplates | ? templateid -match (($tmpl).templateid -join "|")).name, "Unlink and clear templates"))
			{  
				$a = Invoke-RestMethod "$URL/api_jsonrpc.php" -ContentType "application/json" -Body $BodyJSON -Method Post
				if ($a.result) { $a.result } else { $a.error }
			}
		}
		
	}
}