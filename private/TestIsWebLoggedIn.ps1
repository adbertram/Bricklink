function TestIsWebLoggedIn {
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$PageContent
    )

    $ErrorActionPreference = 'Stop'

    $json = $PageContent | Select-String -Pattern 'var blo_session\s+= (\{.*\})' | ForEach-Object { $_.matches[0].groups[1].value } | ConvertFrom-Json
    [bool]$json.is_loggedin
}