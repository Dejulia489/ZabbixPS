Function Get-ZabbixScreen
{
	<# 
	.Synopsis
		Get screen from zabbix server
	.Description
		Get screen from zabbix server
	.Example
		Get-ZabbixScreen | ? name -match screenName
		Get screen 
	.Example
		Get-ZabbixScreen | ? name -match "" | select * -ExcludeProperty screenitems | ft -a
		Get screen
	.Example
		Get-ZabbixScreen | ? name -match screenName | select * -ExcludeProperty screenitems | ft -a
		Get screen
	.Example
		Get-ZabbixScreen | ? name -match "" | select -Expands screenitems | ft -a
		Get screen items
	.Example
		Get-ZabbixScreen -ScreenID 20
		Get screen
	.Example
		Get-ZabbixScreen -UserID 1 | select screenid,name,userid | ft -a
		Get screen
	.Example
		Get-ZabbixScreen -UserID (Get-ZabbixUser | ? alias -match admin).userid
		Get screen
	.Example
		Get-ZabbixScreen | ? name -match screenName | Get-ZabbixUser
		Get user, screen belongs to
	.Example
		Get-ZabbixScreen -pv screen | ? name -match screenName | Get-ZabbixUser | select @{n='Screen';e={$screen.Name}},userid,alias
		Get screen names and related user info
	#>
    
	[CmdletBinding()]
	[Alias("gzscr")]
	Param (
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][array]$UserID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][array]$ScreenID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][array]$ScreenItemID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$jsonrpc = ($global:zabSessionParams.jsonrpc),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$session = ($global:zabSessionParams.session),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$id = ($global:zabSessionParams.id),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$URL = ($global:zabSessionParams.url)
	)
    
	process
 {

		if (!(Get-ZabbixSession)) { return }

		$boundparams = $PSBoundParameters | out-string
		write-verbose "($boundparams)"
	
		$Body = @{
			method  = "screen.get"
			params  = @{
				output            = "extend"
				selectUsers       = "extend"
				selectUserGroups  = "extend"
				selectScreenItems = "extend"
				screenids         = $ScreenID
				userids           = $UserID
				screenitemids     = $ScreenItemID
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