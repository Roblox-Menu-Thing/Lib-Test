--[[
    EnhancedSyferEngImplementation.lua
    
    This script implements the SyferEngHub library with additional
    features like hotkeys and visibility toggling.
    Uses the new features including settings tab and Insert key toggle.
]]

-- Load the SyferEngHub library
local SyferEngHubLibrary = loadstring(game:HttpGet("https://pastebin.com/raw/uPpiSbyk", true))()

-- Create a new instance of the hub with custom styling
local hub = SyferEngHubLibrary.Create({
    -- Custom hub name
    name = "Syfer-eng Game Hub",
    
    -- Custom purple theme similar to VapeV4
    accentColor = Color3.fromRGB(180, 50, 255),       -- Purple accent
    defaultColor = Color3.fromRGB(20, 20, 25),        -- Dark background
    secondaryColor = Color3.fromRGB(30, 30, 40),      -- Darker sidebar
    tertiaryColor = Color3.fromRGB(35, 35, 45),       -- Button background
    hoverColor = Color3.fromRGB(40, 40, 50),          -- Hover effect
    textColor = Color3.fromRGB(240, 240, 255),        -- White text
    toggleOnColor = Color3.fromRGB(180, 50, 255),     -- Purple toggle (on)
    toggleOffColor = Color3.fromRGB(50, 50, 60),      -- Dark toggle (off)
    gradientColor1 = Color3.fromRGB(120, 50, 255),    -- Gradient start
    gradientColor2 = Color3.fromRGB(200, 50, 255),    -- Gradient end
    
    -- Custom save folder
    saveFolder = "SyferGameHub",
    
    -- Don't show example toggle
    showExampleToggle = false
})

-- Game-specific scripts for a popular game
-- These toggles are customized for specific game mechanics

-- Player ESP
hub:CreateToggle(
    "Player ESP", 
    "https://raw.githubusercontent.com/example/player_esp.lua", 
    "https://raw.githubusercontent.com/example/disable_player_esp.lua"
)

-- Item ESP
hub:CreateToggle(
    "Item ESP", 
    "https://raw.githubusercontent.com/example/item_esp.lua", 
    "https://raw.githubusercontent.com/example/disable_item_esp.lua"
)

-- Aim Assist (less obvious than full aimbot)
hub:CreateToggle(
    "Aim Assist", 
    "https://raw.githubusercontent.com/example/aim_assist.lua", 
    "https://raw.githubusercontent.com/example/disable_aim_assist.lua"
)

-- Auto Farm
hub:CreateToggle(
    "Auto Farm", 
    "https://raw.githubusercontent.com/example/auto_farm.lua", 
    "https://raw.githubusercontent.com/example/disable_auto_farm.lua"
)

-- Kill Aura
hub:CreateToggle(
    "Kill Aura", 
    "https://raw.githubusercontent.com/example/kill_aura.lua", 
    "https://raw.githubusercontent.com/example/disable_kill_aura.lua"
)

-- Auto Collect
hub:CreateToggle(
    "Auto Collect", 
    "https://raw.githubusercontent.com/example/auto_collect.lua", 
    "https://raw.githubusercontent.com/example/disable_auto_collect.lua"
)

-- Anti-AFK
hub:CreateToggle(
    "Anti-AFK", 
    "https://raw.githubusercontent.com/example/anti_afk.lua", 
    "https://raw.githubusercontent.com/example/disable_anti_afk.lua"
)

-- Get services we need
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Replace the default Insert key with Home key for toggling menu visibility
hub:SetToggleKey(Enum.KeyCode.Home)

-- Setup additional hotkeys
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        -- F1: Toggle Player ESP
        if input.KeyCode == Enum.KeyCode.F1 then
            local currentState = hub:GetToggleState("Player ESP")
            hub:SetToggleState("Player ESP", not currentState)
            
            -- Show notification
            notify("Player ESP: " .. (not currentState and "ON" or "OFF"))
        end
        
        -- F2: Toggle Item ESP
        if input.KeyCode == Enum.KeyCode.F2 then
            local currentState = hub:GetToggleState("Item ESP")
            hub:SetToggleState("Item ESP", not currentState)
            
            -- Show notification
            notify("Item ESP: " .. (not currentState and "ON" or "OFF"))
        end
        
        -- F3: Toggle Aim Assist
        if input.KeyCode == Enum.KeyCode.F3 then
            local currentState = hub:GetToggleState("Aim Assist")
            hub:SetToggleState("Aim Assist", not currentState)
            
            -- Show notification
            notify("Aim Assist: " .. (not currentState and "ON" or "OFF"))
        end
        
        -- F4: Toggle Auto Farm
        if input.KeyCode == Enum.KeyCode.F4 then
            local currentState = hub:GetToggleState("Auto Farm")
            hub:SetToggleState("Auto Farm", not currentState)
            
            -- Show notification
            notify("Auto Farm: " .. (not currentState and "ON" or "OFF"))
        end
        
        -- F5: Toggle Kill Aura
        if input.KeyCode == Enum.KeyCode.F5 then
            local currentState = hub:GetToggleState("Kill Aura")
            hub:SetToggleState("Kill Aura", not currentState)
            
            -- Show notification
            notify("Kill Aura: " .. (not currentState and "ON" or "OFF"))
        end
        
        -- End: Save current config
        if input.KeyCode == Enum.KeyCode.End then
            hub:SaveConfig("QuickSave-" .. os.date("%H%M"))
            notify("Config saved as 'QuickSave-" .. os.date("%H%M") .. "'")
        end
        
        -- PageDown: Toggle all features off
        if input.KeyCode == Enum.KeyCode.PageDown then
            for _, toggle in pairs({"Player ESP", "Item ESP", "Aim Assist", "Auto Farm", "Kill Aura", "Auto Collect"}) do
                hub:SetToggleState(toggle, false)
            end
            notify("All features turned OFF")
        end
        
        -- PageUp: Enable basic features (ESPs only)
        if input.KeyCode == Enum.KeyCode.PageUp then
            hub:SetToggleState("Player ESP", true)
            hub:SetToggleState("Item ESP", true)
            hub:SetToggleState("Anti-AFK", true)
            notify("Basic features enabled")
        end
    end
end)

-- Helper function for notifications
local function notify(text)
    if game:GetService("StarterGui") then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Syfer-eng Hub",
            Text = text,
            Duration = 3
        })
    end
end

-- Customize the menu
local function customizeMenu()
    -- Use the Theme selector in Settings tab instead of coding it here,
    -- but you can programmatically change it too:
    
    -- Example of changing theme through code:
    -- Uncomment the next line to switch to Blue theme
    -- ThemeDropdownButton.MouseButton1Click() -- Would cycle to Blue theme
    
    -- Change tab on startup
    task.spawn(function()
        task.wait(1) -- Wait for menu to initialize
        -- No notifications or print statements at startup
        
        -- No default configuration
        -- No notifications on load
        
        -- No auto-save functionality
    end)
end

-- Run customization
customizeMenu()

-- No automatic player count notifications

-- Return the hub instance
return hub
