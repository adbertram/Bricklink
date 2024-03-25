
<#
.SYNOPSIS
Adds an item to a wanted list on BrickLink.

.DESCRIPTION
The Add-WantedListItem function adds an item to a specified wanted list on BrickLink. It requires the wanted list ID, item number, and various optional parameters to specify the item details.

.PARAMETER WantedListId
The ID of the wanted list to which the item should be added. This parameter is mandatory.

.PARAMETER ItemNumber
The item number of the LEGO piece to be added to the wanted list. This parameter is mandatory.

.PARAMETER Condition
The condition of the item, either "New" or "Used". If not specified, the item is assumed to be new.

.PARAMETER WantedQuantity
The desired quantity of the item. The default value is 1.

.PARAMETER ColorId
The color ID of the item. The default value is 0.

.PARAMETER WantedQuantityFilled
The quantity of the item already filled. The default value is 0.

.PARAMETER Notify
A boolean value indicating whether to receive notifications for the item. If not specified, notifications are not enabled.

.PARAMETER Remarks
Optional remarks or notes about the wanted item.

.PARAMETER WantedPrice
The desired price for the item. If not specified, no specific price is set.

.EXAMPLE
Add-WantedListItem -WantedListId "123456" -ItemNumber "4070" -Condition "New" -WantedQuantity 5

This example adds 5 new items with the item number "4070" to the wanted list with ID "123456".

.EXAMPLE
Add-WantedListItem -WantedListId "789012" -ItemNumber "3001" -ColorId 1 -Notify $true -Remarks "Urgent"

This example adds 1 item with the item number "3001" and color ID 1 to the wanted list with ID "789012". Notifications are enabled, and the remark "Urgent" is added.

.NOTES
- The function currently does not support condition-specific items.
- The function uses the BrickLink API to add the item to the wanted list.
- Error handling is implemented using the $ErrorActionPreference variable set to 'Stop'.

#>
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

    $wantedItemStr = , @([pscustomobject]$wlItem) | ConvertTo-Json

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