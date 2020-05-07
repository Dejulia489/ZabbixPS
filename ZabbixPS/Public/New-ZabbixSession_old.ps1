Function New-ZabbixSession
{
	<#
	.SYNOPSIS

	Create new Zabbix session

	.DESCRIPTION

	Create new Zabbix session

	.PARAMETER PSCredential

	Credential

	.PARAMETER IPAddress

	Accept IP address or domain name

	.PARAMETER noSSL

	Connect to Zabbix server with plain http

	.EXAMPLE

	New-ZabbixSession 10.10.10.10

	Connect to Zabbix server

	.EXAMPLE

	Connect-Zabbix 10.10.10.10

	Connect to Zabbix server

	.EXAMPLE

	Connect-Zabbix -IPAddress 10.10.10.10 -noSSL

	Connect to Zabbix server with noSSL (http)

	.EXAMPLE

	Connect-Zabbix -User admin -Password zabbix -IPAddress zabbix.domain.net

	Connect to Zabbix server

	.EXAMPLE

	Connect-Zabbix -IPAddress zabbix.domain.net -URLCustomPath ""

	Connect to Zabbix server with custom frontend install https://zabbix.domain.net, instead of default https://zabbix.domain.net/zabbix
	#>
	[CmdletBinding()]
	[Alias("Connect-Zabbix", "czab")]
	param (
		[Parameter(Mandatory)]
		[string]
		$Uri,

		[Parameter(Mandatory)]
		[pscredential]
		$Credential
	)

	$Body = @{
		jsonrpc = "2.0"
		method  = "user.login"
		params  = @{
			user     = $Credential.UserName
			password = $Credential.GetNetworkCredential().Password
		}
		id      = 1
		auth    = $null
	}

	$BodyJSON = ConvertTo-Json $Body


	try
 {
		if (!$global:zabSession -or !$global:zabSession.session)
		{
			$global:zabSession = Invoke-RestMethod ("$URL/api_jsonrpc.php") -ContentType "application/json" -Body $BodyJSON -Method Post |
			Select-Object jsonrpc, @{Name = "session"; Expression = { $_.Result } }, id, @{Name = "URL"; Expression = { $URL } }
		}
	}
	catch
 {
		# [void]::$_
		if ($_.exception -match "Unable to connect to the remote server") { write-host "`nNot connected! ERROR: $_`n" -f red; write-verbose $_.exception; return }
		else
		{
			write-host "`nSeems SSL certificate is self signed. Trying with no SSL validation..." -f yellow
			if (($PSVersionTable.PSEdition -eq "core") -and !($PSDefaultParameterValues.keys -eq "Invoke-RestMethod:SkipCertificateCheck")) { $PSDefaultParameterValues.Add("Invoke-RestMethod:SkipCertificateCheck", $true) }
			else
			{
				write-host "`nWARNING: `nNo SSL validation setting in Windows Powershell is session wide.`nAs a result in this powershell session Invoke-Webrequest and Invoke-RestMethod may not work with regular websites: ex. iwr google.com`nUse new Powershell session for this purpose.`n" -f yellow
				[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
			}
			$global:zabSession = Invoke-RestMethod ("$URL/api_jsonrpc.php") -ContentType "application/json" -Body $BodyJSON -Method Post |
			Select-Object jsonrpc, @{Name = "session"; Expression = { $_.Result } }, id, @{Name = "URL"; Expression = { $URL } }
		}
	}

	if ($zabSession.session)
 {
		$global:zabSessionParams = [ordered]@{jsonrpc = $zabSession.jsonrpc; session = $zabSession.session; id = $zabSession.id; url = $zabSession.URL }
		write-host "`nConnected to $IPAddress." -f green
		write-host "Zabbix Server version: " -f green -nonewline
		Get-ZabbixVersion
		""
		write-host 'Usage: Get-ZabbixHelp -list' -f yellow
		write-host 'Usage: Get-ZabbixHelp -alias' -f yellow
		""
	}
	else
 {
		write-host "`nERROR: Not connected. Try again." -f red; $zabsession
		if ($PSCredential.UserName -match "@|\\") { write-warning "`nYou have used domain user name format $($PSCredential.UserName). `nThis is not always supported in Zabbix configuration. Please ask your Zabbix admin for help.`n`n" }
	}
}

