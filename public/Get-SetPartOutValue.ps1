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