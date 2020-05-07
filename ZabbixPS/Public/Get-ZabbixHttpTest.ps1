Function Get-ZabbixHttpTest
{
	<# 
	.Synopsis
		Get web/http test
	.Description
		Get web/http test
	.Parameter HttpTestName
		To filter by name of the http test
	.Example
		Get-ZabbixHttpTest
		Get web/http tests
	.Example
		Get-ZabbixHttpTest | select name -Unique
		Get web/http tests
	.Example
		Get-ZabbixHttpTest | ? name -match httpTest | select httptestid,name
		Get web/http test by name match (case insensitive)
	.Example
		Get-ZabbixHttpTest | ? name -match httpTest | select steps | select -first 1 | fl *
		Get web/http test by name match, first occurrence
	.Example
		Get-ZabbixHttpTest | ? name -like "test*Name" | ? {$_.hosts.host -match "Template name"}) | select name,@{e={$_.steps.url}},@{n='host';e={$_.hosts.host}} -Unique | sort host
		Get web/http test by name (case insensitive)
	.Example
		Get-ZabbixHttpTest -HttpTestID 96
		Get web/http test by ID
	.Example
		(Get-ZabbixHttpTest -HttpTestName HttpTestName).hosts.host 
		Get hosts with web/http test by name match (case sensitive) 
	.Example 
		Get-ZabbixHttpTest -HostID (Get-ZabbixHost | ? name -match host).hostid | select host -ExpandProperty steps | ft -a
		Get web/http tests by hostname match (case insensitive)
	.Example
		Get-ZabbixTemplate | ? name -eq "Template Name" | get-ZabbixHttpTest | select -ExpandProperty steps | ft -a
		Get web/http tests by template name 
	.Example 
		Get-ZabbixHost | ? name -match host | Get-ZabbixHttpTest | select -ExpandProperty steps
		Get web/http tests for hostname match
	.Example
		Get-ZabbixHost | ? name -match host -pv hsts | Get-ZabbixHttpTest | select -ExpandProperty steps | select  @{n='Server';e={$hsts.host}},name,httpstepid,httptestid,no,url,timeout,required,status_codes,follow_redirects | ft -a
		Get web/http tests for hostname match
	.Example
		Get-ZabbixHttpTest -HostID (Get-ZabbixHost | ? name -eq hostname).hostid | ? name -match "httpTest" | fl httptestid,name,steps
		Get web/http test for host by name (case insensitive), and filter web/http test by test name match (case insensitive)
	.Example
		Get-ZabbixHttpTest -HostID (Get-ZabbixHost | ? name -eq hostname).hostid | ? name -match "httpTest" | select -ExpandProperty steps
		Get web/http test for host by name (case insensitive), and filter web/http test by test name match (case insensitive)
	.Example
		Get-ZabbixHttpTest -HttpTestName SomeHTTPTest | select -Unique 
		Get web/http test by name (case sensitive)
	.Example
		Get-ZabbixHttpTest -HttpTestName HTTPTestName | select name,@{n="host";e={$_.hosts.host}}
		Get web/http test by name (case sensitive) and hosts it is assigned to
	.Example
		(Get-ZabbixHttpTest | ? name -eq "HTTPTestName").hosts.host | sort
		Get hosts by web/http test's name (case insensitive)
	.Example	
		(Get-ZabbixHttpTest | ? name -eq "httpTestName").hosts.host | ? {$_ -notmatch "template"} | sort
		Get only hosts by web/http test name, sorted (templates (not hosts) are sorted out)
	.Example
		Get-ZabbixHttpTest | ? name -match httpTestName | select name, @{n="required";e={$_.steps.required}} -Unique
		Get web/http test name and field required
	.Example
		Get-ZabbixHttpTest | ? name -match httpTestName | select name, @{n="url";e={$_.steps.url}} -Unique
		Get web/http test name and field url
	#>
    
	[CmdletBinding()]
	[Alias("gzhttp")]
	Param (
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$HttpTestID,
		$HttpTestName,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$HostID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$TemplateID,
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

		if (!$hostid)
		{
			$Body = @{
				method      = "httptest.get"
				params      = @{
					output      = "extend"
					selectHosts = "extend"
					selectSteps = "extend"
					httptestids = $HttpTestID
					templateids = $TemplateID
					filter      = @{
						name = $HttpTestName
					}
				}
				
				selectHosts = @(
					"hostid",
					"name"
				)
				
				jsonrpc     = $jsonrpc
				id          = $id
				auth        = $session
			}
		}
		if ($HostID)
		{
			$Body = @{
				method      = "httptest.get"
				params      = @{
					output      = "extend"
					selectHosts = "extend"
					selectSteps = "extend"
					httptestids = $HttpTestID
					hostids     = @($hostid)
					filter      = @{
						name = $HttpTestName
					}
				}
				
				selectHosts = @(
					"hostid",
					"name"
				)
				
				jsonrpc     = $jsonrpc
				id          = $id
				auth        = $session
			}
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