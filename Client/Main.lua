local RegisteredVehicles = {}
function RegisterVehicle(spawnCode, spotlightData, controlsData, takedownData)
    RegisteredVehicles[GetHashKey(spawnCode)] = {
        spotlight = spotlightData,
        controls = controlsData,
        takedown = takedownData
    }
end

local function lookupVehicle(vehicleEntity)
    return RegisteredVehicles[GetEntityModel(vehicleEntity)]
end

function GetVehicleControlsData(vehicleEntity, index)
    local vehicleData = RegisteredVehicles[GetEntityModel(vehicleEntity)]
    if vehicleData == nil then return nil end

    if index == 4 then
        return { vehicleData.takedown.extra }
    else
        local controlsData = vehicleData.controls
        if controlsData == nil then return nil end
        return controlsData[index]
    end
end

---Quick gets for toggle control functions.
---@return Entity|nil playerVeh
---@return table|nil vehicleData
---@return boolean|nil playerIsDriver
local function toggleControlQuickGet()
    local playerPed = PlayerPedId()
    local playerVeh = GetVehiclePedIsIn(playerPed, false)
    local playerIsDriver = false

    if DoesEntityExist(playerVeh) then
        local driverEntity = GetPedInVehicleSeat(playerVeh, -1)

        if driverEntity == playerPed then
            playerIsDriver = true
        end
    else
        playerVeh = nil
    end

    return playerVeh, lookupVehicle(playerVeh), playerIsDriver
end

--- This is the main thread for rendering the lights.
Citizen.CreateThread(function()
    while true do
        Wait(0)

        for _, vehicle in pairs(GetGamePool("CVehicle")) do
            local vehicleData = lookupVehicle(vehicle)

            if vehicleData ~= nil and GetIsVehicleEngineRunning(vehicle) then
                local _, _, on = GetVehicleLightsState(vehicle)
                -- Spotlight
                if vehicleData.spotlight ~= nil then
                    local spotlightData = vehicleData.spotlight
                    if IsVehicleExtraTurnedOn(vehicle, spotlightData.extra) then
                        if on == 1 then
                            local bIndex = GetEntityBoneIndexByName(vehicle, "extralight_" .. spotlightData.bone)
                            local bPos = GetWorldPositionOfEntityBone(vehicle, bIndex)
                            local ePos = GetEntityBoneOffset(vehicle, bIndex, 0.0, 5.0, 1.0)
                            local vDir = ePos - bPos

                            DrawSpotLightWithShadow(bPos[1], bPos[2], bPos[3], vDir[1], vDir[2], vDir[3],
                                SPOTLIGHT_CONFIG.Color[1], SPOTLIGHT_CONFIG.Color[2], SPOTLIGHT_CONFIG.Color[3],
                                SPOTLIGHT_CONFIG.Distance, SPOTLIGHT_CONFIG.Brightness, SPOTLIGHT_CONFIG.Roundness,
                                SPOTLIGHT_CONFIG.Radius, SPOTLIGHT_CONFIG.Falloff, vehicle) -- Shadow ID Used to be 0
                        end
                    end
                end

                -- Takedown
                if vehicleData.takedown ~= nil then
                    local takedownData = vehicleData.takedown
                    if IsVehicleExtraTurnedOn(vehicle, takedownData.extra) then
                        if (takedownData.requires_highbeans and on == 1) or (not takedownData.requires_highbeans) then
                            local bIndex = GetEntityBoneIndexByName(vehicle, "extra_" .. tostring(takedownData.extra))
                            local bPos = GetEntityBoneOffset(vehicle, bIndex, 0.0, 0.5, 1.0)
                            local ePos = GetEntityBoneOffset(vehicle, bIndex, 0.0, 5.0, 1.0)
                            local vDir = ePos - bPos

                            DrawSpotLightWithShadow(bPos[1], bPos[2], bPos[3], vDir[1], vDir[2], vDir[3],
                                TAKEDOWN_CONFIG.Color[1], TAKEDOWN_CONFIG.Color[2], TAKEDOWN_CONFIG.Color[3],
                                TAKEDOWN_CONFIG.Distance, TAKEDOWN_CONFIG.Brightness, TAKEDOWN_CONFIG.Roundness,
                                TAKEDOWN_CONFIG.Radius, TAKEDOWN_CONFIG.Falloff, vehicle * 10) -- Shadow ID Used to be 0
                        end
                    end
                end
            end
        end
    end
end)

RegisterKeyMappingEvent("togglecontrol1", "Toggle Light Option 1", "INSERT", function(src, args, raw)
    local playerVehicle, vehicleData, playerIsDriver = toggleControlQuickGet()

    if vehicleData and vehicleData.controls and vehicleData.controls[1] and playerIsDriver then
        ToggleExtraState(playerVehicle, 1)
    end
end)

RegisterKeyMappingEvent("togglecontrol2", "Toggle Light Option 2", "HOME", function(src, args, raw)
    local playerVehicle, vehicleData, playerIsDriver = toggleControlQuickGet()

    if vehicleData and vehicleData.controls and vehicleData.controls[2] and playerIsDriver then
        ToggleExtraState(playerVehicle, 2)
    end
end)

RegisterKeyMappingEvent("togglecontrol3", "Toggle Takedowns", "DELETE", function(src, args, raw)
    local playerVehicle, vehicleData, playerIsDriver = toggleControlQuickGet()

    if vehicleData and vehicleData.takedown and playerIsDriver then
        local areOn = GetExtraState(playerVehicle, 4)
        SetExtraState(playerVehicle, 4, not areOn) -- 4 because 3 is reserved for automatic child with 1 & 2 are on.

        if vehicleData.takedown.disables then
            if areOn == false then
                for _, index in pairs(vehicleData.takedown.disables) do
                    OverrideExtraState(playerVehicle, index, false)
                end
            else
                for _, index in pairs(vehicleData.takedown.disables) do
                    ClearOverrideExtraState(playerVehicle, index)
                end
            end
        end
    end
end)
