function Remove-ZBXSession
{
    <#
    .SYNOPSIS

    Removes a Zabbix session.

    .DESCRIPTION

    Removes a Zabbix session.
    If the session is saved, it will be removed from the saved sessions as well.

    .PARAMETER Id

    Session id.

    .PARAMETER Path

    The path where module data will be stored, defaults to $Script:ZabbixModuleDataPath.

    .INPUTS

    PSObject. Get-ZBXSession

    .OUTPUTS

    None. Does not supply output.

    .EXAMPLE

    Deletes a Zabbix session with the id of '2'.

    Remove-ZBXSession -Id 2

    .EXAMPLE

    Deletes all AP sessions in memory and stored on disk.

    Remove-ZBXSession

    .LINK

    Zabbix documentation:
    https://www.zabbix.com/documentation/4.2/manual/api

    New-ZBXSession
    Get-ZBXSession
    Save-ZBXSession
    Initialize-ZBXSession
    #>
    [CmdletBinding()]
    [Alias("rzsess","dzsess")]
    param
    (
        [Parameter(Mandatory,
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
        $sessions = Get-ZBXSession -Id $Id
        foreach ($session in $sessions)
        {
            if ($session.Saved -eq $true)
            {
                $newData = @{SessionData = @() }
                $data = Get-Content -Path $Path -Raw | ConvertFrom-Json
                foreach ($_data in $data.SessionData)
                {
                    if ($_data.Id -eq $session.Id)
                    {
                        Continue
                    }
                    else
                    {
                        $newData.SessionData += $_data
                    }
                }
                $newData | ConvertTo-Json -Depth 5 | Out-File -FilePath $Path
            }
            $Global:_ZabbixSessions = $Global:_ZabbixSessions | Where-Object { $PSItem.Id -ne $session.Id }
        }
    }
    end
    {

    }
}
