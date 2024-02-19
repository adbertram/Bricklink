function Get-Supersets {
    <#
        .SYNOPSIS
            https://www.bricklink.com/v3/api.page?page=get-supersets
    
        .EXAMPLE
            PS> functionName
    
    #>
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