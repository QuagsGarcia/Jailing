local jailed = false
local timer = 0
local ext = 0
local updateTime = 0

TriggerEvent('chat:addSuggestion', '/jail', 'Used to jail criminals.', {
    { name="target", help="ID of the player that is going to be jailed." },
    { name="time", help="Time in seconds." }
})
TriggerEvent('chat:addSuggestion', '/release', 'Used to release criminals.', {
    { name="target", help="ID of the player that is going to be released." }
})

RegisterNetEvent('QuagsJailing:UnJailCorrectClient')
AddEventHandler('QuagsJailing:UnJailCorrectClient', function()
    if jailed then
        timer = 2
    end
end)

RegisterNetEvent('QuagsJailing:JailCorrectClient')
AddEventHandler('QuagsJailing:JailCorrectClient', function(time, cellTBL)
    if not jailed then
        local ped = GetPlayerPed(-1)
        if tonumber(time) < 2 then
            TriggerEvent("QuagsNotify:Icon", "Knox County Penitentiary", "You are now imprisoned for a month.", 5000, 'information', "mdi-police-badge")
        else
            TriggerEvent("QuagsNotify:Icon", "Knox County Penitentiary", "You are now imprisoned for "..time.." months.", 5000, 'information', "mdi-police-badge")
        end
        setPrisonClothing(ped)
        putInCell(ped, time + 1, cellTBL)
    end
end)

function putInCell(ped, time, cellTBL)
    SetEntityCoords(ped, Config.JailLocations[cellTBL].jailcoords)
    SetEntityHeading(ped, Config.JailLocations[cellTBL].h)

    timer = time
    jailed = true
    SetResourceKvp(GetPlayerServerId(PlayerId())..":JailStatus", tostring(jailed))
    TriggerEvent("vMenu:setupPerm")
    setPrisonClothingStat = false
    SetPedConfigFlag(GetPlayerPed(-1), 120, false)
        SetPedConfigFlag(GetPlayerPed(-1), 122, false)
    while jailed do
        if ext < GetGameTimer() then
            ext = GetGameTimer() + 1500
            if not setPrisonClothingStat then
                setPrisonClothingStat = true
                setPrisonClothing(GetPlayerPed(-1))
            end
            timer = timer - 1
            if timer ~= 1 then
                SendNUIMessage({
                    dataSet = timer.." months left."
                })
            else
                SendNUIMessage({
                dataSet = timer.." month left."
                })
            end
            if timer == 0 then
                SendNUIMessage({
                    dataSet = "done"
                })
                jailed = false
                SetResourceKvp(GetPlayerServerId(PlayerId())..":JailStatus", tostring(jailed))
                TriggerEvent("vMenu:setupPerm")
            end
            local distance = #(GetEntityCoords(GetPlayerPed(-1)) - vector3(1693.0, 2594.83, 45.56))
            if distance > 180 then
                SetEntityCoords(ped, vector3(1761.48, 2485.23, 45.73))
                SetEntityHeading(ped, 2.83)
                timer = timer + 20
                TriggerEvent("QuagsNotify:Icon", "Knox County Penitentiary", "You were put back into your cell and have to serve an additional 20 months.", 5000, 'information', "mdi-police-badge")
            end
        end
        if updateTime < GetGameTimer() then
            updateTime = GetGameTimer() + 5500
            TriggerServerEvent('QuagsJailing:UpdateTime', GetPlayerServerId(PlayerId()), timer)
        end
        if IsEntityDead(GetPlayerPed(-1)) then
            SetEntityCoords(GetPlayerPed(-1), vector3(1766.4, 2592.46, 44.42))
            TriggerEvent("GURevivePlayer")
            setPrisonClothingStat = false
        end
        Citizen.Wait(0)
    end
    TriggerServerEvent('QuagsJailing:Unjail', GetPlayerServerId(PlayerId()), "unjail")
end

function setCivilianClothing()
    local ped = GetPlayerPed(-1)
    if IsMpPed(ped) then
        if IsMpPed(ped) == "Male" then
            setCivMale(ped)
        else
            setCivFemale(ped)
        end
    end
end

RegisterNetEvent('QuagsJailing:CheckIfStillNeedsToServeTime')
AddEventHandler('QuagsJailing:CheckIfStillNeedsToServeTime', function()
    TriggerServerEvent('QuagsJailing:CheckIfStillNeedsToServeTime', GetPlayerServerId(PlayerId()))
end)

RegisterNetEvent('QuagsJailing:SendJailStatus')
AddEventHandler('QuagsJailing:SendJailStatus', function()
    TriggerEvent('QuagsJailing:JailStatus', jailed)
end)

RegisterNetEvent('QuagsJailing:Unjail')
AddEventHandler('QuagsJailing:Unjail', function()
    local ped = GetPlayerPed(-1)
    unJailProcess(ped)
end)

