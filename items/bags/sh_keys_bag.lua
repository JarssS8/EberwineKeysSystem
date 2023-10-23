ITEM.name = "Llavero"
ITEM.description = "Una bolsita donde guardas hasta 6 llaves."
ITEM.model = "models/props_clutter/coin_bag_small.mdl"
ITEM.invWidth = 3
ITEM.invHeight = 2
ITEM.width = 1
ITEM.height = 1
ITEM.weight = 0.5
ITEM.allowedItems = {keys = true}
function ITEM:OnInstanced(invID, x, y)
    local inventory = ix.item.inventories[invID]
    ix.inventory.New(
        inventory and inventory.owner or 0,
        self.uniqueID,
        function(inv)
            local client = inv:GetOwner()
            inv.vars.isBag = self.uniqueID
            inv.vars.allowedItems = self.allowedItems
            self:SetData("id", inv:GetID())
            if IsValid(client) then
                inv:AddReceiver(client)
            end
        end
    )
end