Function Get-ZabbixUser
{ 
	<#
	.Synopsis
		Get users
	.Parameter SortBy
		Sort output by (userid, alias (default)), not mandatory
	.Parameter getAccess
		Adds additional information about user permissions (default=$true), not mandatory
	.Example
		Get-ZabbixUser | select userid,alias,attempt_ip,@{n="attempt_clock(UTC)";e={convertfrom-epoch $_.attempt_clock}},@{n="usrgrps";e={$_.usrgrps.name}}
		Get users
	.Example
		Get-ZabbixUser | ? alias -match userName | select alias -ExpandProperty medias
		Get user medias
	.Example
		Get-ZabbixUser | ? alias -match userName | select alias -ExpandProperty mediatypes
		Get user mediatypes
	.Example
		Get-ZabbixUser | ? alias -match alias | select userid,alias,attempt_ip,@{n="attempt_clock(UTC)";e={convertfrom-epoch $_.attempt_clock}},@{n="usrgrps";e={$_.usrgrps.name}}
		Get users
	.Example
		Get-ZabbixUser | select name, alias, attempt_ip, @{n="attempt_clock (UTC-5)"; e={((convertfrom-epoch $_.attempt_clock)).addhours(-5)}},@{n="usrgrps";e={$_.usrgrps.name}} | ft -a
		Get users
	#>
	
	[cmdletbinding()]
	[Alias("gzu")]
	Param (
		[array]$SortBy = "alias",
		[switch]$getAccess = $true,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)]$UserID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)]$MediaID,
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
			method  = "user.get"
			params  = @{
				output           = "extend"
				selectMedias     = "extend"
				selectMediatypes = "extend"
				selectUsrgrps    = "extend"
				sortfield        = @($sortby)
				getAccess        = $getAccess
				userids          = $UserID
				mediaids         = $MediaID
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

