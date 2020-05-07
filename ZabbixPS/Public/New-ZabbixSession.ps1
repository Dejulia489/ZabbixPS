Function New-ZabbixSession
{
    <#
    .SYNOPSIS

    Creates a new Zabbix session.

    .DESCRIPTION

    Creates a new Zabbix session.
    Use Save-ZabbixSession to persist the session data to disk.
    Save the session to a variable to pass the session to other functions.

    .PARAMETER Name

    The friendly name of the session.

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

    .INPUTS

    None. Does not support pipeline.

    .OUTPUTS

    PSObject. Zabbix session

    .EXAMPLE

    Creates a session with the name of 'myZabbixInstance' returning it to the $session variable.

    $session = New-ZabbixSession -Uri 'http://myCompany/zabbix/api_jsonrpc.php' -Credential $creds -Name myZabbixInstance

    .LINK

    Zabbix documentation:
    https://www.zabbix.com/documentation/4.2/manual/api

    Remove-ZabbixSession
    Get-ZabbixSession
    Save-ZabbixSession
    Initialize-ZabbixSession
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [string]
        $Name,

        [Parameter(Mandatory)]
        [uri]
        $Uri,

        [Parameter(Mandatory)]
        [pscredential]
        $Credential,

        [Parameter()]
        [string]
        $Proxy,

        [Parameter()]
        [pscredential]
        $ProxyCredential,

        [Parameter()]
        [string]
        $ApiVersion = '2.0',

        [Parameter()]
        [string]
        $Path = $Script:ZabbixModuleDataPath
    )
    begin
    {

    }
    process
    {
        [int] $_sessionIdcount = (Get-ZabbixSession | Sort-Object -Property 'Id' | Select-Object -Last 1 -ExpandProperty 'Id') + 1
        $_session = New-Object -TypeName PSCustomObject -Property @{
            Uri        = $Uri
            Name       = $Name
            Id         = $_sessionIdcount
            Credential = $Credential
            ApiVersion = $ApiVersion
        }
        if ($Proxy)
        {
            $_session | Add-Member -NotePropertyName 'Proxy' -NotePropertyValue $Proxy
        }
        if ($ProxyCredential)
        {
            $_session | Add-Member -NotePropertyName 'ProxyCredential' -NotePropertyValue $ProxyCredential
        }
        if ($null -eq $Global:_ZabbixSessions)
        {
            $Global:_ZabbixSessions = @()
        }
        $Global:_ZabbixSessions += $_session
        return $_session
    }
    end
    {

    }
}
