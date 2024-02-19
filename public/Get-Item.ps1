function Get-Item {
    <#
        .SYNOPSIS
            https://www.bricklink.com/v3/api.page?page=get-item
    
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
        [string]$ItemNumber
    )

    $ErrorActionPreference = 'Stop'

    $invApiParams = @{
        Uri = "items/$Type/$ItemNumber"
    }

    InvokeBricklinkApiCall @invApiParams
}