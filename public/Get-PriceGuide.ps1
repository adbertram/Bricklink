<#
.SYNOPSIS
Retrieves price guide information for a specified item from BrickLink.

.DESCRIPTION
The Get-PriceGuide function retrieves price guide information for a specified item from BrickLink's API. It allows querying price guide data based on various parameters such as item type, item number, color, condition, guide type, country code, and region.

.PARAMETER Type
Specifies the type of the item. Possible values are 'PART', 'SET', 'MINIFIG', 'BOOK', 'GEAR', 'CATALOG', and 'INSTRUCTION'.

.PARAMETER ItemNumber
Specifies the item number of the item for which price guide information needs to be retrieved.

.PARAMETER ColorId
Specifies the color ID of the item. This parameter is mutually exclusive with the Color parameter.

.PARAMETER Color
Specifies the color of the item. This parameter is mutually exclusive with the ColorId parameter.

.PARAMETER Condition
Specifies the condition of the item. Possible values are 'N' (new) and 'U' (used). The default value is 'U'.

.PARAMETER GuideType
Specifies the type of price guide to retrieve. Possible values are 'sold' and 'stock'. The default value is 'sold'.

.PARAMETER CountryCode
Specifies the country code to retrieve localized price information. This parameter is optional.

.PARAMETER Region
Specifies the region for which price information is retrieved. The default value is 'north_america'.

.PARAMETER Mandatory
Indicates that the Type and ItemNumber parameters are mandatory. You must provide values for these parameters when invoking the function.

.PARAMETER DefaultParameterSetName
Specifies the default parameter set for the function.

.PARAMETER ValidateSet
Validates that the provided values for Condition and GuideType parameters are within the specified set of values.

.PARAMETER ValidateNotNullOrEmpty
Specifies that the Type, ItemNumber, Condition, and GuideType parameters cannot be null or empty.

.EXAMPLE
Get-PriceGuide -Type 'PART' -ItemNumber '3001' -ColorName 'Red' -Condition 'N' -GuideType 'sold'
Retrieves the price guide information for a new red part with the item number '3001', based on sold listings.
#>

function Get-PriceGuide {
    [CmdletBinding(DefaultParameterSetName = 'ColorName')]
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
        [ValidateSet('N', 'U')]
        [string]$Condition = 'U',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('sold', 'stock')]
        [string]$GuideType = 'sold',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$CountryCode,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Region = 'north_america'
    )

    $ErrorActionPreference = 'Stop'

    $apiParameters = @{
        new_or_used = $Condition
        guide_type  = $GuideType
    }
    if ($PSBoundParameters.ContainsKey('CountryCode')) {
        $apiParameters.country_code = $CountryCode
    }
    if ($PSBoundParameters.ContainsKey('ColorId')) {
        $apiParameters.color_id = $ColorId
    } elseif ($PSBoundParameters.ContainsKey('Color')) {
        $colors = Get-ColorList
        $apiParameters.color_id = $colors.where({ $_.color_name -eq $Color }).color_id
    }

    InvokeBricklinkApiCall -Uri "items/$Type/$ItemNumber/price" -ApiParameter $apiParameters
    
}