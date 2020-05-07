Function Get-ZabbixAction
{ 
	<#
	.Synopsis
		Get actions
	.Description
		Get actions
	.Example
		Get-ZabbixAction
	.Example	
		Get-ZabbixAction | select name
	.Example	
		Get-ZabbixAction | ? name -match action | select name,def_longdata,r_longdata
	.Example
		Get-ZabbixAction  | ? name -match Prod | select name -ExpandProperty def_longdata	
	#>
	[cmdletbinding()]
	[Alias("gzac")]
	Param (
		[array] $SortBy = "name",
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
			method  = "action.get"
			params  = @{
				output           = "extend"
				selectOperations = "extend"
				selectFilter     = "extend"
				sortfield        = @($sortby)
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