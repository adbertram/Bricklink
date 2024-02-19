function Connect-Web {
    [CmdletBinding()]
    param
    ()

    $ErrorActionPreference = 'Stop'

    $loginUri = 'https://www.bricklink.com/ajax/renovate/loginandout.ajax'
    $credentials = @{
        userid          = $script:bricklinkConfiguration.username
        password        = $script:bricklinkConfiguration.password
        keepme_loggedin = '1'
    }
    try {
        $response = Invoke-WebRequest -Uri $loginUri -Method Post -Body $credentials -SessionVariable session
        if ($response.StatusCode -ne 200) {
            $jsonResponse = $response.Content | ConvertFrom-Json
            throw "Unable to authenticate via Bricklink web. Server returned error $($jsonResponse.returnCode): $($jsonResponse.returnMessage)"
        }
        $global:session = $session
    } catch {
        Write-Error -Message "Error running Connect-Web: $($_.Exception.Message)"
    }
}