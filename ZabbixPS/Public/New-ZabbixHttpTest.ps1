Function New-ZabbixHttpTest
{
	<# 
	.Synopsis
		Create web/http test
	.Description
		Create web/http test
	.Parameter HttpTestName
		web/http test name
	.Example
		New-ZabbixHttpTest -HttpTestName NewHttpTest -HttpTestStepURL "http://{HOST.CONN}:30555/health-check/do" -HttpTestStepRequired "version" -HostID (Get-ZabbixHost -HostName HostName).hostid
		Create new web/http test for server/template
	.Example
		Get-ZabbixTemplate | ? name -eq "Template Name" | Get-ZabbixHttpTest | ? name -match httpTestSource | New-ZabbixHttpTest -HttpTestName NewHttpName
		Clone web/http test in template
	#>
    
	[CmdletBinding()]
	[Alias("nzhttp")]
	Param (
		$HttpTestID,
		[Parameter(ValueFromPipelineByPropertyName = $true)]$HostID,
		$HttpTestStepRequired,
		[Parameter(ValueFromPipelineByPropertyName = $true)][array]$StatusCodes = 200,
		[Parameter(ValueFromPipelineByPropertyName = $true)]$Timeout = 15,
		[Parameter(ValueFromPipelineByPropertyName = $true)]$delay,
		[Parameter(ValueFromPipelineByPropertyName = $true)]$retries,
		[Parameter(ValueFromPipelineByPropertyName = $true)]$status,
		[Parameter(ValueFromPipelineByPropertyName = $true)]$Steps,
		[Parameter(ValueFromPipelineByPropertyName = $true)]$applicationid,
		[Parameter(ValueFromPipelineByPropertyName = $true)]$TemplateID,
		$HttpTestStepName,
		[Parameter(Mandatory = $True)]$HttpTestName,
		#[Parameter(Mandatory=$True)]$HttpTestStepURL,
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

		if ($steps)
		{
			$Body = @{
				method  = "httptest.create"
				params  = @{
					name          = $HttpTestName
					hostid        = $HostID
					templateid    = $TemplateID
					applicationid = $applicationid
					status        = $status
					steps         = $steps
				}
				
				jsonrpc = $jsonrpc
				id      = $id
				auth    = $session
			}
		}
		else
		{
			$Body = @{
				method  = "httptest.create"
				params  = @{
					name          = $HttpTestName
					hostid        = $HostID
					templateid    = $TemplateID
					applicationid = $applicationid
					status        = $status
					delay         = $delay
					retries       = $retries
					steps         = @(
						@{
							name             = $HttpTestStepName
							url              = $HttpTestStepURL
							status_codes     = $StatusCodes
							required         = $HttpTestStepRequired
							follow_redirects = 1
							timeout          = $Timeout
						}
					) 
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

