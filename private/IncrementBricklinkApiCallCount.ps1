function IncrementBricklinkApiCallCount {
    $apiCallData = Get-BlApiCallCount
    $apiCallData.count++
    $apiCallData | ConvertTo-Json | Set-Content -Path $script:apiCallCountTrackingFilePath
}