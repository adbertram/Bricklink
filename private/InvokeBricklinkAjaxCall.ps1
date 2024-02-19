function InvokeBricklinkWebCall {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [uri]$Uri,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('GET', 'POST')]
        [string]$Method,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [hashtable]$Body,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [switch]$NoAuthentication
    )

    $ErrorActionPreference = 'Stop'

    $irmParams = @{
        Uri                = $Uri
        Method             = $Method
        StatusCodeVariable = 'irmStatus'
    }

    if (-not $NoAuthentication.IsPresent) {

        if (-not (Get-Variable -Name session -Scope Global -ErrorAction Ignore)) {
            ## This session may not be authenticated even if the variable is there. Need a way to test this.
            Connect-Web
        }
        $irmParams.WebSession = $global:session
    }

    if ($PSBoundParameters.ContainsKey('Body')) {
        $irmParams.Body = $Body
    }
    
    $response = Invoke-RestMethod @irmParams
    if ($irmStatus -ne 200) {
        throw $response
    } elseif (($Uri.ToString() -notmatch '\.page|\.asp') -and $response.returnCode -ne 0) {
        if ($response.returnMessage) {
            throw $response.returnMessage
        } else {
            throw "Error occcured but no return message returned. Response return code was [$($response.returnCode)]."
        }
    }
    $response
}