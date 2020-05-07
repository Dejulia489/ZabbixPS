function Import-ZabbixConfiguration
{
	<# 
	.Synopsis
		Import configuration
	.Description
		Import configuration
	.Parameter GroupID
		GroupID: groups - (array) IDs of host groups to Import.
	.Parameter HostID
		HostID - (array) IDs of hosts to Import
	.Parameter TemplateID
		TemplateID - (array) IDs of templates to Import.
	.Parameter Format
		Format: XML (default) or JSON. 
	.Example
		Import-ZabbixConfig -Path c:\zabbix-export-hosts.xml
		Import hosts configuration
	.Example
		$inputFile = Get-Content c:\zabbix-export-hosts.xml | Out-String 
		Import-ZabbixConfig -source $inputFile
		Import hosts configuration
	.Example
		Get-ZabbixHost | ? name -match host -pv hst | %{Export-ZabbixConfig -HostID $_.hostid | sc c:\ZabbixExport\export-zabbix-host-$($hst.name).xml -Encoding UTF8}
		dir c:\ZabbixExport\* | %{Import-ZabbixConfig $_.fullname}
		Import hosts configuration
	#>
	[CmdletBinding()]
	[Alias("Import-ZabbixConfig", "izconf")]
	Param (
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $false)][string]$Path,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $false)][string]$source,
		# Format XML or JSON
		[string]$Format = "xml",
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$jsonrpc = ($global:zabSessionParams.jsonrpc),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$session = ($global:zabSessionParams.session),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$id = ($global:zabSessionParams.id),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$URL = ($global:zabSessionParams.url)
	)
	
	Process
 {
		if (!(Get-ZabbixSession)) { return }
		elseif (!$psboundparameters.count) { Write-MissingParamsMessage; return }

		$boundparams = $PSBoundParameters | out-string
		write-verbose "($boundparams)"	
		
		if ($Path)
		{
			if (Test-Path $Path) { $xmlFile = Get-Content $Path | out-string }
			# if (Test-Path $Path) {$xmlFile = Get-Content $Path}
			# if (Test-Path $Path) {[string]$xmlFile = Get-Content $Path}
		}
		elseif ($source) { $xmlFile = $source }
		else { Write-Host "`nError: Wrong path!`n" -f red; return }
		
		if (($xmlFile).count -ne 1) { Write-Host "`nBad xml file!`n" -f red; return }
		  
		$Body = @{
			method  = "configuration.import"
			params  = @{
				format = $format
				rules  = @{
					groups          = @{
						createMissing = $true
					}
					templateLinkage = @{
						createMissing = $true
					}
					applications    = @{
						createMissing = $true
					}
					hosts           = @{
						createMissing  = $true
						updateExisting = $true
					}
					items           = @{
						createMissing  = $true
						updateExisting = $true
					}
					discoveryRules  = @{
						createMissing  = $true
						updateExisting = $true
					}
					triggers        = @{
						createMissing  = $true
						updateExisting = $true
					}
					graphs          = @{
						createMissing  = $true
						updateExisting = $true
					}
					httptests       = @{
						createMissing  = $true
						updateExisting = $true
					}
					valueMaps       = @{
						createMissing = $true
					}
				}
				source = $xmlFile
			}
		
			jsonrpc = $jsonrpc
			id      = $id
			auth    = $session
		}

		$BodyJSON = ConvertTo-Json $Body -Depth 3
		write-verbose $BodyJSON
		
		$a = Invoke-RestMethod "$URL/api_jsonrpc.php" -ContentType "application/json" -Body $BodyJSON -Method Post
		if ($a.result)
		{
			$a.result
			Write-Host "`nImport was successful`n" -f green
		} 
		else { $a.error }
	}
}

