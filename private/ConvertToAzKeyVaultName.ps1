function ConvertToAzKeyVaultName {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ConfigurationItem]$ConfigurationItemName
    )

    $ErrorActionPreference = 'Stop'
    "bricklink-$($ConfigurationItemName.ToString().replace('_','-'))"
    
}