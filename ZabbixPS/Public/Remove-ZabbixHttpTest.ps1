Function Remove-ZabbixHttpTest
{
	<# 
	.Synopsis
		Delete web/http test
	.Description
		Delete web/http test
	.Parameter HttpTestName
		web/http test name
	.Example
		Remove-ZabbixHttpTest -HttpTestID (Get-ZabbixTemplate | ? name -eq "Template Name" | Get-ZabbixHttpTest | ? name -match httpTests).httptestid
		Delete web/http tests
	.Example
		Get-ZabbixTemplate | ? name -eq "Template Name" | Get-ZabbixHttpTest | ? name -match httpTest | %{Remove-ZabbixHttpTest -HttpTestID $_.HttpTestID}
		Delete web/http tests 
	#>

	[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
	[Alias("rzhttp")]
	Param (
		[Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)][array]$HttpTestID,
		[Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)][string]$Name,
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

		$Body = @{
			method  = "httptest.delete"
			params  = @($HttpTestID)

			jsonrpc = $jsonrpc
			id      = $id
			auth    = $session
		}

		$BodyJSON = ConvertTo-Json $Body -Depth 3
		write-verbose $BodyJSON
		
		if ([bool]$WhatIfPreference.IsPresent) { }
		if ($PSCmdlet.ShouldProcess($Name, "Delete"))
		{  
			$a = Invoke-RestMethod "$URL/api_jsonrpc.php" -ContentType "application/json" -Body $BodyJSON -Method Post
		}
		
		if ($a.result) { $a.result } else { $a.error }
	}
}

