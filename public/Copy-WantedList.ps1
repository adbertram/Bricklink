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