function Get-ZBXHostGroup
{
    <#
    .SYNOPSIS

    Returns a Zabbix host group.

    .DESCRIPTION

    Returns a Zabbix host group.

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

    The name of the group.

    .PARAMETER GroupId

    Return only host group that use the given host groups in hostgroup conditions.

    .PARAMETER MaintenanceId

    Return only host groups that are affected by the given maintenances.

    .PARAMETER TemplateId

    Return only host groups that contain the given templates.

    .INPUTS

    None, does not support pipeline.

    .OUTPUTS

    PSObject. Zabbix hostgroup.

    .EXAMPLE

    Returns all Zabbix host group.

    Get-ZBXHostGroup

    .EXAMPLE

    Returns Zabbix HostGroup with the HostGroup name of 'myHostGroup'.

    Get-ZBXHostGroup -Name 'myHostGroup'

    .LINK

    https://www.zabbix.com/documentation/4.2/manual/api/reference/hostgroup/get
    #>
    [CmdletBinding(DefaultParameterSetName = 'ByCredential')]
    [Alias("gzhg", "Get-ZBXGroup")]
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
        $GroupId,

        [Parameter()]
        [string[]]
        $HostId,

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
            method  = 'hostgroup.get'
            jsonrpc = $ApiVersion
            id      = 1

            params  = @{
                output          = 'extend'
                selectHosts     = @(
                    "hostid",
                    "host"
                )
                selectTemplates = @(
                    "templateid",
                    "name"
                )
            }
        }
        if ($Name)
        {
            $body.params.filter = @{
                name = $Name
            }
        }
        if ($GroupId)
        {
            $body.params.groupids = $GroupId
        }
        if ($HostId)
        {
            $body.params.hostids = $HostId
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