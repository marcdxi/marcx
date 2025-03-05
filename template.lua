_G.autoLoad = true

-- Only load the GUI in the desired game
if game.PlaceId ~= 0 and game.PlaceId ~= 18417225778 then
    return
end

-- Check if the game is loaded
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local name = "Template Hub"
local version = "1.0.0"
local release = "stable"

_G.versionControl = version .. "." .. release
if _G.desiredVersion and _G.desiredVersion ~= _G.versionControl then
    warn("Version Mismatch Detected")
    warn("Desired Version: " .. tostring(_G.desiredVersion))
    warn("Current Version: " .. tostring(_G.versionControl))
    _G.desiredVersion = nil
    return
end

--------------------------------------------------------------------------------
-- Roblox Services
--------------------------------------------------------------------------------
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")

--------------------------------------------------------------------------------
-- Load Fluent UI Library from its URL
--------------------------------------------------------------------------------
local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/marcdxi/marcx/refs/heads/main/Fluent/BetaFluent.lua"))()

--------------------------------------------------------------------------------
-- Create the GUI Window using Fluent
--------------------------------------------------------------------------------
local guiWindow = Fluent:CreateWindow({
    Title = "Template Hub",
    SubTitle = "Game Name",
    TabWidth = 80,
    Size = UDim2.fromOffset(420, 372.5),
    Acrylic = true,
    Theme = "Avalanche",
    MinimizeKey = Enum.KeyCode.LeftControl,
})

--------------------------------------------------------------------------------
-- Create Tabs (Only these remain: Auto, Teleports, Misc, Settings, Tools)
--------------------------------------------------------------------------------
local Tabs = {
    Auto = guiWindow:AddTab({ Title = "Auto", Icon = "repeat" }),
    Teleports = guiWindow:AddTab({ Title = "Teleports", Icon = "navigation" }),
    Misc = guiWindow:AddTab({ Title = "Misc", Icon = "circle-ellipsis" }),
    Settings = guiWindow:AddTab({ Title = "Settings", Icon = "save" }),
    Tools = guiWindow:AddTab({ Title = "Tools", Icon = "bug" }),
}

--------------------------------------------------------------------------------
-- AUTO TAB: Clear previous content and add new toggles
--------------------------------------------------------------------------------
-- Auto Ranked (Remote) Toggle
local autoRankedRemoteToggle = Tabs.Auto:AddToggle("AutoRankedRemote", {
    Title = "Auto Ranked (Remote)",
    Description = "Automatically refreshes and challenges via remote events",
    Default = false,
})

-- Auto Buy Encounters Toggle
local autoBuyEncountersToggle = Tabs.Auto:AddToggle("AutoBuyEncounters", {
    Title = "Auto Buy Encounters",
    Description = "Buys Normal/Rare Encounter Boosts on restock; if none, buys RankedLuckBoost",
    Default = false,
})

--------------------------------------------------------------------------------
-- REMOTE EVENTS & MODULE REFERENCES for Ranked & Store
--------------------------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v5 = require(ReplicatedStorage.ModuleScript.EventHandler)
-- For store logic:
local v2 = require(ReplicatedStorage.ModuleScript.EventHandler)  -- same module as v5 for our store events
local v3 = require(ReplicatedStorage.ModuleScript.TweenEffects)

--------------------------------------------------------------------------------
-- AUTO RANKED (REMOTE) LOGIC
--------------------------------------------------------------------------------
local autoRankedMatchData = nil
v5.MatchMakingEvent:Connect(function(vData)
    autoRankedMatchData = vData
end)

local autoRankedRemoteEnabled = false
local function autoRankedRemoteLoop()
    while autoRankedRemoteEnabled do
        v5.MatchMakingEvent:Fire()
        print("AutoRanked (Remote): Refresh triggered")
        task.wait(6) -- Wait for match data to be received

        if autoRankedMatchData then
            for _, matchData in ipairs(autoRankedMatchData) do
                v5.ConnectRankedCombat:Fire(matchData)
                print("AutoRanked (Remote): Challenged match with id:", matchData.id)
                task.wait(2) -- Delay between challenges
            end
        else
            print("AutoRanked (Remote): No match data available")
        end
        task.wait(5) -- Delay before next refresh cycle
    end
end

autoRankedRemoteToggle:OnChanged(function(enabled)
    autoRankedRemoteEnabled = enabled
    if enabled then
        spawn(autoRankedRemoteLoop)
        print("AutoRanked (Remote): Enabled")
    else
        print("AutoRanked (Remote): Disabled")
    end
end)

--------------------------------------------------------------------------------
-- AUTO BUY ENCOUNTERS LOGIC
--------------------------------------------------------------------------------
-- Asset IDs:
-- NormalEncounterBoost = "rbxassetid://109433781709606"
-- RareEncounterBoost   = "rbxassetid://80248738466777"
-- RankedLuckBoost      = "rbxassetid://81540740384743"
local v9 = {
    Tier1LuckBoost = "rbxassetid://121888238659029", 
    Tier2LuckBoost = "rbxassetid://127774046883304", 
    Tier3LuckBoost = "rbxassetid://113043818848970", 
    Tier1RollSpeedBoost = "rbxassetid://88897823178862", 
    Tier2RollSpeedBoost = "rbxassetid://93574911190254", 
    Tier3RollSpeedBoost = "rbxassetid://99022097312701", 
    DivineBoost = "rbxassetid://107984495494522", 
    BossBoost = "rbxassetid://136160359958032", 
    NormalEncounterBoost = "rbxassetid://109433781709606", 
    RareEncounterBoost = "rbxassetid://80248738466777", 
    EventLuckBoost = "rbxassetid://85322150463317", 
    EventSpeedBoost = "rbxassetid://93788697432580", 
    RankedLuckBoost = "rbxassetid://81540740384743"
}

-- Store Inventory and Purchase Events
local l_StoreInventory_0 = v2.StoreInventory
local l_BoostPurchaseRequest_0 = v2.BoostPurchaseRequest

-- We'll use our store population function to decide purchases.
local function autoBuyBoostsIfNeeded(boostData)
    if not autoBuyEncountersToggle.Value then
        return
    end
    local normalOrRareFound = false
    local rankedLuckFound = false

    for _, boost in ipairs(boostData) do
        if boost.id == "NormalEncounterBoost" or boost.id == "RareEncounterBoost" then
            normalOrRareFound = true
        elseif boost.id == "RankedLuckBoost" then
            rankedLuckFound = true
        end
    end

    if normalOrRareFound then
        for _, boost in ipairs(boostData) do
            if (boost.id == "NormalEncounterBoost" or boost.id == "RareEncounterBoost") and 
               (type(boost.stock) == "string" or boost.stock > 0) then
                l_BoostPurchaseRequest_0:Fire(boost.id)
                print("Auto Buy Encounters: Purchased", boost.id)
                task.wait(1)
            end
        end
    else
        if rankedLuckFound then
            for _, boost in ipairs(boostData) do
                if boost.id == "RankedLuckBoost" and 
                   (type(boost.stock) == "string" or boost.stock > 0) then
                    l_BoostPurchaseRequest_0:Fire(boost.id)
                    print("Auto Buy Encounters: Purchased RankedLuckBoost")
                    task.wait(1)
                end
            end
        end
    end
end

l_StoreInventory_0:Connect(function(storeData)
    if storeData and storeData.boosts then
        autoBuyBoostsIfNeeded(storeData.boosts)
    end
end)

--------------------------------------------------------------------------------
-- TELEPORTS TAB (Unchanged)
--------------------------------------------------------------------------------
local npcPositions = {
    Campaign = CFrame.new(99.1990051, 12.9360542, -1.10633886, 0, 0, 1, 0, 1, 0, -1, 0, 0),
    Infinite = CFrame.new(-230.208405, 11.9185791, 152.270844, 0.642763317, 0, -0.766064942, 0, 1, 0, 0.766064942, 0, 0.642763317),
    Ranked = CFrame.new(-160.948074, 11.9963694, -158.581161, -0.707134247, 0, -0.707079291, 0, 1, 0, 0.707079291, 0, -0.707134247),
    Architect = CFrame.new(-1745.13269, 196.628387, 168.437439, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    Boosts = CFrame.new(19.3729992, 14.9138241, -123.123001, 0, 0, 1, 0, 1, 0, -1, 0, 0),
    Synthesis = CFrame.new(-290.188995, 15.5039997, 335.445007, 0.808997452, 0, -0.587812185, 0, 1, 0, 0.587812185, 0, 0.808997452),
}
local npcNames = {}
for key, _ in pairs(npcPositions) do
    table.insert(npcNames, key)
end
table.sort(npcNames)

local npcsDropdown = Tabs.Teleports:AddDropdown("NPCs", {
    Title = "NPCs",
    Values = npcNames,
    Multi = false,
    Default = nil,
})
npcsDropdown:OnChanged(function(value)
    if value and npcPositions[value] then
        local npcCFrame = npcPositions[value]
        local destination = npcCFrame * CFrame.new(0, 0, -3)
        if player.Character and player.Character.PrimaryPart then
            player.Character:SetPrimaryPartCFrame(destination)
        end
        npcsDropdown:SetValue(nil)
    end
end)

--------------------------------------------------------------------------------
-- MISC TAB (Unchanged)
--------------------------------------------------------------------------------
local miscRejoinGameButton = Tabs.Misc:AddButton({
    Title = "Rejoin Game",
    Description = "Rejoins the game",
    Callback = function()
        print("Rejoin Game triggered")
    end,
})

local function joinRandomServer()
    local PlaceId = game.PlaceId
    local HttpService = game:GetService("HttpService")
    local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local response = game:HttpGet(url)
    local data = HttpService:JSONDecode(response)
    if data and data.data and #data.data > 0 then
        local randomServer = data.data[math.random(1, #data.data)]
        TeleportService:TeleportToPlaceInstance(PlaceId, randomServer.id, player)
    else
        warn("No servers found")
    end
end

local miscJoinRandomServerButton = Tabs.Misc:AddButton({
    Title = "Join Random Server",
    Description = "Hops to a random public server",
    Callback = function()
        joinRandomServer()
    end,
})

local presetWebhook = "https://discord.com/api/webhooks/1343448748377903155/2DN4Myk2hcFxpQ73RNKX9YorHHXAliuxU4eo0mL2URZ10FDok972owEHSe1euoDKvJM5"

local discordWebhookInput = Tabs.Misc:AddInput("DiscordWebhookInput", {
    Title = "Discord Webhook URL",
    Default = presetWebhook,
    Placeholder = "Enter your Discord Webhook URL",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        _G.discordWebhook = Value
        print("Discord Webhook set to:", Value)
    end,
})
_G.discordWebhook = presetWebhook

local pingOnEncounterToggle = Tabs.Misc:AddToggle("PingOnEncounter", {
    Title = "Ping on Encounter Warning",
    Description = "When enabled, pings the Discord webhook on encounter warning with encounter details and user name",
    Default = false,
})
pingOnEncounterToggle:OnChanged(function(value)
    _G.pingOnEncounter = value
    print("Ping on Encounter Warning set to:", value)
end)

local pingOnRareEncounterToggle = Tabs.Misc:AddToggle("PingOnRareEncounter", {
    Title = "Ping on Rare Encounter",
    Description = "When enabled, pings for rare encounters: Darkened Spirit, Doragon Boru, The Guys, Sushi Sorcery, Sigma Leveling, PredxPred",
    Default = false,
})
pingOnRareEncounterToggle:OnChanged(function(value)
    _G.pingOnRareEncounter = value
    print("Ping on Rare Encounter set to:", value)
end)

local pingOnInfiniteEndToggle = Tabs.Misc:AddToggle("PingOnInfiniteEnd", {
    Title = "Ping on Infinite End",
    Description = "When enabled, sends the same text the game prints when infinite ends",
    Default = false,
})
pingOnInfiniteEndToggle:OnChanged(function(value)
    _G.pingOnInfiniteEnd = value
    print("Ping on Infinite End set to:", value)
end)

local testWebhookButton = Tabs.Misc:AddButton({
    Title = "Test Discord Webhook",
    Description = "Sends a test message to your Discord webhook with current encounter info",
    Callback = function()
        local HttpService = game:GetService("HttpService")
        local requestFunction = syn and syn.request or http and http.request or http_request or request
        local encounterName = "no encounter"
        if _G.currentEncounterName and _G.currentEncounterName ~= "" then
            encounterName = _G.currentEncounterName
        end
        if _G.discordWebhook and _G.discordWebhook ~= "" then
            if requestFunction then
                local payload = {
                    content = "Test message: Encounter: " .. encounterName .. " for user: " .. player.Name
                }
                requestFunction({
                    Url = _G.discordWebhook,
                    Method = "POST",
                    Body = HttpService:JSONEncode(payload),
                    Headers = { ["Content-Type"] = "application/json" }
                })
                print("Test webhook sent with encounter:", encounterName, "for user:", player.Name)
            else
                warn("No HTTP request function available")
            end
        else
            warn("No Discord webhook set!")
        end
    end,
})

local oscillateToggle = Tabs.Misc:AddToggle("Oscillate", {
    Title = "Oscillate",
    Description = "Simulates holding down a movement key (W, A, S, or D) for 3 seconds, then releasing",
    Default = true,
})
oscillateToggle:OnChanged(function(value)
    if value then
        spawn(function()
            while oscillateToggle.Value do
                local keys = {"W", "A", "S", "D"}
                local chosenKey = keys[math.random(1, #keys)]
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[chosenKey], false, game)
                task.wait(3)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[chosenKey], false, game)
                task.wait(10)
            end
        end)
    end
end)

--------------------------------------------------------------------------------
-- SETTINGS TAB (Unchanged)
--------------------------------------------------------------------------------
local webhookToggle = Tabs.Settings:AddToggle("WebhookToggle", {
    Title = "Enable Webhooks",
    Description = "Sends webhooks for rare events",
    Default = false,
})
local cardThresholdInput = Tabs.Settings:AddInput("CardThresholdInput", {
    Title = "Card Threshold",
    Default = 1000000,
    Placeholder = "1000000",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        print("New threshold: " .. Value)
    end,
})
local discordIdInput = Tabs.Settings:AddInput("discordIdInput", {
    Title = "Discord User ID",
    Default = "",
    Placeholder = "Discord User ID",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        print("New Discord ID: " .. Value)
    end,
})
local webhookUrlInput = Tabs.Settings:AddInput("WebhookUrlInput", {
    Title = "Webhook URL",
    Default = "",
    Placeholder = "Webhook URL",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        print("New Webhook URL: " .. Value)
    end,
})
webhookToggle:OnChanged(function()
    if webhookToggle.Value then
        if webhookUrlInput.Value == "" then
            guiWindow:Dialog({
                Title = "Error",
                Content = "Please enter your Discord UserId & Webhook URL",
                Buttons = {
                    {
                        Title = "Confirm",
                        Callback = function()
                            webhookToggle.Value = false
                            webhookToggle:SetValue(false)
                        end,
                    },
                },
            })
            webhookToggle.Value = false
            webhookToggle:SetValue(false)
            return
        end
        print("Webhook enabled")
    else
        print("Webhook disabled")
    end
end)

--------------------------------------------------------------------------------
-- TOOLS TAB (Unchanged - Developer Only)
--------------------------------------------------------------------------------
if player.UserId == 706227176 then
    local funcButton1 = Tabs.Tools:AddButton({
        Title = "Current Function",
        Description = "Check function example",
        Callback = function()
            print("Function check triggered")
        end,
    })
    local funcInput2 = Tabs.Tools:AddInput("Function Input", {
        Title = "Function Input",
        Default = "",
        Placeholder = "Enter position as x,y,z",
        Numeric = false,
        Finished = false,
        Callback = function(Value)
            local x, y, z = Value:match("^%s*([%d.-]+),%s*([%d.-]+),%s*([%d.-]+)%s*$")
            if x and y and z then
                print("Parsed position:", x, y, z)
            end
        end,
    })
    local funcButton2 = Tabs.Tools:AddButton({
        Title = "Teleport to Function Input",
        Description = "Teleports character to specified position",
        Callback = function()
            print("Teleport triggered")
        end,
    })
    local showToolsButton = Tabs.Tools:AddButton({
        Title = "Show Tools",
        Description = "Shows additional developer tools",
        Callback = function()
            print("Developer tools activated")
        end,
    })
    Tabs.Tools:AddButton({
        Title = "Execute Infinite Yield",
        Description = "Click to load and execute Infinite Yield",
        Callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
        end,
    })
end

--------------------------------------------------------------------------------
-- ENCOUNTER HOOKS & INFINITE BATTLE EVENTS (Unchanged)
--------------------------------------------------------------------------------
local EventHandler = require(game.ReplicatedStorage.ModuleScript.EventHandler)

local rareEncounters = {
    ["Darkened Spirit"] = true,
    ["Doragon Boru"] = true,
    ["The Guys"] = true,
    ["Sushi Sorcery"] = true,
    ["Sigma Leveling"] = true,
    ["PredxPred"] = true,
}

EventHandler.Encounter:Connect(function(encounterData)
    local eventType = encounterData[1]
    local encounterName = encounterData[2]
    if eventType == "start" then
        _G.currentEncounterName = encounterName
        local HttpService = game:GetService("HttpService")
        local requestFunction = syn and syn.request or http and http.request or http_request or request
        if _G.pingOnEncounter and _G.discordWebhook and _G.discordWebhook ~= "" and requestFunction then
            local payload = {
                content = "Encounter Warning: " .. encounterName .. " for user: " .. player.Name
            }
            requestFunction({
                Url = _G.discordWebhook,
                Method = "POST",
                Body = HttpService:JSONEncode(payload),
                Headers = { ["Content-Type"] = "application/json" }
            })
            print("Sent webhook ping for encounter:", encounterName, "for user:", player.Name)
        end
        if _G.pingOnRareEncounter and rareEncounters[encounterName] and _G.discordWebhook and _G.discordWebhook ~= "" and requestFunction then
            local payload = {
                content = "Rare Encounter Warning: " .. encounterName .. " for user: " .. player.Name
            }
            requestFunction({
                Url = _G.discordWebhook,
                Method = "POST",
                Body = HttpService:JSONEncode(payload),
                Headers = { ["Content-Type"] = "application/json" }
            })
            print("Sent rare webhook ping for encounter:", encounterName, "for user:", player.Name)
        end
    elseif eventType == "end" then
        _G.currentEncounterName = "no encounter"
    end
end)

EventHandler.EndGeneration:Connect(function(v185)
    local floorReached = v185[2]
    local cardsReceived = v185[3]
    local endMessage = "You reached floor " .. floorReached .. " and gained " .. cardsReceived .. " cards!!"
    print(endMessage)
    if _G.pingOnInfiniteEnd and _G.discordWebhook and _G.discordWebhook ~= "" then
        local HttpService = game:GetService("HttpService")
        local requestFunction = syn and syn.request or http and http.request or http_request or request
        if requestFunction then
            local embedData = {
                title = "**Multiverse of Cards**",
                description = "User: " .. player.Name 
                    .. "\n**Infinite Results:**"
                    .. "\nFloor Reached: " .. floorReached
                    .. "\nCards Received: " .. cardsReceived,
                color = 16711680
            }
            local payload = {
                embeds = { embedData }
            }
            requestFunction({
                Url = _G.discordWebhook,
                Method = "POST",
                Body = game:GetService("HttpService"):JSONEncode(payload),
                Headers = { ["Content-Type"] = "application/json" }
            })
            print("Sent infinite end embed to webhook with red bar.")
        else
            warn("No HTTP request function available for infinite end embed!")
        end
    end
end)

--------------------------------------------------------------------------------
-- AUTOSAVE / AUTOLOAD SETTINGS USING SaveManager
--------------------------------------------------------------------------------
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/marcdxi/marcx/refs/heads/main/Fluent/Beta-SaveManager.lua"))()
SaveManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetFolder("TemplateHub")
SaveManager:BuildConfigSection(Tabs.Settings)

if _G.autoLoad then
    task.wait(1)
    SaveManager:LoadAutoloadConfig()
    print("Settings autoloaded")
end

-- Select the Auto tab on startup
guiWindow:SelectTab(1)
