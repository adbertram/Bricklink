<#
.SYNOPSIS
Removes a wanted list item from BrickLink.

.DESCRIPTION
The Remove-WantedListItem function removes a specific wanted list item from BrickLink's website. It sends a request to the BrickLink website to delete the specified wanted list item based on the provided ID.

.PARAMETER WantedItemId
Specifies the ID of the wanted list item to remove.

.EXAMPLE
Remove-WantedListItem -WantedItemId 12345
Removes the wanted list item with ID "12345" from BrickLink.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
None. The function does not generate any output.

.NOTES
The function relies on the InvokeBricklinkWebCall function to make the HTTP request to the BrickLink website.
#>

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