--[[
    Ecynx - Da Hood Lock and Prediction Module
    Created by saneishere
    
    This module implements an extremely powerful lock with 99% prediction accuracy
    for the Ecynx cheat. It works by calculating precise prediction values based on
    target movement, ping, and other factors to ensure maximum accuracy.
]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

-- Local Player
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Lock Module
local LockModule = {}

-- Configuration (will be overridden by main config)
LockModule.Config = {
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
}

-- Variables
local Target = nil
local Locked = false
local FOVCircle = nil
local TargetDebounce = false
local PredictionValues = {
    [0] = 0.12,
    [10] = 0.13,
    [20] = 0.14,
    [30] = 0.15,
    [40] = 0.16,
    [50] = 0.17,
    [60] = 0.18,
    [70] = 0.19,
    [80] = 0.20,
    [90] = 0.21,
    [100] = 0.22,
    [110] = 0.23,
    [120] = 0.24,
    [130] = 0.25,
    [140] = 0.26,
    [150] = 0.27,
    [160] = 0.28,
    [170] = 0.29,
    [180] = 0.30,
    [190] = 0.31,
    [200] = 0.32,
    [210] = 0.33,
    [220] = 0.34,
    [230] = 0.35,
    [240] = 0.36,
    [250] = 0.37,
    [260] = 0.38,
    [270] = 0.39,
    [280] = 0.40,
    [290] = 0.41,
    [300] = 0.42,
}

-- Utility Functions
local function Notify(title, text, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title or "Ecynx",
        Text = text or "",
        Duration = duration or 3
    })
end

local function PlaySound(soundId)
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = 1
    sound.Parent = game:GetService("SoundService")
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 3)
end

local function CreateFOVCircle(size, color, thickness, filled, transparency)
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

local function UpdateFOVCircle(circle, size, visible)
    if circle then
        circle.Visible = visible
        circle.Radius = size
        circle.Position = Vector2.new(Mouse.X, Mouse.Y + game:GetService("GuiService"):GetGuiInset().Y)
    end
end

local function IsPlayerKnocked(player)
    if player.Character and player.Character:FindFirstChild("BodyEffects") and 
       player.Character.BodyEffects:FindFirstChild("K.O") and 
       player.Character.BodyEffects["K.O"].Value == true then
        return true
    end
    return false
end

local function IsPlayerGrabbed(player)
    if player.Character and player.Character:FindFirstChild("GRABBING_CONSTRAINT") then
        return true
    end
    return false
end

local function IsTargetValid(player)
    -- Check if player exists and is not local player
    if not player or player == LocalPlayer then
        return false
    end
    
    -- Check if player has character and humanoid
    if not player.Character or 
       not player.Character:FindFirstChild("Humanoid") or 
       player.Character.Humanoid.Health <= 0 then
        return false
    end
    
    -- Check if player is knocked or grabbed
    if IsPlayerKnocked(player) or IsPlayerGrabbed(player) then
        return false
    end
    
    -- Team check
    if LockModule.Config.TeamCheck and player.Team == LocalPlayer.Team then
        return false
    end
    
    -- Visibility check
    if LockModule.Config.VisibilityCheck and not LockModule.Config.IgnoreWalls then
        local targetPart = player.Character:FindFirstChild(LockModule.Config.AimPart) or 
                          player.Character.HumanoidRootPart
        
        local ray = Ray.new(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 500)
        local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
        
        if hit and hit:IsDescendantOf(player.Character) == false then
            return false
        end
    end
    
    return true
end

local function GetClosestPlayer(fov, targetMode, targetPriority)
    local closestPlayer = nil
    local shortestDistance = math.huge
    local lowestHealth = math.huge
    local validPlayers = {}
    
    for _, player in pairs(Players:GetPlayers()) do
        if IsTargetValid(player) then
            local targetPart = player.Character:FindFirstChild(LockModule.Config.AimPart) or 
                              player.Character.HumanoidRootPart
            
            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            
            if onScreen or LockModule.Config.IgnoreWalls then
                local magnitude = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                
                if magnitude <= fov then
                    table.insert(validPlayers, {
                        Player = player,
                        Distance = magnitude,
                        Health = player.Character.Humanoid.Health
                    })
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

local function GetClosestPart(character)
    if not LockModule.Config.ClosestPart then
        local part = character:FindFirstChild(LockModule.Config.AimPart)
        return part or character.HumanoidRootPart
    end
    
    local closestPart = nil
    local shortestDistance = math.huge
    
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                local magnitude = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                
                if magnitude < shortestDistance then
                    closestPart = part
                    shortestDistance = magnitude
                end
            end
        end
    end
    
    return closestPart or character.HumanoidRootPart
end

local function GetClosestPointOnPart(part)
    if not LockModule.Config.ClosestPoint then
        return part.Position
    end
    
    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    
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

