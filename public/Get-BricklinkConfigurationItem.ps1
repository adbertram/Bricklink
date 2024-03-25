<#
.SYNOPSIS
Retrieves the BrickLink configuration items from the configuration file.

.DESCRIPTION
The Get-BricklinkConfigurationItem function reads the BrickLink configuration items from the configuration.json file located in the module's root folder. It decrypts the encrypted configuration items and returns the configuration object.

.PARAMETER None
This function does not accept any parameters.

.EXAMPLE
$config = Get-BricklinkConfigurationItem

This example calls the Get-BricklinkConfigurationItem function to retrieve the BrickLink configuration items and stores them in the $config variable.

#>
function Get-BricklinkConfigurationItem {
    [CmdletBinding()]
    param
    ()

    $ErrorActionPreference = 'Stop'

    function decrypt([string]$TextToDecrypt) {
        $secure = ConvertTo-SecureString $TextToDecrypt
        $hook = New-Object system.Management.Automation.PSCredential("test", $secure)
        $plain = $hook.GetNetworkCredential().Password
        return $plain
    }

    $encryptedItems = @(
        'password'
        'api_consumer_key'
        'api_consumer_secret'
        'api_token'
        'api_token_secret'
    )

    if (-not (Test-Path -Path "$script:rootModuleFolderPath\configuration.json" -PathType Leaf)) {
        throw "The required configuration file [$script:rootModuleFolderPath\configuration.json] could not be found. Have you ran Save-BricklinkConfigurationItem yet?"
    }
    $config = Get-Content -Path "$script:rootModuleFolderPath\configuration.json" | ConvertFrom-Json

    $config.PSObject.Properties | ForEach-Object {
        $val = $_.Value
        if ($_.Name -in $encryptedItems -and $_.Value) {
            $val = decrypt($_.Value)
        }
        $config.($_.Name) = $val
    }
    $config
}