-- Version 1.1
local SyferEngHubLibrary = {}

function SyferEngHubLibrary.Create(options)
    if not game then
        return
    end
    
    -- Initialize services
    local Players = game:GetService("Players")
    local CoreGui = game:GetService("CoreGui")
    local HttpService = game:GetService("HttpService")
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local RunService = game:GetService("RunService")
    
    -- Default options
    options = options or {}
    
    -- Set up themes and configurations
    local SAVE_FOLDER = options.saveFolder or "SyferEngHub"
    local CONFIG_EXTENSION = options.configExtension or ".config"
    local DEFAULT_COLOR = options.defaultColor or Color3.fromRGB(20, 20, 25)
    local ACCENT_COLOR = options.accentColor or Color3.fromRGB(180, 50, 255)
    local SECONDARY_COLOR = options.secondaryColor or Color3.fromRGB(30, 30, 40)
    local TERTIARY_COLOR = options.tertiaryColor or Color3.fromRGB(35, 35, 45)
    local HOVER_COLOR = options.hoverColor or Color3.fromRGB(40, 40, 50)
    local TEXT_COLOR = options.textColor or Color3.fromRGB(240, 240, 255)
    local TOGGLE_ON_COLOR = options.toggleOnColor or Color3.fromRGB(180, 50, 255)
    local TOGGLE_OFF_COLOR = options.toggleOffColor or Color3.fromRGB(50, 50, 60)
    local GRADIENT_COLOR1 = options.gradientColor1 or Color3.fromRGB(120, 50, 255)
    local GRADIENT_COLOR2 = options.gradientColor2 or Color3.fromRGB(200, 50, 255)
    
    -- Initialize local variables
    local player = Players.LocalPlayer
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    local configsList = {}
    local toggleButtons = {}
    local currentTab = "Main"
    
    -- Create the main ScreenGui
    local SyferEngHub = Instance.new("ScreenGui")
    SyferEngHub.Name = options.name or "SyferEngHub"
    SyferEngHub.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    SyferEngHub.ResetOnSpawn = false
    
    -- Try to parent to CoreGui first, fallback to PlayerGui
    pcall(function()
        SyferEngHub.Parent = CoreGui
    end)
    if not SyferEngHub.Parent then
        SyferEngHub.Parent = player:WaitForChild("PlayerGui")
    end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 650, 0, 400) -- Increased size from 550x350 to 650x400
MainFrame.Position = UDim2.new(0.5, -325, 0.5, -200) -- Adjusted position to keep it centered
MainFrame.BackgroundColor3 = DEFAULT_COLOR
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = false
MainFrame.Parent = SyferEngHub

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 6)
UICorner.Parent = MainFrame

local DropShadow = Instance.new("ImageLabel")
DropShadow.Name = "DropShadow"
DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
DropShadow.BackgroundTransparency = 1
DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
DropShadow.Size = UDim2.new(1, 30, 1, 30)
DropShadow.ZIndex = -1
DropShadow.Image = "rbxassetid://6014261993"
DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
DropShadow.ImageTransparency = 0.5
DropShadow.ScaleType = Enum.ScaleType.Slice
DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
DropShadow.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = ACCENT_COLOR
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
TitleBar.ZIndex = 2

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 6)
TitleCorner.Parent = TitleBar

local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, GRADIENT_COLOR1),
    ColorSequenceKeypoint.new(1, GRADIENT_COLOR2)
})
TitleGradient.Rotation = 45
TitleGradient.Parent = TitleBar

local CornerFix = Instance.new("Frame")
CornerFix.Name = "CornerFix"
CornerFix.Size = UDim2.new(1, 0, 0.5, 0)
CornerFix.Position = UDim2.new(0, 0, 0.5, 0)
CornerFix.BackgroundColor3 = ACCENT_COLOR
CornerFix.BorderSizePixel = 0
CornerFix.ZIndex = 1
CornerFix.Parent = TitleBar

local CornerFixGradient = Instance.new("UIGradient")
CornerFixGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, GRADIENT_COLOR1),
    ColorSequenceKeypoint.new(1, GRADIENT_COLOR2)
})
CornerFixGradient.Rotation = 45
CornerFixGradient.Parent = CornerFix

local TitleText = Instance.new("TextLabel")
TitleText.Name = "TitleText"
TitleText.Size = UDim2.new(1, -10, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "Syfer-eng Hub"
TitleText.Font = Enum.Font.GothamBold
TitleText.TextColor3 = TEXT_COLOR
TitleText.TextSize = 16
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.ZIndex = 2
TitleText.Parent = TitleBar

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -30, 0, 0)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "X"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextColor3 = TEXT_COLOR
CloseButton.TextSize = 16
CloseButton.ZIndex = 3
CloseButton.Parent = TitleBar

local TabBar = Instance.new("Frame")
TabBar.Name = "TabBar"
TabBar.Size = UDim2.new(0, 120, 1, -30)
TabBar.Position = UDim2.new(0, 0, 0, 30)
TabBar.BackgroundColor3 = SECONDARY_COLOR
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame

local TabBarCorner = Instance.new("UICorner")
TabBarCorner.CornerRadius = UDim.new(0, 6)
TabBarCorner.Parent = TabBar

local TabBarGradient = Instance.new("UIGradient")
TabBarGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, SECONDARY_COLOR),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 35))
})
TabBarGradient.Rotation = 90
TabBarGradient.Parent = TabBar

local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -120, 1, -30)
ContentFrame.Position = UDim2.new(0, 120, 0, 30)
ContentFrame.BackgroundColor3 = DEFAULT_COLOR
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame

local ContentFrameGradient = Instance.new("UIGradient")
ContentFrameGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, DEFAULT_COLOR),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 20))
})
ContentFrameGradient.Rotation = 160
ContentFrameGradient.Parent = ContentFrame

local MainTabContent = Instance.new("ScrollingFrame")
MainTabContent.Name = "MainTabContent"
MainTabContent.Size = UDim2.new(1, 0, 1, 0)
MainTabContent.BackgroundTransparency = 1
MainTabContent.BorderSizePixel = 0
MainTabContent.ScrollBarThickness = 4
MainTabContent.ScrollBarImageColor3 = ACCENT_COLOR
MainTabContent.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will be updated dynamically
MainTabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
MainTabContent.Parent = ContentFrame
MainTabContent.Visible = true

local ToggleLayout = Instance.new("UIListLayout")
ToggleLayout.Name = "ToggleLayout"
ToggleLayout.Padding = UDim.new(0, 10)
ToggleLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ToggleLayout.SortOrder = Enum.SortOrder.LayoutOrder
ToggleLayout.Parent = MainTabContent

