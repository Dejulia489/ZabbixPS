function Get-ZBXUserGroup {
    <#
    .SYNOPSIS

    Returns a Zabbix UserGroup.

    .DESCRIPTION

    Returns a Zabbix UserGroup.

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

    Return only user groups that contain the given users.

    .PARAMETER GroupId

    Return only user groups with the given IDs.

    .PARAMETER GroupStatus

    Return only user groups with the given status.

    .PARAMETER AuthMethod

    Return only user groups with the given frontend authentication method.

    .INPUTS

    None, does not support pipeline.

    .OUTPUTS

    PSObject. Zabbix User.

    .EXAMPLE

    Returns all Zabbix Users.

    Get-ZBXUserGroup

    .LINK

    https://www.zabbix.com/documentation/4.2/manual/api/reference/usergroup/get
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
        [Alias('status')]
        [ValidateSet('Enable', 'Disabled')]
        [string]
        $GroupStatus,

        [Parameter()]
        [Alias('with_gui_access')]
        [ValidateSet('Default', 'Internal', 'LDAP', 'Disabled')]
        [string]
        $AuthMethod
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
        $GroupStatusValues = @{
            'Enabled'  = 0
            'Disabled' = 1
        }
        $AuthMethodValues = @{
            'Default'  = 0
            'Internal' = 1
            'LDAP'     = 2
            'Disabled' = 3
        }
        $SessionParameters = @('Uri', 'Credential', 'Proxy', 'ProxyCredential', 'Session')
        $CommonParameters = $(([System.Management.Automation.PSCmdlet]::CommonParameters, [System.Management.Automation.PSCmdlet]::OptionalCommonParameters) | ForEach-Object { $PSItem })
    }

    process {

        $params = @{
            output      = 'extend'
            selectUsers = 'extend'
        }

        #Dynamically adds any bound parameters that are used for the conditions
        foreach ($Parameter in $PSBoundParameters.GetEnumerator()) {
            if ($Parameter.key -notin $SessionParameters -and $Parameter.key -notin $CommonParameters) {
                #uses the hardcoded Alias of the parameter as the API friendly param
                $apiParam = $MyInvocation.MyCommand.Parameters[$Parameter.key].Aliases[0]
                switch ($apiParam) {
                    'status' { $apiValue = $GroupStatusValues[$Parameter.Value]; break }
                    'with_gui_access' { $apiValue = $AuthMethodValues[$Parameter.Value]; break }
                    default { $apiValue = $Parameter.Value }
                }
                $params[$apiParam] = $apiValue
            }
        }

        $body = New-ZBXRestBody -Method 'usergroup.get' -API $ApiVersion -Params $params


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