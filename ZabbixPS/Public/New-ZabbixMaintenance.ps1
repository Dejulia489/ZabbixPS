function New-ZabbixMaintenance
{
    <#
    .SYNOPSIS

    Creates a new Zabbix maintenance period.

    .DESCRIPTION

    Creates a new Zabbix maintenance period.

    .PARAMETER Uri

    The Zabbix instance uri.

    .PARAMETER Credential

    Specifies a user account that has permission to the project.

    .PARAMETER Proxy

    Use a proxy server for the request, rather than connecting directly to the Internet resource. Enter the URI of a network proxy server.

    .PARAMETER ProxyCredential

    Specifie a user account that has permission to use the proxy server that is specified by the -Proxy parameter. The default is the current user.

    .PARAMETER Session

    ZabbixPS session, created by New-ZabbixSession.

	.PARAMETER Name

	The case sensitive maintenance name.

	.PARAMETER Description

	The maintenance description.

    .PARAMETER GroupId

    The id of the group.
    Can be retrieved with Get-ZabbixGroup.

    .PARAMETER HostId

    The id of the host.
    Can be retrieved with Get-ZabbixHost.

    .PARAMETER Type

    The maintenance type, defaults to 0.
    0 - data collection
    1 - without data collection

    .PARAMETER ActiveSince

	The maintenance start time.

	.PARAMETER ActiveTill

	The maintenance end time.

    .PARAMETER Tags

    A comma sperated list of tags.
    'Key1:Value1', 'Key2:Value2'

	.PARAMETER TpType

    The maintenance time period's type, defaults to 0.
    0 - one time only
    2 - daily
    3 - weekly
    4 - monthly

    .PARAMETER TpStartTime

    The maintenance time period's start time in seconds. Required for daily, weekly and monthly periods.

	.PARAMETER TpStartDate

	The maintenance time period's start date. Required only for one time period, defaults to current date.

    .PARAMETER TpDay

    Day of the month when the maintenance must come into effect
	Required only for monthly time periods

    .PARAMETER TpDayOfWeek

    Days of the week when the maintenance must come into effect.
    Used for weekly and monthly time periods. Required only for weekly time periods
    Days are stored in binary form with each bit representing the corresponding day.
    4 - equals 100 in binary and means, that maintenance will be enabled on Wednesday

    .PARAMETER TpMonth

    Months when the maintenance must come into effect.
    Required only for monthly time periods.
    Months are stored in binary form with each bit representing the corresponding month.
    5 - equals 101 in binary and means, that maintenance will be enabled in January and March

	.PARAMETER TpPeriod

	The maintenance time period's period/duration in seconds.

    .INPUTS

    None, does not support pipeline.

    .OUTPUTS

    PSObject, Zabbix maintenance period.

    .EXAMPLE

    .LINK

    https://www.zabbix.com/documentation/4.2/manual/api/reference/maintenance/create
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
        [string]
        $Name,

        [Parameter()]
        [string]
        $Description,

        [Parameter()]
        [string[]]
        $GroupId,

        [Parameter()]
        [string[]]
        $HostId,

        [Parameter()]
        [int]
        $Type = 0,

        [Parameter()]
        [datetime]
        $ActiveSince,

        [Parameter()]
        [datetime]
        $ActiveTill,

        [Parameter()]
        [string[]]
        $Tags,

        [Parameter()]
        [int]
        $TpType = 0,

        [Parameter()]
        [int]
        $TpStartTime,

        [Parameter()]
        [datetime]
        $TpStartDate,

        [Parameter()]
        [int]
        $TpDay,

        [Parameter()]
        [int]
        $TpDayOfWeek,

        [Parameter()]
        [int]
        $TpMonth,

        [Parameter()]
        [int]
        $TpPeriod
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
        $body = @{
            method  = 'maintenance.create'
            jsonrpc = $ApiVersion
            id      = 1

            params  = @{
                name             = $Name
                description      = $Description
                active_since     = [Math]::Floor([decimal](Get-Date($ActiveSince).ToUniversalTime()-uformat "%s"))
                active_till      = [Math]::Floor([decimal](Get-Date($ActiveTill).ToUniversalTime()-uformat "%s"))
                maintenance_type = $Type
                timeperiods      = @(
                    @{
                        timeperiod_type = $TpType
                        start_date      = [Math]::Floor([decimal](Get-Date($TpStartDate).ToUniversalTime()-uformat "%s"))
                        period          = $TpPeriod

                        every           = $TpEvery
                        start_time      = $TpStartTime
                        month           = $TpMonth
                        dayofweek       = $TpDayOfWeek
                        day             = $TpDay
                    }
                )
            }
        }
        if ($GroupId)
        {
            $body.params.GroupIds = $GroupId
        }
        if ($HostId)
        {
            $body.params.HostIds = $HostId
        }
        if ($Tags)
        {
            $body.params.tags = (Format-ZabbixTags -Tags $Tags)
        }
        $invokeZabbixRestMethodSplat = @{
            Body        = $body
            Uri         = $Uri
            Credential  = $Credential
            ApiVersion  = $ApiVersion
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
        if ($results)
        {
            $results
        }
    }

    end
    {
    }
}