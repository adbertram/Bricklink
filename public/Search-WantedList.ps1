
<#
.SYNOPSIS
Searches for a specific item in wanted lists on BrickLink.

.DESCRIPTION
The Search-WantedList function searches for a specific item in wanted lists on BrickLink's website. It sends a request to the BrickLink website to search for the specified item based on its item number and color ID. Additionally, it can filter the search results to include only missing items.

.PARAMETER ItemNumber
Specifies the item number of the item to search for.

.PARAMETER ColorId
Specifies the color ID of the item to search for.

.PARAMETER MissingItemsOnly
Indicates whether to include only missing items in the search results. This switch is optional.

.EXAMPLE
Search-WantedList -ItemNumber "3001" -ColorId 11 -MissingItemsOnly
Searches for the item with item number "3001" and color ID "11" in wanted lists on BrickLink, including only missing items in the search results.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Object
The function returns an object representing the search results from BrickLink's website.

.NOTES
The function relies on the InvokeBricklinkWebCall and FindWantedListItems functions to make the HTTP request to the BrickLink website and parse the HTML response, respectively.
#>
function Search-WantedList {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ItemNumber,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [int]$ColorId,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [switch]$MissingItemsOnly
    )

    $ErrorActionPreference = 'Stop'
    
    $body = @{
        'pageSize'     = 1000
        'type'         = 'A'
        'sa'           = 1
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
    $whereFilter = { $_.itemNo -eq $ItemNumber -and $_.colorID -eq $ColorId }
    (FindWantedListItems -Html $response).where($whereFilter)
}