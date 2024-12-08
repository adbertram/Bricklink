function GetSecret {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ConfigurationItem]$Name
    )

    $ErrorActionPreference = 'Stop'

    ## Not using Get-BlBrickConfiguration on purpose here to prevent a circular reference
    $config = Get-Content -Path $script:configFilePath | ConvertFrom-Json -Depth 5

    # Determine encryption provider
    $secValue = switch ($config.encryption.provider) {
        'Local' {
            $config.$Name
            break
        }
        'AzureKeyVault' {
            $KeyVaultName = $config.encryption.azure_key_vault_name
            $azKeyName = ConvertToAzKeyVaultName $Name
            $secret = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $azKeyName
            if (-not $secret) {
                throw "Could not find a secret with the name of [$Name] in the Azure Key Vault [$KeyVaultName]"
            }
            $secret.SecretValue
            break
        }
        default {
            throw "Unsupported encryption provider: $($config.encryption.provider)"
        }
    }
    if (-not $secValue) {
        throw "Could not find a secret with the name of [$Name]"
    }

    decryptSecureString $secValue
}