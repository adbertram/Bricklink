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
        $xml.OuterXml
    }
}