<#
.SYNOPSIS
Calculates the part-out value for a LEGO set on BrickLink.

.DESCRIPTION
The Get-SetPartOutValue function calculates the part-out value for a LEGO set on BrickLink. It sends a request to the BrickLink API to determine the average sales and current inventory prices of the set's parts, based on specified conditions such as set number and item condition.

.PARAMETER SetNumber
Specifies the number of the LEGO set for which the part-out value needs to be calculated.

.PARAMETER BreakMinifigs
Indicates whether to include minifigures in the part-out calculation. If this switch is provided, minifigures will be broken down into parts. By default, minifigures are not broken down.

.PARAMETER Condition
Specifies the condition of the parts to consider in the calculation. Possible values are 'N' (new) and 'U' (used). The default value is 'U'.

.PARAMETER Mandatory
Indicates that the SetNumber parameter is mandatory. You must provide a value for this parameter when invoking the function.

.PARAMETER ValidateNotNullOrEmpty
Specifies that the SetNumber parameter cannot be null or empty.

.EXAMPLE
Get-SetPartOutValue -SetNumber "10214-1" -BreakMinifigs -Condition 'N'
Calculates the part-out value for LEGO set "10214-1" by breaking down minifigures and considering only new parts.

.EXAMPLE
Get-SetPartOutValue -SetNumber "3001-1"
Calculates the part-out value for LEGO set "3001-1" without breaking down minifigures and considering used parts by default.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Object
The function returns an object representing the calculated part-out value for the specified LEGO set, including the average sales price over the last six months and the current inventory average price.

.NOTES
The function relies on the InvokeBricklinkWebCall function to make the HTTP request to the BrickLink API.
#>

function Get-SetPartOutValue {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$SetNumber,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [switch]$BreakMinifigs,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('N', 'U')]
        [string]$Condition = 'U'
    )

    $ErrorActionPreference = 'Stop'

    $body = @{
        'itemType'      = 'S'
        'itemNo'        = ($SetNumber -replace '-\d+$', '')
        'itemSeq'       = ($SetNumber -replace '^\d+-', '')
        'itemQty'       = 1
        'itemCondition' = $Condition
    }
    if ($BreakMinifigs.IsPresent) {
        $body.'breakType' = 'P'
    } else {
        $body.'breakType' = 'M'
    }

    $invCallParams = @{
        Uri              = 'https://www.bricklink.com/catalogPOV.asp'
        Body             = $body
        Method           = 'GET'
        NoAuthentication = $true
    }

    $response = InvokeBricklinkWebCall @invCallParams

    $lastSixMonths = [regex]::Matches($response, 'Average of last 6 months Sales:.*?US \$(\d+\.\d{2})').Groups[1].Value
    $curInventory = [regex]::Matches($response, 'Current Items For Sale Average:.*?US \$(\d+\.\d{2})').Groups[1].Value

    [pscustomobject]@{
        SetNumber       = $SetNumber
        LastSixMonthAvg = $lastSixMonths
        CurrentItemsAvg = $curInventory
    }
}