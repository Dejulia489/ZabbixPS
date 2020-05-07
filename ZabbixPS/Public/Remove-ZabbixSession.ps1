Function Remove-ZabbixSession
{
	<# 
	.Synopsis
		Remove Zabbix session
	.Description
		Remove Zabbix session
	.Example
		Disconnect-Zabbix
		Disconnect from Zabbix server
	.Example
		Remove-Zabbixsession
		Disconnect from Zabbix server
	#>
	
	[CmdletBinding()]
	[Alias("Disconnect-Zabbix", "rzsess", "dzsess")]
	Param (
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$jsonrpc = ($global:zabSessionParams.jsonrpc),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$session = ($global:zabSessionParams.session),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$id = ($global:zabSessionParams.id),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$URL = ($global:zabSessionParams.url)
	)

	# if (!$psboundparameters.count -and !$global:zabSessionParams) {Get-Help -ex $PSCmdlet.MyInvocation.MyCommand.Name | out-string | Remove-EmptyLines; return}
	if (!$psboundparameters.count -and !$global:zabSessionParams) { Write-Host "`nDisconnected from Zabbix Server!`n" -f red; return }

	if (Get-ZabbixSession)
 {
		$Body = @{
			method  = "user.logout"
			jsonrpc = $jsonrpc
			params  = @{ }
			id      = $id
			auth    = $session
		}
		
		$BodyJSON = ConvertTo-Json $Body
		write-verbose $BodyJSON
		
		$a = Invoke-RestMethod "$URL/api_jsonrpc.php" -ContentType "application/json" -Body $BodyJSON -Method Post
		if ($a.result) { $a.result | out-null } else { $a.error }
		
		$global:zabSession = ""
		$global:zabSessionParams = ""
		
		if (!(Get-ZabbixVersion)) { }
	}
	else { Get-ZabbixSession }
}

