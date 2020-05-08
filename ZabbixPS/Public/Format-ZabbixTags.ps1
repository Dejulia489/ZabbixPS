function Format-ZabbixTags
{
    <#
    .SYNOPSIS

    Formats an array of tags.

    .DESCRIPTION

    Formats an array of tags.

    .PARAMETER Tags

    A comma sperated list of tags.
    'Key1:Value1', 'Key2:Value2'

    .INPUTS

    None, does not support pipeline.

    .OUTPUTS

    PSObject, formatted Zabbix tags.

    .EXAMPLE

    .LINK

    https://www.zabbix.com/documentation/4.2/manual/api
    #>
    [CmdletBinding(DefaultParameterSetName = 'ByCredential')]
    Param
    (
        [Parameter(Mandatory)]
        [string[]]
        $Tags
    )

    begin
    {

    }

    process
    {
        $formattedTags = Foreach ($tag in $Tags)
        {
            $split = $tag.split(':')
            @{
                tag      = $split[0]
                operator = 0
                value    = $split[-1]
            }
        }
        return $formattedTags
    }

    end
    {
    }
}