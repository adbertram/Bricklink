function Get-StoreInventory {
    <#
        .SYNOPSIS
            https://www.bricklink.com/v3/api.page?page=get-inventory
    
        .EXAMPLE
            PS> functionName
    
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$InventoryId
    )

    $ErrorActionPreference = 'Stop'

    InvokeBricklinkApiCall -Uri "inventories/$InventoryId"
}