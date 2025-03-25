--------------------------------------------------------------------------------
-- BR Hub using Fluent Renewed UI
--------------------------------------------------------------------------------
if game.PlaceId ~= 110829983956014 then
    return
end

if not game:IsLoaded() then
    game.Loaded:Wait()
end

--------------------------------------------------------------------------------
-- Load UI Libraries
--------------------------------------------------------------------------------
local Library = loadstring(game:HttpGetAsync("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()
local SaveManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/SaveManager.luau"))()
local InterfaceManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/InterfaceManager.luau"))()

--------------------------------------------------------------------------------
-- Roblox Services & Required Modules
--------------------------------------------------------------------------------
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local ProximityPromptService = game:GetService("ProximityPromptService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- Folder containing your potion objects – ensure this folder exists
local potionsFolder = Workspace:WaitForChild("Folder")

-- Modules – adjust paths as needed
local LocalUser = require(ReplicatedStorage.TS.user["local"]["local-user"]).LocalUser
local LocalGlobalStates = require(ReplicatedStorage.TS.states["global-states-client"]).LocalGlobalStates
local networkClient = require(ReplicatedStorage.TS.network.client)

--------------------------------------------------------------------------------
-- Define raid boss location (replace with your actual coordinates)
--------------------------------------------------------------------------------
local raidLocation = CFrame.new(-5285.70752, 161.93985, -500.400482, 0, -1, 0, 0, 0, 1, -1, 0, 0)

--------------------------------------------------------------------------------
-- Global variables declaration
--------------------------------------------------------------------------------
local autoPotionsEnabled = false
local autoInfiniteEnabled = false
local autoRaidEnabled = false
local antiAFKEnabled = false


-- Shared state for coordination between auto-features
local infinitePausedForRaid = false  -- Tracks if infinite was paused for a raid
local raidJustCompleted = false      -- Flag to signal raid just finished
local infiniteActive = false         -- Track if we're in an infinite run

-- Boss Farming
local bossCooldowns = {}
local BOSS_COOLDOWN_TIME = 600 -- 10 minutes in seconds
local bossWaitTime = 60 -- Default wait time between boss attempts
local farmingBosses = false

-- Use Item variables
local itemQuantity = 1
local autoUsingItems = false
local autoUseDelay = 5
local selectedAutoUseItem = "instant_roll_50"


-- Exploration variables
local autoExplorationEasyEnabled = false
local autoExplorationMediumEnabled = false
local autoExplorationHardEnabled = false
local explorationCheckDelay = 5 -- Check every 5 seconds


-- Define boss locations and IDs
local bosses = {
    -- Candy Island
    {name = "Soul Queen", id = "soul_queen", enabled = false},
    {name = "Mochi Emperor", id = "mochi_emperor", enabled = false},
    
    -- Demon Slayer
    {name = "Muzan", id = "awakened_pale_demon_lord", enabled = false},
    {name = "Kokushibo", id = "awakened_six_eyed_slayer", enabled = false},
    {name = "Doma", id = "awakened_frost_demon", enabled = false},
    {name = "Akaza", id = "compass_demon", enabled = false},
    {name = "Kaigaku", id = "thunder_demon", enabled = false},
    
    -- Titan City
    {name = "Eren", id = "combat_giant", enabled = false},
    
    -- Shibuya
    {name = "Sukuna", id = "king_of_curses", enabled = false},
    
    -- Namek
    {name = "Frieza", id = "awakened_galactic_tyrant", enabled = false},
    
    -- Leaf Village
    {name = "Naruto", id = "bijuu_beast", enabled = false}
}

--------------------------------------------------------------------------------
-- Create Window and Tabs
--------------------------------------------------------------------------------
local Window = Library:CreateWindow{
    Title = "BR Hub",
    SubTitle = "by .ftgs",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Resize = true,
    MinSize = Vector2.new(470, 380),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
}

local Tabs = {
    Main = Window:CreateTab{
        Title = "Main",
        Icon = "home"
    },
    BossFarm = Window:CreateTab{
        Title = "Boss Farm",
        Icon = "sword"
    },
    UseItem = Window:CreateTab{
        Title = "Use Item",
        Icon = "package"
    },
    Exploration = Window:CreateTab{ 
        Title = "Exploration",
        Icon = "map"
    },
    Settings = Window:CreateTab{
        Title = "Settings",
        Icon = "settings"
    }
}
-- Store options for easier access
local Options = Library.Options

--------------------------------------------------------------------------------
-- Create Interface Elements - Main Tab
--------------------------------------------------------------------------------
Tabs.Main:CreateParagraph("Welcome", {
    Title = "BR Hub Automation",
    Content = "• AutoPotions: Teleports above each potion and oscillates (L: 0.2 s, R: 0.3 s).\n" ..
              "• Auto-Infinite: Repeatedly triggers the infinite tower challenge.\n" ..
              "• Auto Raid: When a raid is active, teleports to the raid boss and presses E."
})

-- AUTO POTIONS TOGGLE
local autoPotionsToggle = Tabs.Main:CreateToggle("AutoPotions", {
    Title = "AutoPotions",
    Description = "Teleport above each potion in Folder then oscillate (L:0.2 s, R:0.3 s).",
    Default = false
})

autoPotionsToggle:OnChanged(function(state)
    autoPotionsEnabled = state
    print("AutoPotions:", state)
    if state then
        spawn(function()
            while autoPotionsEnabled do
                for _, item in ipairs(potionsFolder:GetChildren()) do
                    if not autoPotionsEnabled then break end
                    local bp = nil
                    if item:IsA("BasePart") then
                        bp = item
                    elseif item:IsA("Model") then
                        bp = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
                    end
                    if bp then
                        hrp.CFrame = bp.CFrame + Vector3.new(0, 3, 0)
                        print("AutoPotions: Teleported above", item.Name)
                        task.wait(0.3)
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.A, false, game)
                        task.wait(0.2)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.A, false, game)
                        task.wait(0.1)
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.D, false, game)
                        task.wait(0.3)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.D, false, game)
                        task.wait(0.5)
                    else
                        print("AutoPotions: Skipping", item.Name)
                    end
                    task.wait(0.5)
                end
                task.wait(1)
            end
        end)
    end
