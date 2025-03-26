--[[
    Ecynx - Da Hood ESP Module
    Created by saneishere
    
    This module implements ESP features for the Ecynx cheat, including:
    - Box ESP
    - Name ESP
    - Health ESP
    - Tracer ESP
    - Distance ESP
    With team color support and customizable settings.
]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

-- Local Player
local LocalPlayer = Players.LocalPlayer

-- ESP Module
local ESPModule = {}

-- Configuration (will be overridden by main config)
ESPModule.Config = {
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
}

-- Variables
local ESPContainer = {}
local ESPRunning = false

-- Utility Functions
local function Notify(title, text, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title or "Ecynx",
        Text = text or "",
        Duration = duration or 3
    })
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

-- Create ESP for a player
local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local esp = {
        Player = player,
        BoxOutline = Drawing.new("Square"),
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Health = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Tracer = Drawing.new("Line")
    }
    
    -- Box outline
    esp.BoxOutline.Visible = false
    esp.BoxOutline.Color = Color3.new(0, 0, 0)
    esp.BoxOutline.Thickness = 3
    esp.BoxOutline.Transparency = 1
    esp.BoxOutline.Filled = false
    
    -- Box
    esp.Box.Visible = false
    esp.Box.Color = ESPModule.Config.BoxColor
    esp.Box.Thickness = 1
    esp.Box.Transparency = 1
    esp.Box.Filled = false
    
    -- Name
    esp.Name.Visible = false
    esp.Name.Color = ESPModule.Config.NameColor
    esp.Name.Size = ESPModule.Config.TextSize
    esp.Name.Center = true
    esp.Name.Outline = ESPModule.Config.TextOutline
    
    -- Health
    esp.Health.Visible = false
    esp.Health.Color = ESPModule.Config.HealthColor
    esp.Health.Size = ESPModule.Config.TextSize
    esp.Health.Center = true
    esp.Health.Outline = ESPModule.Config.TextOutline
    
    -- Distance
    esp.Distance.Visible = false
    esp.Distance.Color = ESPModule.Config.DistanceColor
    esp.Distance.Size = ESPModule.Config.TextSize
    esp.Distance.Center = true
    esp.Distance.Outline = ESPModule.Config.TextOutline
    
    -- Tracer
    esp.Tracer.Visible = false
    esp.Tracer.Color = ESPModule.Config.TracerColor
    esp.Tracer.Thickness = 1
    esp.Tracer.Transparency = 1
    
    ESPContainer[player] = esp
end

-- Remove ESP for a player
local function RemoveESP(player)
    if ESPContainer[player] then
        for _, drawing in pairs(ESPContainer[player]) do
            if typeof(drawing) == "table" and drawing.Remove then
                pcall(function()
                    drawing:Remove()
                end)
            end
        end
        
        ESPContainer[player] = nil
    end
end

-- Update ESP
local function UpdateESP()
    for player, esp in pairs(ESPContainer) do
        if player and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 and player.Character:FindFirstChild("HumanoidRootPart") then
            local character = player.Character
            local humanoidRootPart = character.HumanoidRootPart
            local humanoid = character.Humanoid
            local head = character:FindFirstChild("Head")
            
            -- Team check
            local teamCheckPassed = true
            if ESPModule.Config.TeamCheck and player.Team == LocalPlayer.Team then
                teamCheckPassed = false
            end
            
            -- Distance check
            local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) and (LocalPlayer.Character.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude or 0
            local distanceCheckPassed = distance <= ESPModule.Config.MaxDistance
            
            -- Knocked/grabbed check
            local stateCheckPassed = not (IsPlayerKnocked(player) or IsPlayerGrabbed(player))
            
            if teamCheckPassed and distanceCheckPassed and stateCheckPassed then
                local screenPosition, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
                
                if onScreen then
                    -- Calculate box size based on distance
                    local size = 1 / (screenPosition.Z * 0.01) * 2
                    local boxSize = Vector2.new(size, size * 1.5)
                    local boxPosition = Vector2.new(screenPosition.X - boxSize.X / 2, screenPosition.Y - boxSize.Y / 2)
                    
                    -- Update box
                    if ESPModule.Config.BoxESP then
                        esp.BoxOutline.Size = boxSize
                        esp.BoxOutline.Position = boxPosition
                        esp.BoxOutline.Visible = true
                        
                        esp.Box.Size = boxSize
                        esp.Box.Position = boxPosition
                        esp.Box.Color = ESPModule.Config.TeamColor and player.TeamColor.Color or ESPModule.Config.BoxColor
                        esp.Box.Visible = true
                    else
                        esp.BoxOutline.Visible = false
                        esp.Box.Visible = false
                    end
                    
                    -- Update name
                    if ESPModule.Config.NameESP then
                        esp.Name.Text = player.Name
                        esp.Name.Position = Vector2.new(screenPosition.X, boxPosition.Y - 15)
                        esp.Name.Color = ESPModule.Config.TeamColor and player.TeamColor.Color or ESPModule.Config.NameColor
                        esp.Name.Visible = true
                    else
                        esp.Name.Visible = false
                    end
                    
                    -- Update health
                    if ESPModule.Config.HealthESP then
                        esp.Health.Text = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
                        esp.Health.Position = Vector2.new(screenPosition.X, boxPosition.Y + boxSize.Y + 5)
                        esp.Health.Color = Color3.fromRGB(
                            255 - (255 * (humanoid.Health / humanoid.MaxHealth)),
                            255 * (humanoid.Health / humanoid.MaxHealth),
                            0
                        )
                        esp.Health.Visible = true
                    else
                        esp.Health.Visible = false
                    end
                    
                    -- Update distance
                    if ESPModule.Config.DistanceESP then
                        esp.Distance.Text = math.floor(distance) .. " studs"
                        esp.Distance.Position = Vector2.new(screenPosition.X, boxPosition.Y + boxSize.Y + (ESPModule.Config.HealthESP and 20 or 5))
                        esp.Distance.Color = ESPModule.Config.TeamColor and player.TeamColor.Color or ESPModule.Config.DistanceColor
                        esp.Distance.Visible = true
                    else
                        esp.Distance.Visible = false
                    end
                    
                    -- Update tracer
                    if ESPModule.Config.TracerESP then
                        esp.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        esp.Tracer.To = Vector2.new(screenPosition.X, screenPosition.Y)
                        esp.Tracer.Color = ESPModule.Config.TeamColor and player.TeamColor.Color or ESPModule.Config.TracerColor
                        esp.Tracer.Visible = true
                    else
                        esp.Tracer.Visible = false
                    end
                else
                    -- Hide ESP if not on screen
                    esp.BoxOutline.Visible = false
                    esp.Box.Visible = false
                    esp.Name.Visible = false
                    esp.Health.Visible = false
                    esp.Distance.Visible = false
                    esp.Tracer.Visible = false
                end
            else
                -- Hide ESP if team check or distance check failed
                esp.BoxOutline.Visible = false
                esp.Box.Visible = false
                esp.Name.Visible = false
                esp.Health.Visible = false
                esp.Distance.Visible = false
                esp.Tracer.Visible = false
            end
        else
            -- Hide ESP if player is not valid
            esp.BoxOutline.Visible = false
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.Health.Visible = false
            esp.Distance.Visible = false
            esp.Tracer.Visible = false
        end
    end
end

-- Initialize ESP
function ESPModule:Init(config)
    -- Override config if provided
    if config then
        for key, value in pairs(config) do
            self.Config[key] = value
        end
    end
    
    -- Create ESP for all players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreateESP(player)
        end
    end
    
    -- Create ESP for new players
    Players.PlayerAdded:Connect(function(player)
        CreateESP(player)
    end)
    
    -- Remove ESP for players who leave
    Players.PlayerRemoving:Connect(function(player)
        RemoveESP(player)
    end)
    
    -- Start ESP update loop
    if not ESPRunning then
        ESPRunning = true
        
        RunService.RenderStepped:Connect(function()
            if self.Config.Enabled then
                UpdateESP()
            else
                -- Hide all ESP
                for _, esp in pairs(ESPContainer) do
                    esp.BoxOutline.Visible = false
                    esp.Box.Visible = false
                    esp.Name.Visible = false
                    esp.Health.Visible = false
                    esp.Distance.Visible = false
                    esp.Tracer.Visible = false
                end
            end
        end)
    end
    
    -- Return the module for chaining
    return self
end

-- Function to update config
function ESPModule:UpdateConfig(config)
    for key, value in pairs(config) do
        self.Config[key] = value
    end
end

-- Function to toggle ESP
function ESPModule:Toggle(enabled)
    if enabled ~= nil then
        self.Config.Enabled = enabled
    else
        self.Config.Enabled = not self.Config.Enabled
    end
    
    Notify("Ecynx", "ESP " .. (self.Config.Enabled and "Enabled" or "Disabled"), 2)
    
    return self.Config.Enabled
end

-- Function to toggle specific ESP feature
function ESPModule:ToggleFeature(feature, enabled)
    if self.Config[feature] ~= nil then
        if enabled ~= nil then
            self.Config[feature] = enabled
        else
            self.Config[feature] = not self.Config[feature]
        end
        
        Notify("Ecynx", feature .. " " .. (self.Config[feature] and "Enabled" or "Disabled"), 2)
        
        return self.Config[feature]
    end
    
    return false
end

-- Function to set color
function ESPModule:SetColor(feature, color)
    if self.Config[feature .. "Color"] ~= nil then
        self.Config[feature .. "Color"] = color
        return true
    end
    
    return false
end

-- Function to set max distance
function ESPModule:SetMaxDistance(distance)
    self.Config.MaxDistance = distance
end

-- Function to clean up
function ESPModule:Cleanup()
    ESPRunning = false
    
    for player, _ in pairs(ESPContainer) do
        RemoveESP(player)
    end
    
    ESPContainer = {}
end

return ESPModule
