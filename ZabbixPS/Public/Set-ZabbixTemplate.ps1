Function Set-ZabbixTemplate
{
	<# 
	.Synopsis
		Update template
	.Description
		Update template
	.Parameter TemplateID
		Template ID
	.Parameter TemplateHostName
		TemplateHostName: Technical name of the template
	.Parameter TemplateVisibleName
		TemplateVisibleName: Visible name of the template
	.Parameter TemplateDescription
		TemplateDescription: Description of the template
	.Example
		Get-ZabbixTemplate | ? host -match oldTemplateName | Set-ZabbixTemplate -TemplateHostName "newTemplateName"
		Update template host name
	.Example
		Get-ZabbixTemplate | ? name -match oldTemplateName | Set-ZabbixTemplate -TemplateVisibleName "newTemplateName"
		Update template visible name
	.Example
		Set-ZabbixTemplate -TemplateVisibleName newTemplateName -TemplateID 10404
		Update template visible name
	.Example
		Get-ZabbixTemplate | ? name -eq templateName | Set-ZabbixTemplate -TemplateVisibleName VisibleTemplateName -groups 24,25 -hosts (Get-ZabbixHost | ? name -match host).hostid  -Verbose -templates (Get-ZabbixTemplate | ? name -eq "Template App HTTP Service" ).templateid
		Replace values in the template
	.Example
		$addTempID=(Get-ZabbixTemplate | ? host -eq currentTemplate).parenttemplates.templateid
		$addTempID+=((Get-ZabbixTemplate | ? name -match FTP).templateid)
		$addGrpID=(Get-ZabbixTemplate | ? host -eq currentTemplate).groups.groupid
		$addGrpID+=(Get-ZabbixHostGroup | ? name -match hostGroup).groupid
		Get-ZabbixTemplate | ? name -eq currentTemplate | Set-ZabbixTemplate -GroupsID $addTempID -TemplatesID $addGrpID -TemplateDescription "TemplateDescription"
		This will add new values to already existing ones, i.e add, and not replace
	#>
    
	[CmdletBinding()]
	[Alias("szt")]
	Param (
		[Alias("host")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName)][string]$TemplateHostName,
		[Alias("name")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName)][string]$TemplateVisibleName,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName)][string]$TemplateDescription,
		[Parameter(DontShow, Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$TemplateID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][array]$GroupsID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][array]$TemplatesID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][array]$HostsID,
		[Parameter(DontShow, Mandatory = $False, ValueFromPipelineByPropertyName = $True)][array]$groups,
		[Parameter(DontShow, Mandatory = $False, ValueFromPipelineByPropertyName = $True)][array]$templates,
		[Parameter(DontShow, Mandatory = $False, ValueFromPipelineByPropertyName = $True)][array]$hosts,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$jsonrpc = ($global:zabSessionParams.jsonrpc),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$session = ($global:zabSessionParams.session),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$id = ($global:zabSessionParams.id),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$URL = ($global:zabSessionParams.url)
	)
    
	process
 {
		
		if (!(Get-ZabbixSession)) { return }
		elseif (!$psboundparameters.count) { Write-MissingParamsMessage; return }

		$boundparams = $PSBoundParameters | out-string
		write-verbose "($boundparams)"
		
		write-verbose ("groups: " + $groups.length)
		write-verbose ("hosts:  " + $hosts.length)
		write-verbose ("templates:  " + $templates.length)

		for ($i = 0; $i -lt $groupsID.length; $i++) { [array]$grp += $(@{groupid = $($groupsID[$i]) })
  }
		for ($i = 0; $i -lt $hostsID.length; $i++) { [array]$hst += $(@{hostid = $($hostsID[$i]) })
  }
		for ($i = 0; $i -lt $templatesID.length; $i++) { [array]$tmpl += $(@{templateid = $($templatesID[$i]) })
  }

		$Body = @{
			method  = "template.update"
			params  = @{
				host        = $TemplateHostName
				templateid  = $TemplateID
				name        = $TemplateVisibleName
				description = $TemplateDescription
			}

			jsonrpc = $jsonrpc
			id      = $id
			auth    = $session
		}

		if ($groupsID) { $Body.params.groups = @($grp) } else { if ($groups) { $Body.params.groups = $groups } }
		if ($hostsID) { $Body.params.hosts = @($hst) } else { if ($hosts) { $Body.params.hosts = $hosts } }
		if ($templatesID) { $Body.params.templates = @($tmpl) } else { if ($templates) { $Body.params.templates = $templates } }

		$BodyJSON = ConvertTo-Json $Body -Depth 3
		write-verbose $BodyJSON
		
		$a = Invoke-RestMethod "$URL/api_jsonrpc.php" -ContentType "application/json" -Body $BodyJSON -Method Post
		if ($a.result) { $a.result } else { $a.error }
	}
}