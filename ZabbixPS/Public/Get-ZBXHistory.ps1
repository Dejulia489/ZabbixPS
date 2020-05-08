function Get-ZBXHistory
{
    <#
    .SYNOPSIS

    Returns a Zabbix history.

    .DESCRIPTION

    Returns a Zabbix history.

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

    .PARAMETER History

    History object types to return.
    0 - numeric float;
    1 - character;
    2 - log;
    3 - numeric unsigned;
    4 - text.

    Default: 3.

    .PARAMETER GroupId

    Return only historys that use the given host groups in history conditions.

    .PARAMETER ItemId

    Return only history from the given items.

    .INPUTS

    None, does not support pipeline.

    .OUTPUTS

    PSObject. Zabbix history.

    .EXAMPLE

    Returns all Zabbix historys.

    Get-ZBXHistory

    .EXAMPLE

    Returns Zabbix History with the History name of 'myHistory'.

    Get-ZBXHistory -Name 'myHistory'

    .LINK

    https://www.zabbix.com/documentation/4.2/manual/api/reference/history/get
    #>
    [CmdletBinding(DefaultParameterSetName = 'ByCredential')]
	[Alias("gzhist")]
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
        [ValidateSet(0, 1, 2, 3, 4)]
        [int]
        $History = 3,

        [Parameter()]
        [string[]]
        $GroupId,

        [Parameter()]
        [string[]]
        $ItemId
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
            method  = 'history.get'
            jsonrpc = $ApiVersion
            id      = 1

            params  = @{
                output  = 'extend'
                history = $History
            }
        }
        if ($GroupId)
        {
            $body.params.groupids = $GroupId
        }
        if ($ItemId)
        {
            $body.params.itemids = $ItemId
        }
        $invokeZabbixRestMethodSplat = @{
            Body         = $body
            Uri          = $Uri
            Credential   = $Credential
            ApiVersion   = $ApiVersion
            ErrorHistory = 'Stop'
        }
        if ($Proxy)
        {
            $invokeZabbixRestMethodSplat.Proxy = $Proxy
            if ($ProxyCredential)
            {
                $invokeZabbixRestMethodSplat.ProxyCredential = $ProxyCredential
            }
            else
            {
                $invokeZabbixRestMethodSplat.ProxyUseDefaultCredentials = $true
            }
        }
        return Invoke-ZBXRestMethod @invokeZabbixRestMethodSplat
    }

    end
    {
    }
}