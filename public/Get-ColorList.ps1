<#
.SYNOPSIS
Retrieves the list of BrickLink colors.

.DESCRIPTION
The Get-ColorList function retrieves the list of BrickLink colors using the BrickLink API. It returns the color information in the response from the API, along with an additional "Not Applicable" color entry.

.PARAMETER None
This function does not accept any parameters.

.EXAMPLE
$colors = Get-ColorList

This example calls the Get-ColorList function to retrieve the list of BrickLink colors and stores the result in the $colors variable.

#>
function Get-ColorList {
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
