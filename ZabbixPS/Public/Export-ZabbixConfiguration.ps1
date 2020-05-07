Function Export-ZabbixConfiguration
{
	<# 
	.Synopsis
		Export configuration
	.Description
		Export configuration
	.Parameter GroupID
		GroupID: groups - (array) IDs of host groups to export.
	.Parameter HostID
		HostID - (array) IDs of hosts to export
	.Parameter TemplateID
		TemplateID - (array) IDs of templates to export.
	.Parameter Format
		Format: XML (default) or JSON. 
	.Example
		Export-ZabbixConfig -HostID (Get-ZabbixHost | ? name -match host).hostid
		Export hosts configuration
	.Example
		Export-ZabbixConfig -HostID (Get-ZabbixHost | ? name -match host).hostid | clip
		Capture to clipboard exported hosts configuration
	.Example
		Export-ZabbixConfig -HostID (Get-ZabbixHost | ? name -match host).hostid | Set-Content c:\zabbix-hosts-export.xml -Encoding UTF8 -nonewline
		Export hosts configuration to xml file
	.Example
		Export-ZabbixConfig -TemplateID (Get-ZabbixTemplate | ? name -match TemplateName).templateid | Set-Content c:\zabbix-templates-export.xml -Encoding UTF8 
		Export template to xml file
	.Example
		Export-ZabbixConfig -TemplateID (Get-ZabbixHost | ? name -match windows).templateid | Set-Content c:\zabbix-templates-export.xml -Encoding UTF8 -nonewline
		Export template configuration linked to certain hosts to xml file, -nonewline saves file in Unix format (no CR)
	.Example
		Export-ZabbixConfig -HostID (Get-ZabbixHost | ? name -eq host).hostid | format-xml | Set-Content C:\zabbix-host-export-formatted-pretty.xml -Encoding UTF8
		Export host template to xml, beautify with Format-Xml (module pscx) and save to xml file
	.Example
		Get-ZabbixHost | ? name -match host -pv hst | %{Export-ZabbixConfig -HostID $_.hostid | sc c:\ZabbixExport\export-zabbix-host-$($hst.name).xml -Encoding UTF8}
		Export host configuration
	.Example
		Get-ZabbixHost | ? name -eq Host | Export-ZabbixConfig | Format-Xml | Set-Content C:\zabbix-host-export-formatted-pretty.xml -Encoding UTF8
		Export host template to xml, beautify with Format-Xml (module pscx) and save to xml file
	.Example
		diff (Get-Content c:\FirstHost.xml) (Get-content c:\SecondHost.xml)
		Compare hosts by comparing their configuration files
	.Example
		Get-ZabbixTemplate | ? name -match templateNames | Export-ZabbixConfig -Format json | sc C:\zabbix-templates-export.json
		Export templates in JSON format
	.Example
		$expHosts=Get-ZabbixHost | ? name -match hosts | Export-ZabbixConfig -Format JSON | ConvertFrom-Json
		$expHosts.zabbix_export.hosts
		Explore configuration as powershell objects, without retrieving information from the server
	#>
	[CmdletBinding()]
	[Alias("Export-ZabbixConfig", "ezconf")]
	Param (
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$HostID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$GroupID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$TemplateID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$ScreenID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$MapID,
		# Format XML or JSON
		[string]$Format = "xml",
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
		
		if ($HostID)
		{
			$Body = @{
				method  = "configuration.export"
				params  = @{
					options = @{
						hosts = @($HostID)
					}
					format  = $format
				}
			
				jsonrpc = $jsonrpc
				id      = $id
				auth    = $session
			}

			$BodyJSON = ConvertTo-Json $Body -Depth 3
			write-verbose $BodyJSON
			
			$a = Invoke-RestMethod "$URL/api_jsonrpc.php" -ContentType "application/json" -Body $BodyJSON -Method Post
			if ($a.result) { $a.result } else { $a.error }
		}
		elseif ($TemplateID)
		{
			$Body = @{
				method  = "configuration.export"
				params  = @{
					options = @{
						templates = @($TemplateID)
					}
					format  = $format
				}
			
				jsonrpc = $jsonrpc
				id      = $id
				auth    = $session
			}

			$BodyJSON = ConvertTo-Json $Body -Depth 3
			write-verbose $BodyJSON
			
			$a = Invoke-RestMethod "$URL/api_jsonrpc.php" -ContentType "application/json" -Body $BodyJSON -Method Post
			if ($a.result) { $a.result } else { $a.error }
		}
		elseif ($GroupID)
		{
			$Body = @{
				method  = "configuration.export"
				params  = @{
					options = @{
						groups = @($GroupID)
					}
					format  = $format
				}
			
				jsonrpc = $jsonrpc
				id      = $id
				auth    = $session
			}

			$BodyJSON = ConvertTo-Json $Body -Depth 3
			write-verbose $BodyJSON
			
			$a = Invoke-RestMethod "$URL/api_jsonrpc.php" -ContentType "application/json" -Body $BodyJSON -Method Post
			if ($a.result) { $a.result } else { $a.error }
		}
		elseif ($ScreenID)
		{
			$Body = @{
				method  = "configuration.export"
				params  = @{
					options = @{
						screens = @($ScreenID)
					}
					format  = $format
				}
			
				jsonrpc = $jsonrpc
				id      = $id
				auth    = $session
			}

			$BodyJSON = ConvertTo-Json $Body -Depth 3
			write-verbose $BodyJSON
			
			$a = Invoke-RestMethod "$URL/api_jsonrpc.php" -ContentType "application/json" -Body $BodyJSON -Method Post
			if ($a.result) { $a.result } else { $a.error }
		}
		elseif ($MapID)
		{
			$Body = @{
				method  = "configuration.export"
				params  = @{
					options = @{
						maps = @($MapID)
					}
					format  = $format
				}
			
				jsonrpc = $jsonrpc
				id      = $id
				auth    = $session
			}

			$BodyJSON = ConvertTo-Json $Body -Depth 3
			write-verbose $BodyJSON
			
			$a = Invoke-RestMethod "$URL/api_jsonrpc.php" -ContentType "application/json" -Body $BodyJSON -Method Post
			if ($a.result) { $a.result } else { $a.error }
		}
	}
}