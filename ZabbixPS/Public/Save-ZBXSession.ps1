function Save-ZBXSession
{
    <#
    .SYNOPSIS

    Saves a Zabbix session disk.

    .DESCRIPTION

    Saves a Zabbix session disk.
    The sensetive data is encrypted and stored in the users local application data.
    These saved sessions will be available next time the module is imported.

    .PARAMETER Session

    Zabbix session, created by New-ZBXSession.

    .PARAMETER Path

    The path where session data will be stored, defaults to $Script:ZabbixModuleDataPath.

    .PARAMETER PassThru

    Returns the saved session object.

    .INPUTS

    PSbject. Get-ZBXSession, New-ZBXSession

    .OUTPUTS

    None. Save-ZBXSession does not generate any output.

    .EXAMPLE

    Creates a session with the name of 'myZabbixInstance' saving it to disk.

    New-ZBXSession -Uri 'http://myCompany/zabbix/api_jsonrpc.php' -Credential $creds -Name myZabbixInstance | Save-ZBXSession

    .LINK

    Zabbix documentation:
    https://www.zabbix.com/documentation/4.2/manual/api

    New-ZBXSession
    Get-ZBXSession
    Remove-ZBXSession
    Initialize-ZBXSession
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory,
            ValueFromPipeline)]
        [object]
        $Session,

        [Parameter()]
        [string]
        $Path = $Script:ZabbixModuleDataPath
    )
    begin
    {
        if (-not(Test-Path $Path))
        {
            $data = @{SessionData = @() }
        }
        else
        {
            $data = Get-Content -Path $Path -Raw | ConvertFrom-Json
        }
    }
    process
    {
        if ($data.SessionData.Id -notcontains $session.Id)
        {
            $_object = @{
                Id         = $Session.Id
                Name       = $Session.Name
                Uri        = $Session.Uri
                ApiVersion = $Session.ApiVersion
                Saved      = $true
            }
            if ($Session.Credential)
            {
                $_credentialObject = @{
                    Username = $Session.Credential.UserName
                    Password = ($Session.Credential.GetNetworkCredential().SecurePassword | ConvertFrom-SecureString)
                }
                $_object.Credential = $_credentialObject
            }
            if ($Session.Proxy)
            {
                $_object.Proxy = $Session.Proxy
            }
            if ($Session.ProxyCredential)
            {
                $_proxyCredentialObject = @{
                    Username = $Session.ProxyCredential.UserName
                    Password = ($Session.ProxyCredential.GetNetworkCredential().SecurePassword | ConvertFrom-SecureString)
                }
                $_object.ProxyCredential = $_proxyCredentialObject
            }
            $data.SessionData += $_object
            $session | Remove-ZBXSession -Path $Path
        }
    }
    end
    {
        $data | ConvertTo-Json -Depth 5 | Out-File -FilePath $Path
        Write-Verbose "[$($MyInvocation.MyCommand.Name)]: [$Name]: Session data has been stored at [$Path]"
    }
}
