function Initialize-ZBXSession
{
    <#
    .SYNOPSIS

    Logs into the Zabbix instance and returns an authentication token.

    .DESCRIPTION

    Logs into the Zabbix instance and returns an authentication token.

    .PARAMETER Uri

    The zabbix instance uri.

    .PARAMETER Credential

    Specifies a user account that has permission to the project.

    .PARAMETER Proxy

    Use a proxy server for the request, rather than connecting directly to the Internet resource. Enter the URI of a network proxy server.

    .PARAMETER ProxyCredential

    Specifie a user account that has permission to use the proxy server that is specified by the -Proxy parameter. The default is the current user.

    .PARAMETER ApiVersion

    Version of the api to use, defaults to 2.0.

    .PARAMETER Path

    The path where module data will be stored, defaults to $Script:ZabbixModuleDataPath.

    .PARAMETER Session

    The name of the Zabbix session.

    .PARAMETER Force

    Forces an update to the authorization token.

    .INPUTS

    None. Does not support pipeline.

    .OUTPUTS

    None. Does not support output.

    .EXAMPLE


    .LINK

    Zabbix documentation:
    https://www.zabbix.com/documentation/4.2/manual/api

    New-ZBXSession
    Get-ZBXSession
    Save-ZBXSession
    Remove-ZBXSession
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
        $Path = $Script:ZabbixModuleDataPath,

        [Parameter()]
        [switch]
        $Force
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
        if ($Global:_ZabbixAuthenticationToken -and (-not($Force.IsPresent)))
        {
            Write-Verbose "[$($MyInvocation.MyCommand.Name)]: Defaulting to `$Global:_ZabbixAuthenticationToken"
            return $Global:_ZabbixAuthenticationToken
        }
        else
        {
            $body = @{
                jsonrpc = $ApiVersion
                method  = 'user.login'
                params  = @{
                    user     = $Credential.Username
                    password = $Credential.GetNetworkCredential().password
                }
                id      = 1
                auth    = $null
            }
            $invokeRestMethodSplat = @{
                ContentType     = 'application/json'
                Method          = 'POST'
                UseBasicParsing = $true
                Uri             = $Uri.AbsoluteUri
                Body            = $body | ConvertTo-Json -Depth 20
            }
            if ($Proxy)
            {
                $invokeRestMethodSplat.Proxy = $Proxy
                if ($ProxyCredential)
                {
                    $invokeRestMethodSplat.ProxyCredential = $ProxyCredential
                }
                else
                {
                    $invokeRestMethodSplat.ProxyUseDefaultCredentials = $true
                }
            }
            Write-Verbose "[$($MyInvocation.MyCommand.Name)]: Requesting an authentication token"
            try
            {
                $results = Invoke-RestMethod @invokeRestMethodSplat
            }
            catch
            {
                If ($PSitem -match 'File not found')
                {
                    Write-Error "[$($MyInvocation.MyCommand.Name)]: Unable to locate the Zabbix api at: [$Uri], is this the correct uri? See: https://www.zabbix.com/documentation/4.2/manual/api for more information." -ErrorAction 'Stop'
                }
            }
            If ($results.result)
            {
                $Global:_ZabbixAuthenticationToken = $results.result
                return $Global:_ZabbixAuthenticationToken
            }
        }
    }
    end
    {

    }
}
