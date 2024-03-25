<#
.SYNOPSIS
Retrieves subsets of a specified item from BrickLink.

.DESCRIPTION
The Get-Subsets function retrieves subsets of a specified item from BrickLink's API. It allows querying subsets based on various parameters such as item type, item number, color, and inclusion/exclusion of minifigs and subsets. The function sends a request to the BrickLink API to fetch subsets according to the provided parameters.

.PARAMETER Type
Specifies the type of the item. Possible values are 'PART', 'SET', 'MINIFIG', 'BOOK', 'GEAR', 'CATALOG', and 'INSTRUCTION'.

.PARAMETER ItemNumber
Specifies the item number of the item for which subsets need to be retrieved.

.PARAMETER ColorId
Specifies the color ID of the item. This parameter is optional.

.PARAMETER BreakMinifigs
Indicates whether to break minifigs into individual parts. This switch is optional.

.PARAMETER BreakSubsets
Indicates whether to break subsets into individual parts. This switch is optional.

.PARAMETER Exclude
Specifies subsets to exclude from the results. Possible values are 'Alternates', 'Counterparts', 'Extra', and 'Sticker Sheets'. This parameter accepts multiple values.

.PARAMETER Mandatory
Indicates that the Type and ItemNumber parameters are mandatory. You must provide values for these parameters when invoking the function.

.PARAMETER ValidateNotNullOrEmpty
Specifies that the Type and ItemNumber parameters cannot be null or empty.

.PARAMETER ValidateSet
Validates that the provided values for Exclude parameter are within the specified set of values.

.EXAMPLE
Get-Subsets -Type 'SET' -ItemNumber '10214-1' -BreakMinifigs -Exclude 'Extra'
Retrieves subsets of LEGO set "10214-1", breaks minifigs into individual parts, and excludes extra parts from the results.

.EXAMPLE
Get-Subsets -Type 'PART' -ItemNumber '3001' -ColorId '11' -Exclude 'Sticker Sheets' -Exclude 'Extra'
Retrieves subsets of LEGO part "3001" in color ID "11" (Black), excluding sticker sheets and extra parts from the results.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Object
The function returns an object representing the subsets of the specified item fetched from BrickLink.

.NOTES
The function relies on the InvokeBricklinkApiCall function to make the HTTP request to the BrickLink API.
#>

function Get-Subsets {
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