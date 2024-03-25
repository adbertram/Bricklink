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