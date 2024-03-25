<#
.SYNOPSIS
Updates one or more items in a wanted list on BrickLink.

.DESCRIPTION
The Update-WantedListItem function allows you to update various properties of one or more items in a wanted list on BrickLink. You can update the condition, notification setting, quantity filled, remarks, static price, or set the price to the last 6 months average value.

.PARAMETER WantedListItem
The wanted list item(s) to update. This parameter is mandatory and accepts pipeline input.

.PARAMETER Condition
The new condition for the wanted list item(s).

.PARAMETER Notify
A boolean value indicating whether to enable or disable notifications for the wanted list item(s).

.PARAMETER QuantityFilled
The new quantity filled for the wanted list item(s).

.PARAMETER Remarks
The new remarks for the wanted list item(s).

.PARAMETER StaticPrice
The new static price for the wanted list item(s). This parameter is part of the 'StaticPrice' parameter set.

.PARAMETER Last6MonthsAvgValuePrice
A switch parameter that sets the price of the wanted list item(s) to the last 6 months average value. This parameter is part of the 'Last6MonthsAvgValuePrice' parameter set.

.EXAMPLE
$wantedListItem | Update-WantedListItem -Condition 'Used'

This example updates the condition of the wanted list item(s) in the pipeline to 'Used'.

.EXAMPLE
Update-WantedListItem -WantedListItem $wantedListItems -Last6MonthsAvgValuePrice

This example updates the price of the wanted list item(s) in the $wantedListItems variable to the last 6 months average value.

.NOTES
This function requires the InvokeBricklinkWebCall function to make API calls to BrickLink.
Wanted list items can only be updated for a single wanted list at a time.
Multiple wanted list items at once are only supported for updating the price to the last 6 months average value.
#>
function Update-WantedListItem {
    [CmdletBinding(DefaultParameterSetName = 'None')]
    param
    (

        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [pscustomobject[]]$WantedListItem,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Condition,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [bool]$Notify,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [int]$QuantityFilled,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Remarks,

        [Parameter(ParameterSetName = 'StaticPrice')]
        [ValidateNotNullOrEmpty()]
        [decimal]$StaticPrice,

        [Parameter(ParameterSetName = 'Last6MonthsAvgValuePrice')]
        [ValidateNotNullOrEmpty()]
        [switch]$Last6MonthsAvgValuePrice
    )

    begin {
        $ErrorActionPreference = 'Stop'
    }
    
    process {

        $wlItemsByWl = $WantedListItem | Group-Object wantedMoreId
        if (@($wlItemsByWl).Count -gt 1) {
            throw "Wanted list items can only be updated on a single wanted list at a time."
        }

        ## Multiple wanted list items at once are only supported by updating the last 6 months avg price since the API
        ## call is different
        if ($WantedListItem.Count -gt 1 -and $PSCmdlet.ParameterSetName -ne 'Last6MonthsAvgValuePrice') {
            throw "Multiple wanted list items at once are only supported for updating the price to the last 6 months avg value."
        }

        if ($Last6MonthsAvgValuePrice.IsPresent) {
            $invCallParams = @{
                Uri    = 'https://www.bricklink.com/ajax/clone/wanted/price.ajax'
                Method = 'POST'
                Body   = @{
                    mode             = 1
                    modeVal          = 1
                    wantedMoreId     = -1
                    wantedIDArrayStr = $WantedListItem.wantedId -join ','
                }
            }
        } else {
            $itemToUpdate = @{
                wantedID     = $WantedListItem.wantedID
                colorID      = $WantedListItem.colorID
                wantedMoreID = $WantedListItem.wantedMoreID
                wantedQty    = $WantedListItem.wantedQty ## Always keep the wantedQty the same to reuse wanted lists
            }
    
            $paramToWiMap = @{
                QuantityFilled = "wantedQtyFilled"
                Remarks        = "wantedRemarks"
                StaticPrice    = 'wantedPrice'
            }

            $PSBoundParameters.GetEnumerator().where({ $_.Key -notin @('WantedListItem', 'Last6MonthsAvgValuePrice') }).foreach({
                    $itemToUpdate[$paramToWiMap[$_.Key]] = $_.Value
                })
            
            if ($Notify) {
                $itemToUpdate['wantedNotify'] = 'Y'
            }
            $wli = , @($itemToUpdate) | ConvertTo-Json
            $invCallParams = @{
                Uri    = 'https://www.bricklink.com/ajax/clone/wanted/edit.ajax'
                Method = 'POST'
                Body   = @{
                    wantedItemStr = $wli
                }
            }
        }
        
        $null = InvokeBricklinkWebCall @invCallParams

    }
}