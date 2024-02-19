function Get-StoreInventories {
    <#
        .SYNOPSIS
            https://www.bricklink.com/v3/api.page?page=get-inventories
    
        .EXAMPLE
            PS> functionName
    
    #>
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Y', 'S', 'B', 'C', 'N', 'R')]
        [string]$Status,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('part', 'set')]
        [string]$ItemType = 'part',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Location
    )

    $ErrorActionPreference = 'Stop'

    $apiParameters = @{
        item_type = $ItemType
    }

    if ($PSBoundParameters.ContainsKey('Status')) {
        $apiParameters.status = $Status
    }

    $whereFilter = "'*'"
    if ($PSBoundParameters.ContainsKey('Location')) {
        $whereFilter = "`$_.remarks -eq '$Location'"
    }
    $whereFilter = [scriptblock]::Create($whereFilter)

    InvokeBricklinkApiCall -Uri 'inventories' -ApiParameter $apiParameters | Where-Object -FilterScript $whereFilter
}