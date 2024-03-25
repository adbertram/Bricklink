<#
.SYNOPSIS
Retrieves the known colors for a specified item from BrickLink.

.DESCRIPTION
The Get-KnownColors function retrieves the known colors for a specified item from BrickLink's API. It sends a request to the BrickLink API to fetch the known colors for the specified item number and type (default type is 'PART').

.PARAMETER ItemNumber
Specifies the item number of the item for which known colors need to be retrieved.

.PARAMETER Type
Specifies the type of the item. Default value is 'PART'. Possible values are 'PART', 'SET', 'MINIFIG', 'BOOK', 'GEAR', 'CATALOG', and 'INSTRUCTION'.

.PARAMETER Mandatory
Indicates that the ItemNumber parameter is mandatory. You must provide a value for this parameter when invoking the function.

.PARAMETER ValidateNotNullOrEmpty
Specifies that the ItemNumber parameter cannot be null or empty.

.EXAMPLE
Get-KnownColors -ItemNumber "3001"
Retrieves the known colors for the item with the item number "3001" of type 'PART'.

.EXAMPLE
Get-KnownColors -ItemNumber "10214-1" -Type "SET"
Retrieves the known colors for the set with the item number "10214-1".

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Object
The function returns an object representing the known colors for the specified item fetched from BrickLink.

.NOTES
The function relies on the InvokeBricklinkApiCall function to make the HTTP request to the BrickLink API.
#>

function Get-KnownColors {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ItemNumber,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ItemType]$Type = 'PART'
    )

    $ErrorActionPreference = 'Stop'

    InvokeBricklinkApiCall -Uri "items/$Type/$ItemNumber/colors"
}