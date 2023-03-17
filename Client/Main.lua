local SpotlightVehicles = {
    [`legacy1bb`] = {
        extras = {
            SpotlightUp = 12,
        },
        bone = "extralight_1",
    },
    [`legacy2bb`] = {
        extras = {
            SpotlightUp = 12,
        },
        bone = "extralight_3",
    },
    [`legacy3bb`] = {
        extras = {
            SpotlightUp = 12,
        },
        bone = "extralight_3",
    },
    [`legacy4bb`] = {
        extras = {
            SpotlightUp = 12,
        },
        bone = "extralight_1",
    },
    [`legacy5bb`] = {
        extras = {
            SpotlightUp = 12,
        },
        bone = "extralight_1",
    },
    [`legacy6bb`] = {
        extras = {
            SpotlightUp = 12,
        },
        bone = "extralight_3",
    },
    [`legacy7bb`] = {
        extras = {
            SpotlightUp = 12,
        },
        bone = "extralight_3",
    },
    [`legacy8bb`] = {
        extras = {
            SpotlightUp = 12,
        },
        bone = "extralight_3",
    },
    [`legacy9bb`] = {
        extras = {
            SpotlightUp = 12,
        },
        bone = "extralight_1",
    },
    [`legacy10bb`] = {
        extras = {
            SpotlightUp = 12,
        },
        bone = "extralight_1",
    },
    [`legacy11bb`] = {
        extras = {
            SpotlightUp = 12,
        },
        bone = "extralight_3",
    },
    [`legacy12bb`] = {
        extras = {
            SpotlightUp = 12,
        },
        bone = "extralight_3",
    },
    [`legacy13bb`] = {
        extras = {
            SpotlightUp = 12,
        },
        bone = "extralight_3",
    },
    [`legacy14bb`] = {
        extras = {
            SpotlightUp = 12,
        },
        bone = "extralight_1",
    },
    [`legacy15bb`] = {
        extras = {
            SpotlightUp = 12,
        },
        bone = "extralight_3",
    }
}

local SpotlightConfig = {
    Color = {255, 255, 255},
    Distance = 60.0,
    Brightness = 1.2, -- 1.0
    Roundness = 2.0,
    Radius = 30.0,
    Falloff = 0.5,
}

local function getEntityMatrix(element, elementbone)
    local rot = GetEntityBoneRotation(element, elementbone) -- ZXY
    local rx, ry, rz = rot.x, rot.y, rot.z
    rx, ry, rz = math.rad(rx), math.rad(ry), math.rad(rz)
    local matrix = {}
    matrix[1] = {}
    matrix[1][1] = math.cos(rz)*math.cos(ry) - math.sin(rz)*math.sin(rx)*math.sin(ry)
    matrix[1][2] = math.cos(ry)*math.sin(rz) + math.cos(rz)*math.sin(rx)*math.sin(ry)
    matrix[1][3] = -math.cos(rx)*math.sin(ry)
    matrix[1][4] = 1
    
    matrix[2] = {}
    matrix[2][1] = -math.cos(rx)*math.sin(rz)
    matrix[2][2] = math.cos(rz)*math.cos(rx)
    matrix[2][3] = math.sin(rx)
    matrix[2][4] = 1
	
    matrix[3] = {}
    matrix[3][1] = math.cos(rz)*math.sin(ry) + math.cos(ry)*math.sin(rz)*math.sin(rx)
    matrix[3][2] = math.sin(rz)*math.sin(ry) - math.cos(rz)*math.cos(ry)*math.sin(rx)
    matrix[3][3] = math.cos(rx)*math.cos(ry)
    matrix[3][4] = 1
	
    matrix[4] = {}
    local pos = GetWorldPositionOfEntityBone(element, elementbone)
    matrix[4][1], matrix[4][2], matrix[4][3] = pos.x, pos.y, pos.z - 1.0
    matrix[4][4] = 1
	
    return matrix
end

local function getOffsetFromEntityInWorldCoords(entity, boneindex, offX, offY, offZ)
    local m = getEntityMatrix(entity, boneindex)
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return vector3(x, y, z)
end

Citizen.CreateThread(function()
    while true do
        Wait(0)

        for _,v in pairs(GetGamePool("CVehicle")) do
            local vSpotlight = SpotlightVehicles[GetEntityModel(v)]

            if vSpotlight ~= nil then
                if IsVehicleExtraTurnedOn(v, vSpotlight.extras.SpotlightUp) and GetIsVehicleEngineRunning(v) then
                    local _, _, on = GetVehicleLightsState(v)

                    if on == 1 then
                        local bIndex = GetEntityBoneIndexByName(v, vSpotlight.bone)
                        local bPos = GetWorldPositionOfEntityBone(v, bIndex)
                        local ePos = getOffsetFromEntityInWorldCoords(v, bIndex, 0.0, 5.0, 1.0)
                        local vDir = ePos - bPos

                        DrawSpotLightWithShadow(bPos[1], bPos[2], bPos[3], vDir[1], vDir[2], vDir[3], SpotlightConfig.Color[1], SpotlightConfig.Color[2], SpotlightConfig.Color[3], SpotlightConfig.Distance, SpotlightConfig.Brightness, SpotlightConfig.Roundness, SpotlightConfig.Radius, SpotlightConfig.Falloff, v) -- Shadow ID Used to be 0
                    end
                end
            end
        end
    end
end)