function InvokeBricklinkApiCall {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Uri,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('GET', 'POST', 'PUT')]
        [string]$Method = 'GET',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [hashtable]$ApiParameter,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [hashtable]$RequestBody
    )

    $ErrorActionPreference = 'Stop'

    $apiCallData = Get-BlApiCallCount

    if ($apiCallData.count -ge $script:maxDailyApiCallCount) {
        throw "API call limit reached: $script:maxDailyApiCallCount calls in 24 hours."
    } else {
        Write-Verbose -Message "Bricklink API 24-hour call count is currently at: $($apiCallData.count)."
        IncrementBricklinkApiCallCount
    }


    $baseUri = 'https://api.bricklink.com/api/store/v1'
    $apiUri = "$baseUri/$Uri"

    if ($PSBoundParameters.ContainsKey('ApiParameter')) {
        Add-Type -AssemblyName System.Web
        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
        $ApiParameter.GetEnumerator() | ForEach-Object {
            $query.Add($_.Key, $_.Value)
        }
        $uriRequest = [System.UriBuilder]$apiUri
        $uriRequest.Query = $query.ToString()
        $apiUri = $uriRequest.Uri.OriginalString
    }

    $authHeader = GetBricklinkApiAuthorizationHeader -Uri $apiUri -Method $Method

    $headers = @{
        "Authorization" = $authHeader
        "Accept"        = "application/json"
        'Content-Type'  = 'application/json'
    }

    $irmParams = @{
        Uri                = $apiUri
        Method             = $Method
        Headers            = $headers
        StatusCodeVariable = 'respStatus'
    }

    if ($PSBoundParameters.ContainsKey('RequestBody')) {
        $irmParams.Body = ($RequestBody | ConvertTo-Json)
    }

    $response = Invoke-RestMethod @irmParams
    if ($respStatus -ne 200) {
        throw $response
    } elseif ($response.meta.code -ne 200) {
        throw $response.meta.description
    }
    $response.data
}