<#
.SYNOPSIS
Tests for the existence of a BrickLink item by number and type.

.DESCRIPTION
The Test-Item function queries the BrickLink API for an item based on the specified item number and type. 
It returns $true if the item exists or $false if the item is not found (404 Not Found). 
If any other exception occurs, it throws a terminating error.

.PARAMETER ItemNumber
The item number to query. This parameter is mandatory and cannot be null or empty.

.PARAMETER Type
The type of the item to query. The default type is 'PART'. This parameter is optional.

.EXAMPLE
Test-Item -ItemNumber 3001

Tests to see if item number 3001 exists as a 'PART' in the BrickLink catalog.

.EXAMPLE
Test-Item -ItemNumber 3001 -Type 'SET'

Tests to see if item number 3001 exists as a 'SET' in the BrickLink catalog.

.INPUTS
None. You cannot pipe objects to Test-Item.

.OUTPUTS
Boolean. Test-Item outputs $true if the item exists, or $false if the item does not exist.

#>

function Test-Item {
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

    try {
        Get-BLItem -ItemNumber $ItemNumber -Type $Type
        $true
    } catch {
        if ($_.Exception.Message -like '*404 (Not Found)*') {
            $false
        } else {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
}