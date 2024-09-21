local QBCore = exports['qb-core']:GetCoreObject()

-- Handle item purchase
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

-- Check if the player has any fragrance item from Config
local function CheckPlayerFragrance(player)
    local Player = QBCore.Functions.GetPlayer(player)
    for _, item in pairs(Config.Shop[1].Items) do
        if Player.Functions.GetItemByName(item.Item) then
            return item.Item -- Return the item name for usage
        end
    end
    return nil
end

-- Notify nearby players of the fragrance
RegisterNetEvent('pengu-fragrance:notifyNearbyPlayer', function(targetPlayer)
    local src = source
    local fragranceItem = CheckPlayerFragrance(src)

    if fragranceItem then
        TriggerClientEvent('QBCore:Notify', targetPlayer, 'You smell a nice fragrance nearby.', 'info')
    end
end)

-- Handle fragrance usage
RegisterNetEvent('pengu-fragrance:useFragrance', function(itemName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    -- Debug: Check item name being used
    print("Attempting to use item: " .. itemName)

    -- Check if the player has the item
    if Player.Functions.RemoveItem(itemName, 1) then
        TriggerClientEvent('pengu-fragrance:sprayAnimation', src, itemName)
        TriggerClientEvent('QBCore:Notify', src, 'You used ' .. itemName .. '.', 'success')

        -- Notify nearby players about the fragrance scent
        local players = QBCore.Functions.GetPlayers()
        for _, otherPlayerId in ipairs(players) do
            if otherPlayerId ~= src then
                TriggerClientEvent('pengu-fragrance:notifyNearbyPlayer', otherPlayerId)
            end
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'You do not have that fragrance!', 'error')
        -- Debug: Notify that item removal failed
        print("Failed to remove item: " .. itemName)
    end
end)

-- Debug command to check player's fragrance
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
