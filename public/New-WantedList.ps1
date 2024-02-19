function New-WantedList {
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    $ErrorActionPreference = 'Stop'

    $invCallParams = @{
        Uri    = 'https://www.bricklink.com/ajax/clone/wanted/editList.ajax'
        Body   = @{
            'wantedMoreName' = $Name
            'wantedMoreDesc' = $null
            'action'         = 'C'
        }
        Method = 'POST'
    }

    InvokeBricklinkWebCall @invCallParams
}