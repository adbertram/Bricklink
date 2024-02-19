function Save-BricklinkConfigurationItem {
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Username,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Password,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$ApiConsumerKey,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$ApiConsumerSecret,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$ApiToken,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$ApiTokenSecret
    )

    $ErrorActionPreference = 'Stop'
    
    function encrypt([string]$TextToEncrypt) {
        $secure = ConvertTo-SecureString $TextToEncrypt -AsPlainText -Force
        $encrypted = $secure | ConvertFrom-SecureString
        return $encrypted
    }

    $encryptedItems = @(
        'password'
        'api_consumer_key'
        'api_consumer_secret'
        'api_token'
        'api_token_secret'
    )

    $paramToConfItemMap = @{
        'Username'          = 'username'
        'Password'          = 'password'
        'ApiConsumerKey'    = 'api_consumer_key'
        'ApiConsumerSecret' = 'api_consumer_secret'
        'ApiToken'          = 'api_token'
        'ApiTokenSecret'    = 'api_token_secret'
    }

    $config = Get-BricklinkConfigurationItem

    $PSBoundParameters.GetEnumerator() | ForEach-Object {
        $val = $_.Value
        if ($paramToConfItemMap[$_.Key] -in $encryptedItems) {
            $val = encrypt($_.Value)
        }
        $config.($paramToConfItemMap[$_.Key]) = $val
        $config | ConvertTo-Json | Set-Content -Path "$script:rootModuleFolderPath\configuration.json"
    }
}