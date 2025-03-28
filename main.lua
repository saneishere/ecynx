--[[
    Ecynx - Da Hood Cheat (Beta)
    Created by sane
    
    Features:
    - Extremely powerful triggerbot (99% accuracy)
    - Advanced lock with prediction (99% accuracy)
    - Modern UI with round edges, bubbles, and black to red gradient
    - Additional utility features
]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local Camera = Workspace.CurrentCamera

-- Local Player
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Import UI Library
local UILibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/sane/ecynx/main/ui_design.lua"))()

-- Configuration
local Config = {
    -- Main Settings
    Enabled = false,
    
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
    
    -- Camlock Settings
    Camlock = {
        Enabled = false,
        Key = "E",
        ToggleKey = "C",
        Prediction = 0.151,
        AimPart = "HumanoidRootPart",
        Smoothness = 0.5,
        FOV = 500,
        ShowFOV = false,
        TeamCheck = false,
        VisibilityCheck = false,
        CamlockNotifications = true,
        CamlockSound = true,
        CamlockSoundID = "rbxassetid://6229656188"
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

-- Variables
local Target = nil
local Locked = false
local Triggered = false
local Camlocked = false
local SilentAimed = false
local FOVCircle = nil
local TriggerFOVCircle = nil
local CamlockFOVCircle = nil
local SilentAimFOVCircle = nil
local OriginalWalkSpeed = 16
local OriginalJumpPower = 50
local ChatSpamRunning = false
local BunnyHopRunning = false
local ESPRunning = false
local AntiAimRunning = false
local KillSoundRunning = false
local HitMarkerRunning = false
local AutoReloadRunning = false
local AutoEquipRunning = false
local RapidFireRunning = false
local NoRecoilRunning = false
local NoSpreadRunning = false
local InfiniteAmmoRunning = false
local CustomWalkSpeedRunning = false
local CustomJumpPowerRunning = false

-- Utility Functions
local Utilities = {}

-- Check if game is Da Hood
function Utilities:CheckGame()
    local gameId = game.PlaceId
    if gameId == 2788229376 or gameId == 7213786345 then
        return true
    else
        return false
    end
end

-- Create notification
function Utilities:Notify(title, text, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title or "Ecynx",
        Text = text or "",
        Duration = duration or 3
    })
end

-- Play sound
function Utilities:PlaySound(soundId)
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = 1
    sound.Parent = game:GetService("SoundService")
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 3)
end

-- Get closest player
function Utilities:GetClosestPlayer(fov, teamCheck, visibilityCheck, targetMode, targetPriority)
    local closestPlayer = nil
    local shortestDistance = math.huge
    local lowestHealth = math.huge
    local randomIndex = 0
    local validPlayers = {}
    
    for i, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            -- Team check
            local teamCheckPassed = true
            if teamCheck and player.Team == LocalPlayer.Team then
                teamCheckPassed = false
            end
            
            if teamCheckPassed and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 and player.Character:FindFirstChild("HumanoidRootPart") then
                -- Check if player is knocked
                local knockedCheck = true
                if player.Character:FindFirstChild("BodyEffects") and player.Character.BodyEffects:FindFirstChild("K.O") and player.Character.BodyEffects["K.O"].Value == true then
                    knockedCheck = false
                end
                
                -- Check if player is grabbed
                local grabbedCheck = true
                if player.Character:FindFirstChild("GRABBING_CONSTRAINT") then
                    grabbedCheck = false
                end
                
                if knockedCheck and grabbedCheck then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                    local magnitude = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    
                    -- FOV check
                    if magnitude <= fov then
                        -- Visibility check
                        local visibilityCheckPassed = true
                        if visibilityCheck then
                            local ray = Ray.new(Camera.CFrame.Position, (player.Character.HumanoidRootPart.Position - Camera.CFrame.Position).Unit * 500)
                            local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
                            if hit and hit:IsDescendantOf(player.Character) == false then
                                visibilityCheckPassed = false
                            end
                        end
                        
                        if visibilityCheckPassed then
                            table.insert(validPlayers, {
                                Player = player,
                                Distance = magnitude,
                                Health = player.Character.Humanoid.Health
                            })
                        end
                    end
                end
            end
        end
    end
    
    -- Sort players based on target mode and priority
    if #validPlayers > 0 then
        if targetMode == "Closest" then
            table.sort(validPlayers, function(a, b)
                if targetPriority == "Distance" then
                    return a.Distance < b.Distance
                elseif targetPriority == "Health" then
                    return a.Health < b.Health
                else -- Random
                    return math.random() < 0.5
                end
            end)
            return validPlayers[1].Player
        elseif targetMode == "Health" then
            table.sort(validPlayers, function(a, b)
                if targetPriority == "Health" then
                    return a.Health < b.Health
                elseif targetPriority == "Distance" then
                    return a.Distance < b.Distance
                else -- Random
                    return math.random() < 0.5
                end
            end)
            return validPlayers[1].Player
        else -- Random
            return validPlayers[math.random(1, #validPlayers)].Player
        end
    end
    
    return nil
end

-- Get closest part
function Utilities:GetClosestPart(character, aimPart)
    if aimPart ~= "Closest" then
        if character:FindFirstChild(aimPart) then
            return character[aimPart]
        else
            return character.HumanoidRootPart
        end
    end
    
    local closestPart = nil
    local shortestDistance = math.huge
    
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
            local magnitude = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
            
            if magnitude < shortestDistance then
                closestPart = part
                shortestDistance = magnitude
            end
        end
    end
    
    return closestPart or character.HumanoidRootPart
end

-- Get closest point on part
function Utilities:GetClosestPointOnPart(part)
    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    local screenSize = Vector2.new(Camera.ViewportSize.X, Camera.ViewportSize.Y)
    
    -- Calculate 8 corners of the part's bounding box
    local corners = {
        part.CFrame * CFrame.new(part.Size.X/2, part.Size.Y/2, part.Size.Z/2),
        part.CFrame * CFrame.new(-part.Size.X/2, part.Size.Y/2, part.Size.Z/2),
        part.CFrame * CFrame.new(part.Size.X/2, -part.Size.Y/2, part.Size.Z/2),
        part.CFrame * CFrame.new(-part.Size.X/2, -part.Size.Y/2, part.Size.Z/2),
        part.CFrame * CFrame.new(part.Size.X/2, part.Size.Y/2, -part.Size.Z/2),
        part.CFrame * CFrame.new(-part.Size.X/2, part.Size.Y/2, -part.Size.Z/2),
        part.CFrame * CFrame.new(part.Size.X/2, -part.Size.Y/2, -part.Size.Z/2),
        part.CFrame * CFrame.new(-part.Size.X/2, -part.Size.Y/2, -part.Size.Z/2)
    }
    
    local closestPoint = part.Position
    local shortestDistance = math.huge
    
    for _, corner in pairs(corners) do
        local cornerScreenPos, onScreen = Camera:WorldToViewportPoint(corner.Position)
        if onScreen then
            local distance = (Vector2.new(cornerScreenPos.X, cornerScreenPos.Y) - mousePos).Magnitude
            if distance < shortestDistance then
                closestPoint = corner.Position
                shortestDistance = distance
            end
        end
    end
    
    return closestPoint
end

-- Calculate prediction
function Utilities:CalculatePrediction(part, predictionValue)
    local velocity = part.Velocity
    local ping = LocalPlayer:GetNetworkPing() * 1000
    
    if Config.Lock.PredictionBasedOnPing then
        if ping < 130 then
            predictionValue = 0.151
        elseif ping < 150 then
            predictionValue = 0.162
        elseif ping < 180 then
            predictionValue = 0.173
        elseif ping < 200 then
            predictionValue = 0.184
        elseif ping < 250 then
            predictionValue = 0.195
        elseif ping < 300 then
            predictionValue = 0.206
        else
            predictionValue = 0.22
        end
    end
    
    return part.Position + (velocity * predictionValue)
end

-- Create FOV circle
function Utilities:CreateFOVCircle(size, color, thickness, filled, transparency)
    local circle = Drawing.new("Circle")
    circle.Visible = false
    circle.Radius = size
    circle.Color = color or Color3.fromRGB(255, 0, 0)
    circle.Thickness = thickness or 1
    circle.Filled = filled or false
    circle.Transparency = transparency or 1
    circle.NumSides = 100
    circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    return circle
end

-- Update FOV circle
function Utilities:UpdateFOVCircle(circle, size, visible)
    if circle then
        circle.Visible = visible
        circle.Radius = size
        circle.Position = Vector2.new(Mouse.X, Mouse.Y + game:GetService("GuiService"):GetGuiInset().Y)
    end
end

-- Check if hit chance is successful
function Utilities:HitChanceCheck(percentage)
    return math.random(1, 100) <= percentage
end

-- Lock Implementation
local LockModule = {}

-- Initialize lock
function LockModule:Init()
    -- Create FOV circle
    FOVCircle = Utilities:CreateFOVCircle(Config.Lock.FOV, Color3.fromRGB(255, 0, 0), 1, false, 1)
    
    -- Input detection for lock toggle
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed then
            -- Toggle lock with toggle key
            if input.KeyCode == Enum.KeyCode[Config.Lock.ToggleKey] then
                Config.Lock.Enabled = not Config.Lock.Enabled
                
                if Config.Lock.LockNotifications then
                    Utilities:Notify("Ecynx", "Lock " .. (Config.Lock.Enabled and "Enabled" or "Disabled"), 2)
                end
                
                if Config.Lock.LockSound then
                    Utilities:PlaySound(Config.Lock.Enabled and Config.Lock.LockSoundID or Config.Lock.UnlockSoundID)
                end
            end
            
            -- Activate lock with hold key
            if input.KeyCode == Enum.KeyCode[Config.Lock.Key] then
                if Config.Lock.Enabled then
                    Target = Utilities:GetClosestPlayer(
                        Config.Lock.FOV,
                        Config.Lock.TeamCheck,
                        Config.Lock.VisibilityCheck,
                        Config.Lock.TargetMode,
                        Config.Lock.TargetPriority
                    )
                    
                    if Target then
                        Locked = true
                        
                        if Config.Lock.LockNotifications then
                            Utilities:Notify("Ecynx", "Locked onto: " .. Target.Name, 2)
                        end
                        
                        if Config.Lock.LockSound then
                            Utilities:PlaySound(Config.Lock.LockSoundID)
                        end
                    end
                end
            end
        end
   <response clipped><NOTE>To save on context only part of this file has been shown to you. You should retry this tool after you have searched inside the file with `grep -n` in order to find the line numbers of what you are looking for.</NOTE>
