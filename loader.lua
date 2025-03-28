--[[
    Ecynx - Da Hood Cheat Loader
    Created by sane
    
    This is the main loader script for the Ecynx cheat.
    It loads all modules and initializes the cheat with the requested features.
]]

-- Loader Information
local EcynxInfo = {
    Name = "Ecynx",
    Version = "Beta",
    Creator = "saneishere",
    LastUpdated = "March 26, 2025"
}

-- Print loading message
local function printLogo()
    print([[
    
    ███████╗ ██████╗██╗   ██╗███╗   ██╗██╗  ██╗
    ██╔════╝██╔════╝╚██╗ ██╔╝████╗  ██║╚██╗██╔╝
    █████╗  ██║      ╚████╔╝ ██╔██╗ ██║ ╚███╔╝ 
    ██╔══╝  ██║       ╚██╔╝  ██║╚██╗██║ ██╔██╗ 
    ███████╗╚██████╗   ██║   ██║ ╚████║██╔╝ ██╗
    ╚══════╝ ╚═════╝   ╚═╝   ╚═╝  ╚═══╝╚═╝  ╚═╝
                                              
    ]])
    
    print("Loading " .. EcynxInfo.Name .. " " .. EcynxInfo.Version .. " by " .. EcynxInfo.Creator)
    print("Last Updated: " .. EcynxInfo.LastUpdated)
    print("Initializing...")
end

-- Check if game is supported
local function isGameSupported()
    local gameId = game.PlaceId
    if gameId == 2788229376 or gameId == 7213786345 then
        return true
    else
        return false
    end
end

