function Get-KnownColors {
    <#
        .SYNOPSIS
            https://www.bricklink.com/v3/api.page?page=get-known-colors
    
        .EXAMPLE
            PS> functionName
    
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ItemNumber,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ItemType]$Type = 'PART'
    )

    $ErrorActionPreference = 'Stop'

    InvokeBricklinkApiCall -Uri "items/$Type/$ItemNumber/colors"
}