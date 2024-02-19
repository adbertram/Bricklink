function Update-WantedList {
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [int]$Id,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Remarks
    )

    $ErrorActionPreference = 'Stop'

    $invCallParams = @{
        Uri    = 'https://www.bricklink.com/ajax/clone/wanted/editList.ajax'
        Body   = @{
            'wantedMoreName' = $Name
            'wantedMoreID'   = $Id
            'action'         = 'E'
        }
        Method = 'POST'
    }

    if ($PSBoundParameters.ContainsKey('Remarks')) {
        $invCallParams.Body['wantedMoreDesc'] = $Remarks
    }

    InvokeBricklinkWebCall @invCallParams
}