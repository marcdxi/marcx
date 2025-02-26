-- Uncomment or add this line at the very top to ensure autoload is enabled:
_G.autoLoad = true

-- Only load the GUI in the desired game (optional)
-- if game.PlaceId ~= 0 and game.PlaceId ~= 18417225778 then
--     return
-- end

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

-- Roblox Services
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")

-- Load Fluent UI Library from its URL
local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/marcdxi/marcx/refs/heads/main/Fluent/BetaFluent.lua"))()

-- Create the GUI Window using Fluent
local guiWindow = Fluent:CreateWindow({
    Title = "Template Hub",
    SubTitle = "Game Name",
    TabWidth = 80,
    Size = UDim2.fromOffset(420, 372.5),
    Acrylic = true,
    Theme = "Avalanche",
    MinimizeKey = Enum.KeyCode.LeftControl,
})

-- Create Tabs
local Tabs = {
    Main = guiWindow:AddTab({ Title = "Main", Icon = "info" }),
    Auto = guiWindow:AddTab({ Title = "Auto", Icon = "repeat" }),
    Stats = guiWindow:AddTab({ Title = "Stats", Icon = "bar-chart" }),
    Teleports = guiWindow:AddTab({ Title = "Teleports", Icon = "navigation" }),
    Cards = guiWindow:AddTab({ Title = "Cards", Icon = "book-open" }),
    Codes = guiWindow:AddTab({ Title = "Codes", Icon = "baseline" }),
    Misc = guiWindow:AddTab({ Title = "Misc", Icon = "circle-ellipsis" }),
    Settings = guiWindow:AddTab({ Title = "Settings", Icon = "save" }),
    Tools = guiWindow:AddTab({ Title = "Tools", Icon = "bug" }),
}

-- Main Tab
Tabs.Main:AddParagraph({
    Title = "Information",
    Content = "Version: v_" .. version .. "_" .. release .. "\nMade By: YourName\n\nExtra: Customizable Hub Script Template"
})
Tabs.Main:AddParagraph({
    Title = "Latest",
    Content = "Latest Changes:\n- Added template structure\n- Placeholder for future features"
})

-- Auto Tab
local farmSection = Tabs.Auto:AddSection("Farm")
local autoPotionsToggle = Tabs.Auto:AddToggle("AutoPotions", {
    Title = "Auto Potions",
    Description = "Automatically collects potions",
    Default = false,
})
local autoSwordToggle = Tabs.Auto:AddToggle("AutoSword", {
    Title = "Auto Sword",
    Description = "Automatically claims sword",
    Default = false,
})

local battleSection = Tabs.Auto:AddSection("Battle")
local autoRaidToggle = Tabs.Auto:AddToggle("AutoRaid", {
    Title = "Auto Raid",
    Description = "Automatically starts raids",
    Default = false,
})
local autoInfiniteToggle = Tabs.Auto:AddToggle("AutoInfinite", {
    Title = "Auto Infinite",
    Description = "Automatically starts infinite battles",
    Default = false,
})
local autoRankedToggle = Tabs.Auto:AddToggle("AutoRanked", {
    Title = "Auto Ranked",
    Description = "Automatically starts ranked battles",
    Default = false,
})
local autoCloseResultToggle = Tabs.Auto:AddToggle("AutoCloseResult", {
    Title = "Auto Close Result",
    Description = "Automatically closes results",
    Default = false,
})
local autoHideBattleToggle = Tabs.Auto:AddToggle("AutoHideBattle", {
    Title = "Auto Hide Battle",
    Description = "Automatically hides battle UI",
    Default = false,
})

local miscSectionAuto = Tabs.Auto:AddSection("Misc")
local claimChestButton = Tabs.Auto:AddButton({
    Title = "Claim Daily Chest",
    Description = "Claims the daily chest",
    Callback = function()
        print("Claim Daily Chest triggered")
    end,
})

-- Stats Tab
local farmParagraph = Tabs.Stats:AddParagraph({
    Title = "Farm",
    Content = "Potions Collected: N/A\nSword Cooldown: N/A"
})
local battleParagraph = Tabs.Stats:AddParagraph({
    Title = "Battle",
    Content = "Raid Status: N/A\nTotal Damage: N/A / N/A\nDamage Dealt: N/A\nHighest Floor: N/A\nPrevious Run: N/A\nCurrent Run: N/A"
})
local hubInfoParagraph = Tabs.Stats:AddParagraph({
    Title = "Extra",
    Content = "Uptime: N/A\nAnti-AFK: N/A\nAutoLoad: N/A"
})

-- Teleports Tab
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
        -- Teleport to a position 3 studs in front of the NPC (using its LookVector)
        local destination = npcCFrame * CFrame.new(0, 0, -3)
        if player.Character and player.Character.PrimaryPart then
            player.Character:SetPrimaryPartCFrame(destination)
        end
        npcsDropdown:SetValue(nil)
    end
end)