end)

-- AUTO INFINITE TOGGLE
local autoInfiniteToggle = Tabs.Main:CreateToggle("AutoInfinite", {
    Title = "Auto-Infinite",
    Description = "Triggers infinite tower challenge; ensures continuous runs after raids.",
    Default = false
})

autoInfiniteToggle:OnChanged(function(state)
    autoInfiniteEnabled = state
    print("Auto-Infinite:", state)
    
    if state then
        spawn(function()
            local consecutiveFailures = 0
            local MAX_FAILURES = 20  -- Prevent infinite loop if something is fundamentally wrong
            
            while autoInfiniteEnabled do
                -- Check raid state
                local raidState = LocalGlobalStates:getRaid()
                local raidActive = raidState.active
                
                -- Pause during active raid
                if raidActive and autoRaidEnabled then
                    print("Auto-Infinite: Raid active, waiting...")
                    task.wait(5)
                    continue
                end
                
                -- Attempt to start or continue infinite tower
                game:GetService("ReplicatedStorage"):WaitForChild("qVL"):WaitForChild("79f1b6e9-0e5d-49fa-b11e-063dcbcb1544"):FireServer()
                local startSuccess = pcall(function()
                    -- First, check if we're on a summary screen
                    local summaryFound = false
                    for _, instance in pairs(game:GetDescendants()) do
                        if instance:IsA("TextLabel") and instance.Text then
                            if instance.Text:find("Advancing to the next floor") or 
                               (instance.Text:find("Floor") and instance.Text:find("Summary")) then
                                summaryFound = true
                                
                                -- Try to click SKIP or CONTINUE LATER
                                for _, btn in pairs(game:GetDescendants()) do
                                    if btn:IsA("TextButton") or btn:IsA("TextLabel") then
                                        if btn.Text == "SKIP" or btn.Text == "CONTINUE LATER" then
                                            if btn:IsA("TextButton") then
                                                btn.MouseButton1Click:Fire()
                                            elseif btn.Parent and btn.Parent:IsA("TextButton") then
                                                btn.Parent.MouseButton1Click:Fire()
                                            end
                                            break
                                        end
                                    end
                                end
                                break
                            end
                        end
                    end
                    
                    -- If no summary screen, try to start a new run
                    if not summaryFound then
                        print("Auto-Infinite: Starting new tower run")
                        LocalUser.infiniteTower:start()
                        game:GetService("ReplicatedStorage"):WaitForChild("55B"):WaitForChild("897f9a78-7f89-42a3-8780-e664f83581e5"):FireServer()
                    end
                end)
                
                -- Track and handle potential issues
                if startSuccess then
                    consecutiveFailures = 0
                else
                    consecutiveFailures = consecutiveFailures + 1
                    print("Auto-Infinite: Start attempt failed. Consecutive failures:", consecutiveFailures)
                end
                
                -- Prevent potential infinite loop
                if consecutiveFailures >= MAX_FAILURES then
                    print("Auto-Infinite: Too many consecutive failures. Stopping.")
                    break
                end
                
                -- Wait between attempts
                task.wait(5)
            end
            
            print("Auto-Infinite: Loop ended")
        end)
    end
end)

