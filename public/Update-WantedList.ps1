<#
.SYNOPSIS
Updates an existing wanted list on BrickLink.

.DESCRIPTION
The Update-WantedList function allows you to update the name, ID, and remarks of an existing wanted list on BrickLink.

.PARAMETER Name
The new name for the wanted list.

.PARAMETER Id
The ID of the wanted list to update.

.PARAMETER Remarks
The new remarks or description for the wanted list.

.EXAMPLE
Update-WantedList -Name 'Updated Wanted List' -Id 12345

This example updates the name of the wanted list with ID 12345 to 'Updated Wanted List'.

.EXAMPLE
Update-WantedList -Id 12345 -Remarks 'These are my updated remarks for the wanted list.'

This example updates the remarks or description of the wanted list with ID 12345 to 'These are my updated remarks for the wanted list.'.

.EXAMPLE
Update-WantedList -Name 'New List Name' -Id 12345 -Remarks 'Updated remarks'

This example updates the name to 'New List Name', the ID to 12345, and the remarks to 'Updated remarks' for the specified wanted list.

.NOTES
This function requires the InvokeBricklinkWebCall function to make API calls to BrickLink.
At least one of the Name, Id, or Remarks parameters must be provided.
#>
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