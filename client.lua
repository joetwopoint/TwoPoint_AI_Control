-------------------------------------------------------------
-- TwoPoint AI Control - Client
-- Unified AI relationships, density, dispatch & cleanup
-------------------------------------------------------------

-- Configure in config.lua only.

-- =============================
-- AI RELATIONSHIPS / DENSITY / DISPATCH
-- =============================

-- Relationship setup (run once on start)
CreateThread(function()
    -- keep player neutral to self
    SetRelationshipBetweenGroups(2, `PLAYER`, `PLAYER`)

    -- civilians neutral to each other
    SetRelationshipBetweenGroups(1, `CIVMALE`, `CIVMALE`)
    SetRelationshipBetweenGroups(1, `CIVMALE`, `CIVFEMALE`)
    SetRelationshipBetweenGroups(1, `CIVFEMALE`, `CIVFEMALE`)
    SetRelationshipBetweenGroups(1, `CIVFEMALE`, `CIVMALE`)

    -- service groups
    SetRelationshipBetweenGroups(1, `COP`, `MEDIC`)
    SetRelationshipBetweenGroups(1, `MEDIC`, `COP`)
    SetRelationshipBetweenGroups(1, `FIREMAN`, `COP`)
    SetRelationshipBetweenGroups(1, `COP`, `FIREMAN`)
end)

-- Main density loop — must run every frame for *_ThisFrame natives
CreateThread(function()
    while true do
        Wait(0)
        local v = Config.VehDensity or 0.8
        local p = Config.PedDensity or 0.8
        local r = Config.RanVehDensity or 0.8
        local pa = Config.ParkCarDensity or 0.8
        local sp = Config.ScenePedDensity or 0.4

        -- per-frame multipliers
        SetVehicleDensityMultiplierThisFrame(v)
        SetPedDensityMultiplierThisFrame(p)
        SetRandomVehicleDensityMultiplierThisFrame(r)
        SetParkedVehicleDensityMultiplierThisFrame(pa)
        SetScenarioPedDensityMultiplierThisFrame(sp, sp)
        SetSomeVehicleDensityMultiplierThisFrame(v)
    end
end)

-- Dispatch / wanted — does not need to run every frame
CreateThread(function()
    if not Config.DispatchDead then return end
    -- disable all dispatch services once, then occasionally reinforce
    for i = 1, 15 do
        EnableDispatchService(i, false)
    end
    SetMaxWantedLevel(0)
    ClearPlayerWantedLevel(PlayerId())

    while true do
        Wait(5000)
        for i = 1, 15 do
            EnableDispatchService(i, false)
        end
        SetPlayerWantedLevel(PlayerId(), 0, false)
        SetPlayerWantedLevelNow(PlayerId(), false)
        SetPlayerWantedLevelNoDrop(PlayerId(), 0, false)
    end
end)

-- =============================
-- EMERGENCY CLEANUP (VEHICLES & PEDS)
-- =============================

