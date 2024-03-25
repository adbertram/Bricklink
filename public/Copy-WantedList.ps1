<#
.SYNOPSIS
Copies items from one wanted list to a new wanted list on BrickLink.

.DESCRIPTION
The Copy-WantedList function creates a new wanted list on BrickLink and copies all the items from an existing wanted list to the new one. It requires the ID of the source wanted list and the name for the new wanted list.

.PARAMETER FromId
The ID of the wanted list from which the items should be copied. This parameter is mandatory.

.PARAMETER ToName
The name of the new wanted list to be created. This parameter is mandatory.

.EXAMPLE
Copy-WantedList -FromId 123456 -ToName "New Wanted List"

This example copies all the items from the wanted list with ID 123456 to a new wanted list named "New Wanted List".

.NOTES
- The function uses the Get-WantedListItem function to retrieve the items from the source wanted list.
- The function modifies the retrieved items to remove any specific wanted list IDs and prepares them for adding to the new wanted list.
- The function uses the BrickLink API to create the new wanted list and add the copied items to it.
- Error handling is implemented using the $ErrorActionPreference variable set to 'Stop'.

.LINK
Get-WantedListItem

#>
function Copy-WantedList {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [int]$FromId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ToName
    )

    $ErrorActionPreference = 'Stop'

    $wlItems = Get-WantedListItem -WantedListId $FromId

    ## Genericize the wanted lists to not attach to a specific wanted list ID
    $wlItems = foreach ($i in $wlItems) {
        [pscustomobject]@{
            "wantedID"        = 0
            "wantedMoreID"    = -1
            "itemID"          = $i.itemID
            "colorID"         = $i.colorID
            "wantedNew"       = $i.wantedNew
            "wantedNotify"    = $i.wantedNotify
            "wantedQtyFilled" = $i.wantedQtyFilled
            "wantedQty"       = $i.wantedQty
            "wantedRemarks"   = $i.wantedRemark
            "wantedPrice"     = $i.wantedPrice
        }
    }
    $wlItems = $wlItems | ConvertTo-Json

    ## Create the wanted list and add the items
    $invCallParams = @{
        Uri    = 'https://www.bricklink.com/ajax/clone/wanted/upload.ajax'
        Body   = @{
            wantedMoreName = $ToName
            wantedItemStr  = $wlItems
        }
        Method = 'POST'
    }

    InvokeBricklinkWebCall @invCallParams
}