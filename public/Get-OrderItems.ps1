function Get-OrderItems {
    <#
        .SYNOPSIS
            https://www.bricklink.com/v3/api.page?page=get-order-items
    
        .EXAMPLE
            PS> functionName
    
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$OrderId
    )

    $ErrorActionPreference = 'Stop'

    InvokeBricklinkApiCall -Uri "orders/$OrderId/items"
}