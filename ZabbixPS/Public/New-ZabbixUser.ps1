Function New-ZabbixUser
{ 
	<#
	.Synopsis
		Create new user
	.Parameter UserID
		UserID
	.Parameter Name
		User name
	.Parameter Surname
		User last name
	.Parameter Type
		Type of the user. Possible values: 1 - (default) Zabbix user; 2 - Zabbix admin; 3 - Zabbix super admin
	.Parameter Alias
		User alias. Example: firstname.lastname
	.Parameter Passwd
		User password
	.Parameter UserGroupID
		GroupID user belongs to
	.Parameter UserMediaSeverity
		User media settings: Severity. Trigger severities: Default: 63
	.Parameter UserMediaPeriod
		User media settings: Period. Example: "1-7,00:00-24:00"
	.Parameter UserMediaSendto
		User media settings: SendTo. Mostly email address
	.Parameter UserMediaActive
		User media settings: Active. User media enabled=0/disabled=1
	.Parameter mediatypeid
		Unique global media type id
	.Parameter RowsPerPage
		GUI frontend: Rows per page in web browser
	.Parameter Refresh
		GUI frontend: Automatic refresh period. Accepts seconds and time unit with suffix. Default: 30s
	.Parameter Autologin
		GUI frontend: Possible values: 0 - (default) auto-login disabled; 1 - auto-login enabled
	.Parameter Autologout
		GUI frontend: User session life time. Accepts seconds and time unit with suffix. If set to 0s, the session will never expire. Default: 15m
	.Parameter Theme
		GUI frontend: User's theme. Possible values: default - (default) system default; blue-theme - Blue; dark-theme - Dark
	.Parameter UserDefaultURL
		GUI frontend: URL of the page to redirect the user to after logging in
	.Example
		New-ZabbixUser -Name NewName -Surname NewSurname -Alias first.last -passwd "123456" -sendto first.last@domain.com -UserGroupID 7,9 
		Create new user
	.Example
		New-ZabbixUser -Name NewName -Surname NewSurname -Alias first.last -passwd "123456" -sendto first.last@domain.com -UserMediaActive 0 -rows_per_page 100 -Refresh 300 -UserGroupID (Get-ZabbixUserGroup | ? name -match "disabled|administrator" | select usrgrpid)
		Create new user (disabled)
	.Example
		New-ZabbixUser -Name NewName -Surname NewSurname -Alias first.last -passwd "123456" -sendto first.last@domain.com -UserMediaActive 0 -rows_per_page 100 -Refresh 300 -UserGroupID (Get-ZabbixUserGroup | ? name -match "disabled|administrator").usrgrpid
		Create new user (disabled)
	.Example
		Import-Csv C:\zabbix-users.csv | %{New-ZabbixUser -Name $_.UserName -Surname $_.UserSurname -Alias $_.UserAlias -passwd "$_.Passwd" -UserMediaSendto $_.UserMediaSendto -UserMediaActive $_.UserMediaActive -rows_per_page $_.rows_per_page -Refresh $_.refresh -usrgrps (Get-ZabbixUserGroup | ? name -match "guest").usrgrpid}
		Mass create new users from the csv file
	.Example
		Import-Csv C:\zabbix-users.csv | %{New-ZabbixUser -Name $_.UserName -Surname $_.UserSurname -Alias $_.UserAlias -passwd "$_.Passwd" -UserMediaSendto $_.UserEmail -mediatypeid 1 -RowsPerPage 120 -Refresh 60s -UserGroupID (Get-ZabbixUserGroup | ? name -match "guest").usrgrpid}
		Mass create new users from the csv file
	.Example
		Get-ZabbixUser | ? alias -eq "SourceUser" | New-ZabbixUser -Name NewName -Surname NewSurname -Alias first.last -passwd "123456" -sendto first@first.com -UserMediaActive 0 -rows_per_page 100 -Refresh 300
		Clone user. Enable media (-UserMediaActive 0)
	.Example
		Get-Zabbixuser | ? alias -eq "SourceUser" | New-ZabbixUser -Name NewName -Surname NewSurname -Alias first.last -passwd "123456"
		Clone user
	.Example
		Get-ZabbixUser | ? alias -match "SourceUser" | New-ZabbixUser -Name NewName -Surname NewSurname -Alias first.last -passwd "123456" -usrgrps (Get-ZabbixUserGroup | ? name -match disabled).usrgrpid
		Clone user, but disable it (assign to usrgrp Disabled)
	.Example
		Import-Csv C:\zabbix-users.csv | %{Get-Zabbixuser | ? alias -eq template.user | New-ZabbixUser -Name $_.UserName -Surname $_.UserSurname -Alias $_UserAlias -passwd "$_.Passwd" -UserMediaSendto $_.UserEmail}
		Mass create/clone from the user template
	.Example
		Import-Csv C:\zabbix-users.csv | %{Get-Zabbixuser | ? alias -eq template.user | New-ZabbixUser -Name $_.UserName -Surname $_.UserSurname -Alias $_UserAlias -passwd "$_.Passwd" -UserMediaSendto $_.UserEmail -UserMediaActive 1}
		Mass create/clone from the user template, but disable all medias for new users
	#>	
	
	[cmdletbinding()]
	[Alias("nzu")]
	Param (
		# [switch]$getAccess=$true,
		[Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)][string]$Alias,
		[Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)][string]$Passwd,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][array]$UserGroupID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$Name,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$Surname,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][array]$usrgrpid,
		# Trigger severities to send notifications about. Severities are stored in binary form with each bit representing the corresponding severity. For example, 12 equals 1100 in binary and means, that notifications will be sent from triggers with severities warning and average. 
		# Refer to the trigger object page for a list of supported trigger severities. Default: 63
		[Alias("severity")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][int]$UserMediaSeverity = "63",
		[Alias("period")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$UserMediaPeriod = "1-7,00:00-24:00",
		[Alias("sendto")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$UserMediaSendto,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][int]$mediatypeid,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][array]$usrgrps,
		[Alias("rows_per_page")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][int]$RowsPerPage,
		# Whether the media is enabled. Possible values: 0 - (default) enabled; 1 - disabled.
		[Alias("active")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$UserMediaActive,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][array]$medias,
		# Type of the user. Possible values: 1 - (default) Zabbix user; 2 - Zabbix admin; 3 - Zabbix super admin.
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][int]$Type,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][array]$mediaTypes,
		# Automatic refresh period. Accepts seconds and time unit with suffix. Default: 30s.
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$Refresh,
		# Possible values: 0 - (default) auto-login disabled; 1 - auto-login enabled.
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][int]$Autologin,
		# User session life time. Accepts seconds and time unit with suffix. If set to 0s, the session will never expire. Default: 15m.
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$Autologout,
		# User's theme. Possible values: default - (default) system default; blue-theme - Blue; dark-theme - Dark.
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][ValidateSet("default", "blue-theme", "dark-theme")][string]$Theme,
		# URL of the page to redirect the user to after logging in.
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$UserDefaultURL,
		
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
		
		if ($Autologin -and $Autologout) { Write-Host "`nAutologin and Autologout options cannot be enabled together!`n" -f red; return }
		
		if ($UserGroupID.length -gt 0)
		{
			if ($UserGroupID[0] -notmatch "[a-z][A-Z]") { for ($i = 0; $i -lt $UserGroupID.length; $i++) { [array]$usrgrp += $(@{usrgrpid = $($UserGroupID[$i]) }) } 
   }
			else { $usrgrp = $UserGroupID }
		}

		# for ($i=0; $i -lt $UserGroupID.length; $i++) {[array]$usrgrp+=$(@{usrgrpid = $($UserGroupID[$i])})}
		# for ($i=0; $i -lt $medias.length; $i++) {$medias[$i].active=0}
		
		if ($UserMediaActive -and $medias) { for ($i = 0; $i -lt $medias.length; $i++) { $medias[$i].active = $UserMediaActive } }
		if ($UserMediaSendto -and $medias) { for ($i = 0; $i -lt $medias.length; $i++) { $medias[$i].sendto = $UserMediaSendto } }
		
		if ($medias) { $medias = $medias | select * -ExcludeProperty mediaid, userid }
		
		if (($UserMediaSendto -or $UserMediaActive) -and !$medias)
		{
			$Body = @{
				method  = "user.create"
				params  = @{
					name        = $Name
					surname     = $Surname
					alias       = $Alias
					passwd      = $Passwd
					url         = $UserDefaultURL
					user_medias = @(
						@{
							mediatypeid = $mediatypeid
							sendto      = $UserMediaSendto
							active      = $UserMediaActive
							severity    = $UserMediaSeverity
							period      = $UserMediaPeriod
						}
					)
				}
				
				jsonrpc = $jsonrpc
				id      = $id
				auth    = $session
			}
		}
		elseif ($medias)
		{
			$Body = @{
				method  = "user.create"
				params  = @{
					name        = $Name
					surname     = $Surname
					alias       = $Alias
					passwd      = $Passwd
					url         = $UserDefaultURL
					user_medias = @($medias)
				}
			
				jsonrpc = $jsonrpc
				id      = $id
				auth    = $session
			}
		}
		else
		{
			$Body = @{
				method  = "user.create"
				params  = @{
					name    = $Name
					surname = $Surname
					alias   = $Alias
					passwd  = $Passwd
					url     = $UserDefaultURL
				}
			
				jsonrpc = $jsonrpc
				id      = $id
				auth    = $session
			}
		}

		if ($Type) { $Body.params.type = $Type }
		if ($Autologin) { $Body.params.autologin = $Autologin }
		if ($Autologout) { $Body.params.autologout = $Autologout }
		if ($Theme) { $Body.params.theme = $Theme }
		if ($Refresh) { $Body.params.refresh = $Refresh }
		if ($RowsPerPage) { $Body.params.rows_per_page = $RowsPerPage }
		if ($UserGroupID) { $Body.params.usrgrps = $usrgrp } else { $Body.params.usrgrps = @($usrgrps | select usrgrpid) }

		$BodyJSON = ConvertTo-Json $Body -Depth 3
		write-verbose $BodyJSON
		
		$a = Invoke-RestMethod "$URL/api_jsonrpc.php" -ContentType "application/json" -Body $BodyJSON -Method Post
		if ($a.result) { $a.result } else { $a.error }
	}
}

