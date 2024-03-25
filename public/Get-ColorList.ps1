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
        'color_id'   = '0'
        'color_name' = 'NotApplicable'
        'color_code' = 'XXXXXX'
        'color_type' = 'N/A'
    }

    ## Must ensure color_id is a string due to some problems with the SelectColor function if it's 0
    $response | Select-Object -Property *,@{n='color_id';e={[string]$_.color_id}} -ExcludeProperty 'color_id'
}
