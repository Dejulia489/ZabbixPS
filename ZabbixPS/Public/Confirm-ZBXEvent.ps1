function Confirm-ZBXEvent
{
    <#
    .SYNOPSIS

    Changes the status of an Event

    .DESCRIPTION

    Changes the acknowledgement of an Event

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

    .PARAMETER EventId

    IDs of the events to acknowledge.

    .PARAMETER Action

    Event update action(s). This is bitmask field (under the hood), any combination of text values is acceptable.

    Possible values:
    1 - close problem;
    2 - acknowledge event;
    4 - add message;
    8 - change severity.

    .PARAMETER Message

    Text of the message.
    Required, if action contains 'add message' flag.

    .PARAMETER Severity

    New severity for events.
    Required, if action contains 'change severity' flag.

    Possible values:
    0 - notclassified;
    1 - information;
    2 - warning;
    3 - average;
    4 - high;
    5 - disaster.

    .INPUTS

    None, does not support pipeline.

    .OUTPUTS

    PSObject.


    .EXAMPLE

    Acknowledges a event.

    Confirm-ZBXEvent TBD

    .LINK

    https://www.zabbix.com/documentation/4.2/manual/api/reference/event/get
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
        [Alias('eventids')]
        [string[]]
        $EventId,

        [Parameter(Mandatory)]
        [Alias('action')]
        [ValidateSet('CloseProblem','Acknowledge','AddMessage','ChangeSeverity')]
        [string[]]
        $AcknowledgeAction,

        [Parameter()]
        [Alias('message')]
        [string]
        $AcknowledgeMessage,

        [Parameter()]
        [Alias('severity')]
        [ValidateSet('NotClassified','Information','Warning','Average','High','Disaster')]
        [string]
        $NewSeverity
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
        $ActionValues = @{
            'CloseProblem'   = 1
            'Acknowledge'    = 2
            'AddMessage'     = 4
            'ChangeSeverity' = 8
        }
        $SeverityValues = @{
            'NotClassified' = 0
            'Information'   = 1
            'Warning'       = 2
            'Average'       = 3
            'High'          = 4
            'Disaster'      = 5
        }
        $SessionParameters = @('Uri','Credential','Proxy','ProxyCredential','Session')
        $CommonParameters = $(([System.Management.Automation.PSCmdlet]::CommonParameters,[System.Management.Automation.PSCmdlet]::OptionalCommonParameters) | ForEach-Object {$PSItem})
    }

    process
    {

        $params  = @{}

        #Dynamically adds any bound parameters that are used for the conditions
        foreach ($Parameter in $PSBoundParameters.GetEnumerator()) {
            if ($Parameter.key -notin $SessionParameters -and $Parameter.key -notin $CommonParameters) {
                #uses the hardcoded Alias of the parameter as the API friendly param
                $apiParam = $MyInvocation.MyCommand.Parameters[$Parameter.key].Aliases[0]
                switch ($apiParam) {
                    'action'   { [int]$total = 0
                                 foreach ($value in $parameter.Value) {
                                    $total = $total + [int]$ActionValues[$value]
                                 }
                                 $apiValue = $total
                                 break
                               }
                    'severity' { $apiValue = $SeverityValues[$Parameter.Value]; break }
                    default    { $apiValue = $Parameter.Value }
                }

                $params[$apiParam] = $apiValue

            }
        }

        $body = New-ZBXRestBody -Method 'event.acknowledge' -API $ApiVersion -Params $params


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
        }
        Invoke-ZBXRestMethod @invokeZabbixRestMethodSplat
    }

}