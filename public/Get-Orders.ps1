function Get-Orders {
    <#
        .SYNOPSIS
            https://www.bricklink.com/v3/api.page?page=get-orders
    
        .EXAMPLE
            PS> functionName
    
    #>
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('in', 'out')]
        [string]$Direction = 'in',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('pending', 'completed', 'ready', 'paid', 'shipped', 'received')]
        [string]$Status = 'paid' ## defaults to open orders yet to be shipped
    )

    $ErrorActionPreference = 'Stop'

    $apiParameters = @{
        direction = $Direction
        status    = $Status
    }

    InvokeBricklinkApiCall -Uri 'orders' -ApiParameter $apiParameters
}