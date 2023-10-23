local CHAR = ix.meta.character

function CHAR:HasDoorAccess(door)
    local inv = self:GetInventory()
    if not inv then return false end
    local bKeys = inv:HasItems({"keys"})
    if not bKeys then return false end
    for _, v in pairs(inv:GetItems(false)) do
        if v.uniqueID != "keys" then continue end
        if v:CanInteractDoor(door) then
            return true
        end
    end
end