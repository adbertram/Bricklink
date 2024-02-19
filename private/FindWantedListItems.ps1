function FindWantedListItems {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Html
    )

    $ErrorActionPreference = 'Stop'

    $json = $Html | Select-String -Pattern 'var wlJson = (\{.*\})' | ForEach-Object { $_.matches[0].groups[1].value }
    $wiResponse = $json | ConvertFrom-Json
    if (TestObjectProperty -InputObject $wiResponse -PropertyName 'wantedItems') {
        if ($wiResponse.wantedItems.count -ne $wiResponse.totalResults) {
            throw "Did not extract 100% of wanted list items in wanted list. This can sometimes happen if you're not logged in. Run Connect-Web and try again."
        }
        $wiResponse.wantedItems
    }
}