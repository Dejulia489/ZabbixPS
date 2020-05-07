Function Remove-ZabbixMediaType
{ 
	<#
	.Synopsis
		Remove media types
	.Description
		Remove media types
	.Example
		Get-ZabbixMediaType | ? descr* -match MediatypeToDelete | Remove-ZabbixMediaType -WhatIf
		WhatIf on deleting media types
	.Example
		Get-ZabbixMediaType | ? descr* -match MediatypeToDelete | Remove-ZabbixMediaType
		Remove media types
	.Example
		Delete-ZabbixMediaType -mediatypeid (Get-ZabbixMediaType | ? descr* -match MediaTypeToDelete-0[1-3]).mediatypeid
		Delete media types
	#>
	[cmdletbinding(SupportsShouldProcess, ConfirmImpact = 'High')]
	[Alias("rzmt", "Delete-ZabbixMediaType")]
	Param (
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][array]$mediatypeid,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][string]$jsonrpc = ($global:zabSessionParams.jsonrpc),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][string]$session = ($global:zabSessionParams.session),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][string]$id = ($global:zabSessionParams.id),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $False)][string]$URL = ($global:zabSessionParams.url)
	)
	
	process
 {

		if (!(Get-ZabbixSession)) { return }
		elseif (!$psboundparameters.count) { Write-MissingParamsMessage; return }
		
		$boundparams = $PSBoundParameters | out-string
		write-verbose "($boundparams)"

		$Body = @{
			method  = "mediatype.delete"
			params  = @(
				$mediatypeid
			)

			jsonrpc = $jsonrpc
			id      = $id
			auth    = $session
		}

		$BodyJSON = ConvertTo-Json $Body
		write-verbose $BodyJSON
		
		if ([bool]$WhatIfPreference.IsPresent) { }
		if ($PSCmdlet.ShouldProcess($mediatypeid, "Delete"))
		{  
			$a = Invoke-RestMethod "$URL/api_jsonrpc.php" -ContentType "application/json" -Body $BodyJSON -Method Post
		}
		# $a = Invoke-RestMethod "$URL/api_jsonrpc.php" -ContentType "application/json" -Body $BodyJSON -Method Post
		if ($a.result) { $a.result } else { $a.error }
	}
}

