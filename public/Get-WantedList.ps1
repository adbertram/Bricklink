<#
.SYNOPSIS
Retrieves wanted lists from BrickLink.

.DESCRIPTION
The Get-WantedList function retrieves wanted lists from BrickLink's website. It sends a request to the BrickLink website to fetch the wanted lists associated with the logged-in user. The function can retrieve all wanted lists or a specific wanted list based on the provided name.

.PARAMETER Name
Specifies the name of the wanted list to retrieve. This parameter is optional. If not provided, all wanted lists associated with the logged-in user are retrieved.

.EXAMPLE
Get-WantedList -Name "MyWantedList"
Retrieves the wanted list named "MyWantedList".

.EXAMPLE
Get-WantedList
Retrieves all wanted lists associated with the logged-in user.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Object
The function returns an object representing the wanted lists fetched from BrickLink's website.

.NOTES
The function relies on the InvokeBricklinkWebCall function to make the HTTP request to the BrickLink website.
#>

function Get-WantedList {
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    $ErrorActionPreference = 'Stop'

    $response = InvokeBricklinkWebCall -Uri 'https://www.bricklink.com/v2/wanted/list.page' -Method 'GET'

    ## This returns the wanted lists and only 10 of the wanted list items (with IDS! that we need for Update-WantedListItem) but
    ## I can't figure out a way to A. get this to produce all of the wanted list items (with IDs) or B. get Get-WantedListItem
    ## to return the wanted list item IDs
    if (-not ($jsonItems = $response | Select-String -Pattern 'var wlJson = \{(.*)\}' | ForEach-Object { $_.matches[0].groups[1].value })) {
        throw 'No wanted lists found. Are you logged in?'
    }
    $jsonItems = "{$jsonItems}"
    $jsonItems = $jsonItems | ConvertFrom-Json
    $wantedLists = $jsonItems.wantedLists
    if ($PSBoundParameters.ContainsKey('Name')) {
        $wantedLists | Where-Object { $_.name -eq $Name }
    } else {
        $wantedLists
    }
    
}