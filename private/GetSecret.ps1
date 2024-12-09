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

    $name = $Name.ToString().replace('_', '-')

    # Determine encryption provider
    $secValue = switch ($config.encryption.provider) {
        'Local' {
            $config.$name
            break
        }
        'AzureKeyVault' {
            $KeyVaultName = $config.encryption.azure_key_vault_name
            $secret = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $name
            if (-not $secret) {
                throw "Could not find a secret with the name of [$name] in the Azure Key Vault [$KeyVaultName]"
            }
            $secret.SecretValue
            break
        }
        default {
            throw "Unsupported encryption provider: $($config.encryption.provider)"
        }
    }
    if (-not $secValue) {
        throw "Could not find a secret with the name of [$name]"
    }

    decryptSecureString $secValue
}