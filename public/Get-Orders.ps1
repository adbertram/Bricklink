<#
.SYNOPSIS
Retrieves orders from BrickLink based on specified criteria.

.DESCRIPTION
The Get-Orders function retrieves orders from BrickLink's API based on specified criteria, such as direction (incoming or outgoing) and status. It sends a request to the BrickLink API to fetch orders according to the provided parameters.

.PARAMETER Direction
Specifies the direction of the orders to retrieve. Possible values are 'in' for incoming orders and 'out' for outgoing orders. The default value is 'in'.

.PARAMETER Status
Specifies the status of the orders to retrieve. Possible values are 'pending', 'completed', 'ready', 'paid', 'shipped', and 'received'. The default value is 'paid', which corresponds to open orders yet to be shipped.

.PARAMETER ValidateSet
Validates that the provided values for Direction and Status parameters are within the specified set of values.

.PARAMETER ValidateNotNullOrEmpty
Specifies that the Direction and Status parameters cannot be null or empty.

.EXAMPLE
Get-Orders -Direction 'in' -Status 'paid'
Retrieves incoming orders with a status of 'paid'.

.EXAMPLE
Get-Orders -Direction 'out' -Status 'shipped'
Retrieves outgoing orders with a status of 'shipped'.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Object
The function returns an object representing the orders fetched from BrickLink based on the specified criteria.

.NOTES
The function relies on the InvokeBricklinkApiCall function to make the HTTP request to the BrickLink API.
#>

function Get-Orders {
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('in', 'out')]
        [string]$Direction = 'in',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('pending', 'completed', 'ready', 'paid', 'shipped', 'received')]
        [string]$Status = 'paid' ## defaults to open orders yet to be shipped
    )

    $ErrorActionPreference = 'Stop'

    $apiParameters = @{
        direction = $Direction
        status    = $Status
    }

    InvokeBricklinkApiCall -Uri 'orders' -ApiParameter $apiParameters
}