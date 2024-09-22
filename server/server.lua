local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('pengu-fragrance:purchaseItem', function(item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player.Functions.RemoveMoney('cash', item.Price) then
        Player.Functions.AddItem(item.Item, 1)
        TriggerClientEvent('QBCore:Notify', src, 'You bought ' .. item.Name .. ' for $' .. item.Price, 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, 'Not enough money!', 'error')
    end
end)

local function CheckPlayerFragrance(player)
    local Player = QBCore.Functions.GetPlayer(player)
    for _, item in pairs(Config.Shop[1].Items) do
        if Player.Functions.GetItemByName(item.Item) then
            return item.Item
        end
    end
    return nil
end

RegisterNetEvent('pengu-fragrance:notifyNearbyPlayer', function(targetPlayer)
    local src = source
    local fragranceItem = CheckPlayerFragrance(src)

    if fragranceItem then
        TriggerClientEvent('QBCore:Notify', targetPlayer, 'You smell a nice fragrance nearby.', 'info')
    end
end)

RegisterNetEvent('pengu-fragrance:useFragrance', function(itemName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    print("Attempting to use item: " .. itemName)

    if Player.Functions.RemoveItem(itemName, 1) then
        TriggerClientEvent('pengu-fragrance:sprayAnimation', src, itemName)
        TriggerClientEvent('QBCore:Notify', src, 'You used ' .. itemName .. '.', 'success')

        local players = QBCore.Functions.GetPlayers()
        for _, otherPlayerId in ipairs(players) do
            if otherPlayerId ~= src then
                TriggerClientEvent('pengu-fragrance:notifyNearbyPlayer', otherPlayerId)
            end
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'You do not have that fragrance!', 'error')
        print("Failed to remove item: " .. itemName)
    end
end)

if Config.Debug then
    QBCore.Commands.Add('checkfragrance', 'Check if you are wearing a fragrance', {}, false, function(source)
        local fragrance = CheckPlayerFragrance(source)
        if fragrance then
            TriggerClientEvent('QBCore:Notify', source, 'You are wearing ' .. fragrance, 'success')
        else
            TriggerClientEvent('QBCore:Notify', source, 'You are not wearing any fragrance.', 'error')
        end
    end)
end
