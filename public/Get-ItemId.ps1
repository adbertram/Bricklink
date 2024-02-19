function Get-ItemId {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ItemNumber
    )

    $ErrorActionPreference = 'Stop'

    $invCallParams = @{
        Uri    = 'https://www.bricklink.com/v2/catalog/catalogitem.page'
        Body   = @{
            'P'       = $ItemNumber
            'idColor' = 0
        }
        Method = 'GET'
    }

    $response = InvokeBricklinkWebCall @invCallParams
    $response | Select-String -Pattern 'idItem:\s+(\d+)' | ForEach-Object { $_.matches[0].groups[1].value }
}