function Get-Subsets {
    <#
        .SYNOPSIS
            https://www.bricklink.com/v3/api.page?page=get-subsets
    
        .EXAMPLE
            PS> functionName
    
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ItemType]$Type,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ItemNumber,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$ColorId,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [switch]$BreakMinifigs,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [switch]$BreakSubsets,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Alternates', 'Counterparts', 'Extra', 'Sticker Sheets')]
        [string[]]$Exclude
    )

    $ErrorActionPreference = 'Stop'

    $apiParameters = @{}
    if ($PSBoundParameters.ContainsKey('BreakMinifigs')) {
        $apiParameters.break_minifigs = 'true'
    }
    if ($PSBoundParameters.ContainsKey('BreakSubsets')) {
        $apiParameters.break_subsets = 'true'
    }
    if ($PSBoundParameters.ContainsKey('ColorId')) {
        $apiParameters.color_id = $ColorId
    }

    $invApiParams = @{
        Uri = "items/$Type/$ItemNumber/subsets"
    }
    if ($apiParameters.Count -gt 0) {
        $invApiParams.ApiParameter = $apiParameters
    }

    if ($response = InvokeBricklinkApiCall @invApiParams) {
        $filters = @()
        if ($Exclude -contains "Alternates") {
            $filters += "!`$_.is_alternate"
        }
        if ($Exclude -contains "Counterparts") {
            $filters += "!`$_.is_counterpart"
        }
        if ($Exclude -contains "Sticker Sheets") {
            $filters += "`$_.item.category_id -ne 160"
        }
        if ($filters.Count -eq 0) {
            $whereFilter = "{ $true }"
        } else {
            $whereFilter = "($($filters -join ' -and '))"
        }
        $items = ($response.entries).where([scriptblock]::Create($whereFilter))
        if ($Exclude -contains 'Extra') {
            ## need the where filter because if we decrement the extra_quantity, that sometimes leads an item with 0 quantity and we want to exlcude that
            $items = ($items | Select-Object -Property *, @{n = 'quantity'; e = { [int]$_.quantity - [int]$_.extra_quantity } } -ExcludeProperty quantity).where({ $_.quantity -gt 0 })
        }
        ## when like lots are returned, remove the lot with the lower qty. This happens when the part is marked "MID" on the Bricklink
        ## set inventory page. It has something to do with alternates even if we remove all alternates.
        $items | Group-Object -Property @{Expression={$_.item.no} },@{Expression={$_.color_id}} | ForEach-Object {
            $_.Group | Sort-Object -Property quantity -Descending | Select-Object -First 1
        }
    }
}