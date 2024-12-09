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

    $configFile = Get-Content -Path $script:configFilePath | ConvertFrom-Json -Depth 10

    $config = @{}
    $secretVals = @{}
    foreach ($prop in $configFile.PSObject.Properties) {
        $itemName = $prop.Name
        if ($itemName -eq 'secret-values') {
            foreach ($secProp in $configfile.'secret-values'.PSObject.Properties) {
                $secName = $secProp.Name.ToString().replace('-', '_')
                $secretVals[$secName] = (GetSecret $secName)
            }
        } else {
            $config.$itemName = $prop.Value
        }
    }
    $config.'secret-values' = [pscustomobject]$secretVals
    [pscustomobject]$config
}
