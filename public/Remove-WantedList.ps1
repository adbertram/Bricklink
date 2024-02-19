function Remove-WantedList {
    [CmdletBinding()]
    param
    (

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [int]$WantedListId
    )

    $ErrorActionPreference = 'Stop'

    $invCallParams = @{
        Uri    = 'https://www.bricklink.com/ajax/clone/wanted/editList.ajax'
        Body   = @{
            wantedMoreID = $WantedListId
            action       = 'D'
        }
        Method = 'POST'
    }

    InvokeBricklinkWebCall @invCallParams
}