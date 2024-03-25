<#
.SYNOPSIS
Retrieves the unique identifier (ID) of an item from BrickLink using its item number.

.DESCRIPTION
The Get-ItemId function retrieves the unique identifier (ID) of an item from the BrickLink catalog by providing its item number. It sends a request to the BrickLink API to fetch the item details and then extracts the ID from the response.

.PARAMETER ItemNumber
Specifies the item number of the item whose ID needs to be retrieved.

.PARAMETER Mandatory
Indicates that the ItemNumber parameter is mandatory. You must provide a value for this parameter when invoking the function.

.EXAMPLE
Get-ItemId -ItemNumber "3001"
Retrieves the ID of the item with the item number "3001".

.EXAMPLE
Get-ItemId -ItemNumber "10214-1"
Retrieves the ID of the item with the item number "10214-1".

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.String
The function returns a string representing the unique identifier (ID) of the item fetched from BrickLink.

.NOTES
The function relies on the InvokeBricklinkWebCall function to make the HTTP request to the BrickLink API.
#>

function Get-ItemId {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ItemNumber
    )

    $ErrorActionPreference = 'Stop'

    $invCallParams = @{
        Uri    = 'https://www.bricklink.com/v2/catalog/catalogitem.page'
        Body   = @{
            'P'       = $ItemNumber
            'idColor' = 0
        }
        Method = 'GET'
    }

    $response = InvokeBricklinkWebCall @invCallParams
    $response | Select-String -Pattern 'idItem:\s+(\d+)' | ForEach-Object { $_.matches[0].groups[1].value }
}