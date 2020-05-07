Function Set-ZabbixHttpTest
{
	<# 
	.Synopsis
		Set/Update web/http test
	.Description
		Set/Update web/http test
	.Parameter HttpTestName
		web/http test name
	.Example
		Set-ZabbixHttpTest -HttpTestID (Get-ZabbixHttpTest -HttpTestName TestOldName ).httptestid -HttpTestName "testNewName" -status 0
		Enable (-status 0) web/http test and rename it (case sensitive)  
	.Example
		Get-ZabbixHttpTest -HttpTestName httpTest | Set-ZabbixHttpTest -status 1
		Disable web/http test (-status 1) 
	.Example
		Set-ZabbixHttpTest -HttpTestID (Get-ZabbixHttpTest -HttpTestName testName).httptestid -UpdateSteps -HttpTestStepName (Get-ZabbixHttpTest -HttpTestName testName).steps.name -HttpTestStepURL (Get-ZabbixHttpTest -HttpTestName SourceHttpTestName).steps.url
		Replace test steps' URL by other URL, taken from "othertest"  
	.Example
		Set-ZabbixHttpTest -HttpTestID (Get-ZabbixHttpTest | ? name -like "test*Name" | ? {$_.hosts.host -match "Template"}).httptestid -UpdateSteps -HttpTestStepName "NewTestName" -HttpTestStepURL "http://10.20.10.10:30555/health-check/do"
		Edit web/http test, update name and test url
	#>

	[CmdletBinding()]
	[Alias("szhttp")]
	Param (
		[Parameter(ValueFromPipelineByPropertyName = $true)]$HttpTestID,
		[Alias("name")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)]$HttpTestName,
		[Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]$HttpTestStepURL,
		$HostID,
		[Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]$HttpTestStepName,
		[Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]$HttpTestStepRequired,
		[Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]$delay = 60,
		[Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]$retries = 1,
		[Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]$status,
		[Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]$timeout = 15,
		[switch]$UpdateSteps,
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

		if ($UpdateSteps) 
		{
			$Body = @{
				method  = "httptest.update"
				params  = @{
					httptestid = $HttpTestID
					status     = $status
					name       = $HttpTestName
					steps      = @(
						@{
							name             = $HttpTestStepName
							url              = $HttpTestStepURL
							status_codes     = 200
							required         = $HttpTestStepRequired
							follow_redirects = 1
							timeout          = $timeout
						}
					) 
				}
				
				jsonrpc = $jsonrpc
				id      = $id
				auth    = $session
			}
		}
		else 
		{
			$Body = @{
				method  = "httptest.update"
				params  = @{
					httptestid = $HttpTestID
					status     = $status
					name       = $HttpTestName
					retries    = $retries
					delay      = $delay
				}
			
				jsonrpc = $jsonrpc
				id      = $id
				auth    = $session
			}
		}

		$BodyJSON = ConvertTo-Json $Body -Depth 3
		write-verbose $BodyJSON
		
		$a = Invoke-RestMethod "$URL/api_jsonrpc.php" -ContentType "application/json" -Body $BodyJSON -Method Post
		if ($a.result) { $a.result } else { $a.error }
	}
}