local TogglePadding = Instance.new("UIPadding")
TogglePadding.PaddingTop = UDim.new(0, 15)
TogglePadding.PaddingBottom = UDim.new(0, 15)
TogglePadding.Parent = MainTabContent

local ConfigTabContent = Instance.new("ScrollingFrame")
ConfigTabContent.Name = "ConfigTabContent"
ConfigTabContent.Size = UDim2.new(1, 0, 1, 0)
ConfigTabContent.BackgroundTransparency = 1
ConfigTabContent.BorderSizePixel = 0
ConfigTabContent.ScrollBarThickness = 4
ConfigTabContent.ScrollBarImageColor3 = ACCENT_COLOR
ConfigTabContent.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will be updated dynamically
ConfigTabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
ConfigTabContent.Parent = ContentFrame
ConfigTabContent.Visible = false

-- Create Settings Tab Content
local SettingsTabContent = Instance.new("ScrollingFrame")
SettingsTabContent.Name = "SettingsTabContent"
SettingsTabContent.Size = UDim2.new(1, 0, 1, 0)
SettingsTabContent.BackgroundTransparency = 1
SettingsTabContent.BorderSizePixel = 0
SettingsTabContent.ScrollBarThickness = 4
SettingsTabContent.ScrollBarImageColor3 = ACCENT_COLOR
SettingsTabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
SettingsTabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
SettingsTabContent.Parent = ContentFrame
SettingsTabContent.Visible = false

local SettingsLayout = Instance.new("UIListLayout")
SettingsLayout.Name = "SettingsLayout"
SettingsLayout.Padding = UDim.new(0, 15)
SettingsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SettingsLayout.SortOrder = Enum.SortOrder.LayoutOrder
SettingsLayout.Parent = SettingsTabContent

local SettingsPadding = Instance.new("UIPadding")
SettingsPadding.PaddingTop = UDim.new(0, 20)
SettingsPadding.PaddingBottom = UDim.new(0, 20)
SettingsPadding.Parent = SettingsTabContent

local ConfigLayout = Instance.new("UIListLayout")
ConfigLayout.Name = "ConfigLayout"
ConfigLayout.Padding = UDim.new(0, 10)
ConfigLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ConfigLayout.SortOrder = Enum.SortOrder.LayoutOrder
ConfigLayout.Parent = ConfigTabContent

local ConfigPadding = Instance.new("UIPadding")
ConfigPadding.PaddingTop = UDim.new(0, 15)
ConfigPadding.PaddingBottom = UDim.new(0, 15)
ConfigPadding.Parent = ConfigTabContent

local ConfigInputArea = Instance.new("Frame")
ConfigInputArea.Name = "ConfigInputArea"
ConfigInputArea.Size = UDim2.new(0.9, 0, 0, 40)
ConfigInputArea.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ConfigInputArea.BorderSizePixel = 0
ConfigInputArea.Parent = ConfigTabContent

local ConfigInputCorner = Instance.new("UICorner")
ConfigInputCorner.CornerRadius = UDim.new(0, 6)
ConfigInputCorner.Parent = ConfigInputArea

-- Add outline to Config Input Area
local ConfigInputOutline = Instance.new("UIStroke")
ConfigInputOutline.Name = "ConfigInputOutline"
ConfigInputOutline.Color = Color3.fromRGB(80, 80, 100)
ConfigInputOutline.Thickness = 1.5
ConfigInputOutline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
ConfigInputOutline.Parent = ConfigInputArea

local ConfigInput = Instance.new("TextBox")
ConfigInput.Name = "ConfigInput"
ConfigInput.Size = UDim2.new(0.7, 0, 1, 0)
ConfigInput.BackgroundTransparency = 1
ConfigInput.PlaceholderText = "Enter config name..."
ConfigInput.Text = ""
ConfigInput.Font = Enum.Font.Gotham
ConfigInput.TextColor3 = TEXT_COLOR
ConfigInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
ConfigInput.TextSize = 14
ConfigInput.Parent = ConfigInputArea

local SaveConfigButton = Instance.new("TextButton")
SaveConfigButton.Name = "SaveConfigButton"
SaveConfigButton.Size = UDim2.new(0.3, 0, 1, 0)
SaveConfigButton.Position = UDim2.new(0.7, 0, 0, 0)
SaveConfigButton.BackgroundColor3 = ACCENT_COLOR
SaveConfigButton.BorderSizePixel = 0
SaveConfigButton.Text = "Save"
SaveConfigButton.Font = Enum.Font.GothamBold
SaveConfigButton.TextColor3 = TEXT_COLOR
SaveConfigButton.TextSize = 14
SaveConfigButton.Parent = ConfigInputArea

local SaveButtonCorner = Instance.new("UICorner")
SaveButtonCorner.CornerRadius = UDim.new(0, 6)
SaveButtonCorner.Parent = SaveConfigButton

-- Add outline to Save Config button
local SaveButtonOutline = Instance.new("UIStroke")
SaveButtonOutline.Name = "SaveButtonOutline"
SaveButtonOutline.Color = Color3.fromRGB(100, 30, 150)
SaveButtonOutline.Thickness = 1
SaveButtonOutline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
SaveButtonOutline.Parent = SaveConfigButton

local ConfigListTitle = Instance.new("TextLabel")
ConfigListTitle.Name = "ConfigListTitle"
ConfigListTitle.Size = UDim2.new(0.9, 0, 0, 30)
ConfigListTitle.BackgroundTransparency = 1
ConfigListTitle.Text = "Saved Configurations"
ConfigListTitle.Font = Enum.Font.GothamBold
ConfigListTitle.TextColor3 = TEXT_COLOR
ConfigListTitle.TextSize = 16
ConfigListTitle.Parent = ConfigTabContent

local ConfigListContainer = Instance.new("Frame")
ConfigListContainer.Name = "ConfigListContainer"
ConfigListContainer.Size = UDim2.new(0.9, 0, 0, 200)
ConfigListContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ConfigListContainer.BorderSizePixel = 0
ConfigListContainer.Parent = ConfigTabContent

local ConfigListCorner = Instance.new("UICorner")
ConfigListCorner.CornerRadius = UDim.new(0, 6)
ConfigListCorner.Parent = ConfigListContainer

-- Add outline to Config List Container
local ConfigListOutline = Instance.new("UIStroke")
ConfigListOutline.Name = "ConfigListOutline"
ConfigListOutline.Color = Color3.fromRGB(80, 80, 100)
ConfigListOutline.Thickness = 1.5
ConfigListOutline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
ConfigListOutline.Parent = ConfigListContainer