function unJailProcess(ped)
    SetEntityCoords(ped, vector3(1840.4, 2579.33, 46.01))
    SetEntityHeading(ped, 173.49)
    TriggerEvent("QuagsNotify:Icon", "Knox County Penitentiary", "You were released from prison.", 5000, 'information', "mdi-police-badge")
    setCivilianClothing(ped)
end

function setPrisonClothing(ped)
    if IsMpPed(ped) then
        if IsMpPed(ped) == "Male" then
            setClMale(ped)
        else
            setClFemale(ped)
        end
    end
end

function setCivMale(ped)
    SetPedComponentVariation(ped, 1, 0, 0, 0)
    SetPedComponentVariation(ped, 3, 6, 0, 0)
    SetPedComponentVariation(ped, 4, 7, 0, 0)
    SetPedComponentVariation(ped, 5, 0, 0, 0)
    SetPedComponentVariation(ped, 6, 7, 0, 0)
    SetPedComponentVariation(ped, 7, 0, 0, 0)
    SetPedComponentVariation(ped, 8, 5, 0, 0)
    SetPedComponentVariation(ped, 9, 0, 0, 0)
    SetPedComponentVariation(ped, 10, 0, 0, 0)
    SetPedComponentVariation(ped, 11, 7, 2, 0)
    ClearPedProp(ped, 0)
    ClearPedProp(ped, 1)
    ClearPedProp(ped, 2)
    ClearPedProp(ped, 6)
    ClearPedProp(ped, 7)
end

function setCivFemale(ped)
    SetPedComponentVariation(ped, 1, 0, 0, 0)
    SetPedComponentVariation(ped, 3, 3, 0, 0)
    SetPedComponentVariation(ped, 4, 3, 0, 0)
    SetPedComponentVariation(ped, 5, 0, 0, 0)
    SetPedComponentVariation(ped, 6, 103, 0, 0)
    SetPedComponentVariation(ped, 7, 0, 0, 0)
    SetPedComponentVariation(ped, 8, 14, 0, 0)
    SetPedComponentVariation(ped, 9, 0, 0, 0)
    SetPedComponentVariation(ped, 10, 0, 0, 0)
    SetPedComponentVariation(ped, 11, 3, 2, 0)
    ClearPedProp(ped, 0)
    ClearPedProp(ped, 1)
    ClearPedProp(ped, 2)
    ClearPedProp(ped, 6)
    ClearPedProp(ped, 7)
end

function setClMale(ped)
    SetPedComponentVariation(ped, 1, 0, 0, 0)
    SetPedComponentVariation(ped, 3, 5, 0, 0)
    SetPedComponentVariation(ped, 4, 7, 15, 0)
    SetPedComponentVariation(ped, 5, 0, 0, 0)
    SetPedComponentVariation(ped, 6, 7, 0, 0)
    SetPedComponentVariation(ped, 7, 0, 0, 0)
    SetPedComponentVariation(ped, 8, 15, 0, 0)
    SetPedComponentVariation(ped, 9, 0, 0, 0)
    SetPedComponentVariation(ped, 10, 0, 0, 0)
    SetPedComponentVariation(ped, 11, 5, 0, 0)
    ClearPedProp(ped, 0)
    ClearPedProp(ped, 1)
    ClearPedProp(ped, 2)
    ClearPedProp(ped, 6)
    ClearPedProp(ped, 7)
end

function setClFemale(ped)
    SetPedComponentVariation(ped, 1, 0, 0, 0)
    SetPedComponentVariation(ped, 3, 14, 0, 0)
    SetPedComponentVariation(ped, 4, 3, 15, 0)
    SetPedComponentVariation(ped, 5, 0, 0, 0)
    SetPedComponentVariation(ped, 6, 103, 0, 0)
    SetPedComponentVariation(ped, 7, 0, 0, 0)
    SetPedComponentVariation(ped, 8, 15, 0, 0)
    SetPedComponentVariation(ped, 9, 0, 0, 0)
    SetPedComponentVariation(ped, 10, 0, 0, 0)
    SetPedComponentVariation(ped, 11, 49, 0, 0)
    ClearPedProp(ped, 0)
    ClearPedProp(ped, 1)
    ClearPedProp(ped, 2)
    ClearPedProp(ped, 6)
    ClearPedProp(ped, 7)
end

function IsMpPed(ped)
    local Male = GetHashKey("mp_m_freemode_01") local Female = GetHashKey("mp_f_freemode_01")
    local CurrentModel = GetEntityModel(ped)
    if CurrentModel == Male then return "Male" elseif CurrentModel == Female then return "Female" else return false end
end

Citizen.CreateThread(function()
    SetResourceKvp(GetPlayerServerId(PlayerId())..":JailStatus", tostring(jailed))
end)

RegisterNetEvent('QuagsJailing:UpdateJailStat')
AddEventHandler('QuagsJailing:UpdateJailStat', function(stat)
    SetResourceKvp(GetPlayerServerId(PlayerId())..":JailStatus", tostring(stat))
    TriggerEvent("vMenu:setupPerm")
end)