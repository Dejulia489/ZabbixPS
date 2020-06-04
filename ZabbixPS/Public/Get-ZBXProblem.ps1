function Get-ZBXProblem
{
    <#
    .SYNOPSIS

    Returns a Zabbix Problem.

    .DESCRIPTION

    Returns a Zabbix Problem.

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

    Return only problems with the given IDs.

    .PARAMETER GroupId

    Return only problems that use the given host groups in problems conditions.

    .PARAMETER HostId

    Return only problems that use the given hosts in problems conditions.

    .PARAMETER ObjectId

    Return only problems that have the given ObjectId in problems conditions.

    .PARAMETER ApplicationId

    Return only problems that have the given ApplicationId in problems conditions.

    .INPUTS

    None, does not support pipeline.

    .OUTPUTS

    PSObject. Zabbix problems.

    .EXAMPLE

    Returns all Zabbix Problems.

    Get-ZBXProblem

    .EXAMPLE

    Returns Zabbix Problem from the HostID 10084.

    Get-ZBXProblem -Session $Session -HostId 10084

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
        [Alias('eventids')]
        [string[]]
        $EventId,

        [Parameter()]
        [Alias('groupids')]
        [string[]]
        $GroupId,

        [Parameter()]
        [Alias('hostids')]
        [string[]]
        $HostId,

        [Parameter()]
        [Alias('objectids')]
        [string[]]
        $ObjectId,

        [Parameter()]
        [Alias('applicationids')]
        [string[]]
        $ApplicationId
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
            select_acknowledges   = 'extend'
            selectTags            = 'extend'
        }

        #Dynamically adds any bound parameters that are used for the conditions
        foreach ($Parameter in $PSBoundParameters.GetEnumerator()){
            if ($Parameter.key -notin $SessionParameters -and $Parameter.key -notin $CommonParameters) {
                #uses the hardcoded Alias of the parameter as the API friendly param
                $apiParam = $MyInvocation.MyCommand.Parameters[$Parameter.key].Aliases[0]
                $params[$apiParam] = $Parameter.Value
            }
        }

        $body = New-ZBXRestBody -Method 'problem.get' -API $ApiVersion -Params $params


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