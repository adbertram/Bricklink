<#
.SYNOPSIS
Retrieves store inventories from BrickLink based on specified criteria.

.DESCRIPTION
The Get-StoreInventories function retrieves store inventories from BrickLink's API based on specified criteria, such as status, item type, and location. It sends a request to the BrickLink API to fetch store inventories according to the provided parameters.

.PARAMETER Status
Specifies the status of the inventories to retrieve. Possible values are 'Y' (available for sale), 'S' (on hold), 'B' (reserved), 'C' (checked out), 'N' (not for sale), and 'R' (sold). This parameter is optional.

.PARAMETER ItemType
Specifies the type of items in the inventories to retrieve. Possible values are 'part' and 'set'. The default value is 'part'.

.PARAMETER Location
Specifies the location of the inventories to retrieve. This parameter is optional.

.PARAMETER ValidateSet
Validates that the provided values for Status and ItemType parameters are within the specified set of values.

.PARAMETER ValidateNotNullOrEmpty
Specifies that the Status, ItemType, and Location parameters cannot be null or empty.

.EXAMPLE
Get-StoreInventories -Status 'Y' -ItemType 'part' -Location 'USA'
Retrieves store inventories for parts that are available for sale in the USA.

.EXAMPLE
Get-StoreInventories -ItemType 'set'
Retrieves all store inventories for sets.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Object
The function returns an object representing the store inventories fetched from BrickLink based on the specified criteria.

.NOTES
The function relies on the InvokeBricklinkApiCall function to make the HTTP request to the BrickLink API.
#>

function Get-StoreInventories {
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Y', 'S', 'B', 'C', 'N', 'R')]
        [string]$Status,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('part', 'set')]
        [string]$ItemType = 'part',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Location
    )

    $ErrorActionPreference = 'Stop'

    $apiParameters = @{
        item_type = $ItemType
    }

    if ($PSBoundParameters.ContainsKey('Status')) {
        $apiParameters.status = $Status
    }

    $whereFilter = "'*'"
    if ($PSBoundParameters.ContainsKey('Location')) {
        $whereFilter = "`$_.remarks -eq '$Location'"
    }
    $whereFilter = [scriptblock]::Create($whereFilter)

    InvokeBricklinkApiCall -Uri 'inventories' -ApiParameter $apiParameters | Where-Object -FilterScript $whereFilter
}