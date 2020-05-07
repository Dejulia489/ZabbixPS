Function Get-ZabbixVersion
{
	<# 
	.Synopsis
		Get Zabbix server version
	.Description
		Get Zabbix server version
	.Example
		Get-ZabbixVersion
		Get Zabbix server version
	.Example
		Get-ZabbixVersion
		Get Zabbix server version
	#>
    
	[CmdletBinding()]
	[Alias("gzver")]
	Param (
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][array]$params = @(),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$jsonrpc = ($global:zabSessionParams.jsonrpc),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$session = ($global:zabSessionParams.session),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$id = ($global:zabSessionParams.id),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$URL = ($global:zabSessionParams.url)
	)
    
	if (!($global:zabSession -or $global:zabSessionParams)) { write-host "`nDisconnected from Zabbix Server!`n" -f red; return }
	else
 {
		$Body = @{
			method  = "apiinfo.version"
			jsonrpc = $jsonrpc
			id      = $id
			params  = $params
		}
		
		$BodyJSON = ConvertTo-Json $Body
		write-verbose $BodyJSON
		
		try
		{
			$a = Invoke-RestMethod "$URL/api_jsonrpc.php" -ContentType "application/json" -Body $BodyJSON -Method Post
			if ($a.result) { return $a.result } else { $a.error }
		}
		catch { Write-Host "`nERROR: $_." -f red }
	}
}
