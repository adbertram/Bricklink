<#
.SYNOPSIS
Establishes a connection to the BrickLink website.

.DESCRIPTION
The Connect-Web function authenticates and logs in to the BrickLink website using the provided credentials stored in the $script:bricklinkConfiguration variable. It sets up a web session that can be used for subsequent requests.

.PARAMETER None
This function does not accept any parameters.

.EXAMPLE
Connect-Web

This example calls the Connect-Web function to establish a connection to the BrickLink website using the stored credentials.

.NOTES
- The function uses the $script:bricklinkConfiguration variable to retrieve the username and password for authentication. Make sure this variable is properly defined before calling the function.
- The function sets the $ErrorActionPreference to 'Stop' to ensure that any errors encountered during execution are treated as terminating errors.
- The function sends a POST request to the BrickLink login URL (https://www.bricklink.com/ajax/renovate/loginandout.ajax) with the provided credentials.
- If the authentication is successful (status code 200), the function stores the web session in the $global:session variable for use in subsequent requests.
- If the authentication fails, the function throws an exception with the error details returned by the BrickLink server.
- The function uses a try-catch block to handle any errors that may occur during execution. If an error is caught, it is written to the error stream using Write-Error.

.LINK
Related functions or documentation links (if applicable)

#>
function Connect-Web {
    [CmdletBinding()]
    param
    ()

    $ErrorActionPreference = 'Stop'

    $loginUri = 'https://www.bricklink.com/ajax/renovate/loginandout.ajax'
    $credentials = @{
        userid          = $script:bricklinkConfiguration.'bricklink-username'
        password        = $script:bricklinkConfiguration.'secret-values'.password
        keepme_loggedin = '1'
    }
    try {
        $response = Invoke-WebRequest -Uri $loginUri -Method Post -Body $credentials -SessionVariable session
        if ($response.StatusCode -ne 200 -or (($response.Content | ConvertFrom-Json).returnCode -ne 0)) {
            $jsonResponse = $response.Content | ConvertFrom-Json
            throw "Unable to authenticate via Bricklink web. Server returned error $($jsonResponse.returnCode): $($jsonResponse.returnMessage)"
        }
        $global:session = $session
    } catch {
        Write-Error -Message "Error running Connect-Web: $($_.Exception.Message)"
    }
}