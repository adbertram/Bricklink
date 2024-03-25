<#
.SYNOPSIS
Removes a wanted list from BrickLink.

.DESCRIPTION
The Remove-WantedList function removes a wanted list from BrickLink's website. It sends a request to the BrickLink website to delete the specified wanted list based on the provided ID.

.PARAMETER WantedListId
Specifies the ID of the wanted list to remove.

.EXAMPLE
Remove-WantedList -WantedListId 12345
Removes the wanted list with ID "12345" from BrickLink.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
None. The function does not generate any output.

.NOTES
The function relies on the InvokeBricklinkWebCall function to make the HTTP request to the BrickLink website.
#>

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