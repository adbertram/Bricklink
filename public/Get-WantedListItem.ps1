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