<#
.SYNOPSIS
Retrieves supersets of a specified item from BrickLink.

.DESCRIPTION
The Get-Supersets function retrieves supersets of a specified item from BrickLink's API. It allows querying supersets based on various parameters such as item type, item number, color, and superset type. The function sends a request to the BrickLink API to fetch supersets according to the provided parameters.

.PARAMETER Type
Specifies the type of the item. Possible values are 'PART', 'SET', 'MINIFIG', 'BOOK', 'GEAR', 'CATALOG', and 'INSTRUCTION'.

.PARAMETER ItemNumber
Specifies the item number of the item for which supersets need to be retrieved.

.PARAMETER ColorId
Specifies the color ID of the item. This parameter is optional.

.PARAMETER Color
Specifies the color of the item. This parameter is optional.

.PARAMETER SuperSetType
Specifies the type of the supersets to retrieve. Possible values are 'PART', 'SET', 'MINIFIG', 'BOOK', 'GEAR', 'CATALOG', and 'INSTRUCTION'. The default value is 'SET'.

.EXAMPLE
Get-Supersets -Type 'PART' -ItemNumber '3001' -ColorName 'Red'
Retrieves supersets of LEGO part "3001" in red color.

.EXAMPLE
Get-Supersets -Type 'SET' -ItemNumber '10214-1' -SuperSetType 'MINIFIG'
Retrieves supersets of LEGO set "10214-1" which contain minifigs.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Object
The function returns an object representing the supersets of the specified item fetched from BrickLink.

.NOTES
The function relies on the InvokeBricklinkApiCall and Get-ColorList functions to make the HTTP requests to the BrickLink API and retrieve color information, respectively.
#>

function Get-Supersets {
    [CmdletBinding(DefaultParameterSetName = 'Color')]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ItemType]$Type,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ItemNumber,

        [Parameter(ParameterSetName = 'ColorID')]
        [ValidateNotNullOrEmpty()]
        [string]$ColorId,

        [Parameter(ParameterSetName = 'ColorName')]
        [ValidateNotNullOrEmpty()]
        [Color]$Color,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ItemType]$SuperSetType = 'SET'

    )

    $ErrorActionPreference = 'Stop'

    $inBlApiParams = @{
        Uri = "items/$Type/$ItemNumber/supersets"
    }
    if ($PSBoundParameters.ContainsKey('ColorId')) {
        $inBlApiParams.ApiParameter = @{
            color_id = $ColorId
        }
    } elseif ($PSBoundParameters.ContainsKey('Color')) {
        $colors = Get-ColorList
        if (-not ($colorId = $colors.where({ (ConvertColorName -Color $_.color_name) -eq $Color }).color_id)) {
            throw "Could not find a color ID for color [$($Color)]."
        }
        $inBlApiParams.ApiParameter = @{
            color_id = $colorId
        }
    }

    WriteLog -Message "Getting Bricklink supersets of item number [$($ItemNumber)]/ColorID [$($ColorId)] of type [$($Type)]..."
    if ($response = InvokeBricklinkApiCall @inBlApiParams) {
        $whereFilter = { '* ' }
        if ($PSBoundParameters.ContainsKey('SuperSetType')) {
            $whereFilter = { $_.item.type -eq $SuperSetType }
        }
        $response.entries.where($whereFilter)
    }
}