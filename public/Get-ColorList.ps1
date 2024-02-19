function Get-ColorList {
    <#
        .SYNOPSIS
            https://www.bricklink.com/v3/api.page?page=get-color-list
    
        .EXAMPLE
            PS> functionName
    
    #>
    [CmdletBinding()]
    param
    ()

    $ErrorActionPreference = 'Stop'

    $response = InvokeBricklinkApiCall -Uri 'colors'

    ## The API doesn't return the "not applicable" color ID
    $response += [pscustomobject]@{
        'color_id'   = 0
        'color_name' = 'NotApplicable'
        'color_code' = 'XXXXXX'
        'color_type' = 'N/A'
    }
    $response
}