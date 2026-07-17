-- prop_hide (client) ─ hides configured static map props, and optionally deletes ambient
-- vehicle-type trailers inside configured zones. All behaviour is driven by config.lua.
--
-- Why CreateModelHide for map props? DeleteEntity does NOT reliably remove ymap-baked
-- geometry - the object streams straight back in on the next load. CreateModelHide is the
-- native meant for this. It is cheap and idempotent, but it does NOT survive a stream-out/in
-- cycle, so the main loop re-applies it while the player is near a blocker.

local vehHash = {}
for _, m in ipairs(Config.VehicleTrailerModels or {}) do
    vehHash[GetHashKey(m)] = true
end

local function inAabb(c, z)
    return c.x >= z.min.x and c.x <= z.max.x
       and c.y >= z.min.y and c.y <= z.max.y
       and c.z >= z.min.z and c.z <= z.max.z
end

local function zoneCentre(z)
    return vec3((z.min.x + z.max.x) * 0.5, (z.min.y + z.max.y) * 0.5, (z.min.z + z.max.z) * 0.5)
end

local function nuke(entity)
    NetworkRequestControlOfEntity(entity)
    SetEntityAsMissionEntity(entity, true, true)
    DeleteEntity(entity)
    if DoesEntityExist(entity) then SetEntityAsNoLongerNeeded(entity) end
end

CreateThread(function()
    while true do
        local pc     = GetEntityCoords(PlayerPedId())
        local active = false

        -- (1) static map props via CreateModelHide
        for _, b in ipairs(Config.Props or {}) do
            if #(pc - b.pos) < Config.ActivationRange then
                active = true
                CreateModelHide(b.pos.x, b.pos.y, b.pos.z, b.radius or 4.0, b.hash, false)
            end
        end

        -- (2) optional ambient vehicle-trailer cleanup inside zones
        if Config.VehicleZones and #Config.VehicleZones > 0 then
            local myVeh = GetVehiclePedIsIn(PlayerPedId(), false)
            for _, z in ipairs(Config.VehicleZones) do
                if #(pc - zoneCentre(z)) < Config.ActivationRange then
                    active = true
                    if z.suppressTraffic then
                        SetRoadsInArea(z.min.x, z.min.y, z.min.z, z.max.x, z.max.y, z.max.z, false, false)
                        SetAllVehicleGeneratorsActiveInArea(z.min.x, z.min.y, z.min.z, z.max.x, z.max.y, z.max.z, false, false)
                        RemoveVehiclesFromGeneratorsInArea(z.min.x, z.min.y, z.min.z, z.max.x, z.max.y, z.max.z, false)
                    end
                    for _, veh in ipairs(GetGamePool('CVehicle')) do
                        if DoesEntityExist(veh) and veh ~= myVeh
                            and not IsEntityAttached(veh)          -- not hitched to a truck
                            and GetPedInVehicleSeat(veh, -1) == 0  -- driverless
                            and vehHash[GetEntityModel(veh)]
                            and inAabb(GetEntityCoords(veh), z)
                        then
                            nuke(veh)
                        end
                    end
                end
            end
        end

        Wait(active and 1000 or 3000)
    end
end)

-- ── Diagnostic ───────────────────────────────────────────────────────────────
-- Triggered by the server-side (ACE-restricted) /prophideinfo command. Prints every
-- object + vehicle within 25m of the player to THIS client's F8 console, so you can
-- read off the hash and position of the prop you want to hide.
RegisterNetEvent('prop_hide:runInfo', function()
    local pc = GetEntityCoords(PlayerPedId())
    print(('==== prop_hide info @ %.2f, %.2f, %.2f ===='):format(pc.x, pc.y, pc.z))

    local function scan(pool, kind, named)
        local n = 0
        for _, e in ipairs(GetGamePool(pool)) do
            if DoesEntityExist(e) then
                local c = GetEntityCoords(e)
                local d = #(c - pc)
                if d < 25.0 then
                    n = n + 1
                    local model = GetEntityModel(e)
                    -- GetDisplayNameFromVehicleModel only resolves a name for vehicle models.
                    local name = named and GetDisplayNameFromVehicleModel(model) or '-'
                    print(('[%s] hash=%d name=%s dist=%.1f pos=%.2f,%.2f,%.2f'):format(
                        kind, model, tostring(name), d, c.x, c.y, c.z))
                end
            end
        end
        print(('---- %s: %d within 25m ----'):format(kind, n))
    end

    -- Objects first: a map-prop blocker is whatever OBJ sits closest (smallest dist) to you.
    scan('CObject', 'OBJ', false)
    scan('CVehicle', 'VEH', true)
    print('==== end prop_hide info ====')
    print('Add the closest matching line to Config.Props as { hash = <hash>, pos = vec3(<x>,<y>,<z>), radius = 4.0 } then restart the resource.')
end)
