Function Get-ZabbixProblem
{ 
	<#
	.Synopsis
		Get Problems
	.Description
		Get Problems
	.Example
		Get-ZabbixProblem | select @{n="clock(UTC+2)";e={(convertfrom-epoch $_.clock).addhours(2)}},* | ft -a
		Get Problems
	#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$objectids,
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
			method  = "problem.get"
			params  = @{
				output             = "extend"
				selectAcknowledges = "extend"
				selectTags         = "extend"
				objectids          = $objectid
				recent             = "true"
				sortfield          = "eventid"
				sortorder          = "DESC"	
				
			}

			jsonrpc = $jsonrpc
			id      = $id
			auth    = $session
		}
		
		$BodyJSON = ConvertTo-Json $Body
		write-verbose $BodyJSON
		
		$a = Invoke-RestMethod "$URL/api_jsonrpc.php" -ContentType "application/json" -Body $BodyJSON -Method Post
		if ($a.result) { $a.result } else { $a.error }
	}
}

