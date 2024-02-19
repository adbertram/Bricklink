function Update-StoreInventory {
    <#
        .SYNOPSIS
            https://www.bricklink.com/v3/api.page?page=update-inventory
    
        .EXAMPLE
            PS> functionName
    
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$InventoryId,

        [Parameter(ParameterSetName = 'QuantityChange')]
        [ValidateNotNullOrEmpty()]
        [int]$QuantityChange,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('A', 'B', 'C', 'D')]
        [string]$StockroomId
    )

    $ErrorActionPreference = 'Stop'

    $requestBody = @{}

    if ($PSBoundParameters.ContainsKey('QuantityChange')) {
        if ($QuantityChange -gt 0) {
            $QuantityChange = "+$QuantityChange"
        }
        $requestBody.quantity = $QuantityChange
    }

    if ($PSBoundParameters.ContainsKey('StockroomId')) {
        $requestBody.is_stock_room = 'true'
        $requestBody.stock_room_id = $StockroomId
    }

    try {
        InvokeBricklinkApiCall -Uri "inventories/$InventoryId" -Method 'PUT' -RequestBody $requestBody
    } catch {
        $err = ($_.ErrorDetails.Message | ConvertFrom-Json).meta
        if ($err.message -eq 'RESOURCE_UPDATE_NOT_ALLOWED' -and $err.description -match 'Update would result in 0 quantity in your inventory without being in stockroom') {
            Update-BricklinkStoreInventory -StockroomId 'A' -Quantity $QuantityChange -InventoryId $InventoryId
        } else {
            throw $_
        }
    }
}