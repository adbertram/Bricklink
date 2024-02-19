function Update-WantedListItem {
    [CmdletBinding(DefaultParameterSetName='None')]
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