ITEM.name = "Llave Base"
ITEM.description = "Una llave de metal, no parece tener ningun uso."
ITEM.model = "models/spartex117/key.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.weight = 0.3
ITEM.duration = 60 * 60 * 24 * 14 -- 2 week
function ITEM:GetName()
    if self:GetData("customName", nil) then return self:GetData("customName") end
end

function ITEM:GetDescription()
    if self:GetData("customDesc", nil) then return self:GetData("customDesc") end
end

function ITEM:GetDoors()
    return self:GetData("doors", {})
end

function ITEM:GetModel()
    return self:GetData("model", self.model)
end

function ITEM:SetDoors(doors)
    if istable(doors) then
        self:SetData("doors", doors)
    end
end

function ITEM:PaymentRequired()
    return self:GetData("paymentRequired", false)
end

function ITEM:CanInteractDoor(door)
    if not IsValid(door) or not door:IsDoor() or self:PaymentRequired() then return false end
    local doors = self:GetDoors()
    if not doors[door:MapCreationID()] then return false end

    return true
end

function ITEM:CanChangeName()
    return self:GetData("canChangeName", true)
end

function ITEM:SetCanChangeName(bCanChangeName)
    self:SetData("canChangeName", bCanChangeName)
end

if CLIENT then
    netstream.Hook(
        "ixEditKeyData",
        function(tittle, desc, key, id)
            Derma_StringRequest(
                tittle,
                desc,
                "",
                function(text)
                    if text and text ~= "" then
                        text = string.Trim(text)
                        netstream.Start("ixEditKeyData", id, key, text)
                    end
                end, nil, "Cambiar", "Cancelar"
            )
        end
    )

    netstream.Hook(
        "ixCopyText",
        function(str)
            SetClipboardText(str)
        end
    )

    netstream.Hook(
        "ixPasteText",
        function(id)
            Derma_StringRequest(
                "Pegar Puertas del Portapapeles",
                "Pega aqui el texto que has copiado del portapapeles.",
                "",
                function(text)
                    if text and text ~= "" then
                        text = string.Trim(text)
                        local doors = util.JSONToTable(text)
                        if doors then
                            netstream.Start("ixPasteText", doors, id)
                        end
                    end
                end, nil, "Pegar", "Cancelar"
            )
        end
    )
else
    netstream.Hook(
        "ixEditKeyData",
        function(client, id, key, text)
            local item = ix.item.instances[id]
            if not item then return end
            item:SetData(key, text)
            client:Notify("Has cambiado el " .. key .. " de la llave a " .. text .. ".")
        end
    )

    netstream.Hook(
        "ixPasteText",
        function(client, doors, id)
            local item = ix.item.instances[id]
            if not item then return end
            item:SetDoors(doors)
            client:Notify("Has pegado las puertas del portapapeles a la llave.")
        end
    )
end

ITEM.functions.SetName = {
    name = "Poner Nombre",
    OnRun = function(item)
        netstream.Start(item.player, "ixEditKeyData", "Nombre de la llave", "Escribe aqui el nombre que le quieres poner a la llave", "customName", item:GetID())

        return false
    end,
    OnCanRun = function(item) return item:CanChangeName() or item.player:IsStaff() end
}

ITEM.functions.CanChangeName = {
    name = "Dejar al usuario cambiar el nombre",
    OnRun = function(item)
        item:SetCanChangeName(true)
        item.player:Notify("Ahora puedes cambiar el nombre de la llave.")

        return false
    end,
    OnCanRun = function(item) return item.player:IsStaff() and not item:CanChangeName() end
}

ITEM.functions.CantChangeName = {
    name = "No dejar al usuario cambiar el nombre",
    OnRun = function(item)
        item:SetCanChangeName(false)
        item.player:Notify("Ahora no puedes cambiar el nombre de la llave.")

        return false
    end,
    OnCanRun = function(item) return item.player:IsStaff() and item:CanChangeName() end
}

