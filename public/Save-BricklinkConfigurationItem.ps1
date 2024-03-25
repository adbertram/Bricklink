<#
.SYNOPSIS
Saves Bricklink configuration settings.

.DESCRIPTION
The Save-BricklinkConfiguration function saves Bricklink configuration settings to a JSON file. It encrypts sensitive information such as passwords and API tokens before saving them to ensure security.

.PARAMETER Username
Specifies the Bricklink username.

.PARAMETER Password
Specifies the Bricklink password.

.PARAMETER ApiConsumerKey
Specifies the Bricklink API consumer key.

.PARAMETER ApiConsumerSecret
Specifies the Bricklink API consumer secret.

.PARAMETER ApiToken
Specifies the Bricklink API token.

.PARAMETER ApiTokenSecret
Specifies the Bricklink API token secret.

.EXAMPLE
Save-BricklinkConfiguration -Username "user123" -Password "password123" -ApiConsumerKey "consumerkey123" -ApiConsumerSecret "consumersecret123" -ApiToken "token123" -ApiTokenSecret "tokensecret123"
Saves the Bricklink configuration settings to a JSON file.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
None. The function does not generate any output.

.NOTES
The function encrypts sensitive information before saving it to the configuration file. It relies on the Get-BricklinkConfigurationItem function to retrieve the current configuration.
#>

function Save-BricklinkConfiguration {
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