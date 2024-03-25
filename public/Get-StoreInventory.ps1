<#
.SYNOPSIS
Retrieves a specific store inventory from BrickLink.

.DESCRIPTION
The Get-StoreInventory function retrieves a specific store inventory from BrickLink's API based on the provided inventory ID. It sends a request to the BrickLink API to fetch details of the inventory identified by the specified inventory ID.

.PARAMETER InventoryId
Specifies the ID of the store inventory to retrieve.

.PARAMETER Mandatory
Indicates that the InventoryId parameter is mandatory. You must provide a value for this parameter when invoking the function.

.PARAMETER ValidateNotNullOrEmpty
Specifies that the InventoryId parameter cannot be null or empty.

.EXAMPLE
Get-StoreInventory -InventoryId "123456"
Retrieves the details of the store inventory identified by the inventory ID "123456".

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Object
The function returns an object representing the store inventory fetched from BrickLink based on the specified inventory ID.

.NOTES
The function relies on the InvokeBricklinkApiCall function to make the HTTP request to the BrickLink API.
#>

function Get-StoreInventory {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$InventoryId
    )

    $ErrorActionPreference = 'Stop'

    InvokeBricklinkApiCall -Uri "inventories/$InventoryId"
}