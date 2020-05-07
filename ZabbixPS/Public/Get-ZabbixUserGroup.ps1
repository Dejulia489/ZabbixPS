Function Get-ZabbixUserGroup
{ 
	<#
	.Synopsis
		Get user group
	.Description
		Get user group
	.Parameter SortBy
		Sort output by (usrgrpid, name (default)), not mandatory
	.Parameter getAccess
		adds additional information about user permissions (default=$true), not mandatory
	.Example
		Get-ZabbixUserGroup | select usrgrpid,name
		Get user groups
	.Example
		Get-ZabbixUserGroup | ? name -match administrators | select -ExpandProperty users | ft -a
		Get users in Administrators group
	.Example
		(Get-ZabbixUserGroup | ? name -match administrators).users | select alias,users_status
		Get users in user group
	#>
	
	[cmdletbinding()]
	[Alias("gzug")]
	Param (
		[array]$SortBy = "name",
		# [Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$true)][array]$UserGroupName,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)]$status,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$userids,
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
			method  = "usergroup.get"
			params  = @{
				output       = "extend"
				selectUsers  = "extend"
				selectRights = "extend"
				userids      = $userids
				status       = $status
				sortfield    = @($sortby)
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

