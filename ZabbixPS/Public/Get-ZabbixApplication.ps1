Function Get-ZabbixApplication
{
	<# 
	.Synopsis
		Get application
	.Description
		Get application
	.Parameter HostID
		Get by HostID
	.Parameter TemplateID
		Get by TemplateID
	.Example
		Get-ZabbixApplication | ? name -match "appname" | ft -a
		Get applications by name match
	.Example
		Get-ZabbixHost -HostName HostName | Get-ZabbixApplication | ft -a
		Get applications by hostname (case sensitive)
	.Example
		Get-ZabbixApplication | ? name -match "appname" | ft -a
		Get applications by name match 
	.Example
		Get-ZabbixTemplate | ? name -match Template | Get-ZabbixApplication  | ft -a
		Get application and template
	.Example
		Get-ZabbixApplication -TemplateID (Get-ZabbixTemplate | ? name -match templateName).templateid | ? name -match "appName" | ft -a
		Get applications by TemplateID
	.Example
		Get-ZabbixTemplate | ? name -match templateName | %{Get-ZabbixApplication -TemplateID $_.templateid } | ft -a
		Get applications by TemplateID
	.Example
		Get-ZabbixHostGroup -GroupName "GroupName" | Get-ZabbixApplication
		Get applications by GroupName (case sensitive)
	.Example
		Get-ZabbixHost | ? name -eq SourceHost | Get-ZabbixApplication | New-ZabbixApplication -HostID (Get-ZabbixHost | ? name -match newHost).hostid
		Clone application(s) from host to host
	.Example
		Get-ZabbixHost | ? name -eq host | Get-ZabbixApplication | New-ZabbixApplication -HostID (Get-ZabbixTemplate | ? name -match "templateName").templateid
		Clone application(s) from template to template
	#>
    
	[CmdletBinding()]
	[Alias("gzapp")]
	Param (
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$HostID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$TemplateID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$GroupID,
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
			method  = "application.get"
			params  = @{
				output                     = "extend"
				selectHost                 = @(
					"hostid",
					"host"
				)
				# selectItems = "extend"
				selectDiscoveryRule        = "extend"
				selectApplicationDiscovery = "extend"
				sortfield                  = "name"
				hostids                    = $HostID
				groupids                   = $GroupID
				templateids                = $TemplateID
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

