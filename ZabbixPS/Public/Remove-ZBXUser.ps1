function Remove-ZBXUser {
    <#
    .SYNOPSIS

    Removes a Zabbix User.

    .DESCRIPTION

    Removes a Zabbix User.

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

    IDs of users to delete.

    .PARAMETER Force

    Suppresses prompt.

    .INPUTS

    None, does not support pipeline.

    .OUTPUTS

    PSObject. Zabbix User.

    .EXAMPLE

    Removes the user whose id is 7

    Remove-ZBXUser -UserID 7

    .EXAMPLE

    Removes the users without prompting for confirmation

    Remove-ZBXUser -UserID 7,8 -Force

    .LINK

    https://www.zabbix.com/documentation/4.2/manual/api/reference/user/delete
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High', DefaultParameterSetName = 'ByCredential')]
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
        [int[]]
        $UserId,

        [Parameter()]
        [switch]
        $Force
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

        $params = @{ }
        $SessionParameters = @('Uri', 'Credential', 'Proxy', 'ProxyCredential', 'Session')
        $CommonParameters = $(([System.Management.Automation.PSCmdlet]::CommonParameters, [System.Management.Automation.PSCmdlet]::OptionalCommonParameters) | ForEach-Object { $PSItem })
    }

    process {
        #This method only takes an array of ids, so needs a blank hashtable to get the basic body
        $params = @{ }
        $body = New-ZBXRestBody -Method 'user.delete' -API $ApiVersion -Params $params
        $body.params = @($UserId)

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
        #Get the frendly name of the user
        $getUserSplat = $invokeZabbixRestMethodSplat.Clone()
        $getUserSplat.Remove('body')
        $getUserSplat.Remove('apiversion')
        $userName = Get-ZBXUser @getUserSplat -UserID $UserId
        $userName = $userName.alias -join ' '

        if ($Force -or $PSCmdlet.ShouldContinue("About to remove $userName", "Would you like to continue?" )) {
            Invoke-ZBXRestMethod @invokeZabbixRestMethodSplat
        }
    }
}