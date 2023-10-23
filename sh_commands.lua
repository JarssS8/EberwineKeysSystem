local PLUGIN = PLUGIN
ix.command.Add(
    "AddDoorToTempTable",
    {
        description = "Adds a door to the temporary table.",
        arguments = ix.type.string,
        adminOnly = true,
        OnRun = function(self, client, key)
            if not PLUGIN.tempDoors then
                PLUGIN.tempDoors = {}
            end

            if not key or key == "" then
                client:Notify("You must specify a key.")

                return
            end

            key = key:lower()
            key = string.Trim(key)
            local trace = client:GetEyeTraceNoCursor()
            local door = trace.Entity
            if IsValid(door) and door:IsDoor() then
                if not PLUGIN.tempDoors[key] then
                    PLUGIN.tempDoors[key] = {}
                end

                local mapCreationID = door:MapCreationID()
                PLUGIN.tempDoors[key][mapCreationID] = true
                client:Notify("Door added to the temporary table with key " .. key .. ".")
            else
                client:Notify("You must be looking at a door.")
            end
        end
    }
)

ix.command.Add(
    "CopyDoorTempTable",
    {
        description = "Copies the temporary table to the permanent table.",
        adminOnly = true,
        arguments = ix.type.string,
        OnRun = function(self, client, key)
            if not PLUGIN.tempDoors then
                PLUGIN.tempDoors = {}
            end

            if not key or key == "" then
                client:Notify("You must specify a key.")

                return
            end

            key = key:lower()
            key = string.Trim(key)
            if not PLUGIN.tempDoors[key] then
                client:Notify("There is no temporary table with that key.")

                return
            end

            local data = util.TableToJSON(PLUGIN.tempDoors[key])
            netstream.Start(client, "ixCopyText", data)
            client:Notify("Temporary table copied to clipboard.")
        end
    }
)

ix.command.Add(
    "CreateCustomKey",
    {
        description = "Creates a custom key.",
        adminOnly = true,
        arguments = ix.type.string,
        OnRun = function(self, client, key)
            key = key or ""
            key = key:upper()
            key = string.Trim(key)
            if key == "" then
                client:Notify("You must specify a key.")
            end

            if not PLUGIN.PreloadedKeys[key] and table.Count(PLUGIN.PreloadedKeys[key]) > 0 then
                client:Notify("That key does not exist in the preloaded keys.")

                return
            end

            local data = PLUGIN.PreloadedKeys[key]
            local char = client:GetCharacter()
            if not char then
                client:Notify("You must have a character to create a key.")

                return
            end

            local inv = char:GetInventory()
            if not inv then
                client:Notify("You must have an inventory to create a key.")

                return
            end

            if not inv:FindEmptySlot(1, 1, false) then
                client:Notify("No tienes espacio en el inventario.")

                return
            end

            local bSuccess = inv:Add(
                "keys",
                1,
                {
                    ["customName"] = data.name,
                    ["customDesc"] = data.description,
                    ["doors"] = data.doors
                }
            )

            if bSuccess then
                client:Notify("Has creado la llave, se ha guardado en tu inventario.")
            else
                client:Notify("Algo ha ido mal, checkea la consola.")
            end
        end
    }
)

ix.command.Add(
    "GetPreloadedKeys",
    {
        description = "Gets the preloaded keys.",
        adminOnly = true,
        OnRun = function(self, client)
            local keys = table.GetKeys(PLUGIN.PreloadedKeys)
            local data = util.TableToJSON(keys)
            client:ChatPrint(data)
        end
    }
)