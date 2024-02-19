function NewWantedListItemObject {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ItemId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [int]$WantedListId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [int]$ColorId,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [int]$WantedQty = -1,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [int]$WantedQtyFilled = 0,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Condition = 'X',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Notify = 'N',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Remarks = $null,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [int]$WantedPrice = '-1'
    )

    $ErrorActionPreference = 'Stop'

    $paramtoWantedStringMap = @{
        'WantedListId'    = 'wantedMoreID'
        'ItemId'          = 'wantedID'
        'ColorId'         = 'colorID'
        'WantedQty'       = 'wantedQty'
        'WantedQtyFilled' = 'wantedQtyFilled'
        'Condition'       = 'wantedNew'
        'Notify'          = 'wantedNotify'
        'Remarks'         = 'wantedRemarks'
        'WantedPrice'     = 'wantedPrice'
    }

    $wantedItem = @{}
    $paramtoWantedStringMap.GetEnumerator() | ForEach-Object {
        $wantedItem[$_.Value] = (Invoke-Expression "`$$($_.Key)")
    }
    [pscustomobject]$wantedItem
}