function Get-ZBXUser {
    <#
    .SYNOPSIS

    Returns a Zabbix User.

    .DESCRIPTION

    Returns a Zabbix User.

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

    .PARAMETER UserID

    Return only users with the given IDs.

    .PARAMETER GroupId

    Return only users that belong to the given user groups.

    .PARAMETER MediaID

    Return only users that use the given media.

    .PARAMETER MediaTypeID

    Return only users that use the given media types.

    .INPUTS

    None, does not support pipeline.

    .OUTPUTS

    PSObject. Zabbix User.

    .EXAMPLE

    Returns all Zabbix Users.

    Get-ZBXUser

    .LINK

    https://www.zabbix.com/documentation/4.2/manual/api/reference/user/get
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
        [Alias('userids')]
        [string[]]
        $UserID,

        [Parameter()]
        [Alias('usrgrpids')]
        [string[]]
        $GroupID,

        [Parameter()]
        [Alias('mediaids')]
        [string[]]
        $MediaID,

        [Parameter()]
        [Alias('mediatypeids')]
        [string[]]
        $MediaTypeID
    )

    begin {
        if ($PSCmdlet.ParameterSetName -eq 'BySession') {
            $currentSession = $Session | Get-ZBXSession -ErrorAction 'Stop' | Select-Object -First 1
            if ($currentSession) {
                $Uri = $currentSession.Uri
                $Credential = $currentSession.Credential
                $Proxy = $currentSession.Proxy
                $ProxyCredential = $currentSession.ProxyCredential
                $ApiVersion = $currentSession.ApiVersion
            }
        }

        $SessionParameters = @('Uri', 'Credential', 'Proxy', 'ProxyCredential', 'Session')
        $CommonParameters = $(([System.Management.Automation.PSCmdlet]::CommonParameters, [System.Management.Automation.PSCmdlet]::OptionalCommonParameters) | ForEach-Object { $PSItem })
    }

    process {

        $params = @{
            output           = 'extend'
            selectMedias     = 'extend'
            selectMediatypes = 'extend'
            selectUsrgrps    = 'extend'
        }

        #Dynamically adds any bound parameters that are used for the conditions
        foreach ($Parameter in $PSBoundParameters.GetEnumerator()) {
            if ($Parameter.key -notin $SessionParameters -and $Parameter.key -notin $CommonParameters) {
                #uses the hardcoded Alias of the parameter as the API friendly param
                $apiParam = $MyInvocation.MyCommand.Parameters[$Parameter.key].Aliases[0]
                $params[$apiParam] = $Parameter.Value
            }
        }

        $body = New-ZBXRestBody -Method 'user.get' -API $ApiVersion -Params $params


        $invokeZabbixRestMethodSplat = @{
            Body        = $body
            Uri         = $Uri
            Credential  = $Credential
            ApiVersion  = $ApiVersion
            ErrorAction = 'Stop'
        }
        if ($Proxy) {
            $invokeZabbixRestMethodSplat.Proxy = $Proxy
            if ($ProxyCredential) {
                $invokeZabbixRestMethodSplat.ProxyCredential = $ProxyCredential
            }
        }
        Invoke-ZBXRestMethod @invokeZabbixRestMethodSplat
    }

}