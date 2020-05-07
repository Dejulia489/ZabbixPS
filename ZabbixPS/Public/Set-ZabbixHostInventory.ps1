Function Set-ZabbixHostInventory
{
	<# 
	.Synopsis
		Set host's inventory
	.Description
		Set host's inventory
	.Example
		Get-ZabbixHost | ? name -eq host | Set-ZabbixHost -InventoryMode 0
		Enable manual inventory mode on host
	.Example
		Get-ZabbixHostInventory | ? inventory_mode -eq 0 | select hostid,@{n='hostname';e={(Get-ZabbixHost -HostID $_.hostid).host}},inventory_mode,name | ft -a
		Get inventory enabled hosts
	.Example
		Get-ZabbixHostInventory -HostName Hostname1,Hostname2 | Set-ZabbixHostInventory HostName1,HostName2 -OSFullName "OSFullName"
		Set inventory
	.Example
		Get-ZabbixHost | ? name -match "host-0[5-9]" | Set-ZabbixHostInventory -OSFullName "OSFullName"
		Set inventory
	.Example
		Get-ZabbixHostInventory | ? name -eq NameInInventory | Set-ZabbixHostInventory -OSFullName "OSFullName"
		Set inventory for host, which inventory entry name is NameInInventory 
	.Example
		Get-ZabbixHostInventory | select @{n='hostname';e={(Get-ZabbixHost -HostID $_.hostid).host}},* | ? hostname -match "host" | Set-ZabbixHostInventory -OSFullName "-OSFullName"
		Set inventory entry for multiple hosts
	.Example
		Get-ZabbixHostInventory | ? name -match host | Set-ZabbixHostInventory -OSName " "
		Delete inventory entry
	.Example
		Get-ZabbixHostInventory -GroupID 15 | Set-ZabbixHostInventory -Location Location
		Set inventory location to all, inventory enabled hosts, in host group 15
	.Example
		Get-ZabbixHostInventory -GroupID 15 | select @{n='hostname';e={(Get-ZabbixHost -HostID $_.hostid).host}},* | %{Set-ZabbixHostInventory -Name $_.hostname -HostID $_.hostid}
		Copy hostname to inventory's name field
	.Example
		Get-ZabbixHostInventory -GroupID 15 | ? location | Set-ZabbixHostInventory -Location Location
		Set inventory location to hosts
	.Example
		Import-csv C:\input-inventory-mass-data.csv | %{$splatParams=@{}}{$splatParams=(("$_").trim('@{}').replace("; ","`r`n") | ConvertFrom-StringData); Set-ZabbixHostInventory @splatParams}
		Mass inventory data population
		(Get-ZabbixHostInventory -hostid (Import-csv C:\Inventory-input.csv).hostid) -verbose | select hostid,os*
		Data validation
	.Example
		HostID,Type,TypeDetails,Name,Alias,OSName,OSFullName,OSShortName,SerialNumberA,SerialNumberB,Tag,AssetTag,MACAddressA,MACAddressB,Hardware,DetailedHardware,Software,SoftwareDetails,SoftwareApplicationA,SoftwareApplicationB,SoftwareApplicationC,SoftwareApplicationD,SoftwareApplicationE,ContactPerson,Location,LocationLatitude,LocationLongitude,Notes,Chassis,Model,HWArchitecture,Vendor,ContractNumber,InstallerName,DeploymentStatus,URLA,URLB,URLC,HostNetworks,HostSubnetMask,HostRouter,OOBIPAddress,OOBHostSubnetMask,OOBRouter,HWPurchaseDate,HWInstallationDate,HWMaintenanceExpiryDate,HWDecommissioningDate,SiteAddressA,SiteAddressB,SiteAddressC,SiteCity,SiteState,SiteCountry,SiteZIPCode,SiteRackLocation,SiteNotes,PrimaryPOCName,PrimaryEmail,PrimaryPOCPhoneA,PrimaryPOCPhoneB,PrimaryPOCMobileNumber,PrimaryPOCScreenName,PrimaryPOCnNotes,SecondaryPOCName,SecondaryPOCEmail,SecondaryPOCPhoneA,SecondaryPOCPhoneB,SecondaryPOCMobileNumber,SecondaryPOCScreenName,SecondaryPOCNotes
		10000,Type,TypeDetails,Name,Alias,OSName,DetailedOSName,ShortOSName,SerialNumberA,SerialNumberBB,Tag,AssetTag,MACAddressA,MACAddressB,Hardware,DetailedHardware,Software,SoftwareDetails,SoftwareApplicationA,SoftwareApplicationB,SoftwareApplicationC,SoftwareApplicationD,SoftwareApplicationE,ContactPerson,Location,LocLat,LocLong,Notes,Chassis,Model,HWArchitecture,Vendor,ContractNumber,InstallerName,DeploymentStatus,URLA,URLB,URLC,HostNetworks,HostSubnetMask,HostRouter,OOBIPAddress,OOBHostSubnetMask,OOBRouter,HWPurchaseDate,HWInstallationDate,HWMaintenanceExpiryDate,HWDecommissioningDate,SiteAddressA,SiteAddressB,SiteAddressC,SiteCity,SiteState,SiteCountry,SiteZIPCode,SiteRackLocation,SiteNotes,PrimaryPOCName,PrimaryEmail,PrimaryPOCPhoneA,PrimaryPOCPhoneB,PrimaryPOCMobileNumber,PrimaryPOCScreenName,PrimaryPOCnNotes,SecondaryPOCName,SecondaryPOCEmail,SecondaryPOCPhoneA,SecondaryPOCPhoneB,SecondaryPOCMobileNumber,SecondaryPOCScreenName,SecondaryPOCNotes
		CSV file used in previous example
	#>
	[CmdletBinding()]
	[Alias("szhstinv")]
	Param (
		# [Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$False)][array]$HostName,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$HostID,
		# [Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$true)][string]$hostids,
		# Host inventory population mode: Possible values are: -1 - disabled; 0 - (default) manual; 1 - automatic.
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][int]$InventoryMode,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$status,
		[switch]$force,

		# [Alias("type")][Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$True)][string]$Type,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$Type,
		[Alias("type_full")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$TypeDetails,
		# [Alias("name")][Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$True)][string]$Name,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$Name,
		# [Alias("alias")][Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$True)][string]$Alias,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$Alias,
		[Alias("os")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$OSName,
		# [Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$True)][string]$OS,
		[Alias("os_full")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$OSFullName,
		[Alias("os_short")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$OSShortName,
		[Alias("serialno_a")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$SerialNumberA,
		[Alias("serialno_b")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$SerialNumberB,
		# [Alias("tag")][Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$True)][string]$Tag,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$Tag,
		[Alias("asset_tag")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$AssetTag,
		[Alias("macaddress_a")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$MACAddressA,
		[Alias("macaddress_b")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$MACAddressB,
		# [Alias("hardware")][Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$True)][string]$Hardware,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$Hardware,
		[Alias("hardware_full")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$DetailedHardware,
		# [Alias("software")][Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$True)][string]$Software,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$Software,
		[Alias("software_full")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$SoftwareDetails,
		[Alias("software_app_a")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$SoftwareApplicationA,
		[Alias("software_app_b")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$SoftwareApplicationB,
		[Alias("software_app_c")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$SoftwareApplicationC,
		[Alias("software_app_d")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$SoftwareApplicationD,
		[Alias("software_app_e")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$SoftwareApplicationE,
		[Alias("contact")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$ContactPerson,
		# [Alias("location")][Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$True)][string]$Location,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$Location,
		[Alias("location_lat")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$LocationLatitude,
		[Alias("location_lon")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$LocationLongitude,
		# [Alias("notes")][Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$True)][string]$Notes,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$Notes,
		# [Alias("chassis")][Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$True)][string]$Chassis,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$Chassis,
		# [Alias("model")][Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$True)][string]$Model,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$Model,
		[Alias("hw_arch")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$HWArchitecture,
		# [Alias("vendor")][Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$True)][string]$Vendor,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$Vendor,
		[Alias("contract_number")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$ContractNumber,
		[Alias("installer_name")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$InstallerName,
		[Alias("deployment_status")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$DeploymentStatus,
		[Alias("url_a")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$URLA,
		[Alias("url_b")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$URLB,
		[Alias("url_c")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$URLC,
		[Alias("host_networks")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$HostNetworks,
		[Alias("host_netmask")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$HostSubnetMask,
		[Alias("host_router")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$HostRouter,
		[Alias("oob_ip")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$OOBIPAddress,
		[Alias("oob_netmask")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$OOBHostSubnetMask,
		[Alias("oob_router")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$OOBRouter,
		[Alias("date_hw_purchase")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$HWPurchaseDate,
		[Alias("date_hw_install")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$HWInstallationDate,
		[Alias("date_hw_expiry")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$HWMaintenanceExpiryDate,
		[Alias("date_hw_decomm")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$HWDecommissioningDate,
		[Alias("site_address_a")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$SiteAddressA,
		[Alias("site_address_b")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$SiteAddressB,
		[Alias("site_address_c")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$SiteAddressC,
		[Alias("site_city")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$SiteCity,
		[Alias("site_state")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$SiteState,
		[Alias("site_country")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$SiteCountry,
		[Alias("site_zip")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$SiteZIPCode,
		[Alias("site_rack")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$SiteRackLocation,
		[Alias("site_notes")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$SiteNotes,
		[Alias("poc_1_name")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$PrimaryPOCName,
		[Alias("poc_1_email")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$PrimaryEmail,
		[Alias("poc_1_phone_a")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$PrimaryPOCPhoneA,
		[Alias("poc_1_phone_b")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$PrimaryPOCPhoneB,
		[Alias("poc_1_cell")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$PrimaryPOCMobileNumber,
		[Alias("poc_1_screen")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$PrimaryPOCScreenName,
		[Alias("poc_1_notes")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$PrimaryPOCnNotes,
		[Alias("poc_2_name")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$SecondaryPOCName,
		[Alias("poc_2_email")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$SecondaryPOCEmail,
		[Alias("poc_2_phone_a")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$SecondaryPOCPhoneA,
		[Alias("poc_2_phone_b")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$SecondaryPOCPhoneB,
		[Alias("poc_2_cell")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$SecondaryPOCMobileNumber,
		[Alias("poc_2_screen")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$SecondaryPOCScreenName,
		[Alias("poc_2_notes")][Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)][string]$SecondaryPOCNotes,
		
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$jsonrpc = ($global:zabSessionParams.jsonrpc),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$session = ($global:zabSessionParams.session),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$id = ($global:zabSessionParams.id),
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $true)][string]$URL = ($global:zabSessionParams.url)
	)

	process
 {

		if (!(Get-ZabbixSession)) { return }
		elseif (!$psboundparameters.count) { Write-MissingParamsMessage; return }

		$boundparams = $PSBoundParameters | out-string
		write-verbose "($boundparams)"

		$Body = @{
			method  = "host.update"
			params  = @{
				# host = $HostName
				hostid         = $HostID
				groupid        = $GroupID
				inventory_mode = $InventoryMode
				# filter = @{
				# 	host = $HostName
				# }
				inventory      = @{ }
			}
			
			jsonrpc = $jsonrpc
			id      = $id
			auth    = $session
		}

		if ($Type) { $Body.params.inventory.type = $Type }
		if ($TypeDetails) { $Body.params.inventory.type_full = $TypeDetails }
		if ($Name) { $Body.params.inventory.name = $Name }
		if ($Alias) { $Body.params.inventory.alias = $Alias }
		if ($OSName) { $Body.params.inventory.os = $OSName }
		if ($OSFullName) { $Body.params.inventory.os_full = $OSFullName }
		if ($OSShortName) { $Body.params.inventory.os_short = $OSShortName }
		if ($SerialNumberA) { $Body.params.inventory.serialno_a = $SerialNumberA }
		if ($SerialNumberB) { $Body.params.inventory.serialno_b = $SerialNumberB }
		if ($Tag) { $Body.params.inventory.tag = $Tag }
		if ($AssetTag) { $Body.params.inventory.asset_tag = $AssetTag }
		if ($MACAddressA) { $Body.params.inventory.macaddress_a = $MACAddressA }
		if ($MACAddressB) { $Body.params.inventory.macaddress_b = $MACAddressB }
		if ($Hardware) { $Body.params.inventory.hardware = $Hardware }
		if ($DetailedHardware) { $Body.params.inventory.hardware_full = $DetailedHardware }
		if ($Software) { $Body.params.inventory.software = $Software }
		if ($SoftwareDetails) { $Body.params.inventory.software_full = $SoftwareDetails }
		if ($SoftwareApplicationA) { $Body.params.inventory.software_app_a = $SoftwareApplicationA }
		if ($SoftwareApplicationB) { $Body.params.inventory.software_app_b = $SoftwareApplicationB }
		if ($SoftwareApplicationC) { $Body.params.inventory.software_app_c = $SoftwareApplicationC }
		if ($SoftwareApplicationD) { $Body.params.inventory.software_app_d = $SoftwareApplicationD }
		if ($SoftwareApplicationE) { $Body.params.inventory.software_app_e = $SoftwareApplicationE }
		if ($ContactPerson) { $Body.params.inventory.contact = $ContactPerson }
		if ($Location) { $Body.params.inventory.location = $Location }
		if ($LocationLatitude) { $Body.params.inventory.location_lat = $LocationLatitude }
		if ($LocationLongitude) { $Body.params.inventory.location_lon = $LocationLongitude }
		if ($Notes) { $Body.params.inventory.notes = $Notes }
		if ($Chassis) { $Body.params.inventory.chassis = $Chassis }
		if ($Model) { $Body.params.inventory.model = $Model }
		if ($HWArchitecture) { $Body.params.inventory.hw_arch = $HWArchitecture }
		if ($Vendor) { $Body.params.inventory.vendor = $Vendor }
		if ($ContractNumber) { $Body.params.inventory.contract_number = $ContractNumber }
		if ($InstallerName) { $Body.params.inventory.installer_name = $InstallerName }
		if ($DeploymentStatus) { $Body.params.inventory.deployment_status = $DeploymentStatus }
		if ($URLA) { $Body.params.inventory.url_a = $URLA }
		if ($URLB) { $Body.params.inventory.url_b = $URLB }
		if ($URLC) { $Body.params.inventory.url_c = $URLC }
		if ($HostNetworks) { $Body.params.inventory.host_networks = $HostNetworks }
		if ($HostSubnetMask) { $Body.params.inventory.host_netmask = $HostSubnetMask }
		if ($HostRouter) { $Body.params.inventory.host_router = $HostRouter }
		if ($OOBIPAddress) { $Body.params.inventory.oob_ip = $OOBIPAddress }
		if ($OOBHostSubnetMask) { $Body.params.inventory.oob_netmask = $OOBHostSubnetMask }
		if ($OOBRouter) { $Body.params.inventory.oob_router = $OOBRouter }
		if ($HWPurchaseDate) { $Body.params.inventory.date_hw_purchase = $HWPurchaseDate }
		if ($HWInstallationDate) { $Body.params.inventory.date_hw_install = $HWInstallationDate }
		if ($HWMaintenanceExpiryDate) { $Body.params.inventory.date_hw_expiry = $HWMaintenanceExpiryDate }
		if ($HWDecommissioningDate) { $Body.params.inventory.date_hw_decomm = $HWDecommissioningDate }
		if ($SiteAddressA) { $Body.params.inventory.site_address_a = $SiteAddressA }
		if ($SiteAddressB) { $Body.params.inventory.site_address_b = $SiteAddressB }
		if ($SiteAddressC) { $Body.params.inventory.site_address_c = $SiteAddressC }
		if ($SiteCity) { $Body.params.inventory.site_city = $SiteCity }
		if ($SiteState) { $Body.params.inventory.site_state = $SiteState }
		if ($SiteCountry) { $Body.params.inventory.site_country = $SiteCountry }
		if ($SiteZIPCode) { $Body.params.inventory.site_zip = $SiteZIPCode }
		if ($SiteRackLocation) { $Body.params.inventory.site_rack = $SiteRackLocation }
		if ($SiteNotes) { $Body.params.inventory.site_notes = $SiteNotes }
		if ($PrimaryPOCName) { $Body.params.inventory.poc_1_name = $PrimaryPOCName }
		if ($PrimaryEmail) { $Body.params.inventory.poc_1_email = $PrimaryEmail }
		if ($PrimaryPOCPhoneA) { $Body.params.inventory.poc_1_phone_a = $PrimaryPOCPhoneA }
		if ($PrimaryPOCPhoneB) { $Body.params.inventory.poc_1_phone_b = $PrimaryPOCPhoneB }
		if ($PrimaryPOCMobileNumber) { $Body.params.inventory.poc_1_cell = $PrimaryPOCMobileNumber }
		if ($PrimaryPOCScreenName) { $Body.params.inventory.poc_1_screen = $PrimaryPOCScreenName }
		if ($PrimaryPOCnNotes) { $Body.params.inventory.poc_1_notes = $PrimaryPOCnNotes }
		if ($SecondaryPOCName) { $Body.params.inventory.poc_2_name = $SecondaryPOCName }
		if ($SecondaryPOCEmail) { $Body.params.inventory.poc_2_email = $SecondaryPOCEmail }
		if ($SecondaryPOCPhoneA) { $Body.params.inventory.poc_2_phone_a = $SecondaryPOCPhoneA }
		if ($SecondaryPOCPhoneB) { $Body.params.inventory.poc_2_phone_b = $SecondaryPOCPhoneB }
		if ($SecondaryPOCMobileNumber) { $Body.params.inventory.poc_2_cell = $SecondaryPOCMobileNumber }
		if ($SecondaryPOCScreenName) { $Body.params.inventory.poc_2_screen = $SecondaryPOCScreenName }
		if ($SecondaryPOCNotes) { $Body.params.inventory.poc_2_notes = $SecondaryPOCNotes }


		$BodyJSON = ConvertTo-Json $Body
		write-verbose $BodyJSON
		
		try
		{
			$a = Invoke-RestMethod "$URL/api_jsonrpc.php" -ContentType "application/json" -Body $BodyJSON -Method Post
			# if ($a.result) {$a.result} else {$a.error}
			if ($a.result) { $a.result } else { $a.error }
		}
		catch
		{
			Write-Host "$_"
			Write-Host "Too many entries to return from Zabbix server. Check/reduce the filters." -f cyan
		}
	}

}