Citizen.CreateThread(function()
    local vehicleModels = {
        "ambulance", "firetruk", "polmav", "police", "police2", "police3", "police4", "fbi", "fbi2", "policet", "policeb", "riot", "apc", "barracks", "barracks2", "barracks3", "rhino", "hydra", "lazer", "valkyrie", 
        "valkyrie2", "savage", "trailersmall2", "barrage", "chernobog", "khanjali", "menacer", "scarab", "scarab2", "scarab3", "armytanker", "avenger", "avenger2", "tula", "bombushka", "molotok", "volatol", "starling", 
        "mogul", "nokota", "strikeforce", "rogue", "cargoplane", "jet", "buzzard", "besra", "titan", "cargobob", "cargobob2", "cargobob3", "cargobob4", "akula", "hunt"
    }

    local pedModels = {
        "s_m_m_paramedic_01", "s_m_m_paramedic_02", "s_m_y_fireman_01", "s_m_y_pilot_01", "s_m_y_cop_01", "s_m_y_cop_02", "s_m_y_swat_01", "s_m_y_hwaycop_01", "s_m_y_marine_01", "s_m_y_marine_02", "s_m_y_marine_03", 
        "s_m_m_marine_01", "s_m_m_marine_02"
    }

    for _, modelName in ipairs(vehicleModels) do
        SetVehicleModelIsSuppressed(GetHashKey(modelName), true)
    end

    for _, modelName in ipairs(pedModels) do
        SetPedModelIsSuppressed(GetHashKey(modelName), true)
    end

while true do
    Citizen.Wait(1250) -- wait 1.250 seconds before running the loop again

    local playerPed = GetPlayerPed(-1)
    local playerLocalisation = GetEntityCoords(playerPed)
    ClearAreaOfCops(playerLocalisation.x, playerLocalisation.y, playerLocalisation.z, 400.0)

local vehicles = GetGamePool("CVehicle")
for i = 1, #vehicles do
    local vehicle = vehicles[i]
    local model = GetEntityModel(vehicle)

    for _, modelName in ipairs(vehicleModels) do
        if model == GetHashKey(modelName) then
            SetEntityAsMissionEntity(vehicle, true, true)
            DeleteVehicle(vehicle)
            break
        end
    end
end

local peds = GetGamePool("CPed")
for i = 1, #peds do
    local ped = peds[i]
    local model = GetEntityModel(ped)

    for _, modelName in ipairs(pedModels) do
        if model == GetHashKey(modelName) then
            SetEntityAsMissionEntity(ped, true, true)
            DeletePed(ped)
            break
        end
    end
end

    end
end)
-------------------------------------------------------------
-- TwoPoint AI Control - Emergency vehicle blocking logic
-- Helps NPC traffic brake before rear-ending stopped emergency vehicles
-------------------------------------------------------------

CreateThread(function()
    local scanInterval = 750 -- ms
    local brakeTask = 27    -- TASK_VEH_TEMP_ACTION: brake

    while true do
        Wait(scanInterval)

        -- Collect stopped emergency vehicles (class 18)
        local emergencyVehicles = {}
        local vehicles = GetGamePool("CVehicle")

        for _, veh in ipairs(vehicles) do
            if DoesEntityExist(veh) and not IsEntityDead(veh) then
                if GetVehicleClass(veh) == 18 and GetEntitySpeed(veh) < 1.0 then
                    emergencyVehicles[#emergencyVehicles + 1] = veh
                end
            end
        end

        if #emergencyVehicles == 0 then
            goto continue
        end

        -- For each NPC-driven vehicle, if it's closing on a blocked emergency unit, tap the brakes.
        for _, veh in ipairs(vehicles) do
            if DoesEntityExist(veh) and not IsEntityDead(veh) then
                local driver = GetPedInVehicleSeat(veh, -1)
                if driver ~= 0 and not IsPedAPlayer(driver) then
                    local vehPos = GetEntityCoords(veh)
                    local vehFwd = GetEntityForwardVector(veh)
                    local speed = GetEntitySpeed(veh)

                    if speed > 1.0 then
                        for _, blocker in ipairs(emergencyVehicles) do
                            if blocker ~= veh and DoesEntityExist(blocker) then
                                local blkPos = GetEntityCoords(blocker)
                                local toBlk = blkPos - vehPos
                                local dist = #(toBlk)

                                if dist < 30.0 then
                                    local mag = math.sqrt(toBlk.x * toBlk.x + toBlk.y * toBlk.y + toBlk.z * toBlk.z)
                                    if mag > 0.0 then
                                        local dirX = toBlk.x / mag
                                        local dirY = toBlk.y / mag
                                        local dirZ = toBlk.z / mag
                                        local dot = vehFwd.x * dirX + vehFwd.y * dirY + vehFwd.z * dirZ

                                        -- dot > 0.5 ~= roughly in front; distance < 9m = close enough to brake
                                        if dot > 0.5 and dist < 9.0 then
                                            TaskVehicleTempAction(driver, veh, brakeTask, 1000)
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        ::continue::
    end
end)
