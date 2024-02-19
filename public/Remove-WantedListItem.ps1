function Remove-WantedListItem {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [int]$WantedItemId
    )

    $ErrorActionPreference = 'Stop'

    $invCallParams = @{
        Uri    = 'https://www.bricklink.com/ajax/clone/wanted/delete.ajax'
        Body   = @{
            wantedIDArrayStr = $WantedItemId
            num              = 1
        }
        Method = 'POST'
    }

    InvokeBricklinkWebCall @invCallParams
}