-- AUTO RAID TOGGLE
local autoRaidToggle = Tabs.Main:CreateToggle("AutoRaid", {
    Title = "Auto Raid",
    Description = "Performs raid when available; coordinates with infinite mode.",
    Default = false
})

autoRaidToggle:OnChanged(function(state)
    autoRaidEnabled = state
    print("Auto Raid:", state)
    if state then
        spawn(function()
            local lastRaidState = false
            local raidStateCheckCount = 0
            
            while autoRaidEnabled do
                local raidState = LocalGlobalStates:getRaid()
                local raidActive = raidState.active
                
                -- Detect when raid transitions from active to inactive
                if lastRaidState and not raidActive then
                    print("Auto Raid: Raid just completed")
                    raidJustCompleted = true
                    infinitePausedForRaid = false
                    task.wait(1)
                end
                
                -- Extra check to ensure we're tracking state correctly
                if not raidActive and infinitePausedForRaid then
                    raidStateCheckCount = raidStateCheckCount + 1
                    if raidStateCheckCount >= 3 then
                        print("Auto Raid: Extra check - Raid inactive but infinite still paused, sending resume signal")
                        raidJustCompleted = true
                        infinitePausedForRaid = false
                        raidStateCheckCount = 0
                    end
                else
                    raidStateCheckCount = 0
                end
                
                lastRaidState = raidActive
                
                if raidActive then
                    -- Notify auto-infinite about raid
                    if autoInfiniteEnabled then
                        infinitePausedForRaid = true
                        print("Auto Raid: Signaling infinite to pause for raid")
                    end
                    
                    local success, errorMsg = pcall(function()
                        -- Use the staging location as the portal location
                        local portalLocation = CFrame.new(543.247253, 37.5526161, 86.8686905, 0.707134247, 0, 0.707079291, 0, 1, 0, -0.707079291, 0, 0.707134247)
                        hrp.CFrame = portalLocation
                        print("Auto Raid: Teleported to raid portal")
                        task.wait(1)
                        -- Access the Dragon model using FindFirstChild for reliability
                        local dragonFolder = Workspace:FindFirstChild("raid"):FindFirstChild("eternal_dragon")
                        local dragonModel = dragonFolder:FindFirstChild("Blue Eyes White Dragon")
                        local proximityPrompt = dragonModel:FindFirstChild("ProximityPrompt")

                        
                        if proximityPrompt and proximityPrompt:IsA("ProximityPrompt") then
                            print("Auto Raid: Found dragon proximity prompt")
                            
                            -- Store the original max distance
                            local originalDistance = proximityPrompt.MaxActivationDistance
                            
                            -- Temporarily increase the activation distance to a very large value
                            proximityPrompt.MaxActivationDistance = 100000
                            
                            -- Trigger the prompt
                            fireproximityprompt(proximityPrompt)
                            
                            -- Restore the original distance
                            proximityPrompt.MaxActivationDistance = originalDistance
                            
                            print("Auto Raid: Fired proximity prompt remotely")
                        else
                            print("Auto Raid: Could not find proximity prompt")
                            error("Proximity prompt not found")
                        end
                    end)
                    
                    if not success then
                        print("Auto Raid: Error with proximity prompt method -", errorMsg)
                        print("Auto Raid: Falling back to teleport method")
                        
                        -- Fall back to standard teleport method
                        local char = player.Character or player.CharacterAdded:Wait()
                        local hrp = char:WaitForChild("HumanoidRootPart")
                        
                        hrp.CFrame = raidLocation
                        print("Auto Raid: Teleported to dragon")
                        task.wait(0.5)
                        
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                        task.wait(0.1)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                        print("Auto Raid: Pressed E at dragon")
                    end
                    
                    -- Wait longer between raid checks
                    task.wait(10)
                else
                    task.wait(5)  -- Check for raid availability every 5 seconds
                end
            end
        end)
    end
end)

-- Raid Status Button
Tabs.Main:CreateButton{
    Title = "Check Raid Status",
    Description = "Shows the current status of the raid",
    Callback = function()
        local raidState = LocalGlobalStates:getRaid()
        
        -- Create a comprehensive status message
        local statusMsg = "Raid Status:\n"
        
        if raidState.active then
            statusMsg = statusMsg .. "• Active: YES\n"
        else
            statusMsg = statusMsg .. "• Active: NO\n"
        end
        
        if raidState.timeLeft then
            statusMsg = statusMsg .. "• Time Remaining: " .. math.floor(raidState.timeLeft) .. " seconds\n"
        end
        
        if infinitePausedForRaid then
            statusMsg = statusMsg .. "• Infinite Mode: Paused for raid\n"
        else
            statusMsg = statusMsg .. "• Infinite Mode: Normal operation\n"
        end
        
        -- Print to console
        print(statusMsg)
        
        -- Show notification
        Library:Notify{
            Title = "Raid Status",
            Content = statusMsg,
            Duration = 5
        }
    end
}

local antiAFKToggle = Tabs.Main:CreateToggle("AntiAFK", {
    Title = "Anti-AFK",
    Description = "Oscillates your character every 15 seconds to prevent AFK kick",
    Default = false
})

antiAFKToggle:OnChanged(function(state)
    antiAFKEnabled = state
    print("Anti-AFK:", state)
    if state then
        spawn(function()
            while antiAFKEnabled do
                -- Wait 15 seconds between movements
                task.wait(15)
                
                -- Skip if not enabled anymore
                if not antiAFKEnabled then break end
                
                -- Oscillate left-right
                print("Anti-AFK: Oscillating")
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.A, false, game)
                task.wait(0.2)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.A, false, game)
                task.wait(0.1)
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.D, false, game)
                task.wait(0.3)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.D, false, game)
            end
        end)
    end
end)

