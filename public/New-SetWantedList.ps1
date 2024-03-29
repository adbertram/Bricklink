<#
.SYNOPSIS
Creates a new wanted list on BrickLink for a given set number.

.DESCRIPTION
The New-SetWantedList function creates a new wanted list on BrickLink for a given set number. It retrieves the set's information, including its items, from BrickLink's API and creates a new wanted list with the set's items. The function handles duplicate items by keeping the one with the highest quantity.

.PARAMETER SetNumber
The set number for which to create the wanted list. This parameter is mandatory.

.PARAMETER WantedListName
The name of the wanted list to create. If not provided, the set number will be used as the name.

.EXAMPLE
New-SetWantedList -SetNumber '10255-1'

This example creates a new wanted list on BrickLink for the set with the number '10255-1'. The wanted list will be named '10255-1'.

.EXAMPLE
New-SetWantedList -SetNumber '10255-1' -WantedListName 'Assembly Square'

This example creates a new wanted list on BrickLink for the set with the number '10255-1', and the wanted list will be named 'Assembly Square'.

.NOTES
This function requires the InvokeBricklinkWebCall function to make API calls to BrickLink.
#>
function New-SetWantedList {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$SetNumber,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$WantedListName = $SetNumber
    )

    $ErrorActionPreference = 'Stop'

    $itemNumber = $SetNumber -replace '-\d+$', ''

    ## Get the set's ID
    $invCallParams = @{
        Uri    = 'https://www.bricklink.com/ajax/clone/wanted/partoutinfo.ajax'
        Body   = @{
            itemNo   = $itemNumber
            itemSeq  = [regex]::matches($SetNumber, '-(\d+)$').Groups[1].Value
            summary  = 1
            colorID  = 0
            itemType = 'S'
        }
        Method = 'GET'
    }

    $response = InvokeBricklinkWebCall @invCallParams

    $setItemId = $response.itemID

    ## Find the set items
    ## We're only using this way instead of Get-SubSets becasue this returns the itemID which is required
    ## This method does not find the counterparts

    $invCallParams = @{
        Uri    = 'https://www.bricklink.com/ajax/clone/wanted/partoutinfo.ajax'
        Body   = @{
            itemID        = $setItemId
            itemNo        = $itemNumber
            itemSeq       = [regex]::matches($SetNumber, '-(\d+)$').Groups[1].Value
            summary       = 0
            colorID       = 0
            itemType      = 'S'
            wantedMoreID  = '-1'
            breakMinifigs = 0
            breakSets     = 1
            incInstr      = 0
            incBox        = 0
            incExtraParts = 0
            excludeTypes  = $null
            newWlStr      = $WantedListName
        }
        Method = 'GET'
    }

    $response = InvokeBricklinkWebCall @invCallParams

    ## Modify the items to match required fields
    ## Assigning a temp unique ID to each item for removing dups later
    $counter = 0
    $setItems = foreach ($i in $response.items) {
        [pscustomobject]@{
            "wantedID"        = 0
            "wantedMoreID"    = -1
            "itemID"          = $i.itemID ## This is only found via the partoutinfo.ajax call above.
            "colorID"         = $i.colorID
            "wantedNew"       = "X"
            "wantedNotify"    = "N"
            "wantedQtyFilled" = 0
            "wantedQty"       = $i.itemQty
            "wantedRemarks"   = $null
            "wantedPrice"     = -1
            'tempId'          = $counter
        }
        $counter++
    }

    ## If there are any dup items, pick out the one with the highest wanted qty and remove the other(s)
    $setItemIdsToRemove = @()
    if ($dupItems = $setitems | Group-Object -Property itemID, colorID | Where-Object { $_.count -gt 1 }) {
        $setItemIdsToRemove += $dupItems | ForEach-Object { $_.Group | Sort-Object -Property 'wantedQty' -Descending | Select-Object -Skip 1 -ExpandProperty tempId }
        $uniqueSetItems = $setItems.where({ $_.tempID -notin $setItemIdsToRemove })
    } else {
        $uniqueSetItems = $setItems
    }

    $setItems = $uniqueSetItems | Select-Object -ExcludeProperty 'tempId' | ConvertTo-Json

    ## Create the wanted list and add the set items
    $invCallParams = @{
        Uri    = 'https://www.bricklink.com/ajax/clone/wanted/upload.ajax'
        Body   = @{
            wantedMoreName = $WantedListName
            wantedItemStr  = $setItems
        }
        Method = 'POST'
    }

    InvokeBricklinkWebCall @invCallParams

    request-CacheUpdate -Cache WantedList

}