local ConfigItems = Instance.new("ScrollingFrame")
ConfigItems.Name = "ConfigItems"
ConfigItems.Size = UDim2.new(1, 0, 1, 0)
ConfigItems.BackgroundTransparency = 1
ConfigItems.BorderSizePixel = 0
ConfigItems.ScrollBarThickness = 4
ConfigItems.ScrollBarImageColor3 = ACCENT_COLOR
ConfigItems.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will be updated dynamically
ConfigItems.AutomaticCanvasSize = Enum.AutomaticSize.Y
ConfigItems.Parent = ConfigListContainer

local ConfigItemsLayout = Instance.new("UIListLayout")
ConfigItemsLayout.Name = "ConfigItemsLayout"
ConfigItemsLayout.Padding = UDim.new(0, 5)
ConfigItemsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ConfigItemsLayout.SortOrder = Enum.SortOrder.LayoutOrder
ConfigItemsLayout.Parent = ConfigItems

local ConfigItemsPadding = Instance.new("UIPadding")
ConfigItemsPadding.PaddingTop = UDim.new(0, 10)
ConfigItemsPadding.PaddingBottom = UDim.new(0, 10)
ConfigItemsPadding.PaddingLeft = UDim.new(0, 10)
ConfigItemsPadding.PaddingRight = UDim.new(0, 10)
ConfigItemsPadding.Parent = ConfigItems

local function createTabButton(name, position)
    local TabButton = Instance.new("TextButton")
    TabButton.Name = name .. "Tab"
    TabButton.Size = UDim2.new(1, 0, 0, 40)
    TabButton.Position = UDim2.new(0, 0, 0, position)
    TabButton.BackgroundColor3 = currentTab == name and HOVER_COLOR or Color3.fromRGB(25, 25, 25)
    TabButton.BorderSizePixel = 0
    TabButton.Text = name
    TabButton.Font = Enum.Font.GothamSemibold
    TabButton.TextColor3 = currentTab == name and ACCENT_COLOR or TEXT_COLOR
    TabButton.TextSize = 14
    TabButton.Parent = TabBar
    
    -- Create tab button outline
    local TabOutline = Instance.new("UIStroke")
    TabOutline.Name = "TabOutline"
    TabOutline.Color = Color3.fromRGB(60, 60, 80)
    TabOutline.Thickness = 1
    TabOutline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    TabOutline.Parent = TabButton
    
    -- Indicator for active tab
    local TabIndicator = Instance.new("Frame")
    TabIndicator.Name = "TabIndicator"
    TabIndicator.Size = UDim2.new(0, 3, 1, 0)
    TabIndicator.Position = UDim2.new(0, 0, 0, 0)
    TabIndicator.BackgroundColor3 = ACCENT_COLOR
    TabIndicator.BorderSizePixel = 0
    TabIndicator.Visible = currentTab == name
    TabIndicator.Parent = TabButton
    
    TabButton.MouseButton1Click:Connect(function()
        -- Update tab visibility
        if name == "Main" then
            MainTabContent.Visible = true
            ConfigTabContent.Visible = false
            SettingsTabContent.Visible = false
        elseif name == "Config" then
            MainTabContent.Visible = false
            ConfigTabContent.Visible = true
            SettingsTabContent.Visible = false
            refreshConfigList() -- Refresh the config list when switching to config tab
        elseif name == "Settings" then
            MainTabContent.Visible = false
            ConfigTabContent.Visible = false
            SettingsTabContent.Visible = true
        end
        
        -- Update tab button appearance
        for _, button in pairs(TabBar:GetChildren()) do
            if button:IsA("TextButton") then
                button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                button.TextColor3 = TEXT_COLOR
                button:FindFirstChild("TabIndicator").Visible = false
            end
        end
        
        TabButton.BackgroundColor3 = HOVER_COLOR
        TabButton.TextColor3 = ACCENT_COLOR
        TabIndicator.Visible = true
        currentTab = name
    end)
    
    -- Hover effect
    TabButton.MouseEnter:Connect(function()
        if currentTab ~= name then
            TabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        end
    end)
    
    TabButton.MouseLeave:Connect(function()
        if currentTab ~= name then
            TabButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        end
    end)
    
    return TabButton
end

local MainTab = createTabButton("Main", 0)
local ConfigTab = createTabButton("Config", 40)
local SettingsTab = createTabButton("Settings", 80)

local function makeDraggable(dragFrame, mainFrame)
    local dragToggle = nil
    local dragSpeed = 0.1
    local dragInput = nil
    local dragStart = nil
    local dragPos = nil

    local function updateInput(input)
        local delta = input.Position - dragStart
        local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        mainFrame.Position = position
    end

    dragFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)

    dragFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragToggle then
            updateInput(input)
        end
    end)
end

makeDraggable(TitleBar, MainFrame)

CloseButton.MouseButton1Click:Connect(function()
    SyferEngHub:Destroy()
end)

