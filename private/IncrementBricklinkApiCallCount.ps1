function IncrementBricklinkApiCallCount {
    $apiCallData = Get-BlApiCallCount
    $apiCallData.count++
    ## not using JSON here becuause of an issue when multhreading
    (Get-Content -Path $script:apiCallCountTrackingFilePath -Raw).replace('count": \d+','count": ' + $apiCallData.count) | Set-Content -Path $script:apiCallCountTrackingFilePath
}