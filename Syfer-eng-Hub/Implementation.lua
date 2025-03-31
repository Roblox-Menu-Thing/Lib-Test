local SyferEngHubLibrary = loadstring(game:HttpGet("https://pastebin.com/raw/WUEX5V02", true))()

-- Create a new instance of the hub
local hub = SyferEngHubLibrary.Create({
    name = "Syfer-eng Game Hub",
    accentColor = Color3.fromRGB(180, 50, 255),
    defaultColor = Color3.fromRGB(20, 20, 25),
    secondaryColor = Color3.fromRGB(30, 30, 40),
    tertiaryColor = Color3.fromRGB(35, 35, 45),
    hoverColor = Color3.fromRGB(40, 40, 50),
    textColor = Color3.fromRGB(240, 240, 255),
    toggleOnColor = Color3.fromRGB(180, 50, 255),
    toggleOffColor = Color3.fromRGB(50, 50, 60),
    gradientColor1 = Color3.fromRGB(120, 50, 255),
    gradientColor2 = Color3.fromRGB(200, 50, 255),
    saveFolder = "SyferGameHub",
    
    -- Background blur settings
    backgroundBlurEnabled = false,   -- Blur effect disabled by default (can only be toggled in settings tab)
    backgroundBlurStrength = 0,      -- Default blur strength is 0 (can be adjusted in settings up to 56)
})

hub:CreateToggle(
    "Player ESP", 
    "https://raw.githubusercontent.com/example/player_esp.lua", 
    "https://raw.githubusercontent.com/example/disable_player_esp.lua")

hub:CreateToggle(
    "Item ESP", 
    "https://raw.githubusercontent.com/example/item_esp.lua", 
    "https://raw.githubusercontent.com/example/disable_item_esp.lua")

hub:CreateToggle(
    "Aim Assist", 
    "https://raw.githubusercontent.com/example/aim_assist.lua", 
    "https://raw.githubusercontent.com/example/disable_aim_assist.lua")

hub:CreateToggle(
    "Auto Farm", 
    "https://raw.githubusercontent.com/example/auto_farm.lua", 
    "https://raw.githubusercontent.com/example/disable_auto_farm.lua")

hub:CreateToggle(
    "Kill Aura", 
    "https://raw.githubusercontent.com/example/kill_aura.lua", 
    "https://raw.githubusercontent.com/example/disable_kill_aura.lua")

hub:CreateToggle(
    "Auto Collect", 
    "https://raw.githubusercontent.com/example/auto_collect.lua", 
    "https://raw.githubusercontent.com/example/disable_auto_collect.lua")

hub:CreateToggle(
    "Anti-AFK", 
    "https://raw.githubusercontent.com/example/anti_afk.lua", 
    "https://raw.githubusercontent.com/example/disable_anti_afk.lua")

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

hub:SetToggleKey(Enum.KeyCode.Home)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.F1 then
            local currentState = hub:GetToggleState("Player ESP")
            hub:SetToggleState("Player ESP", not currentState)
            notify("Player ESP: " .. (not currentState and "ON" or "OFF"))
        end
        
        if input.KeyCode == Enum.KeyCode.F2 then
            local currentState = hub:GetToggleState("Item ESP")
            hub:SetToggleState("Item ESP", not currentState)
            notify("Item ESP: " .. (not currentState and "ON" or "OFF"))
        end
        
        if input.KeyCode == Enum.KeyCode.F3 then
            local currentState = hub:GetToggleState("Aim Assist")
            hub:SetToggleState("Aim Assist", not currentState)
            notify("Aim Assist: " .. (not currentState and "ON" or "OFF"))
        end
        
        if input.KeyCode == Enum.KeyCode.F4 then
            local currentState = hub:GetToggleState("Auto Farm")
            hub:SetToggleState("Auto Farm", not currentState)
            notify("Auto Farm: " .. (not currentState and "ON" or "OFF"))
        end
        
        if input.KeyCode == Enum.KeyCode.F5 then
            local currentState = hub:GetToggleState("Kill Aura")
            hub:SetToggleState("Kill Aura", not currentState)
            notify("Kill Aura: " .. (not currentState and "ON" or "OFF"))
        end
        
        -- Home key toggles UI visibility with blur effect (already handled)
        
        -- NOTE: UI blur can ONLY be toggled via the settings panel
        -- This is per explicit user requirements - no keyboard shortcuts
        -- are provided for enabling/disabling blur
        
        -- Blur strength can be adjusted using the slider in settings (0-56)
        -- No keyboard shortcuts are provided for adjusting blur settings
        
        -- NOTE: We've removed the ability to modify background darkness since
        -- the background is now fully transparent with only blur effect
        
        if input.KeyCode == Enum.KeyCode.End then
            hub:SaveConfig("QuickSave-" .. os.date("%H%M"))
            notify("Config saved as 'QuickSave-" .. os.date("%H%M") .. "'")
        end
        
        if input.KeyCode == Enum.KeyCode.PageDown then
            for _, toggle in pairs({"Player ESP", "Item ESP", "Aim Assist", "Auto Farm", "Kill Aura", "Auto Collect"}) do
                hub:SetToggleState(toggle, false)
            end
            notify("All features turned OFF")
        end
        
        if input.KeyCode == Enum.KeyCode.PageUp then
            hub:SetToggleState("Player ESP", true)
            hub:SetToggleState("Item ESP", true)
            hub:SetToggleState("Anti-AFK", true)
            notify("Basic features enabled")
        end
    end
end)

local function notify(text)
    if game:GetService("StarterGui") then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Syfer-eng Hub",
            Text = text,
            Duration = 3
        })
    end
end

local function customizeMenu()
    task.spawn(function()
        task.wait(1)
        -- Log the current background blur settings
        local blurEnabled = hub.isBlurEnabled()
        local blurStrength = hub.getBlurStrength() or 0 -- Default is 0
        

        
        -- Notify user about keyboard controls
        notify("Press Home to toggle UI")
    end)
end

customizeMenu()

return hub
