function Get-ZBXApplication
{
    <#
    .SYNOPSIS

    Returns a Zabbix application.

    .DESCRIPTION

    Returns a Zabbix application.

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

    .PARAMETER ApplicationId

    Return only applications with the given IDs.

    .PARAMETER GroupId

    Return only applications that use the given host groups in application conditions.

    .PARAMETER HostId

    Return only applications that use the given hosts in application conditions.

    .INPUTS

    None, does not support pipeline.

    .OUTPUTS

    PSObject. Zabbix application.

    .EXAMPLE

    Returns all Zabbix applications.

    Get-ZBXApplication

    .EXAMPLE

    Returns Zabbix Application with the Application name of 'myApplication'.

    Get-ZBXApplication -Name 'myApplication'

    .LINK

    https://www.zabbix.com/documentation/4.2/manual/api/reference/application/get
    #>
    [CmdletBinding(DefaultParameterSetName = 'ByCredential')]
	[Alias("gzapp")]
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
        $ApplicationId,

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
            method  = 'application.get'
            jsonrpc = $ApiVersion
            id      = 1

            params  = @{
                output                   = 'extend'
            }
        }
        if ($ApplicationId)
        {
            $body.params.applicationids = $ApplicationId
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
            ErrorApplication = 'Stop'
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