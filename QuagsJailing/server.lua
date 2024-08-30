Config = {}

Config.JailLocations = {
    {jailcoords=vector3(1758.21, 2473.03, 45.74), h=32.14, jailNum="1"},
    {jailcoords=vector3(1761.43, 2474.3, 45.74), h=29.89, jailNum="2"},
    {jailcoords=vector3(1764.57, 2476.22, 45.74), h=29.68, jailNum="3"},
    {jailcoords=vector3(1767.79, 2477.75, 45.74), h=32.31, jailNum="4"},
    {jailcoords=vector3(1770.93, 2479.55, 45.74), h=28.47, jailNum="5"},
    {jailcoords=vector3(1774.08, 2481.68, 45.74), h=33.25, jailNum="6"},
    {jailcoords=vector3(1776.92, 2483.34, 45.74), h=30.06, jailNum="7"},
    {jailcoords=vector3(1767.68, 2501.12, 45.74), h=208.9, jailNum="8"},
    {jailcoords=vector3(1764.4, 2499.3, 45.74), h=208.23, jailNum="9"},
    {jailcoords=vector3(1761.28, 2497.5, 45.74), h=210.78, jailNum="10"},
    {jailcoords=vector3(1755.35, 2493.58, 45.74), h=214.85, jailNum="11"},
    {jailcoords=vector3(1751.82, 2492.11, 45.74), h=213.0, jailNum="12"},
    {jailcoords=vector3(1748.67, 2490.3, 45.74), h=209.7, jailNum="13"},
    {jailcoords=vector3(1748.68, 2490.15, 49.69), h=217.73, jailNum="14"},
    {jailcoords=vector3(1751.96, 2491.97, 49.69), h=212.56, jailNum="15"},
    {jailcoords=vector3(1755.03, 2493.82, 49.69), h=213.47, jailNum="16"},
    {jailcoords=vector3(1758.23, 2495.67, 49.69), h=210.93, jailNum="17"},
    {jailcoords=vector3(1761.53, 2497.24, 49.69), h=211.47, jailNum="18"},
    {jailcoords=vector3(1764.75, 2499.12, 49.69), h=207.93, jailNum="19"},
    {jailcoords=vector3(1767.69, 2501.01, 49.69), h=213.17, jailNum="20"},
    {jailcoords=vector3(1777.19, 2483.5, 49.69), h=27.47, jailNum="21"},
    {jailcoords=vector3(1774.1, 2481.37, 49.69), h=21.96, jailNum="22"},
    {jailcoords=vector3(1770.83, 2479.84, 49.69), h=24.4, jailNum="23"},
    {jailcoords=vector3(1767.83, 2477.76, 49.69), h=25.64, jailNum="24"},
    {jailcoords=vector3(1764.79, 2475.84, 49.69), h=26.77, jailNum="25"},
    {jailcoords=vector3(1761.52, 2474.3, 49.69), h=24.4, jailNum="26"},
    {jailcoords=vector3(1758.38, 2472.6, 49.69), h=21.11, jailNum="27"}
}

RegisterNetEvent('QuagsJailing:JailCorrectClient')
AddEventHandler('QuagsJailing:JailCorrectClient', function(id, time, intiater)
    if not isValidID(id) then
        TriggerClientEvent("QuagsNotify:Icon", intiater, "GU Jail System", "ID: "..id.." does not exist.", 5000, 'negative', "mdi-alert-circle")
    else
        if time == "unjail" then
            RemoveFromJail(id)
        else
            AddToJail(id, time)
        end
    end
end)

RegisterNetEvent('QuagsJailing:Unjail')
AddEventHandler('QuagsJailing:Unjail', function(id)
    TriggerClientEvent("QuagsJailing:Unjail", id)
    RemoveFromJail(id)
end)

RegisterNetEvent('QuagsJailing:UpdateTime')
AddEventHandler('QuagsJailing:UpdateTime', function(id, time)
    local data = LoadFile()
    local a = false
    for k,v in pairs(GetPlayerIdentifiers(id)) do 
        if string.sub(v, 1, string.len("license:")) == "license:" then
            a = v
        end
    end
    local identifier = a
    data[identifier] = {jailNum=data[identifier].jailNum, timeLeft=time}
    SaveFile(data)
end)

RegisterNetEvent('QuagsJailing:CheckIfStillNeedsToServeTime')
AddEventHandler('QuagsJailing:CheckIfStillNeedsToServeTime', function(id)
    local data = LoadFile()
    local a = false
    for k,v in pairs(GetPlayerIdentifiers(id)) do 
        if string.sub(v, 1, string.len("license:")) == "license:" then
            a = v
        end
    end
    local identifier = a
    if data[identifier] then
        if data[identifier].timeLeft ~= "unjail" then
            AddToJail(id, data[identifier].timeLeft)
            return
        end
    end
end)

function isValidID(id)
    local validID = false
    for _, playerId in ipairs(GetPlayers()) do
        if tonumber(playerId) == tonumber(id) then
            validID = true
        end
    end
    return validID
end

function SaveFile(data)
    SaveResourceFile(GetCurrentResourceName(), "cellhistory.json", json.encode(data, { indent = true }), -1)
end

function LoadFile()
    local al = LoadResourceFile(GetCurrentResourceName(), "cellhistory.json")
    local cfg = json.decode(al)
    return cfg;
end

function AddToJail(id, time)
    local data = LoadFile()
    local a = false
    for k,v in pairs(GetPlayerIdentifiers(id)) do 
        if string.sub(v, 1, string.len("license:")) == "license:" then
            a = v
        end
    end
    local identifier = a
    local jailCellNumRNG = math.random(1, countTable(Config.JailLocations))
    while not isUnqiueJailCell(Config.JailLocations[jailCellNumRNG].jailNum) do
        Citizen.Wait(0)
        jailCellNumRNG = math.random(1, countTable(Config.JailLocations))
    end
    data[identifier] = {jailNum=Config.JailLocations[jailCellNumRNG].jailNum, timeLeft=tonumber(time)}
    SaveFile(data)
    TriggerClientEvent("QuagsJailing:JailCorrectClient", id, time, jailCellNumRNG)
end

function RemoveFromJail(id)
    local data = LoadFile()
    local a = false
    for k,v in pairs(GetPlayerIdentifiers(id)) do 
        if string.sub(v, 1, string.len("license:")) == "license:" then
            a = v
        end
    end
    local identifier = a
    data[identifier] = {jailNum=data[identifier].jailNum, timeLeft="unjail"}
    SaveFile(data)
    TriggerClientEvent("QuagsJailing:UnJailCorrectClient", id)
end
function isUnqiueJailCell(num)
    local data = LoadFile()
    local unique = true
    for _, i in pairs(data) do
        if num == i.jailNum then
                unique = false
        end
    end
    return unique
end

function countTable(tbl)
    local tableCount = 0
    for _, i in pairs(tbl) do
        tableCount = tableCount + 1
    end
    return tableCount
end

RegisterCommand( "jail", function(src, args, rawCommand)
    if IsPlayerAceAllowed(src, "gu.jail") then
        if not tonumber(args[1]) then
            TriggerClientEvent("QuagsNotify:Icon", src, "GU Jail System", "You need to type a number for the ID.", 5000, 'negative', "mdi-alert-circle")
        else
            if not tonumber(args[2]) then
                TriggerClientEvent("QuagsNotify:Icon", src, "GU Jail System", "You need to type a number for the jail time in seconds.", 5000, 'negative', "mdi-alert-circle")
            else
                local time = args[2]
                if tonumber(time) > 1000 then
                    time = 1000
                end
                TriggerEvent('QuagsJailing:JailCorrectClient', args[1], time, src)
            end
        end
    else
        TriggerClientEvent("QuagsNotify:Icon", src, "GU Jail System", "You do not have permission to use this command.", 5000, 'negative', "mdi-alert-circle")
    end
end, false )

RegisterCommand( "release", function(src, args, rawCommand)
    if IsPlayerAceAllowed(src, "gu.jail") then
        if not tonumber(args[1]) then
            TriggerClientEvent("QuagsNotify:Icon", src, "GU Jail System", "You need to type a number for the ID.", 5000, 'negative', "mdi-alert-circle")
        else
            TriggerEvent('QuagsJailing:JailCorrectClient', args[1], "unjail", src)
        end
    else
        TriggerClientEvent("QuagsNotify:Icon", src, "GU Jail System", "You do not have permission to use this command.", 5000, 'negative', "mdi-alert-circle")
    end
end)