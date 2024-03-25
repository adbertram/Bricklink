<#
.SYNOPSIS
Creates a new wanted list on BrickLink.

.DESCRIPTION
The New-WantedList function creates a new empty wanted list on BrickLink with the specified name.

.PARAMETER Name
The name of the wanted list to create. This parameter is mandatory.

.EXAMPLE
New-WantedList -Name 'My Wanted List'

This example creates a new wanted list on BrickLink with the name 'My Wanted List'.

.NOTES
This function requires the InvokeBricklinkWebCall function to make API calls to BrickLink.
#>
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