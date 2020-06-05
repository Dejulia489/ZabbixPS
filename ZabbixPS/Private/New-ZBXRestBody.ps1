function New-ZBXRestBody
{
    <#
    .SYNOPSIS

    Returns the correct API body for a Zabbix API call.

    .DESCRIPTION

    Intended as an internal function for returning the body of an API call where the params may change

    .PARAMETER Method

    The Zabbix API method used in the call

    .PARAMETER ApiVersion

    Specifies the API Version being used

    .PARAMETER Param

    A hashtable of Zabbix specific filters for the specific method

    .INPUTS

    None, does not support pipeline.

    .OUTPUTS

    Hashtable. RestMethod Body.

    .EXAMPLE

    Dynamically generates the body for an API call.

    New-ZBXRestBody -Method 'event.problem' -API $ApiVersion -Params $params

    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [string]
        $Method,

        [Parameter(Mandatory)]
        [string]
        $ApiVersion,

        [Parameter(Mandatory)]
        [hashtable]
        $Params

    )

    process
    {
        #todo create some validation for the params
        #to make sure they match the methods for the Zabbix API
        $body = @{
            method  = $Method
            jsonrpc = $ApiVersion
            id      = 1

            params  = $Params
        }

        $body
    }

}