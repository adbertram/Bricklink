function Get-ApiCallCount {
    [CmdletBinding()]
    param()
    if (Test-Path -Path $script:apiCallCountTrackingFilePath) {
        $apiCallData = Get-Content -Path $script:apiCallCountTrackingFilePath -Raw | ConvertFrom-Json
        $lastReset = [datetime]$apiCallData.last_reset
        if ((Get-Date) - $lastReset -ge [timespan]::FromDays(1)) {
            # Reset count after 24 hours
            $apiCallData.count = 0
            $apiCallData.last_reset = Get-Date
            $apiCallData | ConvertTo-Json | Set-Content -Path $script:apiCallCountTrackingFilePath
        }
    } else {
        # Initialize if the file does not exist
        $apiCallData = @{
            count     = 0
            last_reset = Get-Date
        }
        $apiCallData | ConvertTo-Json | Set-Content -Path $script:apiCallCountTrackingFilePath
    }
    $apiCallData
}