Function New-ZabbixHost
{
	<# 
	.Synopsis
		Create new host
	.Description
		Create new host
	.Parameter HostName
		HostName of the host as it will appear in zabbix
	.Parameter IP
		IP address of the host
	.Parameter DNSName
		Domain name of the host
	.Parameter Port
		Port to connect to the host (default 10050)
	.Parameter GroupID
		ID of the group host will belong to
	.Parameter TemplateID
		ID/IDs of the templates to link to the host
	.Parameter MonitorByDNSName
		If used, domain name of the host will used to connect
	.Example
		New-ZabbixHost -HostName NewHost -IP 10.20.10.10 -GroupID 8,14 -TemplateID "10081","10166"
		Create new host (case sensitive), with two linked Templates and member of two HostGroups	
	.Example
		New-ZabbixHost -HostName hostName -IP 10.20.10.10 -TemplateID (Get-ZabbixTemplate | ? name -eq "Template OS Windows").templateid -GroupID (Get-ZabbixGroup | ? name -eq "HostGroup").groupid -status 1
		Create new host (case sensitive), with one linked Template, member of one HostGroup and disabled (-status 1)
	.Example
		New-ZabbixHost -HostName NewHost -IP 10.20.10.10 -TemplateID ((Get-ZabbixTemplate | ? name -match "Template OS Windows|Template OS Windows - Ext") -notmatch "Template OS Windows - Backup").templateid -GroupID (Get-ZabbixHostGroup | ? name -match "HostGroup1|HostGroup2").groupid -status 1 
		Create new host (case sensitive), with two linked Templates, member of two HostGroups and disabled (-status 1)
	.Example
		New-ZabbixHost -HostName NewHost -IP 10.20.10.10 -GroupID 8 -TemplateID (Get-ZabbixHost | ? name -match "host").parentTemplates.templateid -status 0
		Create new host (case sensitive), with multiple attached Templates and enable it (-status 0)
	.Example
		New-ZabbixHost -HostName NewHost -IP 10.20.10.10 -GroupID 8 -TemplateID (Get-ZabbixHost | ? name -match "host").parentTemplates.templateid -status 1
		Create new host (case sensitive), with multiple attached Templates and leave it disabled (-status 1)
	.Example
		New-ZabbixHost -HostName NewHost -IP 10.20.10.10 -TemplateID ((Get-ZabbixTemplate | ? name -match "Template OS Windows") -notmatch "Template OS Windows - Backup").templateid -verbose -GroupID (Get-ZabbixGroup | ? name -match "HostGroup1|HostGroup2").groupid -status 1 -DNSName NewHost.example.com -MonitorByDNSName
		Create new host with FQDN and set monitoring according DNS and not IP
	.Example
		Import-Csv c:\new-servers.csv | %{New-ZabbixHost -HostName $_.$Hostname -IP $_.IP -TemplateID "10081","10166" -GroupID 8,14}
		Mass create new hosts
	.Example
		Import-Csv c:\new-servers.csv | %{New-ZabbixHost -HostName $_.Hostname -IP $_.IP -GroupID $_.GroupID -TemplateID $_.TemplateID -status $_.status}
		Mass create new hosts
	.Example
		New-ZabbixHost -HostName NewHost -IP 10.20.10.10 -GroupID (Get-ZabbixHost | ? name -eq "SourceHost").groups.groupid -TemplateID (Get-ZabbixHost | ? name -eq "SourceHost" | Get-ZabbixTemplate | ? name -match os).templateid -status 1 -verbose 
		Clone HostGroups and Templates from other host
	.Example
		Get-ZabbixHost | ? name -match SourceHost | New-ZabbixHost -HostName NewHost -IP 10.20.10.10 -status 1
		Partially clone host (templates and groups will be copied from the source host)
	.Example
		Get-ZabbixHost | ? name -eq SourceHost | Get-ZabbixApplication | New-ZabbixApplication -HostID (Get-ZabbixHost | ? name -match newHost).hostid
		Clone Application(s) from host to host
	#>
	
	[CmdletBinding()]
	[Alias("nzhst")]
	Param (
		[Parameter(Mandatory = $True)][string]$HostName,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $false)][string]$IP,
		[string]$DNSName,
		[Switch]$MonitorByDNSName,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$Port = 10050,
		[Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)][string]$status,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][array]$GroupID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][array]$groups,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][array]$TemplateID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][int]$ProxyHostID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][array]$templates,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][array]$interfaces,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][array]$parentTemplates,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$jsonrpc = ($global:zabSessionParams.jsonrpc),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$session = ($global:zabSessionParams.session),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$id = ($global:zabSessionParams.id),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$URL = ($global:zabSessionParams.url)
	)

	process
 {

		if (!(Get-ZabbixSession)) { return }
		elseif (!$psboundparameters.count) { Write-MissingParamsMessage; return }
		# if (!$psboundparameters.count -and !$global:zabSessionParams) {Get-Help -ex $PSCmdlet.MyInvocation.MyCommand.Name | out-string | Remove-EmptyLines; return}

		$boundparams = $PSBoundParameters | out-string
		write-verbose "($boundparams)"

		Switch ($MonitorByDNSName.IsPresent)
		{
			$False { $ByDNSName = 1 } # = ByIP
			$True { $ByDNSName = 0 } # = ByDomainName
		}
		
		for ($i = 0; $i -lt $TemplateID.length; $i++) { [array]$tmpl += $(@{templateid = $($TemplateID[$i]) })
  }
		for ($i = 0; $i -lt $GroupID.length; $i++) { [array]$grp += $(@{groupid = $($GroupID[$i]) })
  }
		
		$Body = @{
			method  = "host.create"
			params  = @{
				host         = $HostName
				interfaces   = @{
					type  = 1
					main  = 1
					useip = $ByDNSName
					ip    = $IP
					dns   = $DNSName
					port  = $Port
				}
				status       = $Status
				proxy_hostid = $ProxyHostID
			}
			
			jsonrpc = $jsonrpc
			auth    = $session
			id      = $id
		}

		if ($GroupID) { $Body.params.groups = $grp } elseif ($groups) { $Body.params.groups = $groups }
		if ($TemplateID -and ($TemplateID -ne 0)) { $Body.params.templates = $tmpl } elseif ($parentTemplates) { $Body.params.templates = $parentTemplates | select templateid }

		$BodyJSON = ConvertTo-Json $Body -Depth 3
		write-verbose $BodyJSON
		
		$a = Invoke-RestMethod "$URL/api_jsonrpc.php" -ContentType "application/json" -Body $BodyJSON -Method Post
		if ($a.result)
		{
			$a.result
			if ($psboundparameters.interfaces)
			{
				write-host "Replacing the IP address in cloned interfaces..." -f green
				Get-ZabbixHost -HostName $HostName | Get-ZabbixHostInterface | % { Set-ZabbixHostInterface -InterfaceID $_.interfaceid -IP $IP -Port $_.port -HostID $_.hostid -main $_.main }
			}
		}
		else { $a.error }
	}
}

