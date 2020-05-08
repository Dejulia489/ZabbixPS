Function Initialize-ZabbixSession
{
    <#
    .SYNOPSIS

    Logs into the Zabbix instance and returns an authentication token.

    .DESCRIPTION

    Logs into the Zabbix instance and returns an authentication token.

    .PARAMETER Session

    The name of the Zabbix session.

    .INPUTS

    None. Does not support pipeline.

    .OUTPUTS

    None. Does not support output.

    .EXAMPLE


    .LINK

    Zabbix documentation:
    https://www.zabbix.com/documentation/4.2/manual/api

    New-ZabbixSession
    Get-ZabbixSession
    Save-ZabbixSession
    Remove-ZabbixSession
    #>
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    param
    (
        [Parameter(Mandatory,
            ParameterSetName = 'ByName')]
        [uri]
        $Uri,

        [Parameter(Mandatory,
            ParameterSetName = 'ByName')]
        [pscredential]
        $Credential,

        [Parameter(ParameterSetName = 'ByName')]
        [string]
        $Proxy,

        [Parameter(ParameterSetName = 'ByName')]
        [pscredential]
        $ProxyCredential,

        [Parameter(ParameterSetName = 'ByName')]
        [string]
        $ApiVersion = '2.0',

        [Parameter(Mandatory,
            ParameterSetName = 'BySession')]
        [object]
        $Session,

        [Parameter()]
        [string]
        $Path = $Script:ZabbixModuleDataPath
    )
    begin
    {
        if ($PSCmdlet.ParameterSetName -eq 'BySession')
        {
            $currentSession = $Session | Get-ZabbixSession
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
        $invokeZabbixRestMethodSplat = @{
            Uri  = $Uri
            Body = @{
                jsonrpc = $ApiVersion
                method  = 'user.login'
                params  = @{
                    user     = $Credential.Username
                    password = $Credential.GetNetworkCredential().password
                }
                id      = 1
                auth    = $null
            }
            ErrorAction = 'Stop'
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
        $results = Invoke-ZabbixRestMethod @invokeZabbixRestMethodSplat
        If($results.result)
        {
            $Global:_ZabbixAuthenticationToken = $results.result
        }
    }
    end
    {

    }
}
