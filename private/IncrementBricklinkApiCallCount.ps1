function IncrementBricklinkApiCallCount {
    $apiCallData = Get-BlApiCallCount
    $apiCallData.Count++
    $apiCallData | ConvertTo-Json | Set-Content -Path $script:apiCallCountTrackingFilePath
}