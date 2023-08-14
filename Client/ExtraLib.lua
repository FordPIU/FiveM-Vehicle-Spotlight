local ExtraStates = {}
local Extras = {}

function ToggleExtra(vehicle, extraId, value)
    Extras[vehicle] = Extras[vehicle] or {}
    Extras[vehicle][extraId] = Extras[vehicle][extraId] or { enabled = false, overriden = false }
    Extras[vehicle][extraId].enabled = value

    if not Extras[vehicle][extraId].overriden then
        SetVehicleExtra(vehicle, extraId, not value)
    end
end

function GetExtraState(vehicle, index)
    ExtraStates[vehicle] = ExtraStates[vehicle] or {}
    ExtraStates[vehicle][index] = ExtraStates[vehicle][index] or false
    return ExtraStates[vehicle][index]
end

function SetExtraState(vehicle, index, value)
    ExtraStates[vehicle] = ExtraStates[vehicle] or {}
    ExtraStates[vehicle][index] = value

    local extrasToToggle = GetVehicleControlsData(vehicle, index)
    if extrasToToggle == nil then return end
    for _, extra in pairs(extrasToToggle) do
        ToggleExtra(vehicle, extra, value)
    end

    if index == 1 or index == 2 then
        -- If we are toggling on this indexs extras
        if value == true then
            local secondIndex = index == 1 and 2 or index == 2 and 1
            local secondIndexState = GetExtraState(vehicle, secondIndex)

            -- If the sibling state is also on, than we turn on state 3.
            if secondIndexState == true then
                SetExtraState(vehicle, 3, true)
            end
        else
            -- If we arent toggling this indexs extras, and index 3 is on, than turn index 3 off.
            if GetExtraState(vehicle, 3) == true then
                SetExtraState(vehicle, 3, false)
            end
        end
    end
end

function ToggleExtraState(vehicle, index)
    local currentState = GetExtraState(vehicle, index)
    SetExtraState(vehicle, index, not currentState)
end

function OverrideExtraState(vehicle, index, overrideValue)
    -- Get the extras for the overriden index
    local extrasToToggle = GetVehicleControlsData(vehicle, index)
    if extrasToToggle == nil then return end
    for _, extraId in pairs(extrasToToggle) do
        Extras[vehicle] = Extras[vehicle] or {}
        Extras[vehicle][extraId] = Extras[vehicle][extraId] or { enabled = false, overriden = false }
        Extras[vehicle][extraId].overriden = true

        SetVehicleExtra(vehicle, extraId, not overrideValue)
    end
end

function ClearOverrideExtraState(vehicle, index)
    -- Get the extras for the overriden index
    local extrasToToggle = GetVehicleControlsData(vehicle, index)
    if extrasToToggle == nil then return end
    for _, extraId in pairs(extrasToToggle) do
        Extras[vehicle] = Extras[vehicle] or {}
        Extras[vehicle][extraId] = Extras[vehicle][extraId] or { enabled = false, overriden = false }
        Extras[vehicle][extraId].overriden = false

        SetVehicleExtra(vehicle, extraId, not Extras[vehicle][extraId].enabled)
    end
end

function IsExtraStateOverridden(vehicle, index)
    local extrasToToggle = GetVehicleControlsData(vehicle, index)
    if extrasToToggle == nil then return end
    for _, extraId in pairs(extrasToToggle) do
        Extras[vehicle] = Extras[vehicle] or {}
        Extras[vehicle][extraId] = Extras[vehicle][extraId] or { enabled = false, overriden = false }

        if Extras[vehicle][extraId].overriden == true then
            return true
        end
    end

    return false
end