-- Cards Tab
local selectCardDropdown = Tabs.Cards:AddDropdown("Select Card", {
    Title = "Card",
    Values = {"Card1", "Card2", "Card3"},
    Multi = false,
    Default = nil,
})
local cardDataParagraph = Tabs.Cards:AddParagraph({
    Title = "Card Info",
    Content = "Name: \nOrigin: \nSeries: \nCardPack: \nGender: \nAlignment: \nChance: \nPassive: \nDescription:"
})

-- Codes Tab
local claimCodesButton = Tabs.Codes:AddButton({
    Title = "Claim All Codes",
    Description = "Claims all codes",
    Callback = function()
        print("Claim All Codes triggered")
    end,
})
local copyCodesButton = Tabs.Codes:AddButton({
    Title = "Copy All Codes",
    Description = "Copies all codes",
    Callback = function()
        print("Copy All Codes triggered")
    end,
})
local codeInfoParagraph = Tabs.Codes:AddParagraph({
    Title = "SCROLL DOWN",
    Content = "Total Codes: 3\nSome Codes Might Not Work\nNewest -> Oldest"
})
local codesSection = Tabs.Codes:AddSection("List Of Codes")
local function displayCodesInParagraphs()
    local codes = {"CODE1", "CODE2", "CODE3"}
    local MAX_CODES_PER_PARAGRAPH = 15
    local codeCount = #codes
    local numChunks = math.ceil(codeCount / MAX_CODES_PER_PARAGRAPH)
    local codesPerChunk = math.ceil(codeCount / numChunks)
    local startIndex = codeCount
    while startIndex > 0 do
        local endIndex = math.max(startIndex - codesPerChunk + 1, 1)
        local codesChunk = ""
        for i = startIndex, endIndex, -1 do
            codesChunk = codesChunk .. codes[i]
            if i > endIndex then
                codesChunk = codesChunk .. "\n"
            end
        end
        Tabs.Codes:AddParagraph({
            Title = "Page " .. tostring(math.ceil((codeCount - startIndex + 1) / codesPerChunk)),
            Content = codesChunk,
        })
        startIndex = endIndex - 1
    end
end
displayCodesInParagraphs()

-- Misc Tab
local miscRejoinGameButton = Tabs.Misc:AddButton({
    Title = "Rejoin Game",
    Description = "Rejoins the game",
    Callback = function()
        print("Rejoin Game triggered")
    end,
})
-- New: Join Random Server button
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

-- In the Misc Tab, add inputs for Discord webhook settings
local discordWebhookInput = Tabs.Misc:AddInput("DiscordWebhookInput", {
    Title = "Discord Webhook URL",
    Default = "",
    Placeholder = "Enter your Discord Webhook URL",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        _G.discordWebhook = Value
        print("Discord Webhook set to:", Value)
    end,
})
local pingOnEncounterToggle = Tabs.Misc:AddToggle("PingOnEncounter", {
    Title = "Ping on Encounter Warning",
    Description = "When enabled, pings the Discord webhook on encounter warning with encounter details and user name",
    Default = false,
})
pingOnEncounterToggle:OnChanged(function(value)
    _G.pingOnEncounter = value
    print("Ping on Encounter Warning set to:", value)
end)
-- Add a Test Discord Webhook button below the webhook text box.
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
                    Headers = {
                        ["Content-Type"] = "application/json"
                    }
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

-- Misc Tab: Oscillate Toggle (Simulate key press for movement)
local oscillateToggle = Tabs.Misc:AddToggle("Oscillate", {
    Title = "Oscillate",
    Description = "Simulates holding down a movement key (W, A, S, or D) for 3 seconds, then releasing",
    Default = false,
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
                task.wait(10) -- Wait 10 seconds before next movement
            end
        end)
    end
end)

-- Settings Tab
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
                        Callback = function() webhookToggle.Value = false end,
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

-- Tools Tab (Developer Only)
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

-- Select the Main Tab on Start
guiWindow:SelectTab(1)

-- EXTRA: Hook into the Encounter event to store the current encounter name and send a Discord ping when an encounter starts
local EventHandler = require(game.ReplicatedStorage.ModuleScript.EventHandler)
EventHandler.Encounter:Connect(function(encounterData)
    if encounterData[1] == "start" then
        local encounterName = encounterData[2]
        _G.currentEncounterName = encounterName
        if _G.pingOnEncounter and _G.discordWebhook and _G.discordWebhook ~= "" then
            local HttpService = game:GetService("HttpService")
            local requestFunction = syn and syn.request or http and http.request or http_request or request
            if requestFunction then
                local payload = {
                    content = "Encounter Warning: " .. encounterName .. " for user: " .. player.Name
                }
                requestFunction({
                    Url = _G.discordWebhook,
                    Method = "POST",
                    Body = HttpService:JSONEncode(payload),
                    Headers = {
                        ["Content-Type"] = "application/json"
                    }
                })
                print("Sent webhook ping for encounter:", encounterName, "for user:", player.Name)
            else
                warn("No HTTP request function available")
            end
        end
    elseif encounterData[1] == "end" then
        _G.currentEncounterName = "no encounter"
    end
end)

-- AUTOSAVE / AUTOLOAD SETTINGS USING SaveManager
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
