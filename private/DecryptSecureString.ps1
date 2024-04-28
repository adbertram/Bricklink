function DecryptSecureString {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [securestring]$SecureString
    )

    $ErrorActionPreference = 'Stop'

    $hook = New-Object system.Management.Automation.PSCredential("test", $SecureString)
    $hook.GetNetworkCredential().Password
    
}