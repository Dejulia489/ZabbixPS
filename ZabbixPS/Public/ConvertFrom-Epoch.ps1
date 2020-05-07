Function ConvertFrom-Epoch
{
    <#
	.SYNOPSIS

	Convert from epoch time to human

	.DESCRIPTION

	Convert from epoch time to human

	.PARAMETER EpochDate

	The epoch date to convert.

	.EXAMPLE

	convertFrom-epoch 1295113860

	.EXAMPLE

	convertFrom-epoch 1295113860 | convertTo-epoch
	#>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        $EpochDate
    )
    begin
    {

    }
    process
    {
        if (!$psboundparameters.count) { gh -ex $PSCmdlet.MyInvocation.MyCommand.Name | out-string | remove-emptylines; return }
        #[timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($EpochDate))
        if (("$EpochDate").length -gt 10 )
        {
            # (Get-Date -Date "01/01/1970").AddMilliseconds($EpochDate)
            if (("$EpochDate").Contains('.'))
            {
                $seconds = ("$EpochDate").Split('.')[0]
                $millis = ("$EpochDate").Split('.')[1]
                $EpochDate = $seconds + ($millis[0..2] -join "")
                (Get-Date -Date "01/01/1970").AddMilliseconds($EpochDate)
            }
            else { (Get-Date -Date "01/01/1970").AddMilliseconds($EpochDate) }
        }
        else { (Get-Date -Date "01/01/1970").AddSeconds($EpochDate) }
    }
    end
    {

    }
}