local function CalculatePrediction(part)
    local velocity = part.Velocity
    local ping = LocalPlayer:GetNetworkPing() * 1000
    local predictionValue = LockModule.Config.Prediction
    
    if LockModule.Config.AutoPrediction then
        if LockModule.Config.PredictionBasedOnPing then
            -- Find the closest ping value in our table
            local closestPing = 0
            local smallestDifference = math.huge
            
            for pingValue, _ in pairs(PredictionValues) do
                local difference = math.abs(ping - pingValue)
                if difference < smallestDifference then
                    smallestDifference = difference
                    closestPing = pingValue
                end
            end
            
            predictionValue = PredictionValues[closestPing]
        else
            -- Use default prediction value
            predictionValue = 0.151
        end
    end
    
    -- Apply additional factors for more accurate prediction
    local playerMovementFactor = 1.0
    
    -- Check if target is moving and adjust prediction
    if velocity.Magnitude > 0 then
        -- Calculate direction of movement
        local movementDirection = velocity.Unit
        
        -- Check if target is moving erratically
        local lastVelocity = part:GetAttribute("LastVelocity") or velocity
        part:SetAttribute("LastVelocity", velocity)
        
        local velocityChange = (velocity - lastVelocity).Magnitude
        if velocityChange > 5 then
            -- Target is changing direction rapidly, increase prediction
            playerMovementFactor = 1.2
        elseif velocityChange < 1 then
            -- Target is moving steadily, use normal prediction
            playerMovementFactor = 1.0
        end
    end
    
    -- Apply gravity compensation for jumping targets
    local gravityCompensation = Vector3.new(0, 0, 0)
    if velocity.Y > 1 then
        -- Target is moving upward (jumping)
        gravityCompensation = Vector3.new(0, -0.5, 0)
    elseif velocity.Y < -1 then
        -- Target is falling
        gravityCompensation = Vector3.new(0, 0.5, 0)
    end
    
    -- Calculate final prediction
    return part.Position + (velocity * predictionValue * playerMovementFactor) + gravityCompensation
end

-- Initialize lock
function LockModule:Init(config)
    -- Override config if provided
    if config then
        for key, value in pairs(config) do
            self.Config[key] = value
        end
    end
    
    -- Create FOV circle
    FOVCircle = CreateFOVCircle(self.Config.FOV, Color3.fromRGB(255, 0, 0), 1, false, 1)
    
    -- Input detection for lock toggle
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed then
            -- Toggle lock with toggle key
            if input.KeyCode == Enum.KeyCode[self.Config.ToggleKey] then
                self.Config.Enabled = not self.Config.Enabled
                
                if self.Config.LockNotifications then
                    Notify("Ecynx", "Lock " .. (self.Config.Enabled and "Enabled" or "Disabled"), 2)
                end
                
                if self.Config.LockSound then
                    PlaySound(self.Config.Enabled and self.Config.LockSoundID or self.Config.UnlockSoundID)
                end
            end
            
            -- Activate lock with hold key
            if input.KeyCode == Enum.KeyCode[self.Config.Key] then
                if self.Config.Enabled and not TargetDebounce then
                    TargetDebounce = true
                    
                    task.spawn(function()
                        Target = GetClosestPlayer(
                            self.Config.FOV,
                            self.Config.TargetMode,
                            self.Config.TargetPriority
                        )
                        
                        if Target then
                            Locked = true
                            
                            if self.Config.LockNotifications then
                                Notify("Ecynx", "Locked onto: " .. Target.Name, 2)
                            end
                            
                            if self.Config.LockSound then
                                PlaySound(self.Config.LockSoundID)
                            end
                        end
                        
                        task.wait(0.1)
                        TargetDebounce = false
                    end)
                end
            end
        end
    end)
    
    -- Input detection for lock release
    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if not gameProcessed then
            if input.KeyCode == Enum.KeyCode[self.Config.Key] then
                Locked = false
                Target = nil
                
                if self.Config.LockNotifications then
                    Notify("Ecynx", "Unlocked", 2)
                end
                
                if self.Config.UnlockSound then
                    PlaySound(self.Config.UnlockSoundID)
                end
            end
        end
    end)
    
    -- Lock update loop
    RunService.RenderStepped:Connect(function()
        -- Update FOV circle
        UpdateFOVCircle(FOVCircle, self.Config.FOV, self.Config.ShowFOV and self.Config.Enabled)
        
        -- Lock logic
        if Locked and Target and IsTargetValid(Target) then
            local targetPart = GetClosestPart(Target.Character)
            
            if targetPart then
                local targetPosition = GetClosestPointOnPart(targetPart)
                local predictedPosition = CalculatePrediction(targetPart)
                
                local screenPosition, onScreen = Camera:WorldToViewportPoint(predictedPosition)
                
                if onScreen or self.Config.IgnoreWalls then
                    local mousePosition = Vector2.new(Mouse.X, Mouse.Y)
                    local targetScreenPosition = Vector2.new(screenPosition.X, screenPosition.Y)
                    
        <response clipped><NOTE>To save on context only part of this file has been shown to you. You should retry this tool after you have searched inside the file with `grep -n` in order to find the line numbers of what you are looking for.</NOTE>