local function createToggleButton(name, onScript, offScript, isEnabled)
    -- Default to disabled if not specified
    isEnabled = isEnabled or false
    
    local ToggleButton = Instance.new("Frame")
    ToggleButton.Name = name .. "Toggle"
    ToggleButton.Size = UDim2.new(0.9, 0, 0, 40)
    ToggleButton.BackgroundColor3 = TERTIARY_COLOR
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Parent = MainTabContent
    
    -- Create an outline around the toggle button
    local ToggleOutline = Instance.new("UIStroke")
    ToggleOutline.Name = "ToggleOutline"
    ToggleOutline.Color = Color3.fromRGB(80, 80, 100)
    ToggleOutline.Thickness = 1.5
    ToggleOutline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    ToggleOutline.Parent = ToggleButton
    
    -- Add a subtle gradient
    local ToggleGradient = Instance.new("UIGradient")
    ToggleGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, TERTIARY_COLOR),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 45, 55))
    })
    ToggleGradient.Rotation = 90
    ToggleGradient.Parent = ToggleButton
    
    -- Round the corners
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 6)
    ToggleCorner.Parent = ToggleButton
    
    -- Button Text
    local ButtonText = Instance.new("TextLabel")
    ButtonText.Name = "ButtonText"
    ButtonText.Size = UDim2.new(0.8, 0, 1, 0)
    ButtonText.Position = UDim2.new(0, 15, 0, 0)
    ButtonText.BackgroundTransparency = 1
    ButtonText.Text = name
    ButtonText.Font = Enum.Font.Gotham
    ButtonText.TextColor3 = TEXT_COLOR
    ButtonText.TextSize = 14
    ButtonText.TextXAlignment = Enum.TextXAlignment.Left
    ButtonText.Parent = ToggleButton
    
    -- Toggle Indicator
    local ToggleIndicator = Instance.new("Frame")
    ToggleIndicator.Name = "ToggleIndicator"
    ToggleIndicator.Size = UDim2.new(0, 40, 0, 20)
    ToggleIndicator.Position = UDim2.new(1, -50, 0.5, -10)
    ToggleIndicator.BackgroundColor3 = isEnabled and TOGGLE_ON_COLOR or TOGGLE_OFF_COLOR
    ToggleIndicator.BorderSizePixel = 0
    ToggleIndicator.Parent = ToggleButton
    
    -- Round the corners
    local IndicatorCorner = Instance.new("UICorner")
    IndicatorCorner.CornerRadius = UDim.new(1, 0)
    IndicatorCorner.Parent = ToggleIndicator
    
    -- Toggle Knob
    local ToggleKnob = Instance.new("Frame")
    ToggleKnob.Name = "ToggleKnob"
    ToggleKnob.Size = UDim2.new(0, 16, 0, 16)
    ToggleKnob.Position = UDim2.new(isEnabled and 0.6 or 0, isEnabled and 0 or 2, 0.5, -8)
    ToggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleKnob.BorderSizePixel = 0
    ToggleKnob.Parent = ToggleIndicator
    
    -- Round the corners
    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = ToggleKnob
    
    -- Store the toggle state and scripts
    toggleButtons[name] = {
        enabled = isEnabled,
        onScript = onScript,
        offScript = offScript,
        button = ToggleButton,
        indicator = ToggleIndicator,
        knob = ToggleKnob
    }
    
    -- Toggle functionality
    ToggleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local toggleInfo = toggleButtons[name]
            toggleInfo.enabled = not toggleInfo.enabled
            
            -- Update visual appearance
            ToggleIndicator.BackgroundColor3 = toggleInfo.enabled and TOGGLE_ON_COLOR or TOGGLE_OFF_COLOR
            
            -- Tween the knob position
            local newPosition = toggleInfo.enabled and UDim2.new(0.6, 0, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = TweenService:Create(ToggleKnob, tweenInfo, {Position = newPosition})
            tween:Play()
            
            -- Execute the appropriate script
            if toggleInfo.enabled then
                -- Run the on script
                pcall(function()
                    loadstring(game:HttpGet(onScript, true))()
                end)
            else
                -- Run the off script
                pcall(function()
                    loadstring(game:HttpGet(offScript, true))()
                end)
            end
        end
    end)
    
    -- Hover effect
    ToggleButton.MouseEnter:Connect(function()
        ToggleGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 50)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 50, 65))
        })
    end)
    
    ToggleButton.MouseLeave:Connect(function()
        ToggleGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, TERTIARY_COLOR),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 45, 55))
        })
    end)
    
    return ToggleButton
end

local function saveConfig(configName)
    if configName == "" then return end
    
    -- Create a configuration table with toggle states
    local config = {}
    for name, info in pairs(toggleButtons) do
        config[name] = info.enabled
    end
    
    -- Convert to JSON
    local jsonConfig = HttpService:JSONEncode(config)
    
    -- Save the configuration
    pcall(function()
        if not isfolder(SAVE_FOLDER) then
            makefolder(SAVE_FOLDER)
        end
        writefile(SAVE_FOLDER .. "/" .. configName .. CONFIG_EXTENSION, jsonConfig)
    end)
    
    -- Refresh the config list
    refreshConfigList()
end

