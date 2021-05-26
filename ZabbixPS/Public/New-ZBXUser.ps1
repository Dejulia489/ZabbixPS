function New-ZBXUser {
    <#
    .SYNOPSIS

    Creates a Zabbix User.

    .DESCRIPTION

    Creates a Zabbix User.

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

    .PARAMETER Username

    User Alias

    .PARAMETER Password

    User's password. Can be omitted if user is added only to groups that have LDAP access.

    .PARAMETER GroupId

    User groups to add the user to. Must be the GroupID

    .PARAMETER UserMedia

    Medias to create for the user. This parameter takes a Hashtable of values.

    @{
        mediatypeid = 0|1|2|3
        sendto = @('EmailAddress@example.com') # other media types are single string
        active = 0|1
        severity = 63| #binary combination of severity default shown
        period = 1-7,00:00-24:00 # days and times
    }

    .PARAMETER AdditionalOptions

    This parameter takes a Hashtable of values to provied userObject values

    @{
        alias = jdoe
        autologin = 0|1 #disable|enable
        autologout = 15m # timeframe
        lang = en_GB # language for user
        name = Jane
        refresh = 30s
        rows_per_page = 50
        surname = Doe
        theme = default|blue-theme|dark-theme
        type = 1|2|3 # ZabbixUser|Zabbix Admin| Zabbix Super Admin
        url = htpps://zabbix/devices.php # Page after logging in
        #UserMedia Options can also be included
    }

    .INPUTS

    None, does not support pipeline.

    .OUTPUTS

    PSObject. Zabbix User.

    .EXAMPLE

    Adds the LDAP user jdoe to an LDAP group

    New-ZBXUser -Username jdoe -GroupID 15

    .EXAMPLE

    Adds the local user jcool with additional options

    $AdditionalOptions = @{name='Joe';surname='Cool';autologin=0;autologout="30m";lang='en_US';refresh='60s';rows_per_page=100;theme='dark-theme';type=3;}
    New-ZBXUser -Session $session -Username jcool -Password (Read-Host -AsSecureString) -GroupID 7 -AdditionalOptions $AdditionalOptions
    .LINK

    https://www.zabbix.com/documentation/4.2/manual/api/reference/user/create
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

        [Parameter(Mandatory)]
        [Alias('alias')]
        [string]
        $Username,

        [Parameter()]
        [Alias('passwd')]
        [securestring]
        $Password,

        [Parameter()]
        [Alias('usrgrps')]
        [int]
        $GroupID,

        [Parameter()]
        [hashtable]
        $UserMedia,

        [Parameter()]
        [hashtable]
        $AdditionalOptions
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

        #These Enums create an easy way to lookup supported API keys
        enum validMediaOptions {
            mediatypeid; sendto; active; severity; period;
        }
        enum validOptions {
            alias; autologin; autologout; lang; name; refresh; rows_per_page; surname; theme;
            type; url; mediatypeid; sendto; active; severity; period;
        }
        $params = @{ }
        $SessionParameters = @('Uri', 'Credential', 'Proxy', 'ProxyCredential', 'Session')
        $CommonParameters = $(([System.Management.Automation.PSCmdlet]::CommonParameters, [System.Management.Automation.PSCmdlet]::OptionalCommonParameters) | ForEach-Object { $PSItem })
    }

    process {
        #Dynamically adds any bound parameters that are used for the conditions
        foreach ($Parameter in $PSBoundParameters.GetEnumerator()) {
            if ($Parameter.key -notin $SessionParameters -and $Parameter.key -notin $CommonParameters) {
                #uses the hardcoded Alias of the parameter as the API friendly param
                $apiParam = $MyInvocation.MyCommand.Parameters[$Parameter.key].Aliases[0]
                if ($null -ne $apiParam) {
                    switch ($apiParam) {
                        'passwd' { $apiValue = ([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))); break }
                        'usrgrps' { $apiValue = @(@{"usrgrpid" = $Parameter.value }); break }
                        default { $apiValue = $Parameter.Value }
                    }
                    $params[$apiParam] = $apiValue
                }
            }
        }
        if ($PSBoundParameters.ContainsKey('UserMedia')) {
            foreach ($Options in $UserMedia.GetEnumerator()) {
                #Validates that the
                if ([validMediaOptions].getEnumNames().Contains("$($Options.key)")) {
                    $params["user_medias"] = @{"$($Options.key)" = $($Options.value) }
                } else {
                    Write-Warning "$($Options.key) is not part of the supported options; See help for valid options"
                }
            }
        }
        if ($PSBoundParameters.ContainsKey('AdditionalOptions')) {
            foreach ($Options in $AdditionalOptions.GetEnumerator()) {
                if ([validOptions].getEnumNames().Contains("$($Options.key)")) {
                    #Ensures that if someone uses AdditionalOptions for everything
                    if ([validMediaOptions].getEnumNames().Contains("$($Options.key)")) {
                        $params["user_medias"] = @{"$($Options.key)" = $($Options.value) }
                    } else {
                        $params[$($Options.key)] = $Options.value
                    }
                } else {
                    Write-Warning "$($Options.key) is not part of the supported options; See help for valid options"
                }
            }
        }

        $body = New-ZBXRestBody -Method 'user.create' -API $ApiVersion -Params $params


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