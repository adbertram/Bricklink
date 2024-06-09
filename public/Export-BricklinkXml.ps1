<#
.SYNOPSIS
Exports Bricklink XML for inventory items.
.DESCRIPTION
Exports Bricklink XML for inventory items.
.PARAMETER InventoryItem
The inventory items to export.
.EXAMPLE
    Get-BlStoreInventories | select *,@{n='bulk';e={if ($_.unit_price -gt .25) { 1 } else { [int]([math]::ceiling((.25/$_.unit_price)))}}} -ExcludeProperty bulk | select -first 10 | Export-BLBricklinkXml | Set-Clipboard
.NOTES
    Go to https://www.bricklink.com/invXMLupdateVerify.asp to upload the XML
#>
function Export-BricklinkXml {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [pscustomobject[]]$InventoryItem
    )

    begin {
        $xml = New-Object System.Xml.XmlDocument
        $inventoryElement = $xml.CreateElement("INVENTORY")
        $xml.AppendChild($inventoryElement) | Out-Null
    }

    process {
        foreach ($item in $InventoryItem) {
            $itemElement = $xml.CreateElement("ITEM")
            
            $lotIdElement = $xml.CreateElement("LOTID")
            $lotIdElement.InnerText = $item.inventory_id
            $itemElement.AppendChild($lotIdElement) | Out-Null
            
            ## This just updates BULK for now. It can be updated to add other fields if needed.
            $bulkElement = $xml.CreateElement("BULK")
            $bulkElement.InnerText = $item.bulk
            $itemElement.AppendChild($bulkElement) | Out-Null
            
            $inventoryElement.AppendChild($itemElement) | Out-Null
        }
    }
    end {
        if ([System.Text.Encoding]::UTF8.GetByteCount($xml.OuterXml) -gt 1MB) {
            throw "The XML content exceeds the Bricklink maximum allowed size of 1MB."
        }
        $xml.OuterXml
    }
}