-- Main loader function
local function loadEcynx()
    -- Print logo
    printLogo()
    
    -- Check if game is supported
    if not isGameSupported() then
        warn("This game is not supported by Ecynx!")
        return
    end
    
    -- Services
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    -- Create notification function
    local function notify(title, text, duration)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title or "Ecynx",
            Text = text or "",
            Duration = duration or 3
        })
    end
    
    -- Notify loading
    notify("Ecynx", "Loading cheat...", 3)
    
    -- Create folder for scripts
    if not isfolder("Ecynx") then
        makefolder("Ecynx")
    end
    
    -- Load UI Library
    local UILibrary
    
    local success, result = pcall(function()
        return loadstring(readfile("Ecynx/ui_design.lua"))()
    end)
    
    if not success then
        -- Try to load from URL if local file fails
        success, result = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/saneishere/ecynx/refs/heads/main/ui_design.lua"))()
        end)
        
        if not success then
            warn("Failed to load UI Library!")
            notify("Ecynx", "Failed to load UI Library!", 5)
            return
        end
        
        -- Save UI Library for future use
        writefile("Ecynx/ui_design.lua", game:HttpGet("https://raw.githubusercontent.com/saneishere/ecynx/refs/heads/main/ui_design.lua"))
    end
    
    UILibrary = result
    
    -- Load modules
    local Modules = {}
    
    -- Module URLs
    local ModuleURLs = {
        Lock = "https://raw.githubusercontent.com/saneishere/ecynx/refs/heads/main/lock.lua",
        Triggerbot = "https://raw.githubusercontent.com/saneishere/ecynx/refs/heads/main/triggerbot.lua",
        ESP = "https://raw.githubusercontent.com/saneishere/ecynx/refs/heads/main/esp.lua",
        SilentAim = "https://raw.githubusercontent.com/saneishere/ecynx/refs/heads/main/silentaim.lua",
        Misc = "https://raw.githubusercontent.com/saneishere/ecynx/refs/heads/main/misc.lua"
    }
    
    -- Load each module
    for name, url in pairs(ModuleURLs) do
        local success, result = pcall(function()
            return loadstring(readfile("Ecynx/" .. string.lower(name) .. ".lua"))()
        end)
        
        if not success then
            -- Try to load from URL if local file fails
            success, result = pcall(function()
                return loadstring(game:HttpGet(url))()
            end)
            
            if not success then
                warn("Failed to load " .. name .. " module!")
                notify("Ecynx", "Failed to load " .. name .. " module!", 5)
                return
            end
            
            -- Save module for future use
            writefile("Ecynx/" .. string.lower(name) .. ".lua", game:HttpGet(url))
        end
        
        Modules[name] = result
        notify("Ecynx", name .. " module loaded", 1)
    end
    
    -- Configuration
    local Config = {
        -- Main Settings
        Enabled = true,
        
        -- Lock Settings
        Lock = {
            Enabled = false,
            Key = "Q",
            ToggleKey = "Z",
            Prediction = 0.151, -- Base prediction value
            AimPart = "HumanoidRootPart",
            SmoothLock = true,
            Smoothness = 0.5,
            FOV = 500,
            ShowFOV = false,
            AutoPrediction = true,
            PredictionBasedOnPing = true,
            ClosestPart = false,
            ClosestPoint = false,
            IgnoreWalls = true,
            TeamCheck = false,
            VisibilityCheck = false,
            TargetMode = "Closest", -- Closest, Health, Random
            TargetPriority = "Distance", -- Distance, Health, Random
            LockNotifications = true,
            LockSound = true,
            LockSoundID = "rbxassetid://6229656188",
            UnlockSound = true,
            UnlockSoundID = "rbxassetid://6229656188"
        },
        
        -- Triggerbot Settings
        Triggerbot = {
            Enabled = false,
            Key = "T",
            ToggleKey = "X",
            Delay = 0.01,
            HitChance = 99,
            AutoShoot = true,
            AutoReload = true,
            TargetPart = "HumanoidRootPart",
            FOV = 500,
            ShowFOV = false,
            TeamCheck = false,
            VisibilityCheck = false,
            TriggerNotifications = true,
            TriggerSound = true,
            TriggerSoundID = "rbxassetid://6229656188"
        },
        
        -- ESP Settings
        ESP = {
            Enabled = false,
            BoxESP = true,
            NameESP = true,
            HealthESP = true,
            TracerESP = false,
            DistanceESP = true,
            TeamCheck = false,
            TeamColor = false,
            BoxColor = Color3.fromRGB(255, 0, 0),
            NameColor = Color3.fromRGB(255, 255, 255),
            HealthColor = Color3.fromRGB(0, 255, 0),
            TracerColor = Color3.fromRGB(255, 0, 0),
            DistanceColor = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            TextOutline = true,
            MaxDistance = 1000
        },
        
        -- Silent Aim Settings
        SilentAim = {
            Enabled = false,
            Key = "R",
            ToggleKey = "V",
            HitChance = 99,
            AimPart = "HumanoidRootPart",
            FOV = 500,
            ShowFOV = false,
            TeamCheck = false,
            VisibilityCheck = false,
            SilentAimNotifications = true
        },
        
        -- Misc Settings
        Misc = {
            NoRecoil = false,
            NoSpread = false,
            InfiniteAmmo = false,
            RapidFire = false,
            WalkSpeed = 16,
            JumpPower = 50,
            CustomWalkSpeed = false,
            CustomJumpPower = false,
            AntiAim = false,
            AntiAimType = "Spin", -- Spin, Jitter, Down, Up
            AntiAimSpeed = 10,
            BunnyHop = false,
            AutoReload = false,
            AutoEquip = false,
            KillSound = false,
            KillSoundID = "rbxassetid://6229656188",
            HitMarker = false,
            HitMarkerSound = false,
            HitMarkerSoundID = "rbxassetid://6229656188",
            ChatSpam = false,
            ChatSpamMessages = {"Ecynx on top!", "Get good, get Ecynx!", "Ecynx > All"},
            ChatSpamDelay = 3
        }
    }
    
    -- Initialize modules
    for name, module in pairs(Modules) do
        if module.Init then
            module:Init(Config[name])
            notify("Ecynx", name .. " module initialized", 1)
        end
    end
    
    -- Create UI
    local Window = UILibrary:CreateWindow("Ecynx | Beta")
    
    -- Create tabs
    local AimbotTab = Window:AddTab("Aimbot")
    local VisualsTab = Window:AddTab("Visuals")
    local MiscTab = Window:AddTab("Misc")
    local SettingsTab = Window:AddTab("Settings")
    
    -- Aimbot Tab
    -- Lock Section
    AimbotTab:AddLabel("Lock Settings")
    
    AimbotTab:AddToggle("Enable Lock", Config.Lock.Enabled, function(value)
        Config.Lock.Enabled = value
        Modules.Lock:Toggle(value)
    end)
    
    AimbotTab:AddToggle("Show FOV", Config.Lock.ShowFOV, function(value)
        Config.Lock.ShowFOV = value
        Modules.Lock:UpdateConfig({ShowFOV = value})
    end)
    
    AimbotTab:AddSlider("FOV Size", 50, 1000, Config.Lock.FOV, function(value)
        Config.Lock.FOV = value
        Modules.Lock:SetFOV(value)
    end)
    
    AimbotTab:AddSlider("Prediction", 0.1, 0.3, Config.Lock.Prediction, function(value)
        Config.Lock.Prediction = value
        Modules.Lock:SetPrediction(value)
    end)
    
    AimbotTab:AddToggle("Auto Prediction", Config.Lock.AutoPrediction, function(value)
        Config.Lock.AutoPrediction = value
        Modules.Lock:UpdateConfig({AutoPrediction = value})
    end)
    
    AimbotTab:AddToggle("Smooth Lock", Config.Lock.SmoothLock, function(value)
        Config.Lock.SmoothLock = value
        Modules.Lock:UpdateConfig({SmoothLock = value})
    end)
    
    AimbotTab:AddSlider("Smoothness", 0.1, 1, Config.Lock.Smoothness, function(value)
        Config.Lock.Smoothness = value
        Modules.Lock:SetSmoothness(value)
    end)
    
    AimbotTab:AddDropdown("Aim Part", {"Head", "HumanoidRootPart", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "Closest"}, Config.Lock.AimPart, function(value)
        Config.Lock.AimPart = value
        Modules.Lock:SetAimPart(value)
    end)
    
    AimbotTab:AddToggle("Team Check", Config.Lock.TeamCheck, function(value)
        Config.Lock.TeamCheck = value
        Modules.Lock:UpdateConfig({TeamCheck = value})
    end)
    
    AimbotTab:AddToggle("Visibility Check", Config.Lock.VisibilityCheck, function(value)
        Config.Lock.VisibilityCheck = value
        Modules.Lock:UpdateConfig({VisibilityCheck = value})
    end)
    
    -- Triggerbot Section
    AimbotTab:AddLabel("Triggerbot Settings")
    
    AimbotTab:AddToggle("Enable Triggerbot", Config.Triggerbot.Enabled, function(value)
        Config.Triggerbot.Enabled = value
        Modules.Triggerbot:Toggle(value)
    end)
    
    AimbotTab:AddToggle("Show FOV", Config.Triggerbot.ShowFOV, function(value)
        Config.Triggerbot.ShowFOV = value
        Modules.Triggerbot:UpdateConfig({ShowFOV = value})
    end)
    
    AimbotTab:AddSlider("FOV Size", 50, 1000, Config.Triggerbot.FOV, function(value)
        Config.Triggerbot.FOV = value
        Modules.Triggerbot:SetFOV(value)
    end)
    
    AimbotTab:AddSlider("Delay (ms)", 0, 500, Config.Triggerbot.Delay * 1000, function(value)
        Config.Triggerbot.Delay = value / 1000
        Modules.Triggerbot:SetDelay(value / 1000)
    end)
    
    AimbotTab:AddSlider("Hit Chance", 1, 100, Config.Triggerbot.HitChance, function(value)
        Config.Triggerbot.HitChance = value
        Modules.Triggerbot:SetHitChance(value)
    end)
    
    AimbotTab:AddToggle("Auto Shoot", Config.Triggerbot.AutoShoot, function(value)
        Config.Triggerbot.AutoShoot = value
        Modules.Triggerbot:UpdateConfig({AutoShoot = value})
    end)
    
    AimbotTab:AddToggle("Auto Reload", Config.Triggerbot.AutoReload, function(value)
        Config.Triggerbot.AutoReload = value
        Modules.Triggerbot:UpdateConfig({AutoReload = value})
    end)
    
    AimbotTab:AddDropdown("Target Part", {"Head", "HumanoidRootPart", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}, Config.Triggerbot.TargetPart, function(value)
        Config.Triggerbot.TargetPart = value
        Modules.Triggerbot:SetTargetPart(value)
    end)
    
    -- Silent Aim Section
    AimbotTab:AddLabel("Silent Aim Settings")
    
    AimbotTab:AddToggle("Enable Silent Aim", Config.SilentAim.Enabled, function(value)
        Config.SilentAim.Enabled = value
        Modules.SilentAim:Toggle(value)
    end)
    
    AimbotTab:AddToggle("Show FOV", Config.SilentAim.ShowFOV, function(value)
        Config.SilentAim.ShowFOV = value
        Modules.SilentAim:UpdateConfig({ShowFOV = value})
    end)
    
    AimbotTab:AddSlider("FOV Size", 50, 1000, Config.SilentAim.FOV, function(value)
        Config.SilentAim.FOV = value
        Modules.SilentAim:SetFOV(value)
    end)
    
    AimbotTab:AddSlider("Hit Chance", 1, 100, Config.SilentAim.HitChance, function(value)
        Config.SilentAim.HitChance = value
        Modules.SilentAim:SetHitChance(value)
    end)
    
    AimbotTab:AddDropdown("Aim Part", {"Head", "HumanoidRootPart", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}, Config.SilentAim.AimPart, function(value)
        Config.SilentAim.AimPart = value
        Modules.SilentAim:SetAimPart(value)
    end)
    
    -- Visuals Tab
    -- ESP Section
    VisualsTab:AddLabel("ESP Settings")
    
    VisualsTab:AddToggle("Enable ESP", Config.ESP.Enabled, function(value)
        Config.ESP.Enabled = value
        Modules.ESP:Toggle(value)
    end)
    
    VisualsTab:AddToggle("Box ESP", Config.ESP.BoxESP, function(value)
        Config.ESP.BoxESP = value
        Modules.ESP:ToggleFeature("BoxESP", value)
    end)
    
    VisualsTab:AddToggle("Name ESP", Config.ESP.NameESP, function(value)
        Config.ESP.NameESP = value
        Modules.ESP:ToggleFeature("NameESP", value)
    end)
    
    VisualsTab:AddToggle("Health ESP", Config.ESP.HealthESP, function(value)
        Config.ESP.HealthESP = value
        Modules.ESP:ToggleFeature("HealthESP", value)
    end)
    
    VisualsTab:AddToggle("Tracer ESP", Config.ESP.TracerESP, function(value)
        Config.ESP.TracerESP = value
        Modules.ESP:ToggleFeature("TracerESP", value)
    end)
    
    VisualsTab:AddToggle("Distance ESP", Config.ESP.DistanceESP, function(value)
        Config.ESP.DistanceESP = value
        Modules.ESP:ToggleFeature("DistanceESP", value)
    end)
    
    VisualsTab:AddToggle("Team Check", Config.ESP.TeamCheck, function(value)
        Config.ESP.TeamCheck = value
        Modules.ESP:ToggleFeature("TeamCheck", value)
    end)
    
    VisualsTab:AddToggle("Team Color", Config.ESP.TeamColor, function(value)
        Config.ESP.TeamColor = value
        Modules.ESP:ToggleFeature("TeamColor", value)
    end)
    
    VisualsTab:AddSlider("Max Distance", 100, 5000, Config.ESP.MaxDistance, function(value)
        Config.ESP.MaxDistance = value
        Modules.ESP:SetMaxDistance(value)
    end)
    
    -- Misc Tab
    -- Character Section
    MiscTab:AddLabel("Character Settings")
    
    MiscTab:AddToggle("Custom Walk Speed", Config.Misc.CustomWalkSpeed, function(value)
        Config.Misc.CustomWalkSpeed = value
        Modules.Misc:ToggleFeature("CustomWalkSpeed", value)
    end)
    
    MiscTab:AddSlider("Walk Speed", 16, 500, Config.Misc.WalkSpeed, function(value)
        Config.Misc.WalkSpeed = value
        Modules.Misc:SetWalkSpeed(value)
    end)
    
    MiscTab:AddToggle("Custom Jump Power", Config.Misc.CustomJumpPower, function(value)
        Config.Misc.CustomJumpPower = value
        Modules.Misc:ToggleFeature("CustomJumpPower", value)
    end)
    
    MiscTab:AddSlider("Jump Power", 50, 500, Config.Misc.JumpPower, function(value)
        Config.Misc.JumpPower = value
        Modules.Misc:SetJumpPower(value)
    end)
    
    MiscTab:AddToggle("Bunny Hop", Config.Misc.BunnyHop, function(value)
        Config.Misc.BunnyHop = value
        Modules.Misc:ToggleFeature("BunnyHop", value)
    end)
    
    -- Gun Mods Section
    MiscTab:AddLabel("Gun Mods")
    
    MiscTab:AddToggle("No Recoil", Config.Misc.NoRecoil, function(value)
        Config.Misc.NoRecoil = value
        Modules.Misc:ToggleFeature("NoRecoil", value)
  <response clipped><NOTE>To save on context only part of this file has been shown to you. You should retry this tool after you have searched inside the file with `grep -n` in order to find the line numbers of what you are looking for.</NOTE>
