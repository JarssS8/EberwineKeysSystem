local PLUGIN = PLUGIN
PLUGIN.name = "Eberwine Keys System"
PLUGIN.description = "Adds a keys system to the server."
PLUGIN.author = "JarssS8"
PLUGIN.tempDoors = PLUGIN.tempDoors or {}
PLUGIN.PreloadedKeys = {
    -- You can use this to preload keys for setup multiple doors with the same key and spawn it with a command. Follow the example below.
    -- PROFESORADO = {
    --     [2194] = true, -- https://wiki.facepunch.com/gmod/Entity:MapCreationID for the key
    -- }
    -- Check commands GetPreloadedKeys, CreateCustomKey, AddDoorToTempTable and CopyDoorTempTable to help you with this.
}

function PLUGIN:CanTransferItem(itemObject, curInv, inventory)
    if curInv.vars and curInv.vars.allowedItems and not curInv.vars.allowedItems[itemObject.uniqueID] then
        itemObject:GetOwner():Notify("Solo puedes guardar llaves en este inventario.")
        return false
    end
    if inventory.vars and inventory.vars.allowedItems and not inventory.vars.allowedItems[itemObject.uniqueID] then
        itemObject:GetOwner():Notify("Solo puedes guardar llaves en este inventario.")
        return false
    end
end

ix.util.Include("sh_commands.lua")
ix.util.Include("sh_meta.lua")