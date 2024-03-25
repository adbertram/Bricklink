<#
.SYNOPSIS
Retrieves information about a specific BrickLink item.

.DESCRIPTION
The Get-Item function retrieves information about a specific BrickLink item using the BrickLink API. It requires the item type and item number as parameters.

.PARAMETER Type
The type of the item. This parameter is mandatory and must be a valid ItemType value.

.PARAMETER ItemNumber
The item number of the item. This parameter is mandatory and must be a non-empty string.

.EXAMPLE
$item = Get-Item -Type 'PART' -ItemNumber '3001'

This example retrieves information about the item with type 'PART' and item number '3001' and stores the result in the $item variable.

#>
function Get-Item {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ItemType]$Type,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ItemNumber
    )

    $ErrorActionPreference = 'Stop'

    $invApiParams = @{
        Uri = "items/$Type/$ItemNumber"
    }

    InvokeBricklinkApiCall @invApiParams
}