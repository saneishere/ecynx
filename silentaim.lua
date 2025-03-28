--[[
    Ecynx - Da Hood Silent Aim Module
    Created by saneishere
    
    This module implements silent aim functionality for the Ecynx cheat,
    allowing for 99% hit accuracy without visible camera movement.
    It works by redirecting shots to target hitboxes through method hooking.
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

-- Silent Aim Module
local SilentAimModule = {}

-- Configuration (will be overridden by main config)
SilentAimModule.Config = {
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
}

-- Variables
local SilentAimActive = false
local FOVCircle = nil
local OriginalNamecall = nil
local OriginalIndex = nil
local OriginalNewIndex = nil
local HookedFunctions = {}

-- Utility Functions
local function Notify(title, text, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title or "Ecynx",
        Text = text or "",
        Duration = duration or 3
    })
end

local function CreateFOVCircle(size, color, thickness, filled, transparency)
    local circle = Drawing.new("Circle")
    circle.Visible = false
    circle.Radius = size
    circle.Color = color or Color3.fromRGB(255, 255, 0)
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

local function HitChanceCheck(percentage)
    return math.random(1, 100) <= percentage
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
    if SilentAimModule.Config.TeamCheck and player.Team == LocalPlayer.Team then
        return false
    end
    
    -- Visibility check
    if SilentAimModule.Config.VisibilityCheck then
        local targetPart = player.Character:FindFirstChild(SilentAimModule.Config.AimPart) or 
                          player.Character.HumanoidRootPart
        
        local ray = Ray.new(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 500)
        local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
        
        if hit and hit:IsDescendantOf(player.Character) == false then
            return false
        end
    end
    
    return true
end

local function GetClosestPlayerToCursor()
    local closestPlayer = nil
    local shortestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if IsTargetValid(player) then
            local targetPart = player.Character:FindFirstChild(SilentAimModule.Config.AimPart) or 
                              player.Character.HumanoidRootPart
            
            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            
            if onScreen then
                local magnitude = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                
                if magnitude <= SilentAimModule.Config.FOV and magnitude < shortestDistance then
                    closestPlayer = player
                    shortestDistance = magnitude
                end
            end
        end
    end
    
    return closestPlayer
end

local function CalculatePrediction(part)
    local velocity = part.Velocity
    local ping = LocalPlayer:GetNetworkPing() * 1000
    local predictionValue = 0.165
    
    -- Adjust prediction based on ping
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

-- Initialize silent aim
function SilentAimModule:Init(config)
    -- Override config if provided
    if config then
        for key, value in pairs(config) do
            self.Config[key] = value
        end
    end
    
    -- Create FOV circle
    FOVCircle = CreateFOVCircle(self.Config.FOV, Color3.fromRGB(255, 255, 0), 1, false, 1)
    
    -- Input detection for silent aim toggle
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed then
            -- Toggle silent aim with toggle key
            if input.KeyCode == Enum.KeyCode[self.Config.ToggleKey] then
                self.Config.Enabled = not self.Config.Enabled
                
                if self.Config.SilentAimNotifications then
                    Notify("Ecynx", "Silent Aim " .. (self.Config.Enabled and "Enabled" or "Disabled"), 2)
                end
            end
            
            -- Activate silent aim with hold key
            if input.KeyCode == Enum.KeyCode[self.Config.Key] then
                if self.Config.Enabled then
                    SilentAimActive = true
                    
                    if self.Config.SilentAimNotifications then
                        Notify("Ecynx", "Silent Aim Active", 1)
                    end
                end
            end
        end
    end)
    
    -- Input detection for silent aim release
    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if not gameProcessed then
            if input.KeyCode == Enum.KeyCode[self.Config.Key] then
                SilentAimActive = false
                
                if self.Config.SilentAimNotifications then
                    Notify("Ecynx", "Silent Aim Inactive", 1)
                end
            end
        end
    end)
    
    -- Silent aim update loop
    RunService.RenderStepped:Connect(function()
        -- Update FOV circle
        UpdateFOVCircle(FOVCircle, self.Config.FOV, self.Config.ShowFOV and self.Config.Enabled)
    end)
    
    -- Hook namecall method for silent aim
    OriginalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        
        if (self.Config.Enabled and SilentAimActive or self.Config.Enabled) and 
           (method == "FireServer" or method == "InvokeServer") and 
           (self.Name == "RemoteEvent" or self.Name:find("Fire") or self.Name:find("Event") or self.Name:find("Function")) then
            
            local target = GetClosestPlayerToCursor()
            
            if target and HitChanceCheck(self.Config.HitChance) then
                local targetPart = target.Character:FindFirstChild(self.Config.AimPart) or 
                                  target.Character.HumanoidRootPart
                
                if targetPart then
                    local predictedPosition = CalculatePrediction(targetPart)
                    
                    -- Modify arguments for silent aim
                    for i, v in pairs(args) do
                        if typeof(v) == "Vector3" then
                            if i == 1 then
                                args[i] = predictedPosition
                            elseif i == 2 and method == "FireServer" then
                                args[i] = predictedPosition
                            end
                        elseif typeof(v) == "CFrame" then
                            args[i] = CFrame.new(v.Position, predictedPosition)
                        end
                    end
                end
            end
            
            return OriginalNamecall(self, unpack(args))
        end
        
        return OriginalNamecall(self, ...)
    end)
    
    -- Hook index method for silent aim
    OriginalIndex = hookmetamethod(game, "__index", function(self, key)
        if key == "Hit" or key == "Target" then
            if (self.Config.Enabled and SilentAimActive or self.Config.Enabled) then
                local target = GetClosestPlayerToCursor()
                
                if target and HitChanceCheck(self.Config.HitChance) then
                    local targetPart = target.Character:FindFirstChild(self.Config.AimPart) or 
                                      target.Character.HumanoidRootPart
                    
                    if targetPart then
                        local predictedPosition = CalculatePrediction(targetPart)
                        
                        if key == "Hit" then
                            return predictedPosition
                        elseif key == "Target" then
                            return targetPart
                        end
                    end
                end
            end
        end
        
        return OriginalIndex(self, key)
    end)
    
    -- Hook newindex method for silent aim
    OriginalNewIndex = hookmetamethod(game, "__newindex", function(self, key, value)
        if key == "Hit" or key == "Target" then
            if (self.Config.Enabled and SilentAimActive or self.Config.Enabled) then
                local target = GetClosestPlayerToCursor()
                
                if target and HitChanceCheck(self.Config.HitChance) then
                    local targetPart = target.Character:FindFirstChild(self.Config.AimPart) or 
                                      target.Character.HumanoidRootPart
                    
                    if targetPart then
                        local predictedPosition = CalculatePrediction(targetPart)
                        
                        if key == "Hit" then
                            value = predictedPosition
                        elseif key == "Target" then
                            value = targetPart
                        end
                    end
                end
            end
        end
        
        return OriginalNewIndex(self, key, value)
    end)
    
    -- Hook specific game functions for silent aim
    self:HookGameFunctions()
    
    -- Return the module for chaining
    return self
end

-- Function to hook game-specific functions
function SilentAimModule:HookGameFunctions()
    -- Hook Da Hood specific functions
    local gunModules = {}
    
    -- Find gun modules
    for _, module in pairs(getgc(true)) do
        if type(module) == "table" and rawget(module, "Reload") and rawget(module, "FireGun") then
            table.insert(gunModules, module)
        end
    end
    
    -- Hook FireGun function in each module
    for _, module in pairs(gunModules) do
        local originalFireGun = module.FireGun
        
        module.FireGun = function(...)
            local args = {...}
            
            if (self.Config.Enabled and SilentAimActive or self.Config.Enabled) then
                local target = GetClosestPlayerToCursor()
                
                if target and HitChanceCheck(self.Config.HitChance) then
                    local targetPart = target.Character:FindFirstChild(self.Config.AimPart) or 
                                      target.Character.HumanoidRootPart
                    
                    if targetPart then
                        local predictedPosition = CalculatePrediction(targetPart)
                        
                        -- Modify mouse hit position
                        if args[2] and typeof(args[2]) == "table" and args[2].Hit then
                            args[2].Hit = predictedPosition
                        end
                        
                        -- Modify target
                        if args[3] and typeof(args[3]) == "Instance" then
                            args[3] = targetPart
                        end
                    end
                end
            end
            
            return originalFireGun(unpack(args))
        end
        
        table.insert(HookedFunctions, {Module = module, Function = "FireGun", Original = originalFireGun})
    end
    
    -- Hook mouse functions
    local originalMouseHit = Mouse.Hit
    local originalMouseTarget = Mouse.Target
    
    setreadonly(Mouse, false)
    
    Mouse.GetPropertyChangedSignal("Hit"):Connect(function()
        if (self.Config.Enabled and SilentAimActive or self.Config.Enabled) then
            local target = GetClosestPlayerToCursor()
            
            if target and HitChanceCheck(self.Config.HitChance) then
                local targetPart = target.Character:FindFirstChild(self.Config.AimPart) or 
                                  target.Character.HumanoidRootPart
                
                if targetPart then
                    local predictedPosition = CalculatePrediction(targetPart)
                    Mouse.Hit = CFrame.new(predictedPosition)
                end
            end
        end
    end)
    
    Mouse.GetPropertyChangedSignal("Target"):Connect(function()
        if (self.Config.Enabled and SilentAimActive or self.Config.Enabled) then
            local target = GetClosestPlayerToCursor()<response clipped><NOTE>To save on context only part of this file has been shown to you. You should retry this tool after you have searched inside the file with `grep -n` in order to find the line numbers of what you are looking for.</NOTE>
