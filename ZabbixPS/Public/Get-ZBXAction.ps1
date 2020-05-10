function Get-ZBXAction
{
    <#
    .SYNOPSIS

    Returns a Zabbix action.

    .DESCRIPTION

    Returns a Zabbix action.

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

    .PARAMETER ActionId

    Return only actions with the given IDs.

    .PARAMETER GroupId

    Return only actions that use the given host groups in action conditions.

    .PARAMETER HostId

    Return only actions that use the given hosts in action conditions.

    .PARAMETER TriggerId

    Return only actions that use the given triggers in action conditions.

    .INPUTS

    None, does not support pipeline.

    .OUTPUTS

    PSObject. Zabbix action.

    .EXAMPLE

    Returns all Zabbix actions.

    Get-ZBXAction

    .EXAMPLE

    Returns Zabbix Action with the Action name of 'myAction'.

    Get-ZBXAction -Name 'myAction'

    .LINK

    https://www.zabbix.com/documentation/4.2/manual/api/reference/action/get
    #>
    [CmdletBinding(DefaultParameterSetName = 'ByCredential')]
	[Alias("gzac")]
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
        $ActionId,

        [Parameter()]
        [string[]]
        $GroupId,

        [Parameter()]
        [string[]]
        $HostId,

        [Parameter()]
        [string[]]
        $TriggerId
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
            method  = 'action.get'
            jsonrpc = $ApiVersion
            id      = 1

            params  = @{
                output                   = 'extend'
                selectOperations         = 'extend'
                selectRecoveryOperations = 'extend'
                selectFilter             = 'extend'
            }
        }
        if ($ActionId)
        {
            $body.params.actionids = $ActionId
        }
        if ($GroupId)
        {
            $body.params.groupids = $GroupId
        }
        if ($HostId)
        {
            $body.params.hostids = $HostId
        }
        if ($TriggerId)
        {
            $body.params.triggerids = $TriggerId
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