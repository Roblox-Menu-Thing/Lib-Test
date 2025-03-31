local SyferEngHubLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/Roblox-Menu-Thing/Lib-Test/refs/heads/main/Syfer-eng-Hub/Libary.lua", true))()

local hub = SyferEngHubLibrary.Create({
    name = "Syfer-eng Game Hub",

    accentColor = Color3.fromRGB(50, 120, 255),
    defaultColor = Color3.fromRGB(15, 15, 30),
    secondaryColor = Color3.fromRGB(25, 25, 40),
    tertiaryColor = Color3.fromRGB(30, 30, 45),
    hoverColor = Color3.fromRGB(35, 35, 55),
    textColor = Color3.fromRGB(240, 240, 255),
    toggleOnColor = Color3.fromRGB(50, 120, 255),
    toggleOffColor = Color3.fromRGB(50, 50, 70),
    gradientColor1 = Color3.fromRGB(30, 80, 220),
    gradientColor2 = Color3.fromRGB(70, 150, 255),

    saveFolder = "SyferGameHub",

    showExampleToggle = false
})

hub:CreateToggle(
    "ESP Wallhack", 
    "https://raw.githubusercontent.com/example/esp_wallhack.lua", 
    "https://raw.githubusercontent.com/example/disable_esp.lua"
)

hub:CreateToggle(
    "Aimbot", 
    "https://raw.githubusercontent.com/example/aimbot.lua", 
    "https://raw.githubusercontent.com/example/disable_aimbot.lua"
)

hub:CreateToggle(
    "Speed Boost", 
    "https://raw.githubusercontent.com/example/speed_hack.lua", 
    "https://raw.githubusercontent.com/example/disable_speed.lua"
)

hub:CreateToggle(
    "Infinite Jump", 
    "https://raw.githubusercontent.com/example/infinite_jump.lua", 
    "https://raw.githubusercontent.com/example/disable_infinite_jump.lua"
)

hub:CreateToggle(
    "No-Clip", 
    "https://raw.githubusercontent.com/example/noclip.lua", 
    "https://raw.githubusercontent.com/example/disable_noclip.lua"
)

hub:CreateToggle(
    "Anti-AFK", 
    "https://raw.githubusercontent.com/example/anti_afk.lua", 
    "https://raw.githubusercontent.com/example/disable_anti_afk.lua",
    true 
)

local UserInputService = game:GetService("UserInputService")

local hubVisible = true
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightControl then
        hubVisible = not hubVisible

        if hubVisible then
            hub:Show()
        else
            hub:Hide()
        end
    end

    if not gameProcessed and input.KeyCode == Enum.KeyCode.F1 then
        local currentState = hub:GetToggleState("ESP Wallhack")
        hub:SetToggleState("ESP Wallhack", not currentState)
    end

    if not gameProcessed and input.KeyCode == Enum.KeyCode.F2 then
        local currentState = hub:GetToggleState("Speed Boost")
        hub:SetToggleState("Speed Boost", not currentState)
    end
end)

hub:SaveConfig("DefaultSetup")

local function notify(text)
    if game:GetService("StarterGui") then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Syfer-eng Hub",
            Text = text,
            Duration = 5
        })
    end
end

notify("Syfer-eng Game Hub loaded successfully!")
notify("Press Right Ctrl to toggle menu visibility")
notify("Press F1 to toggle ESP, F2 to toggle Speed")


return hub