ITEM.functions.SetDesc = {
    name = "Poner Descripcion",
    OnRun = function(item)
        netstream.Start(item.player, "ixEditKeyData", "Descripcion de la llave", "Escribe aqui la descripcion que le quieres poner a la llave", "customDesc", item:GetID())

        return false
    end,
    OnCanRun = function(item) return item.player:IsStaff() end
}

ITEM.functions.SetModel = {
    name = "Poner Modelo",
    OnRun = function(item)
        netstream.Start(item.player, "ixEditKeyData", "Modelo de la llave", "Escribe aqui el modelo que le quieres poner a la llave", "model", item:GetID())

        return false
    end,
    OnCanRun = function(item) return item.player:IsStaff() end
}

ITEM.functions.AddDoor = {
    name = "Añadir Puerta",
    OnRun = function(item)
        local trace = item.player:GetEyeTraceNoCursor()
        local door = trace.Entity
        if IsValid(door) and door:IsDoor() then
            local doors = item:GetDoors()
            doors[door:MapCreationID()] = true
            item:SetDoors(doors)
            item.player:Notify("Has añadido la puerta " .. door:MapCreationID() .. " a la llave.")
        end

        return false
    end,
    OnCanRun = function(item)
        local trace = item.player:GetEyeTraceNoCursor()
        local door = trace.Entity
        if not IsValid(door) or not door:IsDoor() then return false end

        return item.player:IsStaff()
    end
}

ITEM.functions.RemoveDoor = {
    name = "Quitar Puerta",
    OnRun = function(item)
        local trace = item.player:GetEyeTraceNoCursor()
        local door = trace.Entity
        if IsValid(door) and door:IsDoor() then
            local doors = item:GetDoors()
            if not doors[door:MapCreationID()] then
                item.player:Notify("Esta puerta no esta en la llave.")

                return false
            end

            doors[door:MapCreationID()] = nil
            item:SetDoors(doors)
            item.player:Notify("Has quitado la puerta " .. door:MapCreationID() .. " de la llave.")
        else
            item.player:Notify("No estas mirando una puerta.")
        end

        return false
    end,
    OnCanRun = function(item)
        local trace = item.player:GetEyeTraceNoCursor()
        local door = trace.Entity
        if not IsValid(door) or not door:IsDoor() then return false end

        return item.player:IsStaff()
    end
}

ITEM.functions.RemoveDoors = {
    name = "Quitar Todas las Puertas",
    OnRun = function(item)
        item:SetDoors({})
        item.player:Notify("Has quitado todas las puertas de la llave.")

        return false
    end,
    OnCanRun = function(item) return item.player:IsStaff() end
}

ITEM.functions.CopyDoorsClipboard = {
    name = "Copiar Puertas al Portapapeles",
    OnRun = function(item)
        local doors = item:GetDoors()
        local str = util.TableToJSON(doors)
        netstream.Start(item.player, "ixCopyText", str)
        item.player:Notify("Has copiado las puertas de la llave al portapapeles.")

        return false
    end,
    OnCanRun = function(item) return item.player:IsStaff() end
}

ITEM.functions.PasteDoorsClipboard = {
    name = "Pegar Puertas del Portapapeles",
    OnRun = function(item)
        netstream.Start(item.player, "ixPasteText", item:GetID())

        return false
    end,
    OnCanRun = function(item) return item.player:IsStaff() end
}

ITEM.functions.DuplicateKey = {
    name = "Duplicar Llave",
    OnRun = function(item)
        local char = item.player:GetCharacter()
        local inv = char:GetInventory()
        if not inv then return end
        if not inv:FindEmptySlot(item.width, item.height, false) then
            item.player:Notify("No tienes espacio en el inventario.")

            return
        end

        local bSuccess = inv:Add(
            "keys",
            1,
            {
                ["customName"] = item:GetName(),
                ["customDesc"] = item:GetDescription(),
                ["doors"] = item:GetDoors(),
                ["paymentRequired"] = item:PaymentRequired()
            }
        )

        if bSuccess then
            item.player:Notify("Has duplicado la llave, se ha guardado en tu inventario.")
        else
            item.player:Notify("Algo ha ido mal, checkea la consola.")
        end

        return false
    end,
    OnCanRun = function(item) return item.player:IsStaff() end
}