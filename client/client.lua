local QBCore = exports['qb-core']:GetCoreObject()
local shopItems = Config.Shop[1].Items

local function DebugPrint(message)
    print("[DEBUG] " .. message)
end

local function showProgressBar(duration, label)
    if Config.ProgressBar == 'ox' then
        lib.progressBar({
            duration = duration,
            label = label,
            useWhileDead = false,
            canCancel = false,
            disable = { car = true, move = true, combat = true },
            anim = { dict = 'amb@world_human_hang_out_street@male_c@idle_a', clip = 'idle_a' },
        })
    elseif Config.ProgressBar == 'progressbar' then
        exports['progressbar']:startUI(duration, label)
    end
end

Citizen.CreateThread(function()
    DebugPrint("Starting Fragrance Shop blip creation.")
    local blip = AddBlipForCoord(Config.ShopBlip.coords)
    SetBlipSprite(blip, Config.ShopBlip.sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, Config.ShopBlip.scale)
    SetBlipColour(blip, Config.ShopBlip.color)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.ShopBlip.name)
    EndTextCommandSetBlipName(blip)
    DebugPrint("Blip for Fragrance Shop created successfully.")
end)

local function SetupNPC(npcModel, position)
    DebugPrint("Setting up NPC: " .. npcModel)
    RequestModel(GetHashKey(npcModel))

    while not HasModelLoaded(GetHashKey(npcModel)) do
        DebugPrint("Waiting for NPC model to load.")
        Wait(10)
    end

    local npcPed = CreatePed(4, GetHashKey(npcModel), position.x, position.y, position.z - 1, position.w, false, true)

    if DoesEntityExist(npcPed) then
        SetEntityInvincible(npcPed, true)
        SetBlockingOfNonTemporaryEvents(npcPed, true)
        FreezeEntityPosition(npcPed, true)
        DebugPrint("NPC created successfully at coordinates: " .. position.x .. ", " .. position.y .. ", " .. position.z)
        return npcPed
    else
        DebugPrint("Failed to create NPC. Model may not exist or was not loaded.")
        return nil
    end
end

local function SetupTargeting(npcPed)
    if exports[Config.Target] then
        local options = {
            {
                type = "client",
                icon = "fas fa-shopping-bag",
                label = "Buy Fragrance",
                action = function()
                    TriggerEvent("pengu-fragrance:openShop")
                end
            }
        }

        local model = GetEntityModel(npcPed)

        if Config.Target == 'qtarget' then
            exports['qtarget']:AddTargetModel({ model = model, label = Config.NPC.Name, icon = "fas fa-shopping-bag", distance = 2.5, options = options })
        elseif Config.Target == 'qb' then
            exports['qb-target']:AddTargetModel(model, { options = options, distance = 2.5 })
        elseif Config.Target == 'ox' then
            lib.addModel({ model = model, label = Config.NPC.Name, icon = "fas fa-shopping-bag", distance = 2.5, options = options })
        end

        DebugPrint("Targeting system set up successfully for: " .. Config.Target)
    else
        DebugPrint("Targeting system not found: " .. Config.Target)
    end
end

Citizen.CreateThread(function()
    DebugPrint("Creating Fragrance Shop NPC...")
    local npcPed = SetupNPC(Config.NPC.model, Config.NPC.coords)
    if npcPed then
        DebugPrint("Setting up targeting for the NPC.")
        SetupTargeting(npcPed)
    else
        DebugPrint("NPC setup failed, cannot proceed with targeting.")
    end
end)

local mainMenuOptions = {
    {
        title = 'Fragrance Shop',
        description = 'Best Fragrances',
        icon = 'fas fa-shopping-bag',
        onSelect = function() 
            TriggerEvent('pengu-fragrance:openBuyMenu')
        end,
        params = { isAction = true }
    },
}

RegisterNetEvent('pengu-fragrance:openShop', function()
    DebugPrint("Opening Fragrance Shop...")
    showProgressBar(2000, 'Opening Shop...') 

    lib.registerContext({
        id = 'fragrance_shop',
        title = 'Fragrance Shop',
        options = mainMenuOptions,
    })

    lib.showContext('fragrance_shop')
end)

RegisterNetEvent('pengu-fragrance:openBuyMenu', function()
    local buyMenuOptions = {}

    for _, item in pairs(shopItems) do
        DebugPrint("Preparing buy option for: " .. item.Name .. " - Price: " .. item.Price)
        table.insert(buyMenuOptions, {
            title = item.Name,
            description = "Price: $" .. item.Price,
            icon = 'fas fa-gift',
            onSelect = function()
                TriggerEvent('pengu-fragrance:buyItem', item)
            end,
            params = { isAction = true },
        })
    end

    DebugPrint("Buy menu options prepared, attempting to show buy menu...")

    lib.registerContext({
        id = 'buy_fragrances',
        title = 'Buy Fragrances',
        options = buyMenuOptions,
    })

    lib.showContext('buy_fragrances')
    DebugPrint("Context shown: buy_fragrances")
end)

local inventoryType = Config.InventoryType 

RegisterNetEvent('pengu-fragrance:buyItem', function(item)
    DebugPrint("Attempting to purchase " .. item.Name .. " for $" .. item.Price) 
    QBCore.Functions.Notify("Attempting to purchase " .. item.Name .. " for $" .. item.Price, "success", 3000)
    TriggerServerEvent('pengu-fragrance:purchaseItem', item)
end)

RegisterNetEvent('pengu-fragrance:useFragrance', function(itemName)
    local playerPed = PlayerPedId()

    showProgressBar(3000, 'Using Fragrance...') 

    TriggerEvent('pengu-fragrance:sprayAnimation', playerPed)

    DebugPrint("Using fragrance: " .. itemName) 
    handleInventoryAction("use", itemName) 
end)

RegisterNetEvent('pengu-fragrance:sprayAnimation', function(playerPed)
    DebugPrint("Starting spray animation")
    local sprayProp = CreateObject(GetHashKey('prop_spray'), GetEntityCoords(playerPed), true, true, true)
    AttachEntityToEntity(sprayProp, playerPed, GetPedBoneIndex(playerPed, 60309), 0.1, 0, 0, 0, 0, false, true, false, true, 1, true)
    TaskPlayAnim(playerPed, 'mp_common', 'givetake1_a', 3.0, -1.0, -1, 49, 0, false, false, false)

    Wait(2000) 
    DeleteEntity(sprayProp)
end)

Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local players = GetActivePlayers()

        for _, otherPlayer in ipairs(players) do
            local otherPed = GetPlayerPed(otherPlayer)
            local otherCoords = GetEntityCoords(otherPed)
            local distance = #(playerCoords - otherCoords)

            if distance < 5.0 and otherPlayer ~= PlayerId() then
                DebugPrint("Notifying nearby player: " .. GetPlayerServerId(otherPlayer)) 
                TriggerServerEvent('pengu-fragrance:notifyNearbyPlayer', GetPlayerServerId(otherPlayer))
            end
        end
        Wait(5000) 
    end
end)

RegisterNetEvent('pengu-fragrance:showFragranceNotification', function()
    QBCore.Functions.Notify("You smell a nice fragrance nearby!", "success", 5000)
end)

local function handleInventoryAction(action, itemName)
    if inventoryType == "qb" then
        local Player = QBCore.Functions.GetPlayer(PlayerId())
        if action == "use" then
            if Player.Functions.RemoveItem(itemName, 1) then
                TriggerEvent('pengu-fragrance:useFragrance', itemName)
            else
                QBCore.Functions.Notify("You do not have that fragrance!", "error")
            end
        end
    elseif inventoryType == "ox" then
        if action == "use" then
            if exports.ox_inventory:Search('count', itemName) > 0 then
                exports.ox_inventory:RemoveItem(itemName, 1)
                TriggerEvent('pengu-fragrance:useFragrance', itemName)
            else
                QBCore.Functions.Notify("You do not have that fragrance!", "error")
            end
        end
    elseif inventoryType == "ps" then
        if action == "use" then
            local hasItem = false
            for _, item in ipairs(PS_Inventory:GetInventory()) do
                if item.name == itemName and item.amount > 0 then
                    hasItem = true
                    break
                end
            end

            if hasItem then
                PS_Inventory:RemoveItem(itemName, 1)
                TriggerEvent('pengu-fragrance:useFragrance', itemName)
            else
                QBCore.Functions.Notify("You do not have that fragrance!", "error")
            end
        end
    else
        DebugPrint("Unknown inventory type: " .. inventoryType)
    end
end

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0150, 0.015 + factor, 0.03, 0, 0, 0, 75)
end
