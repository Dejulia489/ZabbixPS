function New-ZBXMaintenance {
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

    ZabbixPS session, created by New-ZBXSession.

	.PARAMETER Name

	The case sensitive maintenance name.

	.PARAMETER Description

	The maintenance description.

    .PARAMETER GroupId

    The id of the group.
    Can be retrieved with Get-ZBXGroup.

    .PARAMETER HostId

    The id of the host.
    Can be retrieved with Get-ZBXHost.

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

    .PARAMETER TpEvery

    For daily and weekly periods every defines day or week intervals at which the maintenance must come into effect.

    For monthly periods every defines the week of the month when the maintenance must come into effect.
    Possible values:
    1 - first week;
    2 - second week;
    3 - third week;
    4 - fourth week;
    5 - last week.
    
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
    [Alias("nzm")]
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
        $TpEvery,

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
    }

    process {
        $body = @{
            method  = 'maintenance.create'
            jsonrpc = $ApiVersion
            id      = 1

            params  = @{
                name             = $Name
                description      = $Description
                active_since     = (Get-Date($ActiveSince).ToUniversalTime()-UFormat "%s")
                active_till      = (Get-Date($ActiveTill).ToUniversalTime()-UFormat "%s")
                maintenance_type = $Type
                timeperiods      = @(
                    @{
                        timeperiod_type = $TpType
                        #start_date      = (Get-Date($TpStartDate).ToUniversalTime()-UFormat "%s")
                        period          = $TpPeriod
                    }
                )
            }
        }
        if ($PSBoundParameters.ContainsKey('TpEvery')) {
            $body.params.timeperiods.every = $TpEvery
        }
        if ($PSBoundParameters.ContainsKey('TpStartTime')) {
            $body.params.timeperiods.start_time = $TpStartTime
        }
        if ($PSBoundParameters.ContainsKey('TpMonth')) {
            $body.params.timeperiods.month = $TpMonth
        }
        if ($PSBoundParameters.ContainsKey('TpDayOfWeek')) {
            $body.params.timeperiods.dayofweek = $TpDayOfWeek
        }
        if ($PSBoundParameters.ContainsKey('TpDay')) {
            $body.params.timeperiods.day = $TpDay
        }
        if ($GroupId) {
            $body.params.groupids = $GroupId
        }
        if ($HostId) {
            $body.params.hostids = $HostId
        }
        if ($Tags) {
            $body.params.tags = (Format-ZBXTags -Tags $Tags)
        }
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
        return Invoke-ZBXRestMethod @invokeZabbixRestMethodSplat
    }

    end {
    }
}