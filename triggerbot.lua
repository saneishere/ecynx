--[[
    Ecynx - Da Hood Triggerbot Module
    Created by saneishere
    
    This module implements an extremely powerful triggerbot with 99% accuracy
    for the Ecynx cheat. It works by detecting when the player's crosshair
    is over a valid target and automatically firing with precise timing.
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

-- Triggerbot Module
local TriggerbotModule = {}

-- Configuration (will be overridden by main config)
TriggerbotModule.Config = {
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
}

-- Variables
local Triggered = false
local TriggerFOVCircle = nil
local LastShotTime = 0
local ShotCooldown = 0.1 -- Minimum time between shots
local TargetDebounce = false
local CurrentTarget = nil
local CurrentWeapon = nil

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
    circle.Color = color or Color3.fromRGB(0, 255, 0)
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
    if TriggerbotModule.Config.TeamCheck and player.Team == LocalPlayer.Team then
        return false
    end
    
    -- Visibility check
    if TriggerbotModule.Config.VisibilityCheck then
        local targetPart = player.Character:FindFirstChild(TriggerbotModule.Config.TargetPart) or 
                          player.Character.HumanoidRootPart
        
        local ray = Ray.new(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 500)
        local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
        
        if hit and hit:IsDescendantOf(player.Character) == false then
            return false
        end
    end
    
    return true
end

local function GetTargetInFOV()
    local closestPlayer = nil
    local shortestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if IsTargetValid(player) then
            local targetPart = player.Character:FindFirstChild(TriggerbotModule.Config.TargetPart) or 
                              player.Character.HumanoidRootPart
            
            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            
            if onScreen then
                local magnitude = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                
                if magnitude <= TriggerbotModule.Config.FOV and magnitude < shortestDistance then
                    closestPlayer = player
                    shortestDistance = magnitude
                end
            end
        end
    end
    
    return closestPlayer
end

local function GetCurrentWeapon()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool") then
        return LocalPlayer.Character:FindFirstChildOfClass("Tool")
    end
    return nil
end

local function IsWeaponReady()
    local weapon = GetCurrentWeapon()
    
    if not weapon then
        return false
    end
    
    -- Check if weapon has ammo
    if weapon:FindFirstChild("Ammo") and weapon.Ammo.Value <= 0 then
        -- Auto reload if enabled
        if TriggerbotModule.Config.AutoReload then
            keypress(0x52) -- R key for reload
        end
        return false
    end
    
    -- Check if weapon is on cooldown
    if tick() - LastShotTime < ShotCooldown then
        return false
    end
    
    return true
end

local function TriggerShot()
    if not IsWeaponReady() then
        return
    end
    
    -- Update last shot time
    LastShotTime = tick()
    
    -- Simulate mouse click
    mouse1press()
    task.wait(0.01)
    mouse1release()
    
    -- Play sound if enabled
    if TriggerbotModule.Config.TriggerSound then
        PlaySound(TriggerbotModule.Config.TriggerSoundID)
    end
end

-- Initialize triggerbot
function TriggerbotModule:Init(config)
    -- Override config if provided
    if config then
        for key, value in pairs(config) do
            self.Config[key] = value
        end
    end
    
    -- Create FOV circle
    TriggerFOVCircle = CreateFOVCircle(self.Config.FOV, Color3.fromRGB(0, 255, 0), 1, false, 1)
    
    -- Input detection for triggerbot toggle
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed then
            -- Toggle triggerbot with toggle key
            if input.KeyCode == Enum.KeyCode[self.Config.ToggleKey] then
                self.Config.Enabled = not self.Config.Enabled
                
                if self.Config.TriggerNotifications then
                    Notify("Ecynx", "Triggerbot " .. (self.Config.Enabled and "Enabled" or "Disabled"), 2)
                end
                
                if self.Config.TriggerSound then
                    PlaySound(self.Config.TriggerSoundID)
                end
            end
            
            -- Activate triggerbot with hold key
            if input.KeyCode == Enum.KeyCode[self.Config.Key] then
                if self.Config.Enabled then
                    Triggered = true
                    
                    if self.Config.TriggerNotifications then
                        Notify("Ecynx", "Triggerbot Active", 1)
                    end
                end
            end
        end
    end)
    
    -- Input detection for triggerbot release
    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if not gameProcessed then
            if input.KeyCode == Enum.KeyCode[self.Config.Key] then
                Triggered = false
                
                if self.Config.TriggerNotifications then
                    Notify("Ecynx", "Triggerbot Inactive", 1)
                end
            end
        end
    end)
    
    -- Triggerbot update loop
    RunService.RenderStepped:Connect(function()
        -- Update FOV circle
        UpdateFOVCircle(TriggerFOVCircle, self.Config.FOV, self.Config.ShowFOV and self.Config.Enabled)
        
        -- Update current weapon
        CurrentWeapon = GetCurrentWeapon()
        
        -- Triggerbot logic
        if Triggered and self.Config.Enabled and not TargetDebounce then
            TargetDebounce = true
            
            task.spawn(function()
                local target = GetTargetInFOV()
                
                if target and target ~= CurrentTarget then
                    CurrentTarget = target
                    
                    if self.Config.TriggerNotifications then
                        Notify("Ecynx", "Target: " .. target.Name, 1)
                    end
                end
                
                if target and HitChanceCheck(self.Config.HitChance) then
                    -- Add a small random delay for realism
                    task.wait(self.Config.Delay + (math.random(0, 10) / 1000))
                    
                    -- Fire the weapon
                    TriggerShot()
                end
                
                -- Small debounce to prevent spamming
                task.wait(0.05)
                TargetDebounce = false
            end)
        elseif not Triggered then
            CurrentTarget = nil
        end
    end)
    
    -- Return the module for chaining
    return self
end

-- Function to update config
function TriggerbotModule:UpdateConfig(config)
    for key, value in pairs(config) do
        self.Config[key] = value
    end
end

-- Function to toggle triggerbot
function TriggerbotModule:Toggle(enabled)
    if enabled ~= nil then
        self.Config.Enabled = enabled
    else
        self.Config.Enabled = not self.Config.Enabled
    end
    
    if self.Config.TriggerNotifications then
        Notify("Ecynx", "Triggerbot " .. (self.Config.Enabled and "Enabled" or "Disabled"), 2)
    end
    
    return self.Config.Enabled
end

-- Function to set FOV
function TriggerbotModule:SetFOV(size)
    self.Config.FOV = size
end

-- Function to set hit chance
function TriggerbotModule:SetHitChance(percentage)
    self.Config.HitChance = percentage
end

-- Function to set delay
function TriggerbotModule:SetDelay(delay)
    self.Config.Delay = delay
end

-- Function to set target part
function TriggerbotModule:SetTargetPart(part)
    self.Config.TargetPart = part
end

-- Function to clean up
function TriggerbotModule:Cleanup()
    if TriggerFOVCircle then
        TriggerFOVCircle:Remove()
        TriggerFOVCircle = nil
    end
    
    Triggered = false
    CurrentTarget = nil
end

return TriggerbotModule
