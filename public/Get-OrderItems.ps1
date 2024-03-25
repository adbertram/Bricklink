<#
.SYNOPSIS
Retrieves the items associated with a specific order from BrickLink.

.DESCRIPTION
The Get-OrderItems function retrieves the items associated with a specific order from BrickLink's API. It sends a request to the BrickLink API to fetch the items included in the order identified by the specified order ID.

.PARAMETER OrderId
Specifies the ID of the order for which items need to be retrieved.

.PARAMETER Mandatory
Indicates that the OrderId parameter is mandatory. You must provide a value for this parameter when invoking the function.

.PARAMETER ValidateNotNullOrEmpty
Specifies that the OrderId parameter cannot be null or empty.

.EXAMPLE
Get-OrderItems -OrderId "123456"
Retrieves the items associated with the order with the ID "123456".

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Object
The function returns an object representing the items associated with the specified order fetched from BrickLink.

.NOTES
The function relies on the InvokeBricklinkApiCall function to make the HTTP request to the BrickLink API.
#>

function Get-OrderItems {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$OrderId
    )

    $ErrorActionPreference = 'Stop'

    InvokeBricklinkApiCall -Uri "orders/$OrderId/items"
}