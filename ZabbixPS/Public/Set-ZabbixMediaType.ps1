Function Set-ZabbixMediaType
{ 
	<#
	.Synopsis
		Set media types
	.Description
		Set media types
	.Example
		Get-ZabbixMediatype | ? name -eq EmailMediaType-01 | Set-ZabbixMediaType -status 1
		Disable the media type
	.Example
		Get-ZabbixMediatype | ? name -like *email* | Set-ZabbixMediaType -AlertSendRetryInterval "7s" -EmailAddressFrom "zabbix-02@example.com"
		Update all media types, contain "email" in the description field
	.Example
		$EmailMediaTypeCreateParams=@{
			Description="EmailMediaType-01"
			Type=0
			MaxAlertSendSessions=5
			MaxAlertSendAttempts=5
			AlertSendRetryInterval="12s"
			SMTPServerIPorFQDN="mail.example.com"
			SMTPServerPort=25
			SMTPServerHostName="mail"
			EmailAddressFrom="zabbix-01@example.com"
			SMTPServerAuthentication=1
			Username="testUser"
			Passwd="TestUser"
			SMTPServerConnectionSecurity=""
			SMTPServerConnectionSecurityVerifyPeer=""
			SMTPServerConnectionSecurityVerifyHost=""
		}
		Get-ZabbixMediaType | ? Description -like *email* | Set-ZabbixMediaType @EmailMediaTypeCreateParams
		Update settings in multiple media types
	.Example
		$PushMediaTypeCreateParams=@{
			Description="Push notifications - 01"
			Type=1
			status=1
			MaxAlertSendSessions=3
			MaxAlertSendAttempts=3
			AlertSendRetryInterval="7s"
			ExecScriptName="push-notification.sh"
			ExecScriptParams="{ALERT.SENDTO}\n{ALERT.SUBJECT}\n{ALERT.MESSAGE}\n"
		}
		Get-ZabbixMediaType | ? Description -like *push* | Set-ZabbixMediaType @PushMediaTypeCreateParams 
		Update multiple media types
	#>
	[cmdletbinding()]
	[Alias("szmt")]
	Param (

		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$mediatypeid,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$Description,
		# Transport used by the media type. Possible values: 0 - e-mail; 1 - script; 2 - SMS; 3 - Jabber; 100 - Ez Texting.
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][int]$Type,
		# Email address from which notifications will be sent. Required for email media types.
		[Alias("smtp_email")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$EmailAddressFrom,
		# SMTP HELO. Required for email media types.
		[Alias("smtp_helo")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$SMTPServerHostName,
		# SMTP server. Required for email media types.
		[Alias("smtp_server")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$SMTPServerIPorFQDN,
		# SMTP server port.
		[Alias("smtp_port")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$SMTPServerPort,
		# SMTP server authentication required. Possible values: 0 - (default) disabled; 1 - enabled
		[Alias("smtp_authentication")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][int]$SMTPServerAuthentication,
		# SMTP server connection security. Possible values: 0 - (default) disabled; 1 - StartTLS; 2 - SSL/TLS
		[Alias("smtp_security")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][int]$SMTPServerConnectionSecurity,
		# SMTP server connection security. Possible values: 0 - (default) disabled; 1 - enabled
		[Alias("smtp_verify_peer")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][int]$SMTPServerConnectionSecurityVerifyPeer,
		# SMTP server connection security. Possible values: 0 - (default) disabled; 1 - enabled
		[Alias("smtp_verify_host")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][int]$SMTPServerConnectionSecurityVerifyHost,
		# Whether the media type is enabled. Possible values: 0 - (default) enabled; 1 - disabled.
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][int]$status,
		# Username or Jabber identifier. Required for Jabber and Ez Texting media types.
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$Username,
		# Authentication password. 
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$Passwd,
		# Serial device name of the GSM modem. Required for SMS media types.
		[Alias("gsm_modem")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$GsmModem,
		# For script media types exec_path contains the name of the executed script. 
		[Alias("exec_path")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$ExecScriptName,
		# Script parameters. Each parameter ends with a new line feed.
		[Alias("exec_params")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$ExecScriptParams,
		# The maximum number of alerts that can be processed in parallel. Possible values for SMS: 1 - (default) Possible values for other media types: 0-100
		[Alias("maxsessions")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][int]$MaxAlertSendSessions,
		# The maximum number of attempts to send an alert. Possible values: 1-10 Default value: 3
		[Alias("maxattempts")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][int]$MaxAlertSendAttempts,
		# The interval between retry attempts. Accepts seconds and time unit with suffix. Possible values: 0-60s Default value: 10s
		[Alias("attempt_interval")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$AlertSendRetryInterval,
		
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
			method  = "mediatype.update"
			params  = @{
				mediatypeid = $mediatypeid
				description = $Description
				type        = $Type
				status      = $status
			}

			jsonrpc = $jsonrpc
			id      = $id
			auth    = $session
		}

		# General
		if ($MaxAlertSendSessions) { $Body.params.maxsessions = $MaxAlertSendSessions }
		if ($MaxAlertSendAttempts) { $Body.params.maxattempts = $MaxAlertSendAttempts }
		if ($AlertSendRetryInterval) { $Body.params.attempt_interval = $AlertSendRetryInterval }
		# Email
		if ($SMTPServerIPorFQDN) { $Body.params.smtp_server = $SMTPServerIPorFQDN }
		if ($SMTPServerPort) { $Body.params.smtp_port = $SMTPServerPort }
		if ($SMTPServerHostName) { $Body.params.smtp_helo = $SMTPServerHostName }
		if ($EmailAddressFrom) { $Body.params.smtp_email = $EmailAddressFrom }
		if ($SMTPServerAuthentication) { $Body.params.smtp_authentication = $SMTPServerAuthentication }
		if ($Username) { $Body.params.username = $Username }
		if ($Passwd) { $Body.params.passwd = $Passwd }
		if ($SMTPServerConnectionSecurity) { $Body.params.smtp_security = $SMTPServerConnectionSecurity }
		if ($SMTPServerConnectionSecurityVerifyPeer) { $Body.params.smtp_verify_peer = $SMTPServerConnectionSecurityVerifyPeer }
		if ($SMTPServerConnectionSecurityVerifyHost) { $Body.params.smtp_verify_host = $SMTPServerConnectionSecurityVerifyHost }
		# Other
		if ($ExecScriptName) { $Body.params.exec_path = $ExecScriptName } 
		if ($ExecScriptParams) { $Body.params.exec_params = "$ExecScriptParams`n" } 
		if ($GsmModem) { $Body.params.gsm_modem = $GsmModem } 

		$BodyJSON = ConvertTo-Json $Body
		write-verbose $BodyJSON
		
		$a = Invoke-RestMethod "$URL/api_jsonrpc.php" -ContentType "application/json" -Body $BodyJSON -Method Post
		if ($a.result) { $a.result } else { $a.error }
	}
}
