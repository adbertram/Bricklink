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
        new_or_used  = $Condition
        guide_type   = $GuideType
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