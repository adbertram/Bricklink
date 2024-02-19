function Add-WantedListItem {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$WantedListId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ItemNumber,

        [Parameter()]
        [ValidateSet('New', 'Used')]
        [ValidateNotNullOrEmpty()]
        [string]$Condition,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [int]$WantedQuantity = 1,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$ColorId = 0,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [int]$WantedQuantityFilled = 0,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [bool]$Notify,

        [Parameter()]
        [string]$Remarks = $null,

        [Parameter()]
        [decimal]$WantedPrice = $null
    )

    $ErrorActionPreference = 'Stop'

    $itemId = Get-ItemId -ItemNumber $ItemNumber

    $wlItem = @{
        'itemID'          = $itemId
        'colorID'         = $ColorId
        'wantedQty'       = $WantedQuantity
        'wantedQtyFilled' = $WantedQuantityFilled
        'wantedRemarks'   = $Remarks
        'wantedPrice'     = $WantedPrice
    }

    if (!$Condition) {
        $wlItem.wantedNew = 'X'
    } else {
        throw 'Condition-specific items currently not supported.'
    } 
    
    $wlItem.wantedNotify = 'N'
    if ($Notify) {
        $wlItem.wantedNotify = 'Y'
    }

    $wantedItemStr = ,@([pscustomobject]$wlItem) | ConvertTo-Json

    $invCallParams = @{
        Uri    = 'https://www.bricklink.com/ajax/clone/wanted/add.ajax'
        Body   = @{
            'wantedMoreID'  = $WantedListId
            'wantedItemStr' = $wantedItemStr
        }
        Method = 'POST'
    }

    InvokeBricklinkWebCall @invCallParams
}