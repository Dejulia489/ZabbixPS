Function New-ZabbixTemplate
{
	<# 
	.Synopsis
		Create new template
	.Description
		Create new template
	.Parameter TemplateHostName
		(Required) Template hostname: Technical name of the template
	.Parameter TemplateName
		Template name: Visible name of the host, Default: host property value
	.Parameter Description
		Description of the template
	.Parameter groups
		(Required) Host groups to add the template to, Default: HostGroup=1 (Templates)
	.Parameter templates
		Templates to be linked to the template
	.Parameter hosts
		Hosts to link the template to
	.Example
		New-ZabbixTemplate -TemplateHostName "newTemplateName" -GroupID ((Get-ZabbixHostGroup | ? name -match Templates).groupid) -HostID (Get-ZabbixHost | ? name -match hostName).hostid -templates (Get-ZabbixTemplate | ? name -eq "TemplateName" ).templateid
		Create new template 
	.Example
		Get-ZabbixTemplate | ? name -eq "Template OS Linux" | New-ZabbixTemplate -TemplateHostName "Template OS Linux - Clone" -TemplateDescription "description"
		Clone template (partially: groups, linked templates and hosts)
	.Example
		New-ZabbixTemplate -TemplateHostName "newTemplateName"
		Create new template
	#>
    
	[CmdletBinding()]
	[Alias("nzt")]
	Param (
		[Alias("host")][Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)][string]$TemplateHostName,
		# [Alias("name")][Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$True)][string]$TemplateVisibleName,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$TemplateDescription,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][array]$TemplateID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][array]$GroupID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][array]$HostID,
		[Parameter(DontShow, Mandatory = $False, ValueFromPipelineByPropertyName = $True)][array]$groups,
		[Parameter(DontShow, Mandatory = $False, ValueFromPipelineByPropertyName = $True)][array]$templates,
		[Parameter(DontShow, Mandatory = $False, ValueFromPipelineByPropertyName = $True)][array]$hosts,
		[Parameter(DontShow, Mandatory = $False, ValueFromPipelineByPropertyName = $True)][array]$parentTemplates,
		[Parameter(DontShow, Mandatory = $False, ValueFromPipelineByPropertyName = $True)][array]$screens,
		[Parameter(DontShow, Mandatory = $False, ValueFromPipelineByPropertyName = $True)][array]$applications,
		[Parameter(DontShow, Mandatory = $False, ValueFromPipelineByPropertyName = $True)][array]$triggers,
		[Parameter(DontShow, Mandatory = $False, ValueFromPipelineByPropertyName = $True)][array]$httpTests,
		# [Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$True)][array]$macros,
		# [switch]$AddToDefaultTemplateGroup,
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

		if (!$GroupID -and !$groups) { $GroupID = 1 } 

		for ($i = 0; $i -lt $GroupID.length; $i++) { [array]$grp += $(@{groupid = $($GroupID[$i]) })
  }
		for ($i = 0; $i -lt $HostID.length; $i++) { [array]$hst += $(@{hostid = $($HostID[$i]) })
  }
		for ($i = 0; $i -lt $TemplateID.length; $i++) { [array]$tmpl += $(@{templateid = $($TemplateID[$i]) })
  }
		# for ($i=0; $i -lt $macros.length; $i++) {[array]$mcr+=$(@{macroid = $($macros[$i])})}
		
		$Body = @{
			method  = "template.create"
			params  = @{
				host        = $TemplateHostName
				# name = $TemplateVisibleName
				description = $TemplateDescription
				groups      = if ($GroupID) { @($grp) } else { $groups }
			}

			jsonrpc = $jsonrpc
			id      = $id
			auth    = $session
		}

		if ($HostID) { $Body.params.hosts = @($hst) } elseif ($hosts) { $Body.params.hosts = $hosts | select hostid }
		if ($TemplateID) { $Body.params.templates = @($tmpl) } elseif ($parentTemplates) { $Body.params.templates = $parentTemplates | select templateid }
		# if ($parentTemplates) {$Body.params.parentTemplates=$parentTemplates | select tmplateid}
		# if ($screens) {$Body.params.screens=$screens}
		# if ($applications) {$Body.params.applications=$applications}
		# if ($httpTests) {$Body.params.httpTests=$httpTests}
		# if ($triggers) {$Body.params.httpTests=$triggers}

		$BodyJSON = ConvertTo-Json $Body -Depth 3
		write-verbose $BodyJSON
		
		$a = Invoke-RestMethod "$URL/api_jsonrpc.php" -ContentType "application/json" -Body $BodyJSON -Method Post
		#$a.result | Select-Object Name,TemplateID,@{Name="HostsMembers";Expression={$_.hosts.hostid}}
		if ($a.result) { $a.result } else { $a.error }
	}
}

