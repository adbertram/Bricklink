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