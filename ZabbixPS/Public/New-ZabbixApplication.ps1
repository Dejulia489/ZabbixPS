Function New-ZabbixApplication
{
	<# 
	.Synopsis
		Create new application
	.Description
		Create new application
	.Example
		New-ZabbixApplication -Name newAppName -HostID (Get-ZabbixHost | ? name -match host).hostid
		Create new application on host
	.Example
		Get-ZabbixHost | ? name -match "hostName" | New-ZabbixApplication -Name newAppName
		Create new application on host
	.Example
		Get-ZabbixHost | ? name -eq SourceHost | Get-ZabbixApplication | New-ZabbixApplication -HostID (Get-ZabbixHost | ? name -match newHost).hostid
		Clone application(s) from host to host
	.Example
		New-ZabbixApplication -Name newAppName -HostID (Get-ZabbixTemplate | ? name -match template).hostid
		Create new application in template
	.Example
		Get-ZabbixTemplate | ? name -match "templateName" | New-ZabbixApplication -name newAppName 
		Create new application in template
	#>
    
	[CmdletBinding()]
	[Alias("nzapp")]
	Param (
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$Name,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$HostID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$TemplateID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$jsonrpc = ($global:zabSessionParams.jsonrpc),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$session = ($global:zabSessionParams.session),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$id = ($global:zabSessionParams.id),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$URL = ($global:zabSessionParams.url)
	)
    
	process
 {

		if (!(Get-ZabbixSession)) { return }
		elseif (!$psboundparameters.count) { Write-MissingParamsMessage; return }
		
		If (!$HostID -and !$TemplateID) { write-host "`nHostID or TemplateID is required.`n" -f red; Get-Help -ex $PSCmdlet.MyInvocation.MyCommand.Name | out-string | Remove-EmptyLines; break }

		$boundparams = $PSBoundParameters | out-string
		write-verbose "($boundparams)"
		
		if ($HostID)
		{
			$Body = @{
				method  = "application.create"
				params  = @{
					name   = $Name
					hostid = $HostID
				}

				jsonrpc = $jsonrpc
				id      = $id
				auth    = $session
			}
		}
		if ($TemplateID)
		{
			$Body = @{
				method  = "application.create"
				params  = @{
					name   = $Name
					hostid = $TemplateID
				}

				jsonrpc = $jsonrpc
				id      = $id
				auth    = $session
			}
		}

		$BodyJSON = ConvertTo-Json $Body
		write-verbose $BodyJSON
		
		$a = Invoke-RestMethod "$URL/api_jsonrpc.php" -ContentType "application/json" -Body $BodyJSON -Method Post
		if ($a.result) { $a.result } else { $a.error }
	}
}

