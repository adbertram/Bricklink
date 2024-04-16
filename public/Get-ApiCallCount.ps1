function Get-ApiCallCount {
    [CmdletBinding()]
    param()
    if (Test-Path -Path $script:apiCallCountTrackingFilePath) {
        $apiCallData = Get-Content -Path $script:apiCallCountTrackingFilePath -Raw | ConvertFrom-Json
        $lastReset = [datetime]$apiCallData.LastReset
        if ((Get-Date) - $lastReset -ge [timespan]::FromDays(1)) {
            # Reset count after 24 hours
            $apiCallData.Count = 0
            $apiCallData.LastReset = Get-Date
            $apiCallData | ConvertTo-Json | Set-Content -Path $script:apiCallCountTrackingFilePath
        }
    } else {
        # Initialize if the file does not exist
        $apiCallData = @{
            Count     = 0
            LastReset = Get-Date
        }
        $apiCallData | ConvertTo-Json | Set-Content -Path $script:apiCallCountTrackingFilePath
    }
    $apiCallData
}