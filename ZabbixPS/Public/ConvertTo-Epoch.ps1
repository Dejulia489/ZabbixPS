Function ConvertTo-Epoch
{
    <#
	.Synopsis
		Convert time to epoch
	.Description
		Convert time to epoch
	.Example
		convertTo-epoch (get-date -date "05/24/2015 17:05")
    .Example
        convertTo-epoch (get-date -date "05/24/2015 17:05") | convertFrom-epoch
    .Example
        (get-date -date "05/24/2015 17:05") | convertTo-epoch
    .Example 
        get-date | convertTo-epoch
    .Example
        convertTo-epoch (get-date).ToUniversalTime()
    .Example
        convertTo-epoch (get-date).ToUniversalTime() | convertFrom-epoch
    .Example
        convertTo-epoch ((get-date).AddHours(2)    
	#>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]$date
    )
	
    if (!$psboundparameters.count) { help -ex convertTo-epoch | Out-String | Remove-EmptyLines; return }
	
    $date = $date -f "mm/dd/yyyy hh:mm"
    (New-TimeSpan -Start (Get-Date -Date "01/01/1970") -End $date).TotalSeconds
}