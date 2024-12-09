function SetSecret {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ConfigurationItem]$Name,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [securestring]$Value
    )

    $ErrorActionPreference = 'Stop'

    function encrypt([string]$TextToEncrypt) {
        $secure = ConvertTo-SecureString $TextToEncrypt -AsPlainText -Force
        $secure | ConvertFrom-SecureString
    }

    # Determine encryption provider
    switch ($script:bricklinkConfiguration.encryption.provider) {
        'Local' {
            $secValue = encrypt($Value)
            $script:bricklinkConfiguration.$name = $secValue
            $script:bricklinkConfiguration | ConvertTo-Json | Set-Content -Path $script:configFilePath
            break
        }
        'AzureKeyVault' {
            $keyVaultName = $script:bricklinkConfiguration.encryption.azure_key_vault_name
            $kvSecName = $Name.ToString().replace('_', '-')
            $null = Set-AzKeyVaultSecret -VaultName $keyVaultName -Name $kvSecName -SecretValue $Value
            break
        }
        default {
            throw "Unsupported encryption provider: $($script:bricklinkConfiguration.encryption.provider)"
        }
    }
}

