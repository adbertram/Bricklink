<#
.SYNOPSIS
Retrieves wanted list items from BrickLink.

.DESCRIPTION
The Get-WantedListItem function retrieves wanted list items from BrickLink's website. It sends a request to the BrickLink website to fetch the wanted list items based on the specified criteria such as wanted list ID, item number, color, and option to include only missing items. The function can retrieve all wanted list items or a subset based on the provided parameters.

.PARAMETER WantedListId
Specifies the ID of the wanted list from which to retrieve items. This parameter is optional.

.PARAMETER ItemNumber
Specifies the item number of the wanted list item to retrieve. This parameter is optional.

.PARAMETER ColorId
Specifies the color ID of the wanted list item to retrieve. This parameter is optional.

.PARAMETER MissingItemsOnly
Indicates whether to retrieve only the missing items from the wanted list. This switch is optional.

.EXAMPLE
Get-WantedListItem -WantedListId 12345
Retrieves all items from the wanted list with ID "12345".

.EXAMPLE
Get-WantedListItem -ItemNumber "3001" -ColorId 11 -MissingItemsOnly
Retrieves only the missing items with item number "3001" and color ID "11" from all wanted lists.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Object
The function returns an object representing the wanted list items fetched from BrickLink's website.

.NOTES
The function relies on the InvokeBricklinkWebCall and FindWantedListItems functions to make the HTTP request to the BrickLink website and parse the HTML response, respectively.
#>

function Get-WantedListItem {
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [int]$WantedListId,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$ItemNumber,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [int]$ColorId,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [switch]$MissingItemsOnly
    )

    $ErrorActionPreference = 'Stop'

    $body = @{
        'pageSize'     = 100000 # just a big number to ensure we get all of the items on single page
        'type'         = 'A'
        'sa'           = 1
    }
    if ($PSBoundParameters.ContainsKey('WantedListId')) {
        $body.wantedMoreID = $WantedListId
    }
    if ($PSBoundParameters.ContainsKey('ItemNumber')) {
        $body.q = $ItemNumber
    }
    if ($PSBoundParameters.ContainsKey('ColorId')) {
        $body.color = $ColorId
    }
    if ($MissingItemsOnly.IsPresent) {
        $body.hideHaveWantedItems = 'Y'
    }

    $invCallParams = @{
        Uri    = 'https://www.bricklink.com/v2/wanted/search.page'
        Body   = $body
        Method = 'GET'
    }

    $response = InvokeBricklinkWebCall @invCallParams

    ## Have to use a where filter here locally because the AJAX call only has a "q" criteria that allows you to only
    ## search for items containing a query. To get the exact item number, we have to filter it locally
    $whereFilter = { '*' }
    if ($PSBoundParameters.ContainsKey('ItemNumber')) {
        $whereFilter = { $_.itemNo -eq $ItemNumber -and $_.colorID -eq $ColorId }
    }
    (FindWantedListItems -Html $response).where($whereFilter)
}