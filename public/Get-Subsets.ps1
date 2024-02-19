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
        [ValidateSet('Alternates', 'Counterparts', 'Extra')]
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
        ## Sometimes Bricklink has a completely separate entry for the extra qantity part and the same part
        ## with no extra quantity
        # if ($Exclude -contains "Extra") {
        #     $filters += "`$_.extra_quantity -eq 0"
        # }
        if ($filters.Count -eq 0) {
            $whereFilter = "{ $true }"
        } else {
            $whereFilter = "($($filters -join ' -and '))"
        }
        $items = ($response.entries).where([scriptblock]::Create($whereFilter))
        if ($Exclude -contains 'Extra') {
            ## need the where filter because if we decrement the extra_quantity, that sometimes leads an item with 0 quantity and we want to exlcude that
            ($items | Select-Object -Property *,@{n='quantity';e={ [int]$_.quantity - [int]$_.extra_quantity }} -ExcludeProperty quantity).where({$_.quantity -gt 0})
        } else {
            $items
        }
    }
}