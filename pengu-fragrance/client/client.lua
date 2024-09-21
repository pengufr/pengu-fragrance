local QBCore = exports['qb-core']:GetCoreObject()
local shopItems = Config.Shop[1].Items

-- Function to print debug messages
local function DebugPrint(message)
    print("[DEBUG] " .. message)
end

-- Function to show a progress bar based on the config
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

-- Create Blip for Fragrance Shop
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

-- Function to create the NPC
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

-- Function to set up the targeting system
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

-- Create the Fragrance Shop NPC and set up targeting
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

-- Main menu options for the shop
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

-- Register event to open the main fragrance shop
RegisterNetEvent('pengu-fragrance:openShop', function()
    DebugPrint("Opening Fragrance Shop...")
    showProgressBar(2000, 'Opening Shop...') -- Show progress bar for 2 seconds

    -- Register the main context
    lib.registerContext({
        id = 'fragrance_shop',
        title = 'Fragrance Shop',
        options = mainMenuOptions,
    })

    lib.showContext('fragrance_shop')
end)

-- Register event to open the buy fragrances menu
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

    -- Register the buy fragrances context
    lib.registerContext({
        id = 'buy_fragrances',
        title = 'Buy Fragrances',
        options = buyMenuOptions,
    })

    -- Show the buy fragrances context
    lib.showContext('buy_fragrances')
    DebugPrint("Context shown: buy_fragrances")
end)

-- Determine the inventory type from the config
local inventoryType = Config.InventoryType -- Ensure this variable holds the inventory type

-- Handle item purchase
RegisterNetEvent('pengu-fragrance:buyItem', function(item)
    DebugPrint("Attempting to purchase " .. item.Name .. " for $" .. item.Price) -- Debug message
    QBCore.Functions.Notify("Attempting to purchase " .. item.Name .. " for $" .. item.Price, "success", 3000)
    TriggerServerEvent('pengu-fragrance:purchaseItem', item)
end)

-- Handle fragrance usage with animation and progress bar
RegisterNetEvent('pengu-fragrance:useFragrance', function(itemName)
    local playerPed = PlayerPedId()

    -- Show progress bar for using the fragrance
    showProgressBar(3000, 'Using Fragrance...') -- Show for 3 seconds

    -- Trigger the spray animation
    TriggerEvent('pengu-fragrance:sprayAnimation', playerPed)

    -- Notify the server about the fragrance use
    DebugPrint("Using fragrance: " .. itemName) -- Debug message
    handleInventoryAction("use", itemName) -- Call inventory handling function
end)

-- Function to handle spray animation
RegisterNetEvent('pengu-fragrance:sprayAnimation', function(playerPed)
    DebugPrint("Starting spray animation") -- Debug message
    local sprayProp = CreateObject(GetHashKey('prop_spray'), GetEntityCoords(playerPed), true, true, true)
    AttachEntityToEntity(sprayProp, playerPed, GetPedBoneIndex(playerPed, 60309), 0.1, 0, 0, 0, 0, false, true, false, true, 1, true)
    TaskPlayAnim(playerPed, 'mp_common', 'givetake1_a', 3.0, -1.0, -1, 49, 0, false, false, false)

    Wait(2000) -- Wait for the animation duration
    DeleteEntity(sprayProp)
end)

-- Notify nearby players of fragrance scent
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
                DebugPrint("Notifying nearby player: " .. GetPlayerServerId(otherPlayer)) -- Debug message
                TriggerServerEvent('pengu-fragrance:notifyNearbyPlayer', GetPlayerServerId(otherPlayer))
            end
        end
        Wait(5000) -- Check every 5 seconds
    end
end)

-- Event to show a notification for the nearby player
RegisterNetEvent('pengu-fragrance:showFragranceNotification', function()
    QBCore.Functions.Notify("You smell a nice fragrance nearby!", "success", 5000)
end)

-- Example item handling based on inventory type
local function handleInventoryAction(action, itemName)
    if inventoryType == "qb" then
        -- QB inventory logic
        local Player = QBCore.Functions.GetPlayer(PlayerId())
        if action == "use" then
            if Player.Functions.RemoveItem(itemName, 1) then
                TriggerEvent('pengu-fragrance:useFragrance', itemName)
            else
                QBCore.Functions.Notify("You do not have that fragrance!", "error")
            end
        end
    elseif inventoryType == "ox" then
        -- Ox inventory logic
        if action == "use" then
            if exports.ox_inventory:Search('count', itemName) > 0 then
                exports.ox_inventory:RemoveItem(itemName, 1)
                TriggerEvent('pengu-fragrance:useFragrance', itemName)
            else
                QBCore.Functions.Notify("You do not have that fragrance!", "error")
            end
        end
    elseif inventoryType == "ps" then
        -- PS inventory logic
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

-- Draw 3D text at the shop location
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
