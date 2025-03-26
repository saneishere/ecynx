--[[
    Ecynx - Da Hood Misc Features Module
    Created by saneishere
    
    This module implements various miscellaneous features for the Ecynx cheat, including:
    - No recoil
    - No spread
    - Infinite ammo
    - Rapid fire
    - Custom walk speed and jump power
    - Anti-aim
    - Bunny hop
    - Auto reload
    - And more utility functions
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

-- Misc Module
local MiscModule = {}

-- Configuration (will be overridden by main config)
MiscModule.Config = {
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

-- Variables
local OriginalWalkSpeed = 16
local OriginalJumpPower = 50
local ChatSpamRunning = false
local BunnyHopRunning = false
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
local HookedFunctions = {}
local GunModules = {}

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

local function GetCurrentWeapon()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool") then
        return LocalPlayer.Character:FindFirstChildOfClass("Tool")
    end
    return nil
end

-- Find gun modules
local function FindGunModules()
    for _, module in pairs(getgc(true)) do
        if type(module) == "table" and rawget(module, "Reload") and rawget(module, "FireGun") then
            table.insert(GunModules, module)
        end
    end
    
    return #GunModules > 0
end

-- No Recoil Implementation
local function EnableNoRecoil()
    if NoRecoilRunning then return end
    NoRecoilRunning = true
    
    -- Find and hook recoil functions
    for _, module in pairs(GunModules) do
        if module.Recoil then
            local originalRecoil = module.Recoil
            
            module.Recoil = function(...)
                if MiscModule.Config.NoRecoil then
                    return
                end
                return originalRecoil(...)
            end
            
            table.insert(HookedFunctions, {Module = module, Function = "Recoil", Original = originalRecoil})
        end
    end
    
    -- Hook camera shake functions
    local mt = getrawmetatable(game)
    local oldIndex = mt.__index
    setreadonly(mt, false)
    
    mt.__index = newcclosure(function(self, key)
        if MiscModule.Config.NoRecoil and (key == "ShakeCamera" or key == "CameraShake" or key:find("Recoil") or key:find("Shake")) then
            return function() end
        end
        return oldIndex(self, key)
    end)
    
    setreadonly(mt, true)
    
    Notify("Ecynx", "No Recoil " .. (MiscModule.Config.NoRecoil and "Enabled" or "Disabled"), 2)
end

-- No Spread Implementation
local function EnableNoSpread()
    if NoSpreadRunning then return end
    NoSpreadRunning = true
    
    -- Find and hook spread functions
    for _, module in pairs(GunModules) do
        if module.Spread then
            local originalSpread = module.Spread
            
            module.Spread = function(...)
                if MiscModule.Config.NoSpread then
                    return 0
                end
                return originalSpread(...)
            end
            
            table.insert(HookedFunctions, {Module = module, Function = "Spread", Original = originalSpread})
        end
    end
    
    Notify("Ecynx", "No Spread " .. (MiscModule.Config.NoSpread and "Enabled" or "Disabled"), 2)
end

-- Infinite Ammo Implementation
local function EnableInfiniteAmmo()
    if InfiniteAmmoRunning then return end
    InfiniteAmmoRunning = true
    
    -- Hook ammo functions
    RunService.RenderStepped:Connect(function()
        if MiscModule.Config.InfiniteAmmo then
            local weapon = GetCurrentWeapon()
            
            if weapon and weapon:FindFirstChild("Ammo") then
                weapon.Ammo.Value = weapon:FindFirstChild("MaxAmmo") and weapon.MaxAmmo.Value or 30
            end
        end
    end)
    
    Notify("Ecynx", "Infinite Ammo " .. (MiscModule.Config.InfiniteAmmo and "Enabled" or "Disabled"), 2)
end

-- Rapid Fire Implementation
local function EnableRapidFire()
    if RapidFireRunning then return end
    RapidFireRunning = true
    
    -- Find and hook fire rate functions
    for _, module in pairs(GunModules) do
        if module.FireRate then
            local originalFireRate = module.FireRate
            
            module.FireRate = function(...)
                if MiscModule.Config.RapidFire then
                    return 0.05
                end
                return originalFireRate(...)
            end
            
            table.insert(HookedFunctions, {Module = module, Function = "FireRate", Original = originalFireRate})
        end
    end
    
    Notify("Ecynx", "Rapid Fire " .. (MiscModule.Config.RapidFire and "Enabled" or "Disabled"), 2)
end

-- Custom Walk Speed Implementation
local function EnableCustomWalkSpeed()
    if CustomWalkSpeedRunning then return end
    CustomWalkSpeedRunning = true
    
    -- Store original walk speed
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        OriginalWalkSpeed = LocalPlayer.Character.Humanoid.WalkSpeed
    end
    
    -- Update walk speed
    RunService.RenderStepped:Connect(function()
        if MiscModule.Config.CustomWalkSpeed and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = MiscModule.Config.WalkSpeed
        elseif not MiscModule.Config.CustomWalkSpeed and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = OriginalWalkSpeed
        end
    end)
    
    Notify("Ecynx", "Custom Walk Speed " .. (MiscModule.Config.CustomWalkSpeed and "Enabled" or "Disabled"), 2)
end

-- Custom Jump Power Implementation
local function EnableCustomJumpPower()
    if CustomJumpPowerRunning then return end
    CustomJumpPowerRunning = true
    
    -- Store original jump power
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        OriginalJumpPower = LocalPlayer.Character.Humanoid.JumpPower
    end
    
    -- Update jump power
    RunService.RenderStepped:Connect(function()
        if MiscModule.Config.CustomJumpPower and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = MiscModule.Config.JumpPower
        elseif not MiscModule.Config.CustomJumpPower and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = OriginalJumpPower
        end
    end)
    
    Notify("Ecynx", "Custom Jump Power " .. (MiscModule.Config.CustomJumpPower and "Enabled" or "Disabled"), 2)
end

-- Anti-Aim Implementation
local function EnableAntiAim()
    if AntiAimRunning then return end
    AntiAimRunning = true
    
    -- Anti-aim loop
    RunService.RenderStepped:Connect(function()
        if MiscModule.Config.AntiAim and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local humanoidRootPart = LocalPlayer.Character.HumanoidRootPart
            
            if MiscModule.Config.AntiAimType == "Spin" then
                humanoidRootPart.CFrame = humanoidRootPart.CFrame * CFrame.Angles(0, math.rad(MiscModule.Config.AntiAimSpeed), 0)
            elseif MiscModule.Config.AntiAimType == "Jitter" then
                humanoidRootPart.CFrame = humanoidRootPart.CFrame * CFrame.Angles(0, math.rad(math.random(-60, 60)), 0)
            elseif MiscModule.Config.AntiAimType == "Down" then
                LocalPlayer.Character.Humanoid.CameraOffset = Vector3.new(0, -100, 0)
            elseif MiscModule.Config.AntiAimType == "Up" then
                LocalPlayer.Character.Humanoid.CameraOffset = Vector3.new(0, 100, 0)
            end
        elseif not MiscModule.Config.AntiAim and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.CameraOffset = Vector3.new(0, 0, 0)
        end
    end)
    
    Notify("Ecynx", "Anti-Aim " .. (MiscModule.Config.AntiAim and "Enabled" or "Disabled"), 2)
end

-- Bunny Hop Implementation
local function EnableBunnyHop()
    if BunnyHopRunning then return end
    BunnyHopRunning = true
    
    -- Bunny hop loop
    RunService.RenderStepped:Connect(function()
        if MiscModule.Config.BunnyHop and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            local humanoid = LocalPlayer.Character.Humanoid
            
            if humanoid.FloorMaterial ~= Enum.Material.Air and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
    
    Notify("Ecynx", "Bunny Hop " .. (MiscModule.Config.BunnyHop and "Enabled" or "Disabled"), 2)
end

-- Auto Reload Implementation
local function EnableAutoReload()
    if AutoReloadRunning then return end
    AutoReloadRunning = true
    
    -- Auto reload loop
    RunService.RenderStepped:Connect(function()
        if MiscModule.Config.AutoReload then
            local weapon = GetCurrentWeapon()
            
            if weapon and weapon:FindFirstChild("Ammo") and weapon.Ammo.Value <= 0 then
                keypress(0x52) -- R key for reload
            end
        end
    end)
    
    Notify("Ecynx", "Auto Reload " .. (MiscModule.Config.AutoReload and "Enabled" or "Disabled"), 2)
end

-- Chat Spam Implementation
local function EnableChatSpam()
    if ChatSpamRunning then return end
    ChatSpamRunning = true
    
    -- Chat spam loop
    task.spawn(function()
        while true do
            if MiscModule.Config.ChatSpam then
                local message = MiscModule.Config.ChatSpamMessages[math.random(1, #MiscModule.Config.ChatSpamMessages)]
                game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(message, "All")
            end
            task.wait(MiscModule.Config.ChatSpamDelay)
        end
    end)
    
    Notify("Ecynx", "Chat Spam " .. (MiscModule.Config.ChatSpam and "Enabled" or "Disabled"), 2)
end

-- Kill Sound Implementation
local function EnableKillSound()
    if KillSoundRunning then return end
    KillSoundRunning = true
    
    -- Hook kill events
    local function hookKillEvent()
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" and rawget(v, "ConfirmKill") then
                local oldConfirmKill = v.ConfirmKill
                
                v.ConfirmKill = function(...)
                    local result = oldConfirmKill(...)
                    
                    if MiscModule.Config.KillSound then
                        PlaySound(MiscModule.Config.KillSoundID)
                        Notify("Ecynx", "Kill Confirmed", 1)
                    end
                    
                    return result
                end
                
                table.insert(HookedFunctions, {Module = v, Function = "ConfirmKill", Original = oldConfirmKill})
                break
            end
        end
    end
    
    hookKillEvent()
    
    Notify("Ecynx", "Kill Sound " .. (MiscModule.Config.KillSound and "Enabled" or "Disabled"), 2)
end

-- Hit Marker Implementation
local function EnableHitMarker()
    if HitMarkerRunning then return end
    HitMarkerRunning = true
    
    -- Hook hit events
    local function hookHitEvent()
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" and rawget(v, "RegisterHit") then
                local oldRegisterHit = v.RegisterHit
                
                v.RegisterHit = function(...)
                    local result = oldRegisterHit(...)
                    
                    if MiscModule.Config.HitMarker then
                        -- Create hit marker
                        local hitMarker = Drawing.new("Cross")
                        hitMarker.Visible = true
                        hitMarker.Color = Color3.fromRGB(255, 0, 0)
                        hitMarker.Thickness = 2
                        hitMarker.Size = 20
                        hitMarker.Transparency = 1
                        hitMarker.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                        
                        -- Play hit marker sound
                        if MiscModule.Config.HitMarkerSound then
                            PlaySound(MiscModule.Config.HitMarkerSoundID)
                        end
                        
                        -- Remove hit marker after a short delay
                        task.delay(0.3, function()
                            hitMarker:Remove()
                        end)
                    end
                    
                    return result
                end
                
                table.insert(HookedFunctions, {Module = v, Function = "RegisterHit", Original = oldRegisterHit})
                break
            end
        end
    end
    
    hookHitEvent()
    
    Notify("Ecynx", "Hit Marker " .. (MiscModule.Config.HitMarker and "Enabled" or "Disabled"), 2)
end

-- Initialize misc features
function MiscModule:Init(config)
    -- Override config if provided
    if config then
        for key, value in pairs(config) do
            self.Config[key] = value
        end
    end
    
    -- Store original values
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        OriginalWalkSpeed = LocalPlayer.Character.Humanoid.WalkSpeed
        OriginalJumpPower = LocalPlayer.Character.Humanoid.JumpPower
    end
    
    -- Find gun modules
    FindGunModules()
    
    -- Enable features
    if self.Config.NoRecoil then EnableNoRecoil() end
    if self.Config.NoSpread then EnableNoSpread() end
    if self.Config.InfiniteAmmo then EnableInfiniteAmmo() end
    if self.Config.RapidFire then EnableRapidFire() end
    if self.Config.CustomWalkSpeed then EnableCustomWalkSpeed() end
    if self.Config.CustomJumpPower then EnableCustomJumpPower() end
    if self.Config.AntiAim then EnableAntiAim() end
    if self.Config.BunnyHop then EnableBunnyHop() end
    if self.Config.AutoReload then EnableAutoReload() end
    if self.Config.ChatSpam then EnableChatSpam() e<response clipped><NOTE>To save on context only part of this file has been shown to you. You should retry this tool after you have searched inside the file with `grep -n` in order to find the line numbers of what you are looking for.</NOTE>
