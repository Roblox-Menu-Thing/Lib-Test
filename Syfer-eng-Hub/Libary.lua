local SyferEngHubLibrary = {}

function SyferEngHubLibrary.Create(options)
    if not game then
        return
    end
    
    -- Track all active connections for proper cleanup
    local activeConnections = {}
    -- Flag to track if the UI is currently loaded
    local isLoaded = true

    local Players = game:GetService("Players")
    local CoreGui = game:GetService("CoreGui")
    local HttpService = game:GetService("HttpService")
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local RunService = game:GetService("RunService")

    options = options or {}
    
    -- Background configuration
    
    -- New fullscreen background options
    local backgroundBlurEnabled = options.backgroundBlurEnabled ~= nil and options.backgroundBlurEnabled or false -- Default blur disabled
    local backgroundBlurStrength = options.backgroundBlurStrength or 0 -- Default to 0 blur strength
    -- No darkness level needed as we're using only blur with no dark overlay

    local player = Players.LocalPlayer
    local username = player and player.Name or "Default"
    local SAVE_FOLDER = options.saveFolder or ("SyferEngHub/" .. username)
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

    local dragging = false
    local dragInput
    local dragStart
    local startPos
    local configsList = {}
    local toggleButtons = {}
    local currentTab = "Main"

    local SyferEngHub = Instance.new("ScreenGui")
    SyferEngHub.Name = options.name or "SyferEngHub"
    SyferEngHub.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    SyferEngHub.ResetOnSpawn = false

    pcall(function()
        SyferEngHub.Parent = CoreGui
    end)
    if not SyferEngHub.Parent then
        SyferEngHub.Parent = player:WaitForChild("PlayerGui")
    end
    
    -- Create a completely transparent fullscreen container (no image, no color)
    local FullscreenBackground = Instance.new("Frame")
    FullscreenBackground.Name = "FullscreenBackground"
    FullscreenBackground.Size = UDim2.new(1, 0, 1, 0) -- Full screen
    FullscreenBackground.Position = UDim2.new(0, 0, 0, 0)
    FullscreenBackground.BackgroundTransparency = 1 -- Completely transparent (no color overlay)
    FullscreenBackground.ZIndex = 999999 -- Extremely high to be above EVERYTHING in the game
    FullscreenBackground.BorderSizePixel = 0
    FullscreenBackground.Parent = SyferEngHub
    
    -- Make sure the FullscreenBackground always covers 100% of the screen
    local screenSizeConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if FullscreenBackground and FullscreenBackground.Parent then
            -- Keep it always at 100% of screen size
            FullscreenBackground.Size = UDim2.new(1, 0, 1, 0)
            FullscreenBackground.Position = UDim2.new(0, 0, 0, 0)
        else
            screenSizeConnection:Disconnect()
        end
    end)
    
    -- Add to active connections for tracking and proper cleanup
    table.insert(activeConnections, screenSizeConnection)
    
    -- Apply blur effect to the full-screen background
    local BlurEffect = Instance.new("BlurEffect")
    BlurEffect.Name = "BackgroundBlur"
    -- Set initial blur strength (default is 0)
    BlurEffect.Size = backgroundBlurStrength 
    BlurEffect.Enabled = backgroundBlurEnabled -- Enable/disable based on user preference
    BlurEffect.Parent = game:GetService("Lighting")
    
    -- Create the MainFrame for UI elements
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 650, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -325, 0.5, -200)
    MainFrame.BackgroundTransparency = 1 -- Make the MainFrame background fully transparent
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = false
    MainFrame.ZIndex = 1000000 -- Above the background with even higher ZIndex
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
    TitleText.Size = UDim2.new(1, -40, 1, 0)
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
    TabBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    TabBar.BackgroundTransparency = 0.3 -- Semi-transparent to show the image
    TabBar.BorderSizePixel = 0
    TabBar.ZIndex = 2 -- Above background image
    TabBar.Parent = MainFrame

    local TabBarCorner = Instance.new("UICorner")
    TabBarCorner.CornerRadius = UDim.new(0, 6)
    TabBarCorner.Parent = TabBar

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Size = UDim2.new(1, -120, 1, -30)
    ContentFrame.Position = UDim2.new(0, 120, 0, 30)
    ContentFrame.BackgroundTransparency = 0.3 -- Semi-transparent to show background image
    ContentFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25) -- Tint to maintain readability
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Parent = MainFrame
    ContentFrame.ZIndex = 2 -- Above the background image

    local MainTabContent = Instance.new("ScrollingFrame")
    MainTabContent.Name = "MainTabContent"
    MainTabContent.Size = UDim2.new(1, 0, 1, 0)
    MainTabContent.BackgroundTransparency = 1
    MainTabContent.BorderSizePixel = 0
    MainTabContent.ScrollBarThickness = 4
    MainTabContent.ScrollBarImageColor3 = ACCENT_COLOR
    MainTabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
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
    ConfigTabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    ConfigTabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ConfigTabContent.Parent = ContentFrame
    ConfigTabContent.Visible = false

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
    
    -- Create a settings section for blur settings
    local BlurSection = Instance.new("Frame")
    BlurSection.Name = "BlurSection"
    BlurSection.Size = UDim2.new(0.9, 0, 0, 120)
    BlurSection.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    BlurSection.BorderSizePixel = 0
    BlurSection.Parent = SettingsTabContent
    
    local BlurSectionCorner = Instance.new("UICorner")
    BlurSectionCorner.CornerRadius = UDim.new(0, 6)
    BlurSectionCorner.Parent = BlurSection
    
    local BlurSectionTitle = Instance.new("TextLabel")
    BlurSectionTitle.Name = "BlurSectionTitle"
    BlurSectionTitle.Size = UDim2.new(1, 0, 0, 30)
    BlurSectionTitle.BackgroundTransparency = 1
    BlurSectionTitle.Text = "Background Blur Settings"
    BlurSectionTitle.Font = Enum.Font.GothamBold
    BlurSectionTitle.TextColor3 = TEXT_COLOR
    BlurSectionTitle.TextSize = 16
    BlurSectionTitle.Parent = BlurSection
    
    -- Create toggle for blur effect
    local BlurToggleContainer = Instance.new("Frame")
    BlurToggleContainer.Name = "BlurToggleContainer"
    BlurToggleContainer.Size = UDim2.new(0.9, 0, 0, 40)
    BlurToggleContainer.Position = UDim2.new(0.05, 0, 0, 35)
    BlurToggleContainer.BackgroundTransparency = 1
    BlurToggleContainer.Parent = BlurSection
    
    local BlurToggleLabel = Instance.new("TextLabel")
    BlurToggleLabel.Name = "BlurToggleLabel"
    BlurToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    BlurToggleLabel.BackgroundTransparency = 1
    BlurToggleLabel.Text = "Enable Blur Effect"
    BlurToggleLabel.Font = Enum.Font.Gotham
    BlurToggleLabel.TextColor3 = TEXT_COLOR
    BlurToggleLabel.TextSize = 14
    BlurToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    BlurToggleLabel.Parent = BlurToggleContainer
    
    -- We'll directly create the toggle indicator frame
    local BlurToggleButton = Instance.new("Frame")
    BlurToggleButton.Name = "BlurToggleButton"
    BlurToggleButton.Size = UDim2.new(0, 40, 0, 24)
    BlurToggleButton.Position = UDim2.new(1, -45, 0.5, -12)
    BlurToggleButton.BackgroundTransparency = 1 -- Make it fully transparent as we'll use BlurToggleIndicator
    BlurToggleButton.BorderSizePixel = 0
    BlurToggleButton.Parent = BlurToggleContainer
    
    local BlurToggleIndicator = Instance.new("Frame")
    BlurToggleIndicator.Name = "BlurToggleIndicator"
    BlurToggleIndicator.Size = UDim2.new(0, 40, 0, 24)
    BlurToggleIndicator.Position = UDim2.new(1, -45, 0.5, -12)
    BlurToggleIndicator.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    BlurToggleIndicator.BorderSizePixel = 0
    BlurToggleIndicator.Parent = BlurToggleContainer
    BlurToggleIndicator.ZIndex = 2
    
    local BlurToggleIndicatorCorner = Instance.new("UICorner")
    BlurToggleIndicatorCorner.CornerRadius = UDim.new(1, 0)
    BlurToggleIndicatorCorner.Parent = BlurToggleIndicator
    
    local BlurToggleKnob = Instance.new("Frame")
    BlurToggleKnob.Name = "BlurToggleKnob"
    BlurToggleKnob.Size = UDim2.new(0, 18, 0, 18)
    BlurToggleKnob.Position = UDim2.new(0, 3, 0.5, -9)
    BlurToggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    BlurToggleKnob.BorderSizePixel = 0
    BlurToggleKnob.Parent = BlurToggleIndicator
    BlurToggleKnob.ZIndex = 3
    
    local BlurToggleKnobCorner = Instance.new("UICorner")
    BlurToggleKnobCorner.CornerRadius = UDim.new(1, 0)
    BlurToggleKnobCorner.Parent = BlurToggleKnob
    
    -- Set initial toggle state based on the backgroundBlurEnabled value
    if backgroundBlurEnabled then
        BlurToggleIndicator.BackgroundColor3 = TOGGLE_ON_COLOR
        BlurToggleKnob.Position = UDim2.new(1, -21, 0.5, -9)
    else
        BlurToggleIndicator.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        BlurToggleKnob.Position = UDim2.new(0, 3, 0.5, -9)
    end
    
    -- Add toggle functionality
    local blurToggleClickArea = Instance.new("TextButton")
    blurToggleClickArea.Name = "BlurToggleClickArea"
    blurToggleClickArea.Size = UDim2.new(1, 0, 1, 0)
    blurToggleClickArea.BackgroundTransparency = 1
    blurToggleClickArea.Text = ""
    blurToggleClickArea.Parent = BlurToggleContainer
    
    local blurToggleConnection = blurToggleClickArea.MouseButton1Click:Connect(function()
        -- Toggle the blur state
        backgroundBlurEnabled = not backgroundBlurEnabled
        print("Blur toggle clicked, new state: " .. (backgroundBlurEnabled and "ON" or "OFF"))
        
        -- Update toggle visuals with animation
        if backgroundBlurEnabled then
            BlurToggleIndicator.BackgroundColor3 = TOGGLE_ON_COLOR
            TweenService:Create(BlurToggleKnob, TweenInfo.new(0.2), {Position = UDim2.new(1, -21, 0.5, -9)}):Play()
        else
            BlurToggleIndicator.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            TweenService:Create(BlurToggleKnob, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, -9)}):Play()
        end
        
        -- Update blur effect right away
        local BlurEffect = game:GetService("Lighting"):FindFirstChild("BackgroundBlur")
        if BlurEffect then
            BlurEffect.Enabled = backgroundBlurEnabled and MainFrame.Visible
            print("Blur effect enabled: " .. tostring(BlurEffect.Enabled))
        else
            -- Create the blur effect if it doesn't exist
            BlurEffect = Instance.new("BlurEffect")
            BlurEffect.Name = "BackgroundBlur"
            BlurEffect.Size = backgroundBlurStrength
            BlurEffect.Enabled = backgroundBlurEnabled and MainFrame.Visible
            BlurEffect.Parent = game:GetService("Lighting")
            print("Created new blur effect, enabled: " .. tostring(BlurEffect.Enabled))
        end
    end)
    
    -- Add connection to our tracking system for cleanup
    table.insert(activeConnections, blurToggleConnection)
    
    -- Create a slider for blur strength
    local BlurStrengthSlider = Instance.new("Frame")
    BlurStrengthSlider.Name = "BlurStrengthSlider"
    BlurStrengthSlider.Size = UDim2.new(0.9, 0, 0, 40)
    BlurStrengthSlider.Position = UDim2.new(0.05, 0, 0, 75)
    BlurStrengthSlider.BackgroundTransparency = 1
    BlurStrengthSlider.Parent = BlurSection
    
    local BlurStrengthLabel = Instance.new("TextLabel")
    BlurStrengthLabel.Name = "BlurStrengthLabel"
    BlurStrengthLabel.Size = UDim2.new(0.5, 0, 0.5, 0)
    BlurStrengthLabel.BackgroundTransparency = 1
    BlurStrengthLabel.Text = "Blur Strength"
    BlurStrengthLabel.Font = Enum.Font.Gotham
    BlurStrengthLabel.TextColor3 = TEXT_COLOR
    BlurStrengthLabel.TextSize = 14
    BlurStrengthLabel.TextXAlignment = Enum.TextXAlignment.Left
    BlurStrengthLabel.Parent = BlurStrengthSlider
    
    local BlurStrengthValue = Instance.new("TextLabel")
    BlurStrengthValue.Name = "BlurStrengthValue"
    BlurStrengthValue.Size = UDim2.new(0.2, 0, 0.5, 0)
    BlurStrengthValue.Position = UDim2.new(0.8, 0, 0, 0)
    BlurStrengthValue.BackgroundTransparency = 1
    BlurStrengthValue.Text = tostring(backgroundBlurStrength) -- Show current blur strength
    BlurStrengthValue.Font = Enum.Font.GothamBold
    BlurStrengthValue.TextColor3 = ACCENT_COLOR -- Use accent color to make it stand out
    BlurStrengthValue.TextSize = 14
    BlurStrengthValue.Parent = BlurStrengthSlider
    
    local BlurSliderTrack = Instance.new("Frame")
    BlurSliderTrack.Name = "BlurSliderTrack"
    BlurSliderTrack.Size = UDim2.new(0.9, 0, 0, 4)
    BlurSliderTrack.Position = UDim2.new(0.05, 0, 0.75, 0)
    BlurSliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    BlurSliderTrack.BorderSizePixel = 0
    BlurSliderTrack.Parent = BlurStrengthSlider
    
    local BlurSliderTrackCorner = Instance.new("UICorner")
    BlurSliderTrackCorner.CornerRadius = UDim.new(1, 0)
    BlurSliderTrackCorner.Parent = BlurSliderTrack
    
    local BlurSliderFill = Instance.new("Frame")
    BlurSliderFill.Name = "BlurSliderFill"
    -- Set initial size based on current blur strength
    BlurSliderFill.Size = UDim2.new(backgroundBlurStrength / 56, 0, 1, 0)
    BlurSliderFill.BackgroundColor3 = ACCENT_COLOR
    BlurSliderFill.BorderSizePixel = 0
    BlurSliderFill.Parent = BlurSliderTrack
    
    local BlurSliderFillCorner = Instance.new("UICorner")
    BlurSliderFillCorner.CornerRadius = UDim.new(1, 0)
    BlurSliderFillCorner.Parent = BlurSliderFill
    
    local BlurSliderHandle = Instance.new("Frame")
    BlurSliderHandle.Name = "BlurSliderHandle"
    BlurSliderHandle.Size = UDim2.new(0, 12, 0, 12)
    BlurSliderHandle.Position = UDim2.new(backgroundBlurStrength / 56, 0, 0.5, -6) -- Position based on current blur strength
    BlurSliderHandle.BackgroundColor3 = Color3.fromRGB(220, 220, 230)
    BlurSliderHandle.BorderSizePixel = 0
    BlurSliderHandle.Parent = BlurSliderTrack
    
    local BlurSliderHandleCorner = Instance.new("UICorner")
    BlurSliderHandleCorner.CornerRadius = UDim.new(1, 0)
    BlurSliderHandleCorner.Parent = BlurSliderHandle
    
    -- Add slider functionality for blur strength
    local isDragging = false
    
    local function updateBlurStrength(value)
        -- Clamp the value between 0 and 56 (Roblox limit)
        value = math.clamp(value, 0, 56)
        
        -- Update blur strength value display
        backgroundBlurStrength = value
        BlurStrengthValue.Text = tostring(math.floor(value))
        
        -- Update slider visuals 
        local percentage = value / 56 -- Use 56 as the max instead of 50
        BlurSliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        BlurSliderHandle.Position = UDim2.new(percentage, 0, 0.5, -6)
        
        -- Update blur effect
        local BlurEffect = game:GetService("Lighting"):FindFirstChild("BackgroundBlur")
        if BlurEffect then
            BlurEffect.Size = value
        end
    end
    
    local function beginDrag()
        isDragging = true
    end
    
    local function endDrag()
        isDragging = false
    end
    
    local function updateDrag(input)
        if not isDragging then return end
        
        local mousePos = input.Position.X
        local trackPos = BlurSliderTrack.AbsolutePosition.X
        local trackWidth = BlurSliderTrack.AbsoluteSize.X
        
        local relativePos = math.clamp((mousePos - trackPos) / trackWidth, 0, 1)
        local value = relativePos * 56 -- Use 56 as maximum (Roblox's limit)
        
        updateBlurStrength(value)
    end
    
    local sliderHandleConnection = BlurSliderHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            beginDrag()
        end
    end)
    table.insert(activeConnections, sliderHandleConnection)
    
    local sliderTrackConnection = BlurSliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            beginDrag()
            updateDrag(input)
        end
    end)
    table.insert(activeConnections, sliderTrackConnection)
    
    local inputEndConnection = UserInputService.InputEnded:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            endDrag()
        end
    end)
    table.insert(activeConnections, inputEndConnection)
    
    local inputChangeConnection = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            updateDrag(input)
        end
    end)
    table.insert(activeConnections, inputChangeConnection)

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
    ConfigItems.CanvasSize = UDim2.new(0, 0, 0, 0)
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

        local TabOutline = Instance.new("UIStroke")
        TabOutline.Name = "TabOutline"
        TabOutline.Color = Color3.fromRGB(60, 60, 80)
        TabOutline.Thickness = 1
        TabOutline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        TabOutline.Parent = TabButton

        local TabIndicator = Instance.new("Frame")
        TabIndicator.Name = "TabIndicator"
        TabIndicator.Size = UDim2.new(0, 3, 1, 0)
        TabIndicator.Position = UDim2.new(0, 0, 0, 0)
        TabIndicator.BackgroundColor3 = ACCENT_COLOR
        TabIndicator.BorderSizePixel = 0
        TabIndicator.Visible = currentTab == name
        TabIndicator.Parent = TabButton
        
        local tabClickConnection = TabButton.MouseButton1Click:Connect(function()
            if name == "Main" then
                MainTabContent.Visible = true
                ConfigTabContent.Visible = false
                SettingsTabContent.Visible = false
            elseif name == "Config" then
                MainTabContent.Visible = false
                ConfigTabContent.Visible = true
                SettingsTabContent.Visible = false
                refreshConfigList()
            elseif name == "Settings" then
                MainTabContent.Visible = false
                ConfigTabContent.Visible = false
                SettingsTabContent.Visible = true
            end

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
        table.insert(activeConnections, tabClickConnection)

        local tabEnterConnection = TabButton.MouseEnter:Connect(function()
            if currentTab ~= name then
                TabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            end
        end)
        table.insert(activeConnections, tabEnterConnection)

        local tabLeaveConnection = TabButton.MouseLeave:Connect(function()
            if currentTab ~= name then
                TabButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            end
        end)
        table.insert(activeConnections, tabLeaveConnection)

        return TabButton
    end

    local UserProfileFrame = Instance.new("Frame")
    UserProfileFrame.Name = "UserProfileFrame"
    UserProfileFrame.Size = UDim2.new(1, 0, 0, 80)
    UserProfileFrame.Position = UDim2.new(0, 0, 0, 0)
    UserProfileFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    UserProfileFrame.BackgroundTransparency = 0.2 -- Slightly transparent to show background
    UserProfileFrame.BorderSizePixel = 0
    UserProfileFrame.ZIndex = 3 -- Above other UI elements
    UserProfileFrame.Parent = TabBar

    local ProfileCorner = Instance.new("UICorner")
    ProfileCorner.CornerRadius = UDim.new(0, 6)
    ProfileCorner.Parent = UserProfileFrame

    local UserAvatar = Instance.new("ImageLabel")
    UserAvatar.Name = "UserAvatar"
    UserAvatar.Size = UDim2.new(0, 50, 0, 50)
    UserAvatar.Position = UDim2.new(0.5, -25, 0, 5)
    UserAvatar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    UserAvatar.BackgroundTransparency = 0
    UserAvatar.Image = ""
    UserAvatar.Parent = UserProfileFrame

    local function updateAvatar()
        local success, result = pcall(function()
            local content = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
            return content
        end)
        
        if success then
            UserAvatar.Image = result
        end
    end

    pcall(updateAvatar)

    local AvatarCorner = Instance.new("UICorner")
    AvatarCorner.CornerRadius = UDim.new(1, 0)
    AvatarCorner.Parent = UserAvatar

    local AvatarOutline = Instance.new("UIStroke")
    AvatarOutline.Name = "AvatarOutline"
    AvatarOutline.Color = ACCENT_COLOR
    AvatarOutline.Thickness = 2
    AvatarOutline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    AvatarOutline.Parent = UserAvatar

    -- Player count removed as requested

    local UsernameLabel = Instance.new("TextLabel")
    UsernameLabel.Name = "UsernameLabel"
    UsernameLabel.Size = UDim2.new(1, 0, 0, 15)
    UsernameLabel.Position = UDim2.new(0, 0, 0, 60)
    UsernameLabel.BackgroundTransparency = 1
    UsernameLabel.Text = player.Name
    UsernameLabel.Font = Enum.Font.GothamBold
    UsernameLabel.TextColor3 = TEXT_COLOR
    UsernameLabel.TextSize = 12
    UsernameLabel.Parent = UserProfileFrame

    createTabButton("Main", 90)
    createTabButton("Config", 140)
    createTabButton("Settings", 190)

    local toggleScripts = {}
    local toggleEnabled = {}
    local toggleKey = Enum.KeyCode.Home

    local function makeToggleFunc(name, enableScript, disableScript)
        print("Creating toggle function for '" .. name .. "'")
        
        -- Store the scripts to be executed when this toggle is enabled/disabled
        toggleScripts[name] = {enable = enableScript, disable = disableScript}
        
        -- Initialize the toggle state as false (OFF) if it's not already set
        if toggleEnabled[name] == nil then
            toggleEnabled[name] = false
            print("Initialized toggleEnabled['" .. name .. "'] to false")
        end
        
        -- Return the function that can be called to change this toggle's state
        return function(state)
            -- Update the toggle state in our tracking table
            toggleEnabled[name] = state
            print("Toggle function called for '" .. name .. "', setting to: " .. tostring(state))
            
            -- Determine which script to run based on the new state
            local script = state and enableScript or disableScript
            if script then
                print("Executing " .. (state and "enable" or "disable") .. " script for '" .. name .. "'")
                pcall(function()
                    loadstring(game:HttpGet(script, true))()
                end)
            end
        end
    end

    local function createToggle(name, enableUrl, disableUrl)
        local ToggleButton = Instance.new("Frame")
        ToggleButton.Name = name .. "Toggle"
        ToggleButton.Size = UDim2.new(0.9, 0, 0, 45)
        ToggleButton.BackgroundColor3 = TERTIARY_COLOR
        ToggleButton.BorderSizePixel = 0
        ToggleButton.Parent = MainTabContent

        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 6)
        ToggleCorner.Parent = ToggleButton

        local ToggleOutline = Instance.new("UIStroke")
        ToggleOutline.Name = "ToggleOutline"
        ToggleOutline.Color = Color3.fromRGB(60, 60, 80)
        ToggleOutline.Thickness = 1
        ToggleOutline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        ToggleOutline.Parent = ToggleButton

        local ButtonText = Instance.new("TextLabel")
        ButtonText.Name = "ButtonText"
        ButtonText.Size = UDim2.new(1, -80, 1, 0)
        ButtonText.Position = UDim2.new(0, 15, 0, 0)
        ButtonText.BackgroundTransparency = 1
        ButtonText.Text = name
        ButtonText.Font = Enum.Font.GothamSemibold
        ButtonText.TextColor3 = TEXT_COLOR
        ButtonText.TextSize = 14
        ButtonText.TextXAlignment = Enum.TextXAlignment.Left
        ButtonText.Parent = ToggleButton

        local ToggleIndicator = Instance.new("Frame")
        ToggleIndicator.Name = "ToggleIndicator"
        ToggleIndicator.Size = UDim2.new(0, 50, 0, 24)
        ToggleIndicator.Position = UDim2.new(1, -60, 0.5, -12)
        ToggleIndicator.BackgroundColor3 = TOGGLE_OFF_COLOR
        ToggleIndicator.BorderSizePixel = 0
        ToggleIndicator.Parent = ToggleButton

        local IndicatorCorner = Instance.new("UICorner")
        IndicatorCorner.CornerRadius = UDim.new(1, 0)
        IndicatorCorner.Parent = ToggleIndicator

        local ToggleKnob = Instance.new("Frame")
        ToggleKnob.Name = "ToggleKnob"
        ToggleKnob.Size = UDim2.new(0, 18, 0, 18)
        ToggleKnob.Position = UDim2.new(0, 3, 0.5, -9)
        ToggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ToggleKnob.BorderSizePixel = 0
        ToggleKnob.Parent = ToggleIndicator
        ToggleKnob.ZIndex = 3 -- Make sure the knob is above the indicator

        local KnobCorner = Instance.new("UICorner")
        KnobCorner.CornerRadius = UDim.new(1, 0)
        KnobCorner.Parent = ToggleKnob

        local function updateToggle()
            local isEnabled = toggleEnabled[name]
            ToggleIndicator.BackgroundColor3 = isEnabled and TOGGLE_ON_COLOR or TOGGLE_OFF_COLOR
            TweenService:Create(ToggleKnob, TweenInfo.new(0.2), {Position = isEnabled and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)}):Play()
        end

        local toggleButtonConnection = ToggleButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                -- Toggle state and print debug info
                toggleEnabled[name] = not toggleEnabled[name]
                print("Feature toggle '" .. name .. "' clicked, new state: " .. (toggleEnabled[name] and "ON" or "OFF"))
                
                -- Update the visual state of the toggle
                updateToggle()
                
                -- Update the toggle info in our buttons table
                if toggleButtons[name] then
                    toggleButtons[name].enabled = toggleEnabled[name]
                    print("Updated buttons table state for '" .. name .. "' to: " .. tostring(toggleButtons[name].enabled))
                end
                
                -- Call the appropriate script based on the toggle state
                if toggleScripts[name] then
                    -- Get the appropriate script URL based on the current state
                    local script = toggleEnabled[name] and toggleScripts[name].enable or toggleScripts[name].disable
                    if script then
                        print("Executing " .. (toggleEnabled[name] and "enable" or "disable") .. " script for '" .. name .. "'")
                        pcall(function()
                            loadstring(game:HttpGet(script, true))()
                        end)
                    end
                end
            end
        end)
        
        -- Add the connection to our tracking table for proper cleanup
        table.insert(activeConnections, toggleButtonConnection)

        toggleButtons[name] = {
            button = ToggleButton,
            indicator = ToggleIndicator,
            knob = ToggleKnob,
            enabled = false
        }
        
        return updateToggle
    end
    
    -- Setup background blur effect
    local function setupBackgroundBlur()
        -- Get or create the blur effect
        local BlurEffect = game:GetService("Lighting"):FindFirstChild("BackgroundBlur")
        if not BlurEffect then
            -- Create a new blur effect if it doesn't exist
            BlurEffect = Instance.new("BlurEffect")
            BlurEffect.Name = "BackgroundBlur"
            BlurEffect.Size = backgroundBlurStrength -- Use the specified or default strength
            BlurEffect.Enabled = backgroundBlurEnabled and MainFrame.Visible -- Initially disabled by default
            BlurEffect.Parent = game:GetService("Lighting")
            print("Created new blur effect with strength " .. backgroundBlurStrength)
        else
            -- Update existing blur effect
            BlurEffect.Size = backgroundBlurStrength
            BlurEffect.Enabled = backgroundBlurEnabled and MainFrame.Visible
            print("Updated existing blur effect, strength: " .. backgroundBlurStrength .. ", enabled: " .. tostring(BlurEffect.Enabled))
        end
        
        -- Configure the FullscreenBackground to cover EVERYTHING in Roblox
        FullscreenBackground.AnchorPoint = Vector2.new(0, 0)
        FullscreenBackground.Size = UDim2.new(1, 0, 1, 0) -- Full screen coverage
        FullscreenBackground.Position = UDim2.new(0, 0, 0, 0)
        FullscreenBackground.ZIndex = 999999 -- Extremely high to be above EVERYTHING in the game
        FullscreenBackground.BackgroundTransparency = 1 -- Completely transparent, using only blur
        
        -- Connection to monitor UI state with proper cleanup handling
        local uiStateConnection
        uiStateConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if not FullscreenBackground or not FullscreenBackground.Parent then
                -- Clean up if the GUI is destroyed
                if uiStateConnection then
                    uiStateConnection:Disconnect()
                end
                return
            end
            
            -- Keep FullscreenBackground visibility in sync with MainFrame
            FullscreenBackground.Visible = MainFrame.Visible
            
            -- Get or recreate the blur effect if needed
            local currentBlurEffect = game:GetService("Lighting"):FindFirstChild("BackgroundBlur")
            if not currentBlurEffect then
                currentBlurEffect = Instance.new("BlurEffect")
                currentBlurEffect.Name = "BackgroundBlur"
                currentBlurEffect.Size = backgroundBlurStrength
                currentBlurEffect.Parent = game:GetService("Lighting")
                print("Recreated lost blur effect")
            end
            
            -- Update blur effect state based on UI visibility and toggle state
            currentBlurEffect.Enabled = backgroundBlurEnabled and MainFrame.Visible
            currentBlurEffect.Size = backgroundBlurStrength
        end)
        
        -- Add to activeConnections for proper cleanup when UI is unloaded
        table.insert(activeConnections, uiStateConnection)
        
        print("Background blur setup complete. Initial state: " .. 
              "Enabled=" .. tostring(backgroundBlurEnabled) .. 
              ", Strength=" .. tostring(backgroundBlurStrength) ..
              ", Visible=" .. tostring(MainFrame.Visible))
    end
    
    -- Setup the background blur effect
    setupBackgroundBlur()

    local interface = {}

    interface.CreateToggle = function(self, name, enableUrl, disableUrl)
        local updateFunc = createToggle(name, enableUrl, disableUrl)
        updateFunc()
        return makeToggleFunc(name, enableUrl, disableUrl)
    end

    interface.GetToggleState = function(self, name)
        return toggleEnabled[name] or false
    end

    interface.SetToggleState = function(self, name, state)
        if toggleButtons[name] then
            print("SetToggleState called for '" .. name .. "', setting to: " .. tostring(state))
            
            local toggleInfo = toggleButtons[name]
            toggleInfo.enabled = state
            toggleInfo.indicator.BackgroundColor3 = state and TOGGLE_ON_COLOR or TOGGLE_OFF_COLOR
            TweenService:Create(toggleInfo.knob, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)}):Play()
            
            -- Update the tracked toggle state
            toggleEnabled[name] = state
            print("Updated toggleEnabled['" .. name .. "'] to " .. tostring(toggleEnabled[name]))
            
            -- Execute the associated scripts if any
            if toggleScripts[name] then
                local script = state and toggleScripts[name].enable or toggleScripts[name].disable
                if script then
                    print("Executing " .. (state and "enable" or "disable") .. " script for '" .. name .. "'")
                    pcall(function()
                        loadstring(game:HttpGet(script, true))()
                    end)
                end
            end
        else
            print("SetToggleState ERROR: Toggle '" .. name .. "' not found!")
        end
    end

    interface.SetVisible = function(self, visible)
        MainFrame.Visible = visible
    end

    interface.ToggleVisibility = function(self)
        MainFrame.Visible = not MainFrame.Visible
        
        -- Toggle the background blur when UI visibility changes (only if blur is enabled)
        local BlurEffect = game:GetService("Lighting"):FindFirstChild("BackgroundBlur")
        if BlurEffect then
            -- Only enable blur when the UI is visible AND blur is enabled
            BlurEffect.Enabled = MainFrame.Visible and backgroundBlurEnabled
            
            -- Toggle the fullscreen background visibility as well
            FullscreenBackground.Visible = MainFrame.Visible
        end
    end

    interface.SetTheme = function(self, options)
        if options.accentColor then
            ACCENT_COLOR = options.accentColor
            TitleBar.BackgroundColor3 = ACCENT_COLOR
            TitleGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, options.gradientColor1 or GRADIENT_COLOR1),
                ColorSequenceKeypoint.new(1, options.gradientColor2 or GRADIENT_COLOR2)
            })
            CornerFix.BackgroundColor3 = ACCENT_COLOR
            CornerFixGradient.Color = TitleGradient.Color
            
            for _, button in pairs(TabBar:GetChildren()) do
                if button:IsA("TextButton") and button:FindFirstChild("TabIndicator") then
                    button.TabIndicator.BackgroundColor3 = ACCENT_COLOR
                    if button.TextColor3 ~= TEXT_COLOR then
                        button.TextColor3 = ACCENT_COLOR
                    end
                end
            end
            
            for _, toggle in pairs(toggleButtons) do
                toggle.indicator.BackgroundColor3 = toggle.enabled and TOGGLE_ON_COLOR or TOGGLE_OFF_COLOR
            end
        end
    end
    
    interface.SetToggleKey = function(self, key)
        toggleKey = key or Enum.KeyCode.Home
    end

    interface.SaveConfig = function(self, configName)
        if not configName or configName == "" then return end
        
        local configData = {
            accentColor = ACCENT_COLOR,
            defaultColor = DEFAULT_COLOR,
            secondaryColor = SECONDARY_COLOR,
            tertiaryColor = TERTIARY_COLOR,
            hoverColor = HOVER_COLOR,
            textColor = TEXT_COLOR,
            toggleOnColor = TOGGLE_ON_COLOR,
            toggleOffColor = TOGGLE_OFF_COLOR,
            gradientColor1 = GRADIENT_COLOR1,
            gradientColor2 = GRADIENT_COLOR2,
            -- Background settings
            backgroundBlurEnabled = backgroundBlurEnabled,
            backgroundBlurStrength = game:GetService("Lighting"):FindFirstChild("BackgroundBlur") and game:GetService("Lighting"):FindFirstChild("BackgroundBlur").Size or backgroundBlurStrength,
            backgroundDarkness = backgroundDarkness,
            toggleStates = {}
        }
        
        for name, state in pairs(toggleEnabled) do
            configData.toggleStates[name] = state
        end
        
        writefile(SAVE_FOLDER .. "/" .. configName .. CONFIG_EXTENSION, HttpService:JSONEncode(configData))
        refreshConfigList()
    end
    
    interface.LoadConfig = function(self, configName)
        if not configName then return end
        
        local success, configData = pcall(function()
            return HttpService:JSONDecode(readfile(SAVE_FOLDER .. "/" .. configName .. CONFIG_EXTENSION))
        end)
        
        if success and configData then
            -- Apply theme
            self:SetTheme({
                accentColor = Color3.new(configData.accentColor.r, configData.accentColor.g, configData.accentColor.b),
                defaultColor = Color3.new(configData.defaultColor.r, configData.defaultColor.g, configData.defaultColor.b),
                secondaryColor = Color3.new(configData.secondaryColor.r, configData.secondaryColor.g, configData.secondaryColor.b),
                tertiaryColor = Color3.new(configData.tertiaryColor.r, configData.tertiaryColor.g, configData.tertiaryColor.b),
                hoverColor = Color3.new(configData.hoverColor.r, configData.hoverColor.g, configData.hoverColor.b),
                textColor = Color3.new(configData.textColor.r, configData.textColor.g, configData.textColor.b),
                toggleOnColor = Color3.new(configData.toggleOnColor.r, configData.toggleOnColor.g, configData.toggleOnColor.b),
                toggleOffColor = Color3.new(configData.toggleOffColor.r, configData.toggleOffColor.g, configData.toggleOffColor.b),
                gradientColor1 = Color3.new(configData.gradientColor1.r, configData.gradientColor1.g, configData.gradientColor1.b),
                gradientColor2 = Color3.new(configData.gradientColor2.r, configData.gradientColor2.g, configData.gradientColor2.b)
            })
            
            -- Apply toggle states
            for name, state in pairs(configData.toggleStates) do
                self:SetToggleState(name, state)
            end
            
            -- Apply background settings if they exist in the config
            
            if configData.backgroundBlurEnabled ~= nil then
                backgroundBlurEnabled = configData.backgroundBlurEnabled
                
                -- Update the toggle button visuals
                if BlurToggleIndicator and BlurToggleKnob then
                    if backgroundBlurEnabled then
                        BlurToggleIndicator.BackgroundColor3 = TOGGLE_ON_COLOR
                        BlurToggleKnob.Position = UDim2.new(1, -21, 0.5, -9)
                    else
                        BlurToggleIndicator.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                        BlurToggleKnob.Position = UDim2.new(0, 3, 0.5, -9)
                    end
                end
            end
            
            -- Apply blur strength if it exists in the config
            if configData.backgroundBlurStrength ~= nil then
                backgroundBlurStrength = configData.backgroundBlurStrength
                
                -- Update blur effect strength
                local BlurEffect = game:GetService("Lighting"):FindFirstChild("BackgroundBlur")
                if BlurEffect then
                    BlurEffect.Size = backgroundBlurStrength
                end
                
                -- Update slider visuals if they exist
                if BlurStrengthValue then
                    BlurStrengthValue.Text = tostring(math.floor(backgroundBlurStrength))
                end
                
                if BlurSliderFill then
                    local percentage = backgroundBlurStrength / 56
                    BlurSliderFill.Size = UDim2.new(percentage, 0, 1, 0)
                end
                
                if BlurSliderHandle then
                    local percentage = backgroundBlurStrength / 56
                    BlurSliderHandle.Position = UDim2.new(percentage, 0, 0.5, -6)
                end
            end
            
            -- Apply the enabled state to the BlurEffect
            local BlurEffect = game:GetService("Lighting"):FindFirstChild("BackgroundBlur")
            if BlurEffect then
                BlurEffect.Enabled = backgroundBlurEnabled and MainFrame.Visible
            end
            
            if configData.backgroundDarkness ~= nil and FullscreenBackground then
                FullscreenBackground.BackgroundTransparency = configData.backgroundDarkness
            end
            
            return true
        end
        
        return false
    end
    
    -- All GIF/background image methods removed
    
    -- Method to set the blur strength
    interface.setBlurStrength = function(strength)
        local BlurEffect = game:GetService("Lighting"):FindFirstChild("BackgroundBlur")
        if BlurEffect then
            BlurEffect.Size = strength
            print("Background blur strength set to: " .. strength)
        end
    end
    
    -- Method to set the background darkness (transparency)
    interface.setBackgroundDarkness = function(darkness)
        if FullscreenBackground then
            FullscreenBackground.BackgroundTransparency = darkness
            print("Background darkness set to: " .. darkness)
        end
    end
    
    -- Method to enable/disable the blur effect
    interface.setBlurEnabled = function(enabled)
        backgroundBlurEnabled = enabled
        
        local BlurEffect = game:GetService("Lighting"):FindFirstChild("BackgroundBlur")
        if BlurEffect then
            BlurEffect.Enabled = enabled and MainFrame.Visible
            print("Background blur " .. (enabled and "enabled" or "disabled"))
        end
    end
    
    -- Method to check if blur is enabled
    interface.isBlurEnabled = function()
        return backgroundBlurEnabled
    end
    
    -- Method to get the current blur strength
    interface.getBlurStrength = function()
        local BlurEffect = game:GetService("Lighting"):FindFirstChild("BackgroundBlur")
        if BlurEffect then
            return BlurEffect.Size
        end
        return nil
    end
    
    -- Method to get the current background darkness
    interface.getBackgroundDarkness = function()
        if FullscreenBackground then
            return FullscreenBackground.BackgroundTransparency
        end
        return nil
    end

    local function createConfigItem(configName)
        local ConfigItem = Instance.new("Frame")
        ConfigItem.Name = configName .. "Config"
        ConfigItem.Size = UDim2.new(1, -20, 0, 35)
        ConfigItem.BackgroundColor3 = TERTIARY_COLOR
        ConfigItem.BorderSizePixel = 0
        ConfigItem.Parent = ConfigItems

        local ItemCorner = Instance.new("UICorner")
        ItemCorner.CornerRadius = UDim.new(0, 6)
        ItemCorner.Parent = ConfigItem

        local ItemOutline = Instance.new("UIStroke")
        ItemOutline.Name = "ItemOutline"
        ItemOutline.Color = Color3.fromRGB(60, 60, 80)
        ItemOutline.Thickness = 1
        ItemOutline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        ItemOutline.Parent = ConfigItem

        local ConfigNameLabel = Instance.new("TextLabel")
        ConfigNameLabel.Name = "ConfigNameLabel"
        ConfigNameLabel.Size = UDim2.new(0.5, 0, 1, 0)
        ConfigNameLabel.Position = UDim2.new(0, 10, 0, 0)
        ConfigNameLabel.BackgroundTransparency = 1
        ConfigNameLabel.Text = configName
        ConfigNameLabel.Font = Enum.Font.Gotham
        ConfigNameLabel.TextColor3 = TEXT_COLOR
        ConfigNameLabel.TextSize = 14
        ConfigNameLabel.TextXAlignment = Enum.TextXAlignment.Left
        ConfigNameLabel.Parent = ConfigItem

        local LoadButton = Instance.new("TextButton")
        LoadButton.Name = "LoadButton"
        LoadButton.Size = UDim2.new(0.22, 0, 0.7, 0)
        LoadButton.Position = UDim2.new(0.5, 5, 0.5, -12)
        LoadButton.BackgroundColor3 = ACCENT_COLOR
        LoadButton.BorderSizePixel = 0
        LoadButton.Text = "Load"
        LoadButton.Font = Enum.Font.GothamBold
        LoadButton.TextColor3 = TEXT_COLOR
        LoadButton.TextSize = 12
        LoadButton.Parent = ConfigItem

        local LoadButtonCorner = Instance.new("UICorner")
        LoadButtonCorner.CornerRadius = UDim.new(0, 4)
        LoadButtonCorner.Parent = LoadButton

        local DeleteButton = Instance.new("TextButton")
        DeleteButton.Name = "DeleteButton"
        DeleteButton.Size = UDim2.new(0.22, 0, 0.7, 0)
        DeleteButton.Position = UDim2.new(0.75, 0, 0.5, -12)
        DeleteButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        DeleteButton.BorderSizePixel = 0
        DeleteButton.Text = "Delete"
        DeleteButton.Font = Enum.Font.GothamBold
        DeleteButton.TextColor3 = TEXT_COLOR
        DeleteButton.TextSize = 12
        DeleteButton.Parent = ConfigItem

        local DeleteButtonCorner = Instance.new("UICorner")
        DeleteButtonCorner.CornerRadius = UDim.new(0, 4)
        DeleteButtonCorner.Parent = DeleteButton

        LoadButton.MouseButton1Click:Connect(function()
            interface:LoadConfig(configName)
        end)

        DeleteButton.MouseButton1Click:Connect(function()
            pcall(function()
                delfile(SAVE_FOLDER .. "/" .. configName .. CONFIG_EXTENSION)
                ConfigItem:Destroy()
                refreshConfigList()
            end)
        end)

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

    function refreshConfigList()
        for _, child in pairs(ConfigItems:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end

        local configs = {}
        pcall(function()
            if not isfolder(SAVE_FOLDER) then
                makefolder(SAVE_FOLDER)
            end
            configs = listfiles(SAVE_FOLDER)
        end)

        if #configs == 0 then
            local NoConfigsLabel = Instance.new("TextLabel")
            NoConfigsLabel.Name = "NoConfigsLabel"
            NoConfigsLabel.Size = UDim2.new(1, -20, 0, 35)
            NoConfigsLabel.BackgroundTransparency = 1
            NoConfigsLabel.Text = "No saved configurations"
            NoConfigsLabel.Font = Enum.Font.Gotham
            NoConfigsLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
            NoConfigsLabel.TextSize = 14
            NoConfigsLabel.Parent = ConfigItems
        else
            for _, configPath in pairs(configs) do
                local configName = configPath:match("([^/\\]+)%.[^%.]+$")
                if configName then
                    configName = configName:gsub(CONFIG_EXTENSION .. "$", "")
                    createConfigItem(configName)
                end
            end
        end
    end

    SaveConfigButton.MouseEnter:Connect(function()
        SaveConfigButton.BackgroundColor3 = Color3.fromRGB(100, 40, 220)
    end)

    SaveConfigButton.MouseLeave:Connect(function()
        SaveConfigButton.BackgroundColor3 = ACCENT_COLOR
    end)

    SaveConfigButton.MouseButton1Click:Connect(function()
        interface:SaveConfig(ConfigInput.Text)
        ConfigInput.Text = ""
    end)

    -- Dragging functionality
    local function updateDrag(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)

    TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            updateDrag(input)
        end
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == toggleKey then
            interface:ToggleVisibility()
        end
    end)

    CloseButton.MouseButton1Click:Connect(function()
        -- Completely unload the UI when X button is clicked (not just hide)
        
        -- Remove the blur effect from Lighting service
        local BlurEffect = game:GetService("Lighting"):FindFirstChild("BackgroundBlur")
        if BlurEffect then
            BlurEffect:Destroy()
        end
        
        -- Clean up screen size connection created earlier
        if screenSizeConnection and screenSizeConnection.Connected then
            screenSizeConnection:Disconnect()
        end
        
        -- Disconnect all active connections to prevent memory leaks
        for _, connection in pairs(activeConnections) do
            if connection.Connected then
                connection:Disconnect()
            end
        end
        
        -- Destroy the entire UI
        SyferEngHub:Destroy()
        
        -- Set flag indicating the UI is unloaded
        isLoaded = false
        
        print("SyferEngHub UI has been completely unloaded")
    end)

    pcall(function()
        if not isfolder(SAVE_FOLDER) then
            makefolder(SAVE_FOLDER)
        end
    end)

    refreshConfigList()

    return interface
end

return SyferEngHubLibrary
