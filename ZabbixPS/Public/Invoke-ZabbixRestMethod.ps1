function Invoke-ZabbixRestMethod
{
    <#
    .SYNOPSIS

    Invokes a Zabbix rest method.

    .DESCRIPTION

    Invokes Zabbix rest method.

    .PARAMETER Body

    Specifies the body of the request. The body is the content of the request that follows the headers.

    .PARAMETER Uri

    Specifies the Uniform Resource Identifier (URI) of the Internet resource to which the web request is sent. This parameter supports HTTP, HTTPS, FTP, and FILE values.

    .PARAMETER Credential

    Specifies a user account that has permission to send the request. The default is the Personal Access Token if it is defined, otherwise it is the current user.

    .PARAMETER Proxy

    Use a proxy server for the request, rather than connecting directly to the Internet resource. Enter the URI of a network proxy server.

    .PARAMETER ProxyCredential

    Specifie a user account that has permission to use the proxy server that is specified by the -Proxy parameter. The default is the current user.

    .PARAMETER Path

    The directory to output files to.

    .OUTPUTS

    System.Int64, System.String, System.Xml.XmlDocument, The output of the cmdlet depends upon the format of the content that is retrieved.

    .OUTPUTS

    PSObject, If the request returns JSON strings, Invoke-RestMethod returns a PSObject that represents the strings.

    .EXAMPLE

    .LINK

    Zabbix documentation:
    https://www.zabbix.com/documentation/4.2/manual/api
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter()]
        [psobject]
        $Body,

        [Parameter(Mandatory)]
        [uri]
        $Uri,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter()]
        [string]
        $Proxy,

        [Parameter()]
        [pscredential]
        $ProxyCredential,

        [Parameter()]
        [string]
        $Path
    )

    begin
    {
    }

    process
    {
        $invokeRestMethodSplat = @{
            ContentType     = 'application/json'
            Method          = 'POST'
            UseBasicParsing = $true
            Uri             = $Uri.AbsoluteUri
        }
        if ($Body)
        {
            $invokeRestMethodSplat.Body = $Body | ConvertTo-Json -Depth 20
        }
        if ($Proxy)
        {
            $invokeRestMethodSplat.Proxy = $Proxy
            if ($ProxyCredential)
            {
                $invokeRestMethodSplat.ProxyCredential = $ProxyCredential
            }
            else
            {
                $invokeRestMethodSplat.ProxyUseDefaultCredentials = $true
            }
        }
        if ($Path)
        {
            $invokeRestMethodSplat.OutFile = $Path
        }
        Write-Verbose "[$($MyInvocation.MyCommand.Name)]: Invoking Zabbix rest method: [$Uri]"
        $results = Invoke-RestMethod @invokeRestMethodSplat
        return $results
    }

    end
    {
    }
}
