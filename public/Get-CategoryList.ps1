function Get-CategoryList {
    <#
        .SYNOPSIS
            https://www.bricklink.com/v3/api.page?page=get-category-list
    
        .EXAMPLE
            PS> functionName
    
    #>
    [CmdletBinding()]
    param
    ()

    $ErrorActionPreference = 'Stop'

    InvokeBricklinkApiCall -Uri 'categories'
}