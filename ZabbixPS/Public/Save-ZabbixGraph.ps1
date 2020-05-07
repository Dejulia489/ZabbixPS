Function Save-ZabbixGraph
{
	<#
	.Synopsis
		Save graph
	.Description
		Save graph
	.Example
		Get-ZabbixHost | ? name -eq "singleHost" | Get-ZabbixGraph | ? name -match 'CPU utilization' | Save-ZabbixGraph -verbose 
		Save single graph (default location: $env:TEMP\psbbix)
	.Example
		Get-ZabbixHost | ? name -eq "singleHost" | Get-ZabbixGraph | ? name -match 'CPU utilization' | Save-ZabbixGraph -sTime (convertTo-epoch (get-date).AddMonths(-3)) -fileFullPath $env:TEMP\psbbix\graphName.png -show 
		Save single graph and show it
	.Example
		Get-ZabbixHost | ? name -eq "singleHost" | Get-ZabbixGraph | ? name -eq 'RAM utilization (%)' | Save-ZabbixGraph -sTime (convertto-epoch (get-date -date "05/25/2015 00:00").ToUniversalTime()) -show
		Save single graph, time sent as UTC, and will appear as local Zabbix server time
	.Example	
		(Get-ZabbixHost | ? name -eq "singleHost" | Get-ZabbixGraph | ? name -match 'RAM utilization | CPU utilization').graphid | %{Save-ZabbixGraph -GraphID $_ -sTime (convertto-epoch (get-date -date "05/25/2015 00:00")) -fileFullPath $env:TEMP\psbbix\graphid-$_.png -show}
		Save and show graphs for single host
	.Example
		(Get-ZabbixGraph -HostID (Get-ZabbixHost | ? name -match "multipleHosts").hostid | ? name -match 'RAM utilization | CPU utilization').graphid | %{Save-ZabbixGraph -GraphID $_ -sTime (convertto-epoch (get-date -date "05/25/2015 00:00")) -verbose -show}
		Save multiple graphs for multiple hosts
	.Example
		(Get-ZabbixGraph -HostID (Get-ZabbixHost | ? name -match "multipleHosts").hostid | ? name -match 'RAM utilization | CPU utilization').graphid | %{Save-ZabbixGraph -GraphID $_ -sTime (convertto-epoch (get-date -date "05/25/2015 00:00")) -show -mail -from "zabbix@domain.com" -to first.last@mail.com -smtpserver 10.10.20.10 -priority High}
		Save and send by email multiple graphs, for multiple hosts
    #>
    
	[cmdletbinding()]
	[Alias("szgph")]
	param (
		[Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)][string]$GraphID,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$fileFullPath,
		[Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)][string]$sTime = (convertTo-epoch ((get-date).addmonths(-1)).ToUniversalTime()),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$Period = (convertTo-epoch ((get-date).addhours(0)).ToUniversalTime()) - $sTime,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$Width = "900",
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$Hight = "200",
		[switch]$show,
		[switch]$mail,
		[string]$SMTPServer,
		[string[]]$to,
		[string]$from,
		[string]$subject,
		[string]$priority,
		[string]$body
	)

	if (!(Get-ZabbixSession)) { return }
	elseif (!$psboundparameters.count) { Write-MissingParamsMessage; return }

	$boundparams = $PSBoundParameters | out-string
	write-verbose "($boundparams)"
    
	$psbbixTmpDir = "$env:TEMP\psbbix"
	if (!$fileFullPath)
 {
		if (!(test-path $psbbixTmpDir)) { mkdir $psbbixTmpDir }
		$fileFullPath = "$psbbixTmpDir\graph-$graphid.png"
	}
	write-verbose "Graph files located here: $psbbixTmpDir"
	write-verbose "Full path: $fileFullPath"
	
	if ($noSSL)
 {
		$gurl = ($zabSessionParams.url.replace('https', 'http'))
		try { invoke-webrequest "$gurl/chart2.php?graphid=$graphid`&width=$Width`&hight=$Hight`&stime=$sTime`&period=$Period" -OutFile $fileFullPath }
		catch { write-host "$_" }
	}
 else
 {
		$gurl = $zabSessionParams.url
		write-host "SSL doesn't work currently." -f yellow
	}

	if ($show)
 {
		if (test-path "c:\Program Files (x86)\Google\Chrome\Application\chrome.exe") { &"c:\Program Files (x86)\Google\Chrome\Application\chrome.exe" -incognito $fileFullPath }
		elseif (test-path "c:\Program Files\Internet Explorer\iexplore.exe") { &"c:\Program Files\Internet Explorer\iexplore.exe" $fileFullPath }
		else { start "file:///$fileFullPath" }
	}
	
	if ($mail)
 {
		if (!$from) { $from = "zabbix@example.net" }
		if ($subject) { $subject = "Zabbix: graphid: $GraphID. $subject" }
		if (!$subject) { $subject = "Zabbix: graphid: $GraphID" }
		try
		{
			if ($body) { Send-MailMessage -from $from -to $to -subject $subject -body $body -Attachments $fileFullPath -SmtpServer $SMTPServer }
			else { Send-MailMessage -from $from -to $to -subject $subject -Attachments $fileFullPath -SmtpServer $SMTPServer }
		}
		catch { $_.exception.message }
	}
}