local function loadConfig(configName)
    -- Read the configuration file
    local success, jsonConfig = pcall(function()
        return readfile(SAVE_FOLDER .. "/" .. configName .. CONFIG_EXTENSION)
    end)
    
    if success then
        -- Parse the JSON
        local config = HttpService:JSONDecode(jsonConfig)
        
        -- Apply the configuration
        for name, enabled in pairs(config) do
            if toggleButtons[name] then
                local toggleInfo = toggleButtons[name]
                toggleInfo.enabled = enabled
                
                -- Update visual appearance
                toggleInfo.indicator.BackgroundColor3 = enabled and TOGGLE_ON_COLOR or TOGGLE_OFF_COLOR
                toggleInfo.knob.Position = enabled and UDim2.new(0.6, 0, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                
                -- Execute the appropriate script
                if enabled then
                    pcall(function()
                        loadstring(game:HttpGet(toggleInfo.onScript, true))()
                    end)
                end
            end
        end
    end
end

local function deleteConfig(configName)
    pcall(function()
        delfile(SAVE_FOLDER .. "/" .. configName .. CONFIG_EXTENSION)
    end)
    
    -- Refresh the config list
    refreshConfigList()
end

function refreshConfigList()
    -- Clear existing config items
    for _, child in pairs(ConfigItems:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Get saved configurations
    local configs = {}
    pcall(function()
        if isfolder(SAVE_FOLDER) then
            configs = listfiles(SAVE_FOLDER)
        else
            makefolder(SAVE_FOLDER)
        end
    end)
    
    -- Filter for config files and extract names
    configsList = {}
    for _, path in pairs(configs) do
        local fileName = path:match("[^/\\]+$") -- Extract filename from path
        local configName = fileName:gsub(CONFIG_EXTENSION .. "$", "")
        if fileName:match(CONFIG_EXTENSION .. "$") then
            table.insert(configsList, configName)
        end
    end
    
    -- Create config items for each config
    for i, configName in ipairs(configsList) do
        local ConfigItem = Instance.new("Frame")
        ConfigItem.Name = configName .. "Item"
        ConfigItem.Size = UDim2.new(1, 0, 0, 40)
        ConfigItem.BackgroundColor3 = TERTIARY_COLOR
        ConfigItem.BorderSizePixel = 0
        ConfigItem.Parent = ConfigItems
        
        -- Create an outline around the config item
        local ConfigOutline = Instance.new("UIStroke")
        ConfigOutline.Name = "ConfigOutline"
        ConfigOutline.Color = Color3.fromRGB(80, 80, 100)
        ConfigOutline.Thickness = 1.5
        ConfigOutline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        ConfigOutline.Parent = ConfigItem
        
        -- Add gradient to config item
        local ConfigItemGradient = Instance.new("UIGradient")
        ConfigItemGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, TERTIARY_COLOR),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 45, 55))
        })
        ConfigItemGradient.Rotation = 90
        ConfigItemGradient.Parent = ConfigItem
        
        -- Round the corners
        local ItemCorner = Instance.new("UICorner")
        ItemCorner.CornerRadius = UDim.new(0, 6)
        ItemCorner.Parent = ConfigItem
        
        -- Config Name
        local ConfigNameLabel = Instance.new("TextLabel")
        ConfigNameLabel.Name = "ConfigNameLabel"
        ConfigNameLabel.Size = UDim2.new(0.6, 0, 1, 0)
        ConfigNameLabel.Position = UDim2.new(0, 10, 0, 0)
        ConfigNameLabel.BackgroundTransparency = 1
        ConfigNameLabel.Text = configName
        ConfigNameLabel.Font = Enum.Font.Gotham
        ConfigNameLabel.TextColor3 = TEXT_COLOR
        ConfigNameLabel.TextSize = 14
        ConfigNameLabel.TextXAlignment = Enum.TextXAlignment.Left
        ConfigNameLabel.Parent = ConfigItem
        
        -- Load Button
        local LoadButton = Instance.new("TextButton")
        LoadButton.Name = "LoadButton"
        LoadButton.Size = UDim2.new(0.15, 0, 0.8, 0)
        LoadButton.Position = UDim2.new(0.6, 5, 0.1, 0)
        LoadButton.BackgroundColor3 = ACCENT_COLOR
        LoadButton.BorderSizePixel = 0
        LoadButton.Text = "Load"
        LoadButton.Font = Enum.Font.GothamSemibold
        LoadButton.TextColor3 = TEXT_COLOR
        LoadButton.TextSize = 12
        LoadButton.Parent = ConfigItem
        
        -- Round the corners
        local LoadCorner = Instance.new("UICorner")
        LoadCorner.CornerRadius = UDim.new(0, 4)
        LoadCorner.Parent = LoadButton
        
        -- Add outline to Load button
        local LoadOutline = Instance.new("UIStroke")
        LoadOutline.Name = "LoadOutline"
        LoadOutline.Color = Color3.fromRGB(100, 30, 150)
        LoadOutline.Thickness = 1
        LoadOutline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        LoadOutline.Parent = LoadButton
        
        -- Delete Button
        local DeleteButton = Instance.new("TextButton")
        DeleteButton.Name = "DeleteButton"
        DeleteButton.Size = UDim2.new(0.15, 0, 0.8, 0)
        DeleteButton.Position = UDim2.new(0.8, 0, 0.1, 0)
        DeleteButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        DeleteButton.BorderSizePixel = 0
        DeleteButton.Text = "Delete"
        DeleteButton.Font = Enum.Font.GothamSemibold
        DeleteButton.TextColor3 = TEXT_COLOR
        DeleteButton.TextSize = 12
        DeleteButton.Parent = ConfigItem
        
        -- Round the corners
        local DeleteCorner = Instance.new("UICorner")
        DeleteCorner.CornerRadius = UDim.new(0, 4)
        DeleteCorner.Parent = DeleteButton
        
        -- Add outline to Delete button
        local DeleteOutline = Instance.new("UIStroke")
        DeleteOutline.Name = "DeleteOutline"
        DeleteOutline.Color = Color3.fromRGB(150, 30, 30)
        DeleteOutline.Thickness = 1
        DeleteOutline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        DeleteOutline.Parent = DeleteButton
        
        -- Button functionality
        LoadButton.MouseButton1Click:Connect(function()
            loadConfig(configName)
        end)
        
        DeleteButton.MouseButton1Click:Connect(function()
            deleteConfig(configName)
        end)
        
        -- Hover effects for buttons
        LoadButton.MouseEnter:Connect(function()
            LoadButton.BackgroundColor3 = Color3.fromRGB(100, 40, 220)
        end)
        
        LoadButton.MouseLeave:Connect(function()
            LoadButton.BackgroundColor3 = ACCENT_COLOR
        end)
        
        DeleteButton.MouseEnter:Connect(function()
            DeleteButton.BackgroundColor3 = Color3.fromRGB(240, 70, 70)
        end)
        
        DeleteButton.MouseLeave:Connect(function()
            DeleteButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        end)
    end
    
    -- Show a message if no configs are found
    if #configsList == 0 then
        local NoConfigsLabel = Instance.new("TextLabel")
        NoConfigsLabel.Name = "NoConfigsLabel"
        NoConfigsLabel.Size = UDim2.new(1, 0, 0, 40)
        NoConfigsLabel.BackgroundTransparency = 1
        NoConfigsLabel.Text = "No saved configurations found"
        NoConfigsLabel.Font = Enum.Font.Gotham
        NoConfigsLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        NoConfigsLabel.TextSize = 14
        NoConfigsLabel.Parent = ConfigItems
    end
end

SaveConfigButton.MouseButton1Click:Connect(function()
    local configName = ConfigInput.Text
    if configName and configName ~= "" then
        saveConfig(configName)
        ConfigInput.Text = ""
    end
end)

SaveConfigButton.MouseEnter:Connect(function()
    SaveConfigButton.BackgroundColor3 = Color3.fromRGB(100, 40, 220)
end)

SaveConfigButton.MouseLeave:Connect(function()
    SaveConfigButton.BackgroundColor3 = ACCENT_COLOR
end)


    refreshConfigList()
    
    -- Initialize Settings tab content
    local toggleKeybind = Enum.KeyCode.Insert -- Default toggle key is Insert
    
    -- Create settings elements
    local SettingsTitle = Instance.new("TextLabel")
    SettingsTitle.Name = "SettingsTitle"
    SettingsTitle.Size = UDim2.new(0.9, 0, 0, 40)
    SettingsTitle.BackgroundTransparency = 1
    SettingsTitle.Text = "Settings"
    SettingsTitle.Font = Enum.Font.GothamBold
    SettingsTitle.TextColor3 = TEXT_COLOR
    SettingsTitle.TextSize = 22
    SettingsTitle.Parent = SettingsTabContent
    
    -- Menu Toggle Settings
    local MenuToggleSetting = Instance.new("Frame")
    MenuToggleSetting.Name = "MenuToggleSetting"
    MenuToggleSetting.Size = UDim2.new(0.9, 0, 0, 50)
    MenuToggleSetting.BackgroundColor3 = TERTIARY_COLOR
    MenuToggleSetting.BorderSizePixel = 0
    MenuToggleSetting.Parent = SettingsTabContent
    
    -- Add outline
    local MenuToggleOutline = Instance.new("UIStroke")
    MenuToggleOutline.Name = "MenuToggleOutline"
    MenuToggleOutline.Color = Color3.fromRGB(80, 80, 100)
    MenuToggleOutline.Thickness = 1.5
    MenuToggleOutline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    MenuToggleOutline.Parent = MenuToggleSetting
    
    -- Add gradient
    local MenuToggleGradient = Instance.new("UIGradient")
    MenuToggleGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, TERTIARY_COLOR),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 45, 55))
    })
    MenuToggleGradient.Rotation = 90
    MenuToggleGradient.Parent = MenuToggleSetting
    
    -- Round the corners
    local MenuToggleCorner = Instance.new("UICorner")
    MenuToggleCorner.CornerRadius = UDim.new(0, 6)
    MenuToggleCorner.Parent = MenuToggleSetting
    
    -- Setting Label
    local MenuToggleLabel = Instance.new("TextLabel")
    MenuToggleLabel.Name = "MenuToggleLabel"
    MenuToggleLabel.Size = UDim2.new(0.6, 0, 0.5, 0)
    MenuToggleLabel.Position = UDim2.new(0, 15, 0, 5)
    MenuToggleLabel.BackgroundTransparency = 1
    MenuToggleLabel.Text = "Menu Toggle Key"
    MenuToggleLabel.Font = Enum.Font.GothamSemibold
    MenuToggleLabel.TextColor3 = TEXT_COLOR
    MenuToggleLabel.TextSize = 14
    MenuToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    MenuToggleLabel.Parent = MenuToggleSetting
    
    -- Setting Description
    local MenuToggleDescription = Instance.new("TextLabel")
    MenuToggleDescription.Name = "MenuToggleDescription"
    MenuToggleDescription.Size = UDim2.new(0.6, 0, 0.5, 0)
    MenuToggleDescription.Position = UDim2.new(0, 15, 0.5, 0)
    MenuToggleDescription.BackgroundTransparency = 1
    MenuToggleDescription.Text = "Key to show/hide the menu"
    MenuToggleDescription.Font = Enum.Font.Gotham
    MenuToggleDescription.TextColor3 = Color3.fromRGB(180, 180, 180)
    MenuToggleDescription.TextSize = 12
    MenuToggleDescription.TextXAlignment = Enum.TextXAlignment.Left
    MenuToggleDescription.Parent = MenuToggleSetting
    
    -- Key Selector Button
    local KeySelectorButton = Instance.new("TextButton")
    KeySelectorButton.Name = "KeySelectorButton"
    KeySelectorButton.Size = UDim2.new(0.25, 0, 0.7, 0)
    KeySelectorButton.Position = UDim2.new(0.73, 0, 0.15, 0)
    KeySelectorButton.BackgroundColor3 = SECONDARY_COLOR
    KeySelectorButton.BorderSizePixel = 0
    KeySelectorButton.Text = "Insert"
    KeySelectorButton.Font = Enum.Font.GothamSemibold
    KeySelectorButton.TextColor3 = TEXT_COLOR
    KeySelectorButton.TextSize = 14
    KeySelectorButton.Parent = MenuToggleSetting
    
    -- Round the key selector corners
    local KeySelectorCorner = Instance.new("UICorner")
    KeySelectorCorner.CornerRadius = UDim.new(0, 6)
    KeySelectorCorner.Parent = KeySelectorButton
    
    -- Add outline to key selector
    local KeySelectorOutline = Instance.new("UIStroke")
    KeySelectorOutline.Name = "KeySelectorOutline"
    KeySelectorOutline.Color = Color3.fromRGB(80, 80, 100)
    KeySelectorOutline.Thickness = 1.5
    KeySelectorOutline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    KeySelectorOutline.Parent = KeySelectorButton
    
    -- Appearance Settings Section
    local AppearanceTitle = Instance.new("TextLabel")
    AppearanceTitle.Name = "AppearanceTitle"
    AppearanceTitle.Size = UDim2.new(0.9, 0, 0, 30)
    AppearanceTitle.BackgroundTransparency = 1
    AppearanceTitle.Text = "Appearance"
    AppearanceTitle.Font = Enum.Font.GothamBold
    AppearanceTitle.TextColor3 = TEXT_COLOR
    AppearanceTitle.TextSize = 18
    AppearanceTitle.TextXAlignment = Enum.TextXAlignment.Left
    AppearanceTitle.Parent = SettingsTabContent
    
    -- Theme Selector
    local ThemeSetting = Instance.new("Frame")
    ThemeSetting.Name = "ThemeSetting"
    ThemeSetting.Size = UDim2.new(0.9, 0, 0, 50)
    ThemeSetting.BackgroundColor3 = TERTIARY_COLOR
    ThemeSetting.BorderSizePixel = 0
    ThemeSetting.Parent = SettingsTabContent
    
    -- Add outline
    local ThemeOutline = Instance.new("UIStroke")
    ThemeOutline.Name = "ThemeOutline"
    ThemeOutline.Color = Color3.fromRGB(80, 80, 100)
    ThemeOutline.Thickness = 1.5
    ThemeOutline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    ThemeOutline.Parent = ThemeSetting
    
    -- Add gradient
    local ThemeGradient = Instance.new("UIGradient")
    ThemeGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, TERTIARY_COLOR),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 45, 55))
    })
    ThemeGradient.Rotation = 90
    ThemeGradient.Parent = ThemeSetting
    
    -- Round the corners
    local ThemeCorner = Instance.new("UICorner")
    ThemeCorner.CornerRadius = UDim.new(0, 6)
    ThemeCorner.Parent = ThemeSetting
    
    -- Theme Label
    local ThemeLabel = Instance.new("TextLabel")
    ThemeLabel.Name = "ThemeLabel"
    ThemeLabel.Size = UDim2.new(0.6, 0, 0.5, 0)
    ThemeLabel.Position = UDim2.new(0, 15, 0, 5)
    ThemeLabel.BackgroundTransparency = 1
    ThemeLabel.Text = "Theme Color"
    ThemeLabel.Font = Enum.Font.GothamSemibold
    ThemeLabel.TextColor3 = TEXT_COLOR
    ThemeLabel.TextSize = 14
    ThemeLabel.TextXAlignment = Enum.TextXAlignment.Left
    ThemeLabel.Parent = ThemeSetting
    
    -- Theme Description
    local ThemeDescription = Instance.new("TextLabel")
    ThemeDescription.Name = "ThemeDescription"
    ThemeDescription.Size = UDim2.new(0.6, 0, 0.5, 0)
    ThemeDescription.Position = UDim2.new(0, 15, 0.5, 0)
    ThemeDescription.BackgroundTransparency = 1
    ThemeDescription.Text = "Change the accent color"
    ThemeDescription.Font = Enum.Font.Gotham
    ThemeDescription.TextColor3 = Color3.fromRGB(180, 180, 180)
    ThemeDescription.TextSize = 12
    ThemeDescription.TextXAlignment = Enum.TextXAlignment.Left
    ThemeDescription.Parent = ThemeSetting
    
    -- Theme Dropdown Button
    local ThemeDropdownButton = Instance.new("TextButton")
    ThemeDropdownButton.Name = "ThemeDropdownButton"
    ThemeDropdownButton.Size = UDim2.new(0.25, 0, 0.7, 0)
    ThemeDropdownButton.Position = UDim2.new(0.73, 0, 0.15, 0)
    ThemeDropdownButton.BackgroundColor3 = ACCENT_COLOR
    ThemeDropdownButton.BorderSizePixel = 0
    ThemeDropdownButton.Text = "Purple"
    ThemeDropdownButton.Font = Enum.Font.GothamSemibold
    ThemeDropdownButton.TextColor3 = TEXT_COLOR
    ThemeDropdownButton.TextSize = 14
    ThemeDropdownButton.Parent = ThemeSetting
    
    -- Round the theme dropdown corners
    local ThemeDropdownCorner = Instance.new("UICorner")
    ThemeDropdownCorner.CornerRadius = UDim.new(0, 6)
    ThemeDropdownCorner.Parent = ThemeDropdownButton
    
    -- Add outline to theme dropdown
    local ThemeDropdownOutline = Instance.new("UIStroke")
    ThemeDropdownOutline.Name = "ThemeDropdownOutline"
    ThemeDropdownOutline.Color = Color3.fromRGB(80, 80, 100)
    ThemeDropdownOutline.Thickness = 1.5
    ThemeDropdownOutline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    ThemeDropdownOutline.Parent = ThemeDropdownButton
    
    -- Other Settings Section
    local OtherTitle = Instance.new("TextLabel")
    OtherTitle.Name = "OtherTitle"
    OtherTitle.Size = UDim2.new(0.9, 0, 0, 30)
    OtherTitle.BackgroundTransparency = 1
    OtherTitle.Text = "Other Settings"
    OtherTitle.Font = Enum.Font.GothamBold
    OtherTitle.TextColor3 = TEXT_COLOR
    OtherTitle.TextSize = 18
    OtherTitle.TextXAlignment = Enum.TextXAlignment.Left
    OtherTitle.Parent = SettingsTabContent
    
    -- Notification Setting
    local NotificationSetting = Instance.new("Frame")
    NotificationSetting.Name = "NotificationSetting"
    NotificationSetting.Size = UDim2.new(0.9, 0, 0, 50)
    NotificationSetting.BackgroundColor3 = TERTIARY_COLOR
    NotificationSetting.BorderSizePixel = 0
    NotificationSetting.Parent = SettingsTabContent
    
    -- Add outline
    local NotificationOutline = Instance.new("UIStroke")
    NotificationOutline.Name = "NotificationOutline"
    NotificationOutline.Color = Color3.fromRGB(80, 80, 100)
    NotificationOutline.Thickness = 1.5
    NotificationOutline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    NotificationOutline.Parent = NotificationSetting
    
    -- Add gradient
    local NotificationGradient = Instance.new("UIGradient")
    NotificationGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, TERTIARY_COLOR),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 45, 55))
    })
    NotificationGradient.Rotation = 90
    NotificationGradient.Parent = NotificationSetting
    
    -- Round the corners
    local NotificationCorner = Instance.new("UICorner")
    NotificationCorner.CornerRadius = UDim.new(0, 6)
    NotificationCorner.Parent = NotificationSetting
    
    -- Notification Label
    local NotificationLabel = Instance.new("TextLabel")
    NotificationLabel.Name = "NotificationLabel"
    NotificationLabel.Size = UDim2.new(0.6, 0, 0.5, 0)
    NotificationLabel.Position = UDim2.new(0, 15, 0, 5)
    NotificationLabel.BackgroundTransparency = 1
    NotificationLabel.Text = "Show Notifications"
    NotificationLabel.Font = Enum.Font.GothamSemibold
    NotificationLabel.TextColor3 = TEXT_COLOR
    NotificationLabel.TextSize = 14
    NotificationLabel.TextXAlignment = Enum.TextXAlignment.Left
    NotificationLabel.Parent = NotificationSetting
    
    -- Notification Description
    local NotificationDescription = Instance.new("TextLabel")
    NotificationDescription.Name = "NotificationDescription"
    NotificationDescription.Size = UDim2.new(0.6, 0, 0.5, 0)
    NotificationDescription.Position = UDim2.new(0, 15, 0.5, 0)
    NotificationDescription.BackgroundTransparency = 1
    NotificationDescription.Text = "Enable or disable notifications"
    NotificationDescription.Font = Enum.Font.Gotham
    NotificationDescription.TextColor3 = Color3.fromRGB(180, 180, 180)
    NotificationDescription.TextSize = 12
    NotificationDescription.TextXAlignment = Enum.TextXAlignment.Left
    NotificationDescription.Parent = NotificationSetting
    
    -- Notification Toggle
    local NotificationToggle = Instance.new("Frame")
    NotificationToggle.Name = "NotificationToggle"
    NotificationToggle.Size = UDim2.new(0, 40, 0, 20)
    NotificationToggle.Position = UDim2.new(0.89, -40, 0.5, -10)
    NotificationToggle.BackgroundColor3 = TOGGLE_ON_COLOR
    NotificationToggle.BorderSizePixel = 0
    NotificationToggle.Parent = NotificationSetting
    
    -- Round the corners
    local NotificationToggleCorner = Instance.new("UICorner")
    NotificationToggleCorner.CornerRadius = UDim.new(1, 0)
    NotificationToggleCorner.Parent = NotificationToggle
    
    -- Toggle Knob
    local NotificationKnob = Instance.new("Frame")
    NotificationKnob.Name = "NotificationKnob"
    NotificationKnob.Size = UDim2.new(0, 16, 0, 16)
    NotificationKnob.Position = UDim2.new(0.6, 0, 0.5, -8)
    NotificationKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    NotificationKnob.BorderSizePixel = 0
    NotificationKnob.Parent = NotificationToggle
    
    -- Round the corners
    local NotificationKnobCorner = Instance.new("UICorner")
    NotificationKnobCorner.CornerRadius = UDim.new(1, 0)
    NotificationKnobCorner.Parent = NotificationKnob
    
    -- Key selector functionality
    local isSelectingKey = false
    
    KeySelectorButton.MouseButton1Click:Connect(function()
        if isSelectingKey then return end
        
        isSelectingKey = true
        KeySelectorButton.Text = "Press a key..."
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                toggleKeybind = input.KeyCode
                KeySelectorButton.Text = input.KeyCode.Name
                isSelectingKey = false
                connection:Disconnect()
            end
        end)
    end)
    
    -- Notification toggle functionality
    local showNotifications = true
    
    NotificationSetting.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            showNotifications = not showNotifications
            
            -- Update visual appearance
            NotificationToggle.BackgroundColor3 = showNotifications and TOGGLE_ON_COLOR or TOGGLE_OFF_COLOR
            
            -- Tween the knob position
            local newPosition = showNotifications and UDim2.new(0.6, 0, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = TweenService:Create(NotificationKnob, tweenInfo, {Position = newPosition})
            tween:Play()
        end
    end)
    
    -- Theme selector functionality (simple version)
    ThemeDropdownButton.MouseButton1Click:Connect(function()
        -- Cycle through colors: Purple (default) -> Blue -> Red -> Green
        if ThemeDropdownButton.Text == "Purple" then
            ThemeDropdownButton.Text = "Blue"
            ThemeDropdownButton.BackgroundColor3 = Color3.fromRGB(50, 120, 255)
            ACCENT_COLOR = Color3.fromRGB(50, 120, 255)
            TOGGLE_ON_COLOR = Color3.fromRGB(50, 120, 255)
            GRADIENT_COLOR1 = Color3.fromRGB(30, 80, 220)
            GRADIENT_COLOR2 = Color3.fromRGB(70, 150, 255)
        elseif ThemeDropdownButton.Text == "Blue" then
            ThemeDropdownButton.Text = "Red"
            ThemeDropdownButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            ACCENT_COLOR = Color3.fromRGB(255, 50, 50)
            TOGGLE_ON_COLOR = Color3.fromRGB(255, 50, 50)
            GRADIENT_COLOR1 = Color3.fromRGB(220, 40, 40)
            GRADIENT_COLOR2 = Color3.fromRGB(255, 70, 70)
        elseif ThemeDropdownButton.Text == "Red" then
            ThemeDropdownButton.Text = "Green"
            ThemeDropdownButton.BackgroundColor3 = Color3.fromRGB(50, 200, 80)
            ACCENT_COLOR = Color3.fromRGB(50, 200, 80)
            TOGGLE_ON_COLOR = Color3.fromRGB(50, 200, 80)
            GRADIENT_COLOR1 = Color3.fromRGB(40, 180, 60)
            GRADIENT_COLOR2 = Color3.fromRGB(70, 220, 100)
        else
            ThemeDropdownButton.Text = "Purple"
            ThemeDropdownButton.BackgroundColor3 = Color3.fromRGB(180, 50, 255)
            ACCENT_COLOR = Color3.fromRGB(180, 50, 255)
            TOGGLE_ON_COLOR = Color3.fromRGB(180, 50, 255)
            GRADIENT_COLOR1 = Color3.fromRGB(120, 50, 255)
            GRADIENT_COLOR2 = Color3.fromRGB(200, 50, 255)
        end
        
        -- Update UI elements with new color
        TitleBar.BackgroundColor3 = ACCENT_COLOR
        CornerFix.BackgroundColor3 = ACCENT_COLOR
        TitleGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, GRADIENT_COLOR1),
            ColorSequenceKeypoint.new(1, GRADIENT_COLOR2)
        })
        CornerFixGradient.Color = TitleGradient.Color
        
        -- Update all toggles that are enabled
        for _, info in pairs(toggleButtons) do
            if info.enabled then
                info.indicator.BackgroundColor3 = TOGGLE_ON_COLOR
            end
        end
        
        -- Update save button
        SaveConfigButton.BackgroundColor3 = ACCENT_COLOR
        
        -- Update notification toggle if enabled
        if showNotifications then
            NotificationToggle.BackgroundColor3 = TOGGLE_ON_COLOR
        end
    end)
    
    -- Make toggle key work
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == toggleKeybind then
            SyferEngHub.Enabled = not SyferEngHub.Enabled
        end
    end)

    -- Hub Methods
    local hubMethods = {}
    
    -- Create toggle buttons with loadstrings
    function hubMethods:CreateToggle(name, onScriptUrl, offScriptUrl, defaultEnabled)
        return createToggleButton(name, onScriptUrl, offScriptUrl, defaultEnabled or false)
    end
    
    -- Save the current configuration
    function hubMethods:SaveConfig(configName)
        saveConfig(configName)
    end
    
    -- Load a saved configuration
    function hubMethods:LoadConfig(configName)
        loadConfig(configName)
    end
    
    -- Delete a saved configuration
    function hubMethods:DeleteConfig(configName)
        deleteConfig(configName)
    end
    
    -- Show or hide the hub
    function hubMethods:Show()
        SyferEngHub.Enabled = true
    end
    
    function hubMethods:Hide()
        SyferEngHub.Enabled = false
    end
    
    function hubMethods:ToggleVisibility()
        SyferEngHub.Enabled = not SyferEngHub.Enabled
        return SyferEngHub.Enabled
    end
    
    -- Set toggle key
    function hubMethods:SetToggleKey(keyCode)
        if typeof(keyCode) == "EnumItem" and keyCode.EnumType == Enum.KeyCode then
            toggleKeybind = keyCode
            if KeySelectorButton then
                KeySelectorButton.Text = keyCode.Name
            end
            return true
        end
        return false
    end
    
    -- Get current toggle key
    function hubMethods:GetToggleKey()
        return toggleKeybind
    end
    
    -- Get a list of all saved configurations
    function hubMethods:GetConfigList()
        return configsList
    end
    
    -- Get the toggle state of a specific button
    function hubMethods:GetToggleState(name)
        if toggleButtons[name] then
            return toggleButtons[name].enabled
        end
        return nil
    end
    
    -- Set the toggle state of a specific button
    function hubMethods:SetToggleState(name, enabled)
        if toggleButtons[name] then
            local toggleInfo = toggleButtons[name]
            toggleInfo.enabled = enabled
            
            -- Update visual appearance
            toggleInfo.indicator.BackgroundColor3 = enabled and TOGGLE_ON_COLOR or TOGGLE_OFF_COLOR
            toggleInfo.knob.Position = enabled and UDim2.new(0.6, 0, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            
            -- Execute the appropriate script
            if enabled then
                pcall(function()
                    loadstring(game:HttpGet(toggleInfo.onScript, true))()
                end)
            else
                pcall(function()
                    loadstring(game:HttpGet(toggleInfo.offScript, true))()
                end)
            end
            
            return true
        end
        return false
    end
    
    -- Destroy the hub UI
    function hubMethods:Destroy()
        SyferEngHub:Destroy()
    end
    
    -- Create an example toggle for demonstration
    if options.showExampleToggle then
        hubMethods:CreateToggle("ESP", 
            "https://raw.githubusercontent.com/example/esp.lua",
            "https://raw.githubusercontent.com/example/disable_esp.lua"
        )
    end
    
    return hubMethods
end

-- Example usage:
--[[
local syferHub = SyferEngHubLibrary.Create({
    -- Optional configuration:
    name = "My Custom Hub",
    accentColor = Color3.fromRGB(255, 100, 100),  -- Custom red accent
    saveFolder = "MyHubConfigs",                  -- Custom save folder
    showExampleToggle = false                     -- Don't show example toggle
})

-- Create toggles
syferHub:CreateToggle("ESP", "https://raw.githubusercontent.com/myrepo/esp.lua", "https://raw.githubusercontent.com/myrepo/disable_esp.lua")
syferHub:CreateToggle("Speed", "https://raw.githubusercontent.com/myrepo/speed.lua", "https://raw.githubusercontent.com/myrepo/disable_speed.lua")

-- You can save/load configs
syferHub:SaveConfig("MyConfig")
syferHub:LoadConfig("MyConfig")
]]

return SyferEngHubLibrary
