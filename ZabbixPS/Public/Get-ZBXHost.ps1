function Get-ZBXHost
{
    <#
    .SYNOPSIS

    Returns a Zabbix host.

    .DESCRIPTION

    Returns a Zabbix host.

    .PARAMETER Uri

    The Zabbix instance uri.

    .PARAMETER Credential

    Specifies a user account that has permission to the project.

    .PARAMETER Proxy

    Use a proxy server for the request, rather than connecting directly to the Internet resource. Enter the URI of a network proxy server.

    .PARAMETER ProxyCredential

    Specifie a user account that has permission to use the proxy server that is specified by the -Proxy parameter. The default is the current user.

    .PARAMETER Session

    ZabbixPS session, created by New-ZBXSession.

    .PARAMETER Name

    The name of the host.

    .PARAMETER HostId

    Return only hosts with the given IDs.

    .PARAMETER GroupId

    Return only hosts that use the given host groups in host conditions.

    .PARAMETER ApplicationId

    Return only hosts that have the given applications.

    .PARAMETER DserviceId

    Return only hosts that are related to the given discovered services.

    .PARAMETER GraphId

    Return only hosts that have the given graphs.

    .PARAMETER InterfaceId

    Return only hosts that use the given interfaces.

    .PARAMETER ItemId

    Return only hosts that have the given items.

    .PARAMETER MaintenanceId

    Return only hosts that are affected by the given maintenances.

    .PARAMETER TemplateId

    Return only hosts that are linked to the given templates.

    .INPUTS

    None, does not support pipeline.

    .OUTPUTS

    PSObject. Zabbix host.

    .EXAMPLE

    Returns all Zabbix hosts.

    Get-ZBXHost

    .EXAMPLE

    Returns Zabbix Host with the Host name of 'myHost'.

    Get-ZBXHost -Name 'myHost'

    .LINK

    https://www.zabbix.com/documentation/4.2/manual/api/reference/host/get
    #>
    [CmdletBinding(DefaultParameterSetName = 'ByCredential')]
    param
    (
        [Parameter(Mandatory,
            ParameterSetName = 'ByCredential')]
        [uri]
        $Uri,

        [Parameter(ParameterSetName = 'ByCredential')]
        [pscredential]
        $Credential,

        [Parameter(ParameterSetName = 'ByCredential')]
        [string]
        $Proxy,

        [Parameter(ParameterSetName = 'ByCredential')]
        [pscredential]
        $ProxyCredential,

        [Parameter(Mandatory,
            ParameterSetName = 'BySession')]
        [object]
        $Session,

        [Parameter()]
        [string[]]
        $Name,

        [Parameter()]
        [string[]]
        $HostId,

        [Parameter()]
        [string[]]
        $GroupId,

        [Parameter()]
        [string[]]
        $ApplicationId,

        [Parameter()]
        [string[]]
        $DserviceId,

        [Parameter()]
        [string[]]
        $GraphId,

        [Parameter()]
        [string[]]
        $InterfaceId,

        [Parameter()]
        [string[]]
        $ItemId,

        [Parameter()]
        [string[]]
        $MaintenanceId,

        [Parameter()]
        [string[]]
        $TemplateId
    )

    begin
    {
        if ($PSCmdlet.ParameterSetName -eq 'BySession')
        {
            $currentSession = $Session | Get-ZBXSession -ErrorAction 'Stop' | Select-Object -First 1
            if ($currentSession)
            {
                $Uri = $currentSession.Uri
                $Credential = $currentSession.Credential
                $Proxy = $currentSession.Proxy
                $ProxyCredential = $currentSession.ProxyCredential
                $ApiVersion = $currentSession.ApiVersion
            }
        }
    }

    process
    {
        $body = @{
            method  = 'host.get'
            jsonrpc = $ApiVersion
            id      = 1
            sortfield = 'name'
            params  = @{
                output                   = 'extend'
                selectParentTemplates = @(
					"templateid",
					"name"
				)
				selectInterfaces = @(
					"interfaceid",
					"ip",
					"port"
				)
				selectHttpTests = @(
					"httptestid",
					"name",
					"steps"
				)
				selectTriggers = @(
					"triggerid",
					"description"
				)
				selectApplications = @(
					"applicationid"
					"name"
				)
				selectGraphs = @(
					"graphid"
					"name"
				)
				selectMacros = @(
					"hostmacroid"
					"macro"
					"value"
				)
				selectScreens = @(
					"screenid"
					"name"
				)
				selectInventory = @(
					"name"
					"type"
					"os"
				)
            }
        }
        if ($Name)
        {
            $body.params.filter = @{
                host = $Name
            }
        }
        if ($HostId)
        {
            $body.params.hostids = $HostId
        }
        if ($GroupId)
        {
            $body.params.groupids = $GroupId
        }
        if ($ApplicationId)
        {
            $body.params.applicationids = $ApplicationId
        }
        if ($DserviceId)
        {
            $body.params.dserviceids = $DserviceId
        }
        if ($GraphId)
        {
            $body.params.graphids = $GraphId
        }
        if ($InterfaceId)
        {
            $body.params.interfaceids = $InterfaceId
        }
        if ($ItemId)
        {
            $body.params.itemids = $ItemId
        }
        if ($MaintenanceId)
        {
            $body.params.maintenanceids = $MaintenanceId
        }
        if ($TemplateId)
        {
            $body.params.templateids = $TemplateId
        }
        $invokeZabbixRestMethodSplat = @{
            Body        = $body
            Uri         = $Uri
            Credential  = $Credential
            ApiVersion  = $ApiVersion
            ErrorAction = 'Stop'
        }
        if ($Proxy)
        {
            $invokeZabbixRestMethodSplat.Proxy = $Proxy
            if ($ProxyCredential)
            {
                $invokeZabbixRestMethodSplat.ProxyCredential = $ProxyCredential
            }
        }
        return Invoke-ZBXRestMethod @invokeZabbixRestMethodSplat
    }

    end
    {
    }
}