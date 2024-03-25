<#
.SYNOPSIS
Updates the inventory quantity for a specific item in a BrickLink store.

.DESCRIPTION
The Update-StoreInventory function allows you to update the inventory quantity for a specific item in your BrickLink store. You can either specify a quantity change or move the item to/from a stockroom.

.PARAMETER InventoryId
The ID of the inventory item to update. This parameter is mandatory.

.PARAMETER QuantityChange
The change in quantity for the inventory item. Use a positive value to increase the quantity and a negative value to decrease the quantity. This parameter is part of the 'QuantityChange' parameter set.

.PARAMETER StockroomId
The ID of the stockroom to move the inventory item to or from. Valid values are 'A', 'B', 'C', or 'D'. If not specified, the item will remain in its current location.

.EXAMPLE
Update-StoreInventory -InventoryId '123456' -QuantityChange 10

This example increases the quantity of the inventory item with ID '123456' by 10.

.EXAMPLE
Update-StoreInventory -InventoryId '123456' -QuantityChange -5 -StockroomId 'A'

This example decreases the quantity of the inventory item with ID '123456' by 5 and moves it to stockroom 'A'.

.NOTES
This function requires the InvokeBricklinkApiCall function to make API calls to BrickLink.

If the quantity change would result in a zero quantity outside of a stockroom, the function will automatically move the item to stockroom 'A' and update the quantity accordingly.

.LINK
https://www.bricklink.com/v3/api.page?page=update-inventory
#>
function Update-StoreInventory {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$InventoryId,

        [Parameter(ParameterSetName = 'QuantityChange')]
        [ValidateNotNullOrEmpty()]
        [int]$QuantityChange,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('A', 'B', 'C', 'D')]
        [string]$StockroomId
    )

    $ErrorActionPreference = 'Stop'

    $requestBody = @{}

    if ($PSBoundParameters.ContainsKey('QuantityChange')) {
        if ($QuantityChange -gt 0) {
            $QuantityChange = "+$QuantityChange"
        }
        $requestBody.quantity = $QuantityChange
    }

    if ($PSBoundParameters.ContainsKey('StockroomId')) {
        $requestBody.is_stock_room = 'true'
        $requestBody.stock_room_id = $StockroomId
    }

    try {
        InvokeBricklinkApiCall -Uri "inventories/$InventoryId" -Method 'PUT' -RequestBody $requestBody
    } catch {
        $err = ($_.ErrorDetails.Message | ConvertFrom-Json).meta
        if ($err.message -eq 'RESOURCE_UPDATE_NOT_ALLOWED' -and $err.description -match 'Update would result in 0 quantity in your inventory without being in stockroom') {
            Update-BricklinkStoreInventory -StockroomId 'A' -Quantity $QuantityChange -InventoryId $InventoryId
        } else {
            throw $_
        }
    }
}