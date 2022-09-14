local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateUseableItem("syphoningkit", function(source, item)
    local src = source
    TriggerClientEvent('cdn-syphoning:syphon:menu', src, item)
end)

RegisterNetEvent('cdn-syphoning:info', function(type, amount, srcPlayerData, itemdata)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local srcPlayerData = srcPlayerData
    if amount < 1 or amount > Config.SyphonKitCap then if Config.SyphonDebug then print("Error, amount is invalid (< 1 or > "..Config.SyphonKitCap..")! Amount:" ..amount) end return end
    if type == "add" then
        srcPlayerData.items[itemdata.slot].info.gasamount = srcPlayerData.items[itemdata.slot].info.gasamount + amount
        Player.Functions.SetInventory(srcPlayerData.items)
    elseif type == "remove" then
        srcPlayerData.items[itemdata.slot].info.gasamount = srcPlayerData.items[itemdata.slot].info.gasamount - amount
        Player.Functions.SetInventory(srcPlayerData.items)
    else
        if Config.SyphonDebug then print("error, type is invalid!") end
    end
end)

RegisterNetEvent('cdn-syphoning:callcops', function(coords)
    TriggerClientEvent('cdn-syphoning:client:callcops', -1, coords)
end)