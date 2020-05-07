Function Get-ZabbixSession
{
	<# 
	.Synopsis
		Get Zabbix session
	.Description
		Get Zabbix session
	.Example
		Get-ZabbixSession
		Get Zabbix session
	.Example
		Get-ZabbixConnection
		Get Zabbix session
	#>
	
	[CmdletBinding()]
	[Alias("Get-ZabbixConnection", "gzconn", "gzsess")]
	param ()
	
	if (!($global:zabSession -and $global:zabSessionParams))
 {
		write-host "`nDisconnected form Zabbix Server!`n" -f red; return
	}
	elseif ($global:zabSession -and $global:zabSessionParams -and !($ZabbixVersion = Get-ZabbixVersion))
 {
		write-host "`nZabbix session params are OK (use -verbose for details). Check whether Zabbix Server is online. In case of certificate error try new powershell session.`n" -f red; write-verbose "$($zabSession | select *)"; return	
	}
	elseif ($global:zabSession -and $global:zabSessionParams -and ($ZabbixVersion = Get-ZabbixVersion))
 {
		$zabSession | select *, @{n = "ZabbixVer"; e = { $ZabbixVersion } }
	}
	else { write-host "`nDisconnected form Zabbix Server!`n" -f red; return }
}
