
-- SyferEngHub Library
-- A modular UI library for Roblox exploits with VapeV4-inspired design
-- Version 1.0

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
MainFrame.Size = UDim2.new(0, 550, 0, 350)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
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
        elseif name == "Config" then
            MainTabContent.Visible = false
            ConfigTabContent.Visible = true
            refreshConfigList() -- Refresh the config list when switching to config tab
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