--------------------------------------------------------------------------------
-- Boss Farm Functions
--------------------------------------------------------------------------------
local function fightBoss(bossInfo)
    print("Fighting boss: " .. bossInfo.name .. " (ID: " .. bossInfo.id .. ")")
    
    -- Use the remote event to trigger the boss fight
    local args = {
        [1] = bossInfo.id
    }
    
    local remote = ReplicatedStorage:WaitForChild("qVL"):WaitForChild("a61f4b02-e14f-4033-ab17-d37283df7c91")
    
    
    -- Attempt to fire the remote
    local success = pcall(function()
        remote:FireServer(unpack(args))
    end)
    
    if success then
        -- Set cooldown (we'll assume the fight worked if the remote fired)
        bossCooldowns[bossInfo.id] = os.time() + BOSS_COOLDOWN_TIME
        print("Set cooldown for " .. bossInfo.name .. ". Ready again in " .. BOSS_COOLDOWN_TIME .. " seconds.")
        return true
    else
        print("Failed to fight boss: " .. bossInfo.name .. ". Moving to next boss.")
        return false
    end
end


local function startBossFarming()
    if farmingBosses then return end
    
    farmingBosses = true
    
    spawn(function()
        print("Starting boss farm loop")
        while farmingBosses do
            local raidState = LocalGlobalStates:getRaid()
            if autoRaidEnabled and raidState.active then
                print("Raid is active, pausing boss farm")
                task.wait(5)
            else
                local farmedAny = false
                
                -- Check each boss
                for _, bossInfo in ipairs(bosses) do
                    -- Skip if this boss's toggle is off
                    if not bossInfo.enabled then
                        continue
                    end
                    
                    -- Check if boss is on cooldown
                    local cooldownEnd = bossCooldowns[bossInfo.id]
                    if cooldownEnd and os.time() < cooldownEnd then
                        local remainingTime = cooldownEnd - os.time()
                        print(bossInfo.name .. " on cooldown. " .. remainingTime .. " seconds remaining.")
                        continue
                    end
                    
                    -- Try to fight this boss
                    if fightBoss(bossInfo) then
                        farmedAny = true
                        
                        -- Wait between bosses
                        print("Waiting " .. bossWaitTime .. " seconds before next boss")
                        task.wait(bossWaitTime)
                    else
                        -- If boss fight failed, add a short wait before trying the next boss
                        task.wait(2)
                    end
                    
                    -- Check if we need to stop
                    if not farmingBosses then
                        break
                    end
                    
                    -- Check for raid again
                    raidState = LocalGlobalStates:getRaid()
                    if autoRaidEnabled and raidState.active then
                        print("Raid became active, pausing boss farm")
                        break
                    end
                end
                
                -- If no bosses were farmed, wait a bit before checking again
                if not farmedAny then
                    print("All bosses on cooldown or disabled, waiting...")
                    task.wait(10)
                end
            end
        end
        print("Boss farming stopped")
    end)
end

local function stopBossFarming()
    farmingBosses = false
    print("Boss farming stopped")
end



--------------------------------------------------------------------------------
-- Create Interface Elements - Boss Farm Tab
--------------------------------------------------------------------------------
Tabs.BossFarm:CreateParagraph("BossFarmInfo", {
    Title = "Boss Farm System",
    Content = "Toggle the bosses you want to farm below. When 'Auto Farm Bosses' is enabled, the system will automatically fight each enabled boss and respect cooldowns."
})

-- Wait time slider
local bossWaitSlider = Tabs.BossFarm:CreateSlider("BossWaitTime", {
    Title = "Wait Between Bosses",
    Description = "Time to wait between boss attempts (seconds)",
    Default = bossWaitTime,
    Min = 10,
    Max = 120,
    Rounding = 0,
    Callback = function(value)
        bossWaitTime = value
        print("Boss wait time set to:", value, "seconds")
    end
})


--------------------------------------------------------------------------------
-- Start the UI
--------------------------------------------------------------------------------
Window:SelectTab(1)

Library:Notify{
    Title = "BR Hub Loaded",
    Content = "Welcome to BR Hub! New Use Item tab has been added.",
    Duration = 5
}

print("BR Hub loaded with Fluent Renewed UI")

-- Create boss toggle sections
Tabs.BossFarm:CreateParagraph("CandyIslandBosses", {
    Title = "Candy Island Bosses"
})

-- Boss Toggles - Candy Island
local soulQueenToggle = Tabs.BossFarm:CreateToggle("SoulQueen", {
    Title = "Soul Queen",
    Default = bosses[1].enabled
})

soulQueenToggle:OnChanged(function(state)
    bosses[1].enabled = state
    print("Soul Queen farming:", state)
end)

local mochiEmperorToggle = Tabs.BossFarm:CreateToggle("MochiEmperor", {
    Title = "Mochi Emperor",
    Default = bosses[2].enabled
})

mochiEmperorToggle:OnChanged(function(state)
    bosses[2].enabled = state
    print("Mochi Emperor farming:", state)
end)

Tabs.BossFarm:CreateParagraph("DemonSlayerBosses", {
    Title = "Demon Slayer Bosses"
})

-- Boss Toggles - Demon Slayer
local muzanToggle = Tabs.BossFarm:CreateToggle("Muzan", {
    Title = "Muzan",
    Default = bosses[3].enabled
})

muzanToggle:OnChanged(function(state)
    bosses[3].enabled = state
    print("Muzan farming:", state)
end)

local kokushiboToggle = Tabs.BossFarm:CreateToggle("Kokushibo", {
    Title = "Kokushibo",
    Default = bosses[4].enabled
})

kokushiboToggle:OnChanged(function(state)
    bosses[4].enabled = state
    print("Kokushibo farming:", state)
end)

local domaToggle = Tabs.BossFarm:CreateToggle("Doma", {
    Title = "Doma",
    Default = bosses[5].enabled
})

domaToggle:OnChanged(function(state)
    bosses[5].enabled = state
    print("Doma farming:", state)
end)

local akazaToggle = Tabs.BossFarm:CreateToggle("Akaza", {
    Title = "Akaza",
    Default = bosses[6].enabled
})

akazaToggle:OnChanged(function(state)
    bosses[6].enabled = state
    print("Akaza farming:", state)
end)

local kaigakuToggle = Tabs.BossFarm:CreateToggle("Kaigaku", {
    Title = "Kaigaku",
    Default = bosses[7].enabled
})

kaigakuToggle:OnChanged(function(state)
    bosses[7].enabled = state
    print("Kaigaku farming:", state)
end)

Tabs.BossFarm:CreateParagraph("OtherBosses", {
    Title = "Other Bosses"
})

-- Boss Toggles - Other
local erenToggle = Tabs.BossFarm:CreateToggle("Eren", {
    Title = "Eren (Titan City)",
    Default = bosses[8].enabled
})

erenToggle:OnChanged(function(state)
    bosses[8].enabled = state
    print("Eren farming:", state)
end)

local sukunaToggle = Tabs.BossFarm:CreateToggle("Sukuna", {
    Title = "Sukuna (Shibuya)",
    Default = bosses[9].enabled
})

sukunaToggle:OnChanged(function(state)
    bosses[9].enabled = state
    print("Sukuna farming:", state)
end)

local friezaToggle = Tabs.BossFarm:CreateToggle("Frieza", {
    Title = "Frieza (Namek)",
    Default = bosses[10].enabled
})

friezaToggle:OnChanged(function(state)
    bosses[10].enabled = state
    print("Frieza farming:", state)
end)

local narutoToggle = Tabs.BossFarm:CreateToggle("Naruto", {
    Title = "Naruto (Leaf Village)",
    Default = bosses[11].enabled
})

narutoToggle:OnChanged(function(state)
    bosses[11].enabled = state
    print("Naruto farming:", state)
end)

Tabs.BossFarm:CreateParagraph("FarmControls", {
    Title = "Farm Controls"
})

-- Auto Farm Bosses Toggle
local farmBossesToggle = Tabs.BossFarm:CreateToggle("AutoFarmBosses", {
    Title = "Auto Farm Bosses",
    Description = "Start farming all enabled bosses automatically",
    Default = false
})

farmBossesToggle:OnChanged(function(state)
    if state then
        -- Check if any bosses are enabled
        local anyEnabled = false
        for _, bossInfo in pairs(bosses) do
            if bossInfo.enabled then
                anyEnabled = true
                break
            end
        end
        
        if not anyEnabled then
            Library:Notify{
                Title = "No Bosses Enabled",
                Content = "Please enable at least one boss before starting auto-farm.",
                Duration = 5
            }
            farmBossesToggle:SetValue(false)
            return
        end
        
        startBossFarming()
    else
        stopBossFarming()
    end
end)

-- Clear Cooldowns Button
Tabs.BossFarm:CreateButton{
    Title = "Clear All Cooldowns",
    Description = "Reset all boss cooldowns (for testing)",
    Callback = function()
        bossCooldowns = {}
        Library:Notify{
            Title = "Cooldowns Cleared",
            Content = "All boss cooldowns have been reset.",
            Duration = 3
        }
        print("All boss cooldowns cleared")
    end
}

--------------------------------------------------------------------------------
-- Create Interface Elements - Use Item Tab
--------------------------------------------------------------------------------
-- Function to use items with the remote
local function useItem(itemId, quantity)
    local args = {
        [1] = itemId,
        [2] = quantity
    }
    
    local remote = ReplicatedStorage:WaitForChild("qVL"):WaitForChild("e32a2177-aaa6-4699-af19-bf43b65222f9")
    
    local success = pcall(function()
        remote:FireServer(unpack(args))
    end)
    
    if success then
        print("Used " .. quantity .. "x " .. itemId)
        return true
    else
        print("Failed to use item:", itemId)
        return false
    end
end

local args = {
    [1] = "instant_roll_100",
    [2] = 10
}







-- Input for quantity
local quantityInput = Tabs.UseItem:CreateInput("ItemQuantity", {
    Title = "Quantity",
    Default = "1",
    Placeholder = "Enter quantity",
    Numeric = true,
    Finished = true,
    Callback = function(value)
        local num = tonumber(value)
        if num and num > 0 then
            itemQuantity = num
        else
            quantityInput:SetValue("1")
            itemQuantity = 1
        end
    end
})

-- Item selector dropdown
Tabs.UseItem:CreateDropdown("ItemSelector", {
    Title = "Select Item",
    Values = {
        "instant_roll_50", 
        "instant_roll_100", 
        "instant_roll_500", 
        "instant_roll_1000",
        "moon_cycle_reroll_potion", 
        "boss_chance_potion", 
        "border_chance_potion",
        "large_luck_potion", 
        "large_cooldown_reduction_potion",
        "instant_roll_10000",
    },
    Multi = false,
    Default = 1,
    Callback = function(value) 
        selectedItem = value 
    end
})

-- Use button
Tabs.UseItem:CreateButton{
    Title = "Use Item",
    Description = "Use selected item with specified quantity",
    Callback = function()
        useItem(selectedItem, itemQuantity)
    end
}
--------------------------------------------------------------------------------
-- Create Interface Elements - Exploration Tab
--------------------------------------------------------------------------------
Tabs.Exploration:CreateParagraph("ExplorationInfo", {
    Title = "Exploration System",
    Content = "Auto Exploration will automatically claim completed explorations and start new ones. You can enable different difficulties independently."
})

-- Functions to start explorations of different difficulties
local function startEasyExploration()
    local args = {
        [1] = "easy",
        [2] = {
            [1] = "green_bomber:rainbow",
            [2] = "green_bomber:rainbow",
            [3] = "green_bomber:rainbow",
            [4] = "green_bomber:rainbow"
        }
    }
    
    local success = pcall(function()
        game:GetService("ReplicatedStorage"):WaitForChild("qVL"):WaitForChild("41d7a9bf-4307-4be1-a805-b6e642a7fdce"):FireServer(unpack(args))
    end)
    
    if success then
        print("Started new easy exploration")
    else
        print("Failed to start easy exploration")
    end
end


local function startMediumExploration()
    local args = {
        [1] = "medium",
        [2] = {
            [1] = "red_pilot",
            [2] = "red_pilot",
            [3] = "red_pilot",
            [4] = "red_pilot"
        }
    }
    
    local success = pcall(function()
        game:GetService("ReplicatedStorage"):WaitForChild("qVL"):WaitForChild("41d7a9bf-4307-4be1-a805-b6e642a7fdce"):FireServer(unpack(args))
    end)
    
    if success then
        print("Started new medium exploration")
    else
        print("Failed to start medium exploration")
    end
end


local function startHardExploration()
    local args = {
        [1] = "hard",
        [2] = {
            [1] = "fire_dragon:gold",
            [2] = "fire_dragon:gold",
            [3] = "the_impure_ghost",
            [4] = "stark_gunner:gold"
        }
    }
    
    local success = pcall(function()
        game:GetService("ReplicatedStorage"):WaitForChild("qVL"):WaitForChild("41d7a9bf-4307-4be1-a805-b6e642a7fdce"):FireServer(unpack(args))
    end)
    
    if success then
        print("Started new hard exploration")
    else
        print("Failed to start hard exploration")
    end
end




-- Functions to claim explorations of different difficulties
local function claimEasyExploration()
    local args = {
        [1] = "easy"
    }
    
    local success = pcall(function()
    game:GetService("ReplicatedStorage"):WaitForChild("qVL"):WaitForChild("80184641-5833-40a8-b25f-d75128c8d8cf"):FireServer(unpack(args))
    end)
    
    if success then
        print("Claimed easy exploration")
        return true
    else
        print("Failed to claim easy exploration")
        return false
    end
end





local function claimMediumExploration()
    local args = {
        [1] = "medium"
    }
    
    local success = pcall(function()
    game:GetService("ReplicatedStorage"):WaitForChild("qVL"):WaitForChild("80184641-5833-40a8-b25f-d75128c8d8cf"):FireServer(unpack(args))
    end)
    
    if success then
        print("Claimed medium exploration")
        return true
    else
        print("Failed to claim medium exploration")
        return false
    end
end

local function claimHardExploration()
    local args = {
        [1] = "hard"
    }
    
    local success = pcall(function()
    game:GetService("ReplicatedStorage"):WaitForChild("qVL"):WaitForChild("80184641-5833-40a8-b25f-d75128c8d8cf"):FireServer(unpack(args))
    end)
    
    if success then
        print("Claimed hard exploration")
        return true
    else
        print("Failed to claim hard exploration")
        return false
    end
end

-- Exploration toggles section
Tabs.Exploration:CreateParagraph("ExplorationToggles", {
    Title = "Auto Exploration Toggles"
})

-- Auto Easy Exploration Toggle
local autoEasyExplorationToggle = Tabs.Exploration:CreateToggle("AutoEasyExploration", {
    Title = "Auto Exploration: Easy",
    Description = "Automatically claims and restarts easy explorations",
    Default = false
})

autoEasyExplorationToggle:OnChanged(function(state)
    autoExplorationEasyEnabled = state
    print("Auto Easy Exploration:", state)
    
    if state then
        spawn(function()
            while autoExplorationEasyEnabled do
                -- Try to claim first
                claimEasyExploration()
                
                -- Wait a brief moment
                task.wait(1)
                
                -- Start a new one
                startEasyExploration()
                
                -- Wait before checking again
                task.wait(explorationCheckDelay)
            end
        end)
    end
end)

-- Auto Medium Exploration Toggle
local autoMediumExplorationToggle = Tabs.Exploration:CreateToggle("AutoMediumExploration", {
    Title = "Auto Exploration: Medium",
    Description = "Automatically claims and restarts medium explorations",
    Default = false
})

autoMediumExplorationToggle:OnChanged(function(state)
    autoExplorationMediumEnabled = state
    print("Auto Medium Exploration:", state)
    
    if state then
        spawn(function()
            while autoExplorationMediumEnabled do
                -- Try to claim first
                claimMediumExploration()
                
                -- Wait a brief moment
                task.wait(1)
                
                -- Start a new one
                startMediumExploration()
                
                -- Wait before checking again
                task.wait(explorationCheckDelay)
            end
        end)
    end
end)

-- Auto Hard Exploration Toggle
local autoHardExplorationToggle = Tabs.Exploration:CreateToggle("AutoHardExploration", {
    Title = "Auto Exploration: Hard",
    Description = "Automatically claims and restarts hard explorations",
    Default = false
})

autoHardExplorationToggle:OnChanged(function(state)
    autoExplorationHardEnabled = state
    print("Auto Hard Exploration:", state)
    
    if state then
        spawn(function()
            while autoExplorationHardEnabled do
                -- Try to claim first
                claimHardExploration()
                
                -- Wait a brief moment
                task.wait(1)
                
                -- Start a new one
                startHardExploration()
                
                -- Wait before checking again
                task.wait(explorationCheckDelay)
            end
        end)
    end
end)

-- Settings section
Tabs.Exploration:CreateParagraph("ExplorationSettings", {
    Title = "Exploration Settings"
})

-- Exploration Check Delay Slider
Tabs.Exploration:CreateSlider("ExplorationCheckDelay", {
    Title = "Check Delay",
    Description = "Seconds between exploration cycles",
    Default = explorationCheckDelay,
    Min = 1,
    Max = 30,
    Rounding = 0,
    Callback = function(value)
        explorationCheckDelay = value
        print("Exploration check delay set to:", value, "seconds")
    end
})

-- Manual controls section
Tabs.Exploration:CreateParagraph("ManualControls", {
    Title = "Manual Controls"
})

-- Manual Exploration Buttons
Tabs.Exploration:CreateButton{
    Title = "Start Easy Exploration",
    Description = "Manually start a new easy exploration",
    Callback = function()
        startEasyExploration()
    end
}

Tabs.Exploration:CreateButton{
    Title = "Claim Easy Exploration",
    Description = "Manually claim completed easy exploration",
    Callback = function()
        claimEasyExploration()
    end
}

Tabs.Exploration:CreateButton{
    Title = "Start Medium Exploration",
    Description = "Manually start a new medium exploration",
    Callback = function()
        startMediumExploration()
    end
}

Tabs.Exploration:CreateButton{
    Title = "Claim Medium Exploration",
    Description = "Manually claim completed medium exploration",
    Callback = function()
        claimMediumExploration()
    end
}

Tabs.Exploration:CreateButton{
    Title = "Start Hard Exploration",
    Description = "Manually start a new hard exploration",
    Callback = function()
        startHardExploration()
    end
}

Tabs.Exploration:CreateButton{
    Title = "Claim Hard Exploration",
    Description = "Manually claim completed hard exploration",
    Callback = function()
        claimHardExploration()
    end
}

--------------------------------------------------------------------------------
-- Settings Tab Configuration
--------------------------------------------------------------------------------
-- Setup SaveManager and InterfaceManager
SaveManager:SetLibrary(Library)
InterfaceManager:SetLibrary(Library)

-- Configure folders for the interface and settings
InterfaceManager:SetFolder("BR-Hub")
SaveManager:SetFolder("BR-Hub")

-- Ignore specific settings
SaveManager:IgnoreThemeSettings()

-- Set the list of toggles/options that get saved
SaveManager:SetIgnoreIndexes({})

-- Build the settings UI
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- Auto-load the designated config
SaveManager:LoadAutoloadConfig()

-- Add About section to Settings tab
Tabs.Settings:CreateParagraph("AboutSection", {
    Title = "About BR Hub",
    Content = "Version: 1.1.0\n" ..
              "Creator: .ftgs\n" ..
              "UI Library: Fluent Renewed by Actual Master Oogway\n\n" ..
              "Thank you for using BR Hub!"
})


--------------------------------------------------------------------------------
-- Start the UI
--------------------------------------------------------------------------------
Window:SelectTab(1)

Library:Notify{
    Title = "BR Hub Loaded",
    Content = "Welcome to BR Hub! Settings are loaded automatically.",
    Duration = 5
}

print("BR Hub loaded with Fluent Renewed UI")
