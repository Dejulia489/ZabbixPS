function Get-ZBXSession
{
    <#
    .SYNOPSIS

    Returns Zabbix session data.

    .DESCRIPTION

    Returns Zabbix session data that has been stored in the users local application data.
    Use Save-ZBXSession to persist the session data to disk.
    The sensetive data is returned encrypted.

    .PARAMETER Id

    Session id.

    .PARAMETER Name

    The friendly name of the session.

    .PARAMETER Path

    The path where session data will be stored, defaults to $Script:ZabbixModuleDataPath.

    .INPUTS

    None, does not support pipeline.

    .OUTPUTS

    PSObject. Zabbix session.

    .EXAMPLE

    Returns all Zabbix sessions from disk and memory.

    Get-ZBXSession

    .EXAMPLE

    Returns Zabbix session with the session name of 'myFirstSession'.

    Get-ZBXSession -Name 'myFirstSession'

    .LINK

    Zabbix documentation:
    https://www.zabbix.com/documentation/4.2/manual/api

    New-ZBXSession
    Save-ZBXSession
    Remove-ZBXSession
    Initialize-ZBXSession
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
        [string]
        $Name,

        [Parameter(ParameterSetName = 'ById',
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
        [int]
        $Id,

        [Parameter()]
        [string]
        $Path = $Script:ZabbixModuleDataPath
    )
    begin
    {

    }
    process
    {
        # Process memory sessions
        $_sessions = @()
        if ($null -ne $Global:_ZabbixSessions)
        {
            foreach ($_memSession in $Global:_ZabbixSessions)
            {
                $_sessions += $_memSession
            }
        }

        # Process saved sessions
        if (Test-Path $Path)
        {
            $data = Get-Content -Path $Path -Raw | ConvertFrom-Json
            foreach ($_data in $data.SessionData)
            {
                $_object = New-Object -TypeName PSCustomObject -Property @{
                    Id         = $_data.Id
                    Uri        = $_data.Uri
                    Name       = $_data.Name
                    ApiVersion = $_data.ApiVersion
                    Saved      = $_data.Saved
                }
                if ($_data.Credential)
                {
                    $_psCredentialObject = [pscredential]::new($_data.Credential.Username, ($_data.Credential.Password | ConvertTo-SecureString))
                    $_object | Add-Member -NotePropertyName 'Credential' -NotePropertyValue $_psCredentialObject
                }
                if ($_data.Proxy)
                {
                    $_object | Add-Member -NotePropertyName 'Proxy' -NotePropertyValue $_data.Proxy
                }
                if ($_data.ProxyCredential)
                {
                    $_psProxyCredentialObject = [pscredential]::new($_data.ProxyCredential.Username, ($_data.ProxyCredential.Password | ConvertTo-SecureString))
                    $_object | Add-Member -NotePropertyName 'ProxyCredential' -NotePropertyValue $_psProxyCredentialObject
                }
                $_sessions += $_object
            }
        }
        if ($PSCmdlet.ParameterSetName -eq 'ById')
        {
            $_sessions = $_sessions | Where-Object { $PSItem.Id -eq $Id }
        }
        if ($Name)
        {
            $_sessions = $_sessions | Where-Object { $PSItem.Name -eq $Name }
        }
        if ($_sessions)
        {
            return $_sessions        
        }
        else
        {
            Write-Error "[$($MyInvocation.MyCommand.Name)]: Unable to locate a ZabbixPS session."
        }
    }
    end
    {

    }
}