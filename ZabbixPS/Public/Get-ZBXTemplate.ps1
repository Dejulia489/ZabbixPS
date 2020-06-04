function Get-ZBXTemplate
{
    <#
    .SYNOPSIS

    Returns a Zabbix Template.

    .DESCRIPTION

    Returns a Zabbix Template.

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

    .PARAMETER TemplateId

    Return only Templates with the given IDs.

    .PARAMETER GroupId

    Return only Templates that use the given host groups in the search conditions.

    .PARAMETER HostId

    Return only Templates that use the given hosts in the search conditions.

    .PARAMETER ParentTemplateId

    Return the children Templates of the Parent Templates that is given in the search conditions.

    .PARAMETER TreiggerId

    Return only Templates that have the given ApplicationId in Templates conditions.

    .INPUTS

    None, does not support pipeline.

    .OUTPUTS

    PSObject. Zabbix Templates.

    .EXAMPLE

    Returns all Zabbix Templates.

    Get-ZBXTemplate

    .EXAMPLE

    Returns Zabbix Template from the HostID 10084.

    Get-ZBXTemplate -Session $Session -HostId 10084

    .LINK

    https://www.zabbix.com/documentation/4.2/manual/api/reference/event/get
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
        [Alias('templateids')]
        [string[]]
        $TemplateId,

        [Parameter()]
        [Alias('groupids')]
        [string[]]
        $GroupId,

        [Parameter()]
        [Alias('hostids')]
        [string[]]
        $HostId,

        [Parameter()]
        [Alias('parentTemplateids')]
        [string[]]
        $ParentTemplateId,

        [Parameter()]
        [Alias('triggerids')]
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

        $SessionParameters = @('Uri','Credential','Proxy','ProxyCredential','Session')
        $CommonParameters = $(([System.Management.Automation.PSCmdlet]::CommonParameters,[System.Management.Automation.PSCmdlet]::OptionalCommonParameters) | ForEach-Object {$PSItem})
    }

    process
    {

        $params  = @{
            output                = 'extend'
            selectTags            = 'extend'
            selectGroups          = 'extend'
        }

        #Dynamically adds any bound parameters that are used for the conditions
        foreach ($Parameter in $PSBoundParameters.GetEnumerator()){
            if ($Parameter.key -notin $SessionParameters -and $Parameter.key -notin $CommonParameters) {
                #uses the hardcoded Alias of the parameter as the API friendly param
                $apiParam = $MyInvocation.MyCommand.Parameters[$Parameter.key].Aliases[0]
                $params[$apiParam] = $Parameter.Value
            }
        }

        $body = New-ZBXRestBody -Method 'template.get' -API $ApiVersion -Params $params


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
        Invoke-ZBXRestMethod @invokeZabbixRestMethodSplat
    }

}