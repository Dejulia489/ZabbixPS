Function Get-ZabbixHelp
{
	<# 
	.Synopsis
		Get fast help for most useful examples for every function with no empty lines
	.Description
		Get fast help for most useful examples for every function with no empty lines
	.Example
		Get-ZabbixHelp -list
		Get list of all module functions, like gcm -module psbbix
	.Example
		Get-ZabbixHelp -alias
		Get list of all aliases in the module
	.Example
		gzh host
		Get examples for all zabbixhost commands
	.Example
		gzh hostinterface -p interface
		Get all examples for Get/Set/New/Remove-ZabbixHostInterface with pattern "interface"
	.Example
		gzh hostinterface -p interface -short
		Get all examples for Get/Set/New/Remove-ZabbixHostInterface with pattern "interface", print only matches
	.Example
		gzh host -p "copy|clone" -short
		Get examples with copy or clone 
	.Example
		gzh -zverb set
		Get examples of all Set commands
	.Example
        gzh -zverb get
        Get examples of all Get commands
	.Example
		gzh -zverb get hostinterface 
		Get examples for Get-ZabbixHostInterface
    .Example
		gzh user set
		Get examples for Set-ZabbixUser
    .Example
		gzh host -p step
		Find step by step guides
    .Example
		gzh item -p "cassandra|entropy"
		Get help for cassandra items if you're using my cassandra cluster template
	#>
    
	[CmdletBinding()]
	[Alias("gzh")]
	Param ($znoun, $zverb, [switch]$list, $pattern, [switch]$short, [switch]$alias)
    
	if (!(get-module "Find-String")) { Write-Host "`nInstall module Find-String from Powershell Gallery: install-module find-string -force. Unless this function won't work properly.`n" -f yellow; return }
	if (!$psboundparameters.count) { Get-Help -ex $PSCmdlet.MyInvocation.MyCommand.Name | out-string | Remove-EmptyLines; return }

	if ($list) { dir function:\*-zabbix* | select name | sort name }
	elseif ($alias) { gcm -Module psbbix | % { gal -Definition $_.name -ea 0 } }
	elseif (!$znoun -and $pattern -and $short) { gzh | % { foreach ($i in $_) { $i | Select-String -Pattern $pattern -AllMatches | Out-ColorMatchInfo -onlyShowMatches } } }
	elseif (!$znoun -and $pattern -and !$short) { gzh | out-string | Select-String -Pattern $pattern -AllMatches | Out-ColorMatchInfo -onlyShowMatches }
	elseif ($znoun -and $pattern -and !$short) { gzh $znoun | out-string | Select-String -Pattern $pattern -AllMatches | Out-ColorMatchInfo -onlyShowMatches }
	elseif ($znoun -and $pattern -and $short) { gzh $znoun | % { foreach ($i in $_) { $i | Select-String -Pattern $pattern -AllMatches | Out-ColorMatchInfo -onlyShowMatches } } }
	elseif ($zverb -and !$znoun) { dir function:\$zverb-zabbix* | % { write-host $_.Name -f yellow; get-help -ex $_.Name | out-string | Remove-EmptyLines } }
	elseif ($znoun -and !$zverb) { dir function:\*zabbix$znoun | % { write-host $_.Name -f yellow; get-help -ex $_.Name | out-string | Remove-EmptyLines } }
	elseif ($zverb -and $znoun) { dir function:\$zverb-zabbix$znoun | % { write-host $_.Name -f yellow; get-help -ex $_.Name | out-string | Remove-EmptyLines } }
	else { dir function:\*zabbix* | % { write-host $_.Name -f yellow; get-help -ex $_.Name | out-string | Remove-EmptyLines } }
}
