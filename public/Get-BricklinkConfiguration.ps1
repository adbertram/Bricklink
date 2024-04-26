<#
.SYNOPSIS
Retrieves the BrickLink configuration items from the configuration file.

.DESCRIPTION
The Get-BricklinkConfiguration function reads the BrickLink configuration items from the configuration.json file located in the module's root folder. It decrypts the encrypted configuration items if stored locally or retrieves them from Azure Key Vault based on the configuration settings.

.PARAMETER None
This function does not accept any parameters.

.EXAMPLE
$config = Get-BricklinkConfiguration

This example calls the Get-BricklinkConfiguration function to retrieve the BrickLink configuration items and stores them in the $config variable.

#>
function Get-BricklinkConfiguration {
    [CmdletBinding()]
    param ()

    $ErrorActionPreference = 'Stop'

    # Helper function to decrypt locally stored encrypted values
    function decrypt([string]$TextToDecrypt) {
        $secure = ConvertTo-SecureString $TextToDecrypt
        $hook = New-Object system.Management.Automation.PSCredential("test", $secure)
        $plain = $hook.GetNetworkCredential().Password
        return $plain
    }

    # Helper function to retrieve a secret from Azure Key Vault
    function Get-KeyVaultSecretValue([string]$secretName, [string]$KeyVaultName) {
        $secret = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $secretName
        return $secret.SecretValueText
    }

    $config = Get-Content -Path $script:configFilePath | ConvertFrom-Json

    # Determine encryption provider
    switch ($config.encryption.provider) {
        'Local' {
            $encryptedItems = @(
                'password'
                'api_consumer_key'
                'api_consumer_secret'
                'api_token'
                'api_token_secret'
            )

            $config.PSObject.Properties | ForEach-Object {
                $val = $_.Value
                if ($_.Name -in $encryptedItems -and $_.Value) {
                    $val = decrypt($_.Value)
                }
                $config.($_.Name) = $val
            }
        }
        'AzureKeyVault' {
            $KeyVaultName = $config.encryption.azure_key_vault_name
            $secretNames = @{
                'password'            = 'BricklinkPassword'
                'api_consumer_key'    = 'BricklinkConsumerKey'
                'api_consumer_secret' = 'BricklinkConsumerSecret'
                'api_token'           = 'BricklinkApiToken'
                'api_token_secret'    = 'BricklinkApiTokenSecret'
            }

            foreach ($item in $secretNames.GetEnumerator()) {
                $config[$item.Key] = Get-KeyVaultSecretValue -secretName $item.Value -KeyVaultName $KeyVaultName
            }
        }
        default {
            throw "Unsupported encryption provider: $($config.encryption.provider)"
        }
    }

    $config
}
