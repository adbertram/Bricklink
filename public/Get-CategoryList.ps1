<#
.SYNOPSIS
Retrieves the list of BrickLink categories.

.DESCRIPTION
The Get-CategoryList function retrieves the list of BrickLink categories using the BrickLink API. It returns the category information in the response from the API.

.PARAMETER None
This function does not accept any parameters.

.EXAMPLE
$categories = Get-CategoryList

This example calls the Get-CategoryList function to retrieve the list of BrickLink categories and stores the result in the $categories variable.

#>
function Get-CategoryList {
    [CmdletBinding()]
    param
    ()

    $ErrorActionPreference = 'Stop'

    InvokeBricklinkApiCall -Uri 'categories'
}