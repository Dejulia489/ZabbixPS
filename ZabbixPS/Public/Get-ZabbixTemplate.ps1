Function Get-ZabbixTemplate
{
	<# 
	.Synopsis
		Get templates
	.Description
		Get templates
	.Parameter TemplateName
		To filter by name of the template (case sensitive)
	.Parameter TemplateID
		To filter by id of the template
	.Example
		Get-ZabbixTemplate
		Get all templates 
	.Example
		Get-ZabbixTemplate | select name,hosts
		Get templates and hosts
	.Example
		Get-ZabbixTemplate -TemplateName "Template OS Windows"
		Get template by name (case sensitive)
	.Example
		Get-ZabbixTemplate | ? name -match OS | select templateid,name -Unique
		Get template by name (case insensitive)
	.Example
		Get-ZabbixTemplate | ? {$_.hosts.host -match "host"} | select templateid,name
		Get templates linked to host by hostname
	.Example
		Get-ZabbixTemplate | ? name -eq "Template OS Linux" | select -ExpandProperty hosts | select host,jmx_available,*error* | ft -a
		Get hosts status per template
	.Example
		Get-ZabbixTemplate "Template OS Linux" | select -pv templ | select -ExpandProperty hosts | select @{n='Template';e={$templ.name}},Name,Status,Error
		Get hosts status per template
	.Example
		Get-ZabbixHost | ? name -match hostName | Get-ZabbixTemplate | select name
		Get templates for host
	#>
    
	[CmdletBinding()]
	[Alias("gzt")]
	Param (
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$TemplateName,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$TemplateID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$HostID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$hostids,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$parentTemplates,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$jsonrpc = ($global:zabSessionParams.jsonrpc),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$session = ($global:zabSessionParams.session),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$id = ($global:zabSessionParams.id),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$URL = ($global:zabSessionParams.url)
	)
   
	process
 {

		if (!(Get-ZabbixSession)) { return }

		$boundparams = $PSBoundParameters | out-string
		write-verbose "($boundparams)"

		$Body = @{
			method  = "template.get"
			params  = @{
				output                = "extend"
				selectHosts           = "extend"
				selectTemplates       = "extend"
				selectParentTemplates = "extend"
				selectGroups          = "extend"
				selectHttpTests       = "extend"
				selectItems           = "extend"
				selectTriggers        = "extend"
				selectApplications    = "extend"
				selectMacros          = "extend"
				selectScreens         = "extend"
				filter                = @{
					host = $TemplateName
				}
				# templateids = $TemplateID
				hostids               = $HostID
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