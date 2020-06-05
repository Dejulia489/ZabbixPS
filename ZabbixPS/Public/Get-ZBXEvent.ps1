function Get-ZBXEvent
{
    <#
    .SYNOPSIS

    Returns a Zabbix event.

    .DESCRIPTION

    Returns a Zabbix event.

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

    .PARAMETER EventId

    Return only events with the given IDs.

    .PARAMETER GroupId

    Return only events that use the given host groups in event conditions.

    .PARAMETER HostId

    Return only events that use the given hosts in event conditions.

    .INPUTS

    None, does not support pipeline.

    .OUTPUTS

    PSObject. Zabbix event.

    .EXAMPLE

    Returns all Zabbix events.

    Get-ZBXEvent

    .EXAMPLE

    Returns Zabbix Event with the Event name of 'myEvent'.

    Get-ZBXEvent -Name 'myEvent'

    .LINK

    https://www.zabbix.com/documentation/4.2/manual/api/reference/event/get
    #>
    [CmdletBinding(DefaultParameterSetName = 'ByCredential')]
	[Alias("gze")]
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
        $EventId,

        [Parameter()]
        [string[]]
        $GroupId,

        [Parameter()]
        [string[]]
        $HostId
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
            method  = 'event.get'
            jsonrpc = $ApiVersion
            id      = 1

            params  = @{
                output                = 'extend'
                select_acknowledges   = 'extend'
                selectTags            = 'extend'
                selectSuppressionData = 'extend'
                selectHosts           = 'extend'
            }
        }
        if ($EventId)
        {
            $body.params.eventids = $EventId
        }
        if ($GroupId)
        {
            $body.params.groupids = $GroupId
        }
        if ($HostId)
        {
            $body.params.hostids = $HostId
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