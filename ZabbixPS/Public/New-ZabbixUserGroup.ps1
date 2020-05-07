Function New-ZabbixUserGroup
{ 
	<#
	.Synopsis
		Create user group
	.Description
		Create user group
	.Parameter UserGroupName
		User group name
	.Parameter UserGroupDebugMode
		Enable/Disable debug mode for group members. Possible values are: 0 - (default) disabled; 1 - enabled
	.Parameter UserGroupGuiAccess
		Enable/Disable GUI access for group members. Possible values: 0 - (default) use the system default authentication method; 1 - use internal authentication; 2 - disable access to the frontend
	.Parameter UserGroupUsersStatus
		Enable/Disable status for group members. Possible values are: 0 - (default) enabled; 1 - disabled
	.Parameter UserGroupAccessRights
		Define access level for group members to the host groups. Possible values: 0 - access denied; 2 - read-only access; 3 - read-write access
	.Example
		New-ZabbixUserGroup -UserGroupName "NewUserGroup" -UserID 2,41,84
		Create new user group and assign the members
	.Example
		New-ZabbixUserGroup -UserGroupName "NewUserGroup" -UserID (Get-ZabbixUser | ? alias -match "user1|user2").userid -UserGroupUsersStatus 1 -UserGroupGuiAccess 2
		Create new user group, assign the members, all group members will be in disabled state, and will have no access to GUI frontend
	.Example
		(Get-ZabbixUserGroup | ? name -Match "SourceUserGroup") | New-ZabbixUserGroup -UserGroupName "NewUserGroup"
		Clone user group
	.Example
		$ROAccess=(Get-ZabbixHostGroup | ? name -match "ROHostGroup1|ROHostGroup2|ROHostGroup3").groupid | %{@{"permission"=2;"id"=$_}}
		1. Generate Read-Only access rights for certain host groups 
		$FullAccess=(Get-ZabbixHostGroup | ? name -match "RWHostGroup1|RWHostGroup2|RWHostGroup3").groupid | %{@{"permission"=3;"id"=$_}}
		2. Generate Read/Write access rights for certain host groups
		(Get-ZabbixUserGroup | ? name -Match "SourceUserGroup) | New-ZabbixUserGroup -UserGroupName "NewUserGroup" -UserGroupAccessRights ($ROAccess+$FullAccess)
		3. Clone user group and assign the new access rights
	#>
	
	[cmdletbinding()]
	[Alias("nzug")]
	Param (
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$UserGroupName,
		# Whether debug mode is enabled or disabled. Possible values are: 0 - (default) disabled; 1 - enabled.
		[Alias("debug_mode")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$UserGroupDebugMode,
		# Frontend authentication method of the users in the group. Possible values: 0 - (default) use the system default authentication method; 1 - use internal authentication; 2 - disable access to the frontend.
		[Alias("gui_access")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$UserGroupGuiAccess,
		# Whether the user group is enabled or disabled. Possible values are: 0 - (default) enabled; 1 - disabled.
		[Alias("users_status")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$UserGroupUsersStatus,
		# ID of the host group to add permission to.
		# [Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$True)][string]$UserGroupAccessRightsHostGroupID,
		# Access level to the host group. Possible values: 0 - access denied; 2 - read-only access; 3 - read-write access.
		# [Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$True)][string]$UserGroupAccessRightsPermission,
		[Alias("rights")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][array]$UserGroupAccessRights,
		# [Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$True)][array]$rights,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][array]$UserID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][array]$userids,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][array]$users,

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
			method  = "usergroup.create"
			params  = @{
				name = $UserGroupName
			}

			jsonrpc = $jsonrpc
			id      = $id
			auth    = $session
		}

		if ($UserGroupAccessRights) { $Body.params.rights = @(@($UserGroupAccessRights)) }
		if ($UserID) { $Body.params.userids = $UserID } elseif ($users) { $Body.params.userids = @($users.userid) }
		if ($UserGroupGuiAccess) { $Body.params.gui_access = $UserGroupGuiAccess }
		if ($UserGroupDebugMode) { $Body.params.debug_mode = $UserGroupDebugMode }
		if ($UserGroupUsersStatus) { $Body.params.users_status = $UserGroupUsersStatus }

		$BodyJSON = ConvertTo-Json $Body -Depth 3
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

