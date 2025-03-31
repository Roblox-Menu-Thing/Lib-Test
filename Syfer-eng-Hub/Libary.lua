local SyferEngHubLibrary = {}

function SyferEngHubLibrary.Create(options)
    if not game then
        return
    end

    local Players = game:GetService("Players")
    local CoreGui = game:GetService("CoreGui")
    local HttpService = game:GetService("HttpService")
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local RunService = game:GetService("RunService")

    options = options or {}

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
    
    -- Background options
    local BACKGROUND_TYPE = options.backgroundType or "neon" -- "gradient", "particles", "image", "animated", "blur", "neon"
    local BACKGROUND_IMAGE_ID = options.backgroundImageId or "rbxassetid://6073763717" -- Default space background
    local BACKGROUND_TRANSPARENCY = options.backgroundTransparency or 0.1
    local BACKGROUND_COLOR1 = options.backgroundGradientColor1 or Color3.fromRGB(15, 15, 20)
    local BACKGROUND_COLOR2 = options.backgroundGradientColor2 or Color3.fromRGB(25, 25, 35)
    local PARTICLE_COUNT = options.particleCount or 75 -- Increased particle count
    local PARTICLE_SIZE = options.particleSize or {min = 2, max = 6} -- Larger particle size range
    local PARTICLE_SPEED = options.particleSpeed or 0.8 -- Faster particles
    local PARTICLE_COLOR = options.particleColor or Color3.fromRGB(180, 50, 255)
    local ANIMATION_SPEED = options.animationSpeed or 1.5 -- Faster animation
    local BLUR_INTENSITY = options.blurIntensity or 15
    local NEON_COLOR1 = options.neonColor1 or Color3.fromRGB(0, 200, 255) -- Cyan
    local NEON_COLOR2 = options.neonColor2 or Color3.fromRGB(255, 0, 200) -- Pink
    local NEON_COLOR3 = options.neonColor3 or Color3.fromRGB(0, 255, 100) -- Green
    local NEON_PULSE_SPEED = options.neonPulseSpeed or 1.2

    local dragging = false
    local dragInput
    local dragStart
    local startPos
    local configsList = {}
    local toggleButtons = {}
    local currentTab = "Main"
    local animationConnections = {}

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

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 650, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -325, 0.5, -200)
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
    
    -- Create the background based on the selected type
    local Background = Instance.new("Frame")
    Background.Name = "Background"
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.BackgroundTransparency = 0
    Background.BackgroundColor3 = DEFAULT_COLOR
    Background.BorderSizePixel = 0
    Background.ZIndex = 0
    Background.Parent = MainFrame
    
    local BackgroundUICorner = Instance.new("UICorner")
    BackgroundUICorner.CornerRadius = UDim.new(0, 6)
    BackgroundUICorner.Parent = Background
    
    -- Apply the background based on selected type
    if BACKGROUND_TYPE == "gradient" then
        local UIGradient = Instance.new("UIGradient")
        UIGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, BACKGROUND_COLOR1),
            ColorSequenceKeypoint.new(1, BACKGROUND_COLOR2)
        })
        UIGradient.Rotation = 135
        UIGradient.Parent = Background
        
        -- Animate the gradient if animation speed is set
        if ANIMATION_SPEED > 0 then
            local offset = 0
            local connection = RunService.RenderStepped:Connect(function(deltaTime)
                offset = (offset + deltaTime * ANIMATION_SPEED * 0.1) % 1
                UIGradient.Offset = Vector2.new(offset, offset)
            end)
            table.insert(animationConnections, connection)
        end
    elseif BACKGROUND_TYPE == "image" then
        Background.BackgroundTransparency = 1
        
        local BackgroundImage = Instance.new("ImageLabel")
        BackgroundImage.Name = "BackgroundImage"
        BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
        BackgroundImage.BackgroundTransparency = 1
        BackgroundImage.Image = BACKGROUND_IMAGE_ID
        BackgroundImage.ImageTransparency = BACKGROUND_TRANSPARENCY
        BackgroundImage.ScaleType = Enum.ScaleType.Crop
        BackgroundImage.ZIndex = 0
        BackgroundImage.Parent = Background
        
        local ImageUICorner = Instance.new("UICorner")
        ImageUICorner.CornerRadius = UDim.new(0, 6)
        ImageUICorner.Parent = BackgroundImage
    elseif BACKGROUND_TYPE == "particles" then
        Background.BackgroundTransparency = 0.7
        
        local ParticleContainer = Instance.new("Frame")
        ParticleContainer.Name = "ParticleContainer"
        ParticleContainer.Size = UDim2.new(1, 0, 1, 0)
        ParticleContainer.BackgroundTransparency = 1
        ParticleContainer.ClipsDescendants = true
        ParticleContainer.ZIndex = 0
        ParticleContainer.Parent = Background
        
        local ParticleUICorner = Instance.new("UICorner")
        ParticleUICorner.CornerRadius = UDim.new(0, 6)
        ParticleUICorner.Parent = ParticleContainer
        
        -- Create particles
        local particles = {}
        for i = 1, PARTICLE_COUNT do
            local particle = Instance.new("Frame")
            particle.Name = "Particle_" .. i
            particle.BackgroundColor3 = PARTICLE_COLOR
            
            -- Random size between min and max
            local size = math.random(PARTICLE_SIZE.min, PARTICLE_SIZE.max)
            particle.Size = UDim2.new(0, size, 0, size)
            
            -- Random position
            particle.Position = UDim2.new(
                math.random() * 0.9 + 0.05, 
                0, 
                math.random() * 0.9 + 0.05, 
                0
            )
            
            -- Random transparency
            particle.BackgroundTransparency = math.random() * 0.6 + 0.2
            
            -- Add rounded corners
            local particleCorner = Instance.new("UICorner")
            particleCorner.CornerRadius = UDim.new(1, 0) -- Circle
            particleCorner.Parent = particle
            
            -- Add glow effect
            local particleGlow = Instance.new("UIStroke")
            particleGlow.Color = PARTICLE_COLOR
            particleGlow.Thickness = 1
            particleGlow.Transparency = 0.7
            particleGlow.Parent = particle
            
            particle.Parent = ParticleContainer
            table.insert(particles, {
                ui = particle,
                speed = PARTICLE_SPEED * (0.5 + math.random()),
                direction = Vector2.new(
                    math.random() * 2 - 1,
                    math.random() * 2 - 1
                ).Unit
            })
        end
        
        -- Animate particles
        local connection = RunService.RenderStepped:Connect(function(deltaTime)
            for _, particle in ipairs(particles) do
                local currentPosition = particle.ui.Position
                local newX = currentPosition.X.Scale + (particle.direction.X * particle.speed * deltaTime)
                local newY = currentPosition.Y.Scale + (particle.direction.Y * particle.speed * deltaTime)
                
                -- Bounce particles off the edges
                if newX <= 0 or newX >= 1 then
                    particle.direction = Vector2.new(-particle.direction.X, particle.direction.Y)
                    newX = math.clamp(newX, 0, 1)
                end
                
                if newY <= 0 or newY >= 1 then
                    particle.direction = Vector2.new(particle.direction.X, -particle.direction.Y)
                    newY = math.clamp(newY, 0, 1)
                end
                
                particle.ui.Position = UDim2.new(newX, 0, newY, 0)
            end
        end)
        table.insert(animationConnections, connection)
    elseif BACKGROUND_TYPE == "animated" then
        -- Create multiple background layers for parallax effect
        local layers = 3
        for i = 1, layers do
            local layer = Instance.new("Frame")
            layer.Name = "AnimatedLayer_" .. i
            layer.Size = UDim2.new(1.5, 0, 1.5, 0)
            layer.Position = UDim2.new(-0.25, 0, -0.25, 0)
            layer.BackgroundTransparency = 0.7 + ((i-1) * 0.1)
            layer.ZIndex = 0
            layer.Parent = Background
            
            local layerGradient = Instance.new("UIGradient")
            layerGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, BACKGROUND_COLOR1),
                ColorSequenceKeypoint.new(1, BACKGROUND_COLOR2)
            })
            layerGradient.Rotation = 45 + (i * 30)
            layerGradient.Parent = layer
            
            -- Animate the layer
            local speedMultiplier = 1 / i -- Deeper layers move slower
            local connection = RunService.RenderStepped:Connect(function(deltaTime)
                layerGradient.Rotation = (layerGradient.Rotation + deltaTime * ANIMATION_SPEED * 10 * speedMultiplier) % 360
            end)
            table.insert(animationConnections, connection)
        end
    elseif BACKGROUND_TYPE == "blur" then
        Background.BackgroundTransparency = 0.4
        
        -- Add a blur effect with subtle animation
        local BlurEffect = Instance.new("Frame")
        BlurEffect.Name = "BlurEffect"
        BlurEffect.Size = UDim2.new(1, 0, 1, 0)
        BlurEffect.BackgroundTransparency = 0.7
        BlurEffect.BackgroundColor3 = BACKGROUND_COLOR1
        BlurEffect.ZIndex = 0
        BlurEffect.Parent = Background
        
        local BlurUICorner = Instance.new("UICorner")
        BlurUICorner.CornerRadius = UDim.new(0, 6)
        BlurUICorner.Parent = BlurEffect
        
        -- Add some glass-like elements
        for i = 1, 5 do
            local glassElement = Instance.new("Frame")
            glassElement.Name = "GlassElement_" .. i
            glassElement.Size = UDim2.new(0, math.random(50, 150), 0, math.random(50, 150))
            glassElement.Position = UDim2.new(math.random() * 0.7 + 0.1, 0, math.random() * 0.7 + 0.1, 0)
            glassElement.BackgroundColor3 = Color3.fromRGB(
                math.random(220, 255),
                math.random(220, 255),
                math.random(220, 255)
            )
            glassElement.BackgroundTransparency = 0.85
            glassElement.ZIndex = 0
            glassElement.Parent = BlurEffect
            
            local ElementUICorner = Instance.new("UICorner")
            ElementUICorner.CornerRadius = UDim.new(0, math.random(5, 20))
            ElementUICorner.Parent = glassElement
            
            -- Subtle animation
            local connection = RunService.Heartbeat:Connect(function(deltaTime)
                local t = tick() * ANIMATION_SPEED * 0.2
                local offset = math.sin(t + i) * 0.01
                glassElement.BackgroundTransparency = 0.85 + (math.sin(t * 0.5 + i * 0.7) * 0.05)
                glassElement.Position = UDim2.new(
                    glassElement.Position.X.Scale + offset * deltaTime,
                    0,
                    glassElement.Position.Y.Scale + offset * deltaTime * 0.5,
                    0
                )
            end)
            table.insert(animationConnections, connection)
        end
    elseif BACKGROUND_TYPE == "neon" then
        -- Create a dark background with neon elements
        Background.BackgroundTransparency = 0.2
        Background.BackgroundColor3 = Color3.fromRGB(10, 10, 15) -- Darker background for neon to pop
        
        -- Create a grid of lines
        local gridSize = 12
        local gridContainer = Instance.new("Frame")
        gridContainer.Name = "GridContainer"
        gridContainer.Size = UDim2.new(1.2, 0, 1.2, 0)
        gridContainer.Position = UDim2.new(-0.1, 0, -0.1, 0)
        gridContainer.BackgroundTransparency = 1
        gridContainer.ZIndex = 0
        gridContainer.Parent = Background
        
        -- Create horizontal and vertical grid lines
        for i = 0, gridSize do
            -- Horizontal line
            local hLine = Instance.new("Frame")
            hLine.Name = "HLine_" .. i
            hLine.Size = UDim2.new(1, 0, 0, 1)
            hLine.Position = UDim2.new(0, 0, i/gridSize, 0)
            hLine.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            hLine.BackgroundTransparency = 0.7
            hLine.BorderSizePixel = 0
            hLine.ZIndex = 0
            hLine.Parent = gridContainer
            
            -- Vertical line
            local vLine = Instance.new("Frame")
            vLine.Name = "VLine_" .. i
            vLine.Size = UDim2.new(0, 1, 1, 0)
            vLine.Position = UDim2.new(i/gridSize, 0, 0, 0)
            vLine.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            vLine.BackgroundTransparency = 0.7
            vLine.BorderSizePixel = 0
            vLine.ZIndex = 0
            vLine.Parent = gridContainer
        end
        
        -- Create neon light elements
        local neonColors = {NEON_COLOR1, NEON_COLOR2, NEON_COLOR3}
        local neonElements = {}
        
        -- Create horizontal neon bar at top
        local topBar = Instance.new("Frame")
        topBar.Name = "TopNeonBar"
        topBar.Size = UDim2.new(0.8, 0, 0, 3)
        topBar.Position = UDim2.new(0.1, 0, 0.05, 0)
        topBar.BackgroundColor3 = neonColors[1]
        topBar.BorderSizePixel = 0
        topBar.ZIndex = 0
        topBar.Parent = Background
        
        -- Add glow effect to top bar
        local topBarGlow = Instance.new("UIStroke")
        topBarGlow.Color = neonColors[1]
        topBarGlow.Thickness = 2
        topBarGlow.Transparency = 0.2
        topBarGlow.Parent = topBar
        
        table.insert(neonElements, {ui = topBar, glow = topBarGlow, color = neonColors[1], speed = 1.0})
        
        -- Create vertical neon bar on right
        local rightBar = Instance.new("Frame")
        rightBar.Name = "RightNeonBar"
        rightBar.Size = UDim2.new(0, 3, 0.6, 0)
        rightBar.Position = UDim2.new(0.95, 0, 0.2, 0)
        rightBar.BackgroundColor3 = neonColors[2]
        rightBar.BorderSizePixel = 0
        rightBar.ZIndex = 0
        rightBar.Parent = Background
        
        -- Add glow effect to right bar
        local rightBarGlow = Instance.new("UIStroke")
        rightBarGlow.Color = neonColors[2]
        rightBarGlow.Thickness = 2
        rightBarGlow.Transparency = 0.2
        rightBarGlow.Parent = rightBar
        
        table.insert(neonElements, {ui = rightBar, glow = rightBarGlow, color = neonColors[2], speed = 0.8})
        
        -- Create bottom-left corner accent
        local cornerAccent = Instance.new("Frame")
        cornerAccent.Name = "CornerNeonAccent"
        cornerAccent.Size = UDim2.new(0, 40, 0, 3)
        cornerAccent.Position = UDim2.new(0.1, 0, 0.9, 0)
        cornerAccent.BackgroundColor3 = neonColors[3]
        cornerAccent.BorderSizePixel = 0
        cornerAccent.ZIndex = 0
        cornerAccent.Parent = Background
        
        -- Add glow effect to corner accent
        local cornerGlow = Instance.new("UIStroke")
        cornerGlow.Color = neonColors[3]
        cornerGlow.Thickness = 2
        cornerGlow.Transparency = 0.2
        cornerGlow.Parent = cornerAccent
        
        table.insert(neonElements, {ui = cornerAccent, glow = cornerGlow, color = neonColors[3], speed = 1.2})
        
        -- Create diagonal accent line
        local diagonalLine = Instance.new("Frame")
        diagonalLine.Name = "DiagonalNeonLine"
        diagonalLine.Size = UDim2.new(0, 3, 0.3, 0)
        diagonalLine.Position = UDim2.new(0.2, 0, 0.6, 0)
        diagonalLine.BackgroundColor3 = neonColors[1]
        diagonalLine.BorderSizePixel = 0
        diagonalLine.ZIndex = 0
        diagonalLine.Rotation = 45
        diagonalLine.Parent = Background
        
        -- Add glow effect to diagonal line
        local diagonalGlow = Instance.new("UIStroke")
        diagonalGlow.Color = neonColors[1]
        diagonalGlow.Thickness = 2
        diagonalGlow.Transparency = 0.2
        diagonalGlow.Parent = diagonalLine
        
        table.insert(neonElements, {ui = diagonalLine, glow = diagonalGlow, color = neonColors[1], speed = 0.9})
        
        -- Create circular accent
        local circleAccent = Instance.new("Frame")
        circleAccent.Name = "CircleNeonAccent"
        circleAccent.Size = UDim2.new(0, 30, 0, 30)
        circleAccent.Position = UDim2.new(0.85, 0, 0.75, 0)
        circleAccent.BackgroundTransparency = 1
        circleAccent.ZIndex = 0
        circleAccent.Parent = Background
        
        -- Add circular stroke
        local circleStroke = Instance.new("UIStroke")
        circleStroke.Color = neonColors[2]
        circleStroke.Thickness = 2
        circleStroke.Parent = circleAccent
        
        -- Make it a circle
        local circleCorner = Instance.new("UICorner")
        circleCorner.CornerRadius = UDim.new(1, 0)
        circleCorner.Parent = circleAccent
        
        table.insert(neonElements, {ui = circleAccent, glow = circleStroke, color = neonColors[2], speed = 1.1})
        
        -- Animate the neon elements to pulse
        local connection = RunService.RenderStepped:Connect(function(deltaTime)
            for _, element in ipairs(neonElements) do
                local time = tick() * NEON_PULSE_SPEED * element.speed
                local brightness = 0.5 + 0.5 * math.sin(time)
                
                -- Get the base color and calculate the brightened version
                local baseColor = element.color
                local brightColor = Color3.new(
                    math.min(1, baseColor.R + brightness * 0.4),
                    math.min(1, baseColor.G + brightness * 0.4),
                    math.min(1, baseColor.B + brightness * 0.4)
                )
                
                -- Apply the pulsing effect
                element.ui.BackgroundColor3 = brightColor
                element.glow.Color = brightColor
                element.glow.Transparency = 0.6 - (brightness * 0.4)
            end
            
            -- Rotate the grid slightly for a cyber effect
            gridContainer.Rotation = math.sin(tick() * 0.1) * 1
        end)
        table.insert(animationConnections, connection)
    end

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
    ConfigItemsLayout.SortOrder = Enum.SortOrder.Name
    ConfigItemsLayout.Parent = ConfigItems

    local ConfigItemsPadding = Instance.new("UIPadding")
    ConfigItemsPadding.PaddingTop = UDim.new(0, 5)
    ConfigItemsPadding.PaddingBottom = UDim.new(0, 5)
    ConfigItemsPadding.Parent = ConfigItems

    -- Add background settings section to Settings tab
    local BackgroundSettingsSection = Instance.new("Frame")
    BackgroundSettingsSection.Name = "BackgroundSettingsSection"
    BackgroundSettingsSection.Size = UDim2.new(0.9, 0, 0, 250)
    BackgroundSettingsSection.BackgroundColor3 = TERTIARY_COLOR
    BackgroundSettingsSection.BorderSizePixel = 0
    BackgroundSettingsSection.Parent = SettingsTabContent

    local BackgroundSettingsCorner = Instance.new("UICorner")
    BackgroundSettingsCorner.CornerRadius = UDim.new(0, 6)
    BackgroundSettingsCorner.Parent = BackgroundSettingsSection

    local BackgroundSettingsTitle = Instance.new("TextLabel")
    BackgroundSettingsTitle.Name = "BackgroundSettingsTitle"
    BackgroundSettingsTitle.Size = UDim2.new(1, 0, 0, 30)
    BackgroundSettingsTitle.BackgroundTransparency = 1
    BackgroundSettingsTitle.Text = "Background Settings"
    BackgroundSettingsTitle.Font = Enum.Font.GothamBold
    BackgroundSettingsTitle.TextColor3 = TEXT_COLOR
    BackgroundSettingsTitle.TextSize = 16
    BackgroundSettingsTitle.Parent = BackgroundSettingsSection

    local BackgroundSettingsLayout = Instance.new("UIListLayout")
    BackgroundSettingsLayout.Name = "BackgroundSettingsLayout"
    BackgroundSettingsLayout.Padding = UDim.new(0, 10)
    BackgroundSettingsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    BackgroundSettingsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    BackgroundSettingsLayout.Parent = BackgroundSettingsSection

    local BackgroundSettingsPadding = Instance.new("UIPadding")
    BackgroundSettingsPadding.PaddingTop = UDim.new(0, 40)
    BackgroundSettingsPadding.PaddingBottom = UDim.new(0, 10)
    BackgroundSettingsPadding.Parent = BackgroundSettingsSection

    -- Background Type Selector
    local BackgroundTypeSelector = Instance.new("Frame")
    BackgroundTypeSelector.Name = "BackgroundTypeSelector"
    BackgroundTypeSelector.Size = UDim2.new(0.9, 0, 0, 30)
    BackgroundTypeSelector.BackgroundColor3 = SECONDARY_COLOR
    BackgroundTypeSelector.BorderSizePixel = 0
    BackgroundTypeSelector.Parent = BackgroundSettingsSection

    local BackgroundTypeSelectorCorner = Instance.new("UICorner")
    BackgroundTypeSelectorCorner.CornerRadius = UDim.new(0, 6)
    BackgroundTypeSelectorCorner.Parent = BackgroundTypeSelector

    local BackgroundTypeLabel = Instance.new("TextLabel")
    BackgroundTypeLabel.Name = "BackgroundTypeLabel"
    BackgroundTypeLabel.Size = UDim2.new(0.4, 0, 1, 0)
    BackgroundTypeLabel.BackgroundTransparency = 1
    BackgroundTypeLabel.Text = "Background Type:"
    BackgroundTypeLabel.Font = Enum.Font.Gotham
    BackgroundTypeLabel.TextColor3 = TEXT_COLOR
    BackgroundTypeLabel.TextSize = 14
    BackgroundTypeLabel.TextXAlignment = Enum.TextXAlignment.Left
    BackgroundTypeLabel.Parent = BackgroundTypeSelector

    local BackgroundTypeDropdown = Instance.new("TextButton")
    BackgroundTypeDropdown.Name = "BackgroundTypeDropdown"
    BackgroundTypeDropdown.Size = UDim2.new(0.6, 0, 1, 0)
    BackgroundTypeDropdown.Position = UDim2.new(0.4, 0, 0, 0)
    BackgroundTypeDropdown.BackgroundColor3 = TERTIARY_COLOR
    BackgroundTypeDropdown.BorderSizePixel = 0
    BackgroundTypeDropdown.Text = BACKGROUND_TYPE
    BackgroundTypeDropdown.Font = Enum.Font.Gotham
    BackgroundTypeDropdown.TextColor3 = TEXT_COLOR
    BackgroundTypeDropdown.TextSize = 14
    BackgroundTypeDropdown.Parent = BackgroundTypeSelector
    
    local BackgroundTypeDropdownCorner = Instance.new("UICorner")
    BackgroundTypeDropdownCorner.CornerRadius = UDim.new(0, 6)
    BackgroundTypeDropdownCorner.Parent = BackgroundTypeDropdown

    -- Create tabs
    local function createTab(name, order)
        local TabButton = Instance.new("TextButton")
        TabButton.Name = name .. "Tab"
        TabButton.Size = UDim2.new(0.9, 0, 0, 30)
        TabButton.Position = UDim2.new(0.05, 0, 0, 10 + (order - 1) * 40)
        TabButton.BackgroundColor3 = name == currentTab and ACCENT_COLOR or TERTIARY_COLOR
        TabButton.BorderSizePixel = 0
        TabButton.Text = name
        TabButton.Font = Enum.Font.GothamBold
        TabButton.TextColor3 = TEXT_COLOR
        TabButton.TextSize = 14
        TabButton.Parent = TabBar

        local TabButtonCorner = Instance.new("UICorner")
        TabButtonCorner.CornerRadius = UDim.new(0, 6)
        TabButtonCorner.Parent = TabButton

        TabButton.MouseButton1Click:Connect(function()
            -- Update tab visibility
            MainTabContent.Visible = name == "Main"
            ConfigTabContent.Visible = name == "Config"
            SettingsTabContent.Visible = name == "Settings"
            
            -- Update tab button colors
            for _, child in pairs(TabBar:GetChildren()) do
                if child:IsA("TextButton") then
                    child.BackgroundColor3 = TERTIARY_COLOR
                end
            end
            TabButton.BackgroundColor3 = ACCENT_COLOR
            currentTab = name
        end)

        return TabButton
    end

    createTab("Main", 1)
    createTab("Config", 2)
    createTab("Settings", 3)

    -- Add dragging functionality
    local function updateDrag(input)
        local delta = input.Position - dragStart
        local newPosition = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        TweenService:Create(MainFrame, TweenInfo.new(0.1), {Position = newPosition}):Play()
    end

    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateDrag(input)
        end
    end)

    -- Close button functionality
    CloseButton.MouseButton1Click:Connect(function()
        -- Clean up animation connections
        for _, connection in ipairs(animationConnections) do
            connection:Disconnect()
        end
        animationConnections = {}
        
        SyferEngHub:Destroy()
    end)

    -- Create a toggle function
    local function createToggle(name, callback, section)
        section = section or MainTabContent
        
        local Toggle = Instance.new("Frame")
        Toggle.Name = name .. "Toggle"
        Toggle.Size = UDim2.new(0.9, 0, 0, 40)
        Toggle.BackgroundColor3 = TERTIARY_COLOR
        Toggle.BorderSizePixel = 0
        Toggle.Parent = section

        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 6)
        ToggleCorner.Parent = Toggle

        local ToggleLabel = Instance.new("TextLabel")
        ToggleLabel.Name = "ToggleLabel"
        ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
        ToggleLabel.BackgroundTransparency = 1
        ToggleLabel.Text = "  " .. name
        ToggleLabel.Font = Enum.Font.Gotham
        ToggleLabel.TextColor3 = TEXT_COLOR
        ToggleLabel.TextSize = 14
        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        ToggleLabel.Parent = Toggle

        local ToggleButton = Instance.new("Frame")
        ToggleButton.Name = "ToggleButton"
        ToggleButton.Size = UDim2.new(0, 40, 0, 20)
        ToggleButton.Position = UDim2.new(0.85, 0, 0.5, -10)
        ToggleButton.BackgroundColor3 = TOGGLE_OFF_COLOR
        ToggleButton.BorderSizePixel = 0
        ToggleButton.Parent = Toggle

        local ToggleButtonCorner = Instance.new("UICorner")
        ToggleButtonCorner.CornerRadius = UDim.new(1, 0)
        ToggleButtonCorner.Parent = ToggleButton

        local ToggleIndicator = Instance.new("Frame")
        ToggleIndicator.Name = "ToggleIndicator"
        ToggleIndicator.Size = UDim2.new(0, 16, 0, 16)
        ToggleIndicator.Position = UDim2.new(0, 2, 0.5, -8)
        ToggleIndicator.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
        ToggleIndicator.BorderSizePixel = 0
        ToggleIndicator.Parent = ToggleButton

        local ToggleIndicatorCorner = Instance.new("UICorner")
        ToggleIndicatorCorner.CornerRadius = UDim.new(1, 0)
        ToggleIndicatorCorner.Parent = ToggleIndicator

        local isToggled = false
        table.insert(toggleButtons, {
            name = name,
            toggled = false,
            instance = Toggle,
            indicator = ToggleIndicator,
            button = ToggleButton
        })

        local function updateToggle()
            isToggled = not isToggled
            
            -- Update visual state
            local targetPosition = isToggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            local targetColor = isToggled and TOGGLE_ON_COLOR or TOGGLE_OFF_COLOR
            
            TweenService:Create(ToggleIndicator, TweenInfo.new(0.2), {Position = targetPosition}):Play()
            TweenService:Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
            
            if callback then
                callback(isToggled)
            end
            
            -- Update the toggle in the list
            for i, toggle in ipairs(toggleButtons) do
                if toggle.name == name then
                    toggleButtons[i].toggled = isToggled
                    break
                end
            end
        end

        Toggle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                updateToggle()
            end
        end)

        ToggleButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                updateToggle()
            end
        end)

        return {
            instance = Toggle,
            setToggle = function(state)
                if isToggled ~= state then
                    updateToggle()
                end
            end,
            getToggle = function()
                return isToggled
            end
        }
    end

    -- Add background control toggles to Settings
    local backgroundTypeOptions = {"gradient", "particles", "image", "animated", "blur", "neon"}
    local backgroundTypeDropdown = false

    local function createBackgroundTypeDropdown()
        local DropdownContainer = Instance.new("Frame")
        DropdownContainer.Name = "BackgroundTypeDropdownContainer"
        DropdownContainer.Size = UDim2.new(0.6, 0, 0, #backgroundTypeOptions * 30)
        DropdownContainer.Position = UDim2.new(0.4, 0, 1, 0)
        DropdownContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        DropdownContainer.BorderSizePixel = 0
        DropdownContainer.Visible = false
        DropdownContainer.ZIndex = 10
        DropdownContainer.Parent = BackgroundTypeSelector
        
        local DropdownContainerCorner = Instance.new("UICorner")
        DropdownContainerCorner.CornerRadius = UDim.new(0, 6)
        DropdownContainerCorner.Parent = DropdownContainer
        
        local DropdownLayout = Instance.new("UIListLayout")
        DropdownLayout.Padding = UDim.new(0, 2)
        DropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder
        DropdownLayout.Parent = DropdownContainer
        
        for i, option in ipairs(backgroundTypeOptions) do
            local OptionButton = Instance.new("TextButton")
            OptionButton.Name = option .. "Option"
            OptionButton.Size = UDim2.new(1, 0, 0, 30)
            OptionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            OptionButton.BorderSizePixel = 0
            OptionButton.Text = option
            OptionButton.Font = Enum.Font.Gotham
            OptionButton.TextColor3 = TEXT_COLOR
            OptionButton.TextSize = 14
            OptionButton.ZIndex = 10
            OptionButton.Parent = DropdownContainer
            
            OptionButton.MouseButton1Click:Connect(function()
                BackgroundTypeDropdown.Text = option
                DropdownContainer.Visible = false
                backgroundTypeDropdown = false
                
                -- Apply the background change
                -- This would require saving the setting and restarting the UI
                -- In a real implementation, we would store this and apply on next UI open
                local notification = Instance.new("TextLabel")
                notification.Name = "Notification"
                notification.Size = UDim2.new(0.8, 0, 0, 30)
                notification.Position = UDim2.new(0.1, 0, 0.9, 0)
                notification.BackgroundColor3 = ACCENT_COLOR
                notification.BorderSizePixel = 0
                notification.Text = "Background will change on next UI restart"
                notification.Font = Enum.Font.GothamBold
                notification.TextColor3 = TEXT_COLOR
                notification.TextSize = 14
                notification.ZIndex = 10
                notification.Parent = MainFrame
                
                local NotificationCorner = Instance.new("UICorner")
                NotificationCorner.CornerRadius = UDim.new(0, 6)
                NotificationCorner.Parent = notification
                
                game:GetService("Debris"):AddItem(notification, 3)
            end)
            
            local OptionButtonCorner = Instance.new("UICorner")
            OptionButtonCorner.CornerRadius = UDim.new(0, 4)
            OptionButtonCorner.Parent = OptionButton
        end
        
        return DropdownContainer
    end
    
    local backgroundTypeDropdownContainer = createBackgroundTypeDropdown()
    
    BackgroundTypeDropdown.MouseButton1Click:Connect(function()
        backgroundTypeDropdown = not backgroundTypeDropdown
        backgroundTypeDropdownContainer.Visible = backgroundTypeDropdown
    end)
    
    -- Add animation speed slider
    local AnimationSpeedFrame = Instance.new("Frame")
    AnimationSpeedFrame.Name = "AnimationSpeedFrame"
    AnimationSpeedFrame.Size = UDim2.new(0.9, 0, 0, 30)
    AnimationSpeedFrame.BackgroundColor3 = SECONDARY_COLOR
    AnimationSpeedFrame.BorderSizePixel = 0
    AnimationSpeedFrame.Parent = BackgroundSettingsSection

    local AnimationSpeedFrameCorner = Instance.new("UICorner")
    AnimationSpeedFrameCorner.CornerRadius = UDim.new(0, 6)
    AnimationSpeedFrameCorner.Parent = AnimationSpeedFrame

    local AnimationSpeedLabel = Instance.new("TextLabel")
    AnimationSpeedLabel.Name = "AnimationSpeedLabel"
    AnimationSpeedLabel.Size = UDim2.new(0.4, 0, 1, 0)
    AnimationSpeedLabel.BackgroundTransparency = 1
    AnimationSpeedLabel.Text = "Animation Speed:"
    AnimationSpeedLabel.Font = Enum.Font.Gotham
    AnimationSpeedLabel.TextColor3 = TEXT_COLOR
    AnimationSpeedLabel.TextSize = 14
    AnimationSpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
    AnimationSpeedLabel.Parent = AnimationSpeedFrame

    local AnimationSpeedSlider = Instance.new("Frame")
    AnimationSpeedSlider.Name = "AnimationSpeedSlider"
    AnimationSpeedSlider.Size = UDim2.new(0.55, 0, 0, 10)
    AnimationSpeedSlider.Position = UDim2.new(0.4, 0, 0.5, -5)
    AnimationSpeedSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    AnimationSpeedSlider.BorderSizePixel = 0
    AnimationSpeedSlider.Parent = AnimationSpeedFrame

    local AnimationSpeedSliderCorner = Instance.new("UICorner")
    AnimationSpeedSliderCorner.CornerRadius = UDim.new(1, 0)
    AnimationSpeedSliderCorner.Parent = AnimationSpeedSlider

    local AnimationSpeedValue = Instance.new("Frame")
    AnimationSpeedValue.Name = "AnimationSpeedValue"
    AnimationSpeedValue.Size = UDim2.new(ANIMATION_SPEED / 3, 0, 1, 0)
    AnimationSpeedValue.BackgroundColor3 = ACCENT_COLOR
    AnimationSpeedValue.BorderSizePixel = 0
    AnimationSpeedValue.Parent = AnimationSpeedSlider

    local AnimationSpeedValueCorner = Instance.new("UICorner")
    AnimationSpeedValueCorner.CornerRadius = UDim.new(1, 0)
    AnimationSpeedValueCorner.Parent = AnimationSpeedValue

    local AnimationSpeedText = Instance.new("TextLabel")
    AnimationSpeedText.Name = "AnimationSpeedText"
    AnimationSpeedText.Size = UDim2.new(0.05, 0, 1, 0)
    AnimationSpeedText.Position = UDim2.new(0.95, 0, 0, 0)
    AnimationSpeedText.BackgroundTransparency = 1
    AnimationSpeedText.Text = ANIMATION_SPEED
    AnimationSpeedText.Font = Enum.Font.Gotham
    AnimationSpeedText.TextColor3 = TEXT_COLOR
    AnimationSpeedText.TextSize = 14
    AnimationSpeedText.TextXAlignment = Enum.TextXAlignment.Center
    AnimationSpeedText.Parent = AnimationSpeedFrame

    -- Particle count slider
    local ParticleCountFrame = Instance.new("Frame")
    ParticleCountFrame.Name = "ParticleCountFrame"
    ParticleCountFrame.Size = UDim2.new(0.9, 0, 0, 30)
    ParticleCountFrame.BackgroundColor3 = SECONDARY_COLOR
    ParticleCountFrame.BorderSizePixel = 0
    ParticleCountFrame.Parent = BackgroundSettingsSection

    local ParticleCountFrameCorner = Instance.new("UICorner")
    ParticleCountFrameCorner.CornerRadius = UDim.new(0, 6)
    ParticleCountFrameCorner.Parent = ParticleCountFrame

    local ParticleCountLabel = Instance.new("TextLabel")
    ParticleCountLabel.Name = "ParticleCountLabel"
    ParticleCountLabel.Size = UDim2.new(0.4, 0, 1, 0)
    ParticleCountLabel.BackgroundTransparency = 1
    ParticleCountLabel.Text = "Particle Count:"
    ParticleCountLabel.Font = Enum.Font.Gotham
    ParticleCountLabel.TextColor3 = TEXT_COLOR
    ParticleCountLabel.TextSize = 14
    ParticleCountLabel.TextXAlignment = Enum.TextXAlignment.Left
    ParticleCountLabel.Parent = ParticleCountFrame

    local ParticleCountSlider = Instance.new("Frame")
    ParticleCountSlider.Name = "ParticleCountSlider"
    ParticleCountSlider.Size = UDim2.new(0.55, 0, 0, 10)
    ParticleCountSlider.Position = UDim2.new(0.4, 0, 0.5, -5)
    ParticleCountSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    ParticleCountSlider.BorderSizePixel = 0
    ParticleCountSlider.Parent = ParticleCountFrame

    local ParticleCountSliderCorner = Instance.new("UICorner")
    ParticleCountSliderCorner.CornerRadius = UDim.new(1, 0)
    ParticleCountSliderCorner.Parent = ParticleCountSlider

    local ParticleCountValue = Instance.new("Frame")
    ParticleCountValue.Name = "ParticleCountValue"
    ParticleCountValue.Size = UDim2.new(math.min(PARTICLE_COUNT / 100, 1), 0, 1, 0)
    ParticleCountValue.BackgroundColor3 = ACCENT_COLOR
    ParticleCountValue.BorderSizePixel = 0
    ParticleCountValue.Parent = ParticleCountSlider

    local ParticleCountValueCorner = Instance.new("UICorner")
    ParticleCountValueCorner.CornerRadius = UDim.new(1, 0)
    ParticleCountValueCorner.Parent = ParticleCountValue

    local ParticleCountText = Instance.new("TextLabel")
    ParticleCountText.Name = "ParticleCountText"
    ParticleCountText.Size = UDim2.new(0.05, 0, 1, 0)
    ParticleCountText.Position = UDim2.new(0.95, 0, 0, 0)
    ParticleCountText.BackgroundTransparency = 1
    ParticleCountText.Text = PARTICLE_COUNT
    ParticleCountText.Font = Enum.Font.Gotham
    ParticleCountText.TextColor3 = TEXT_COLOR
    ParticleCountText.TextSize = 14
    ParticleCountText.TextXAlignment = Enum.TextXAlignment.Center
    ParticleCountText.Parent = ParticleCountFrame

    -- Background color pickers
    local BackgroundColor1Frame = Instance.new("Frame")
    BackgroundColor1Frame.Name = "BackgroundColor1Frame"
    BackgroundColor1Frame.Size = UDim2.new(0.9, 0, 0, 30)
    BackgroundColor1Frame.BackgroundColor3 = SECONDARY_COLOR
    BackgroundColor1Frame.BorderSizePixel = 0
    BackgroundColor1Frame.Parent = BackgroundSettingsSection

    local BackgroundColor1FrameCorner = Instance.new("UICorner")
    BackgroundColor1FrameCorner.CornerRadius = UDim.new(0, 6)
    BackgroundColor1FrameCorner.Parent = BackgroundColor1Frame

    local BackgroundColor1Label = Instance.new("TextLabel")
    BackgroundColor1Label.Name = "BackgroundColor1Label"
    BackgroundColor1Label.Size = UDim2.new(0.6, 0, 1, 0)
    BackgroundColor1Label.BackgroundTransparency = 1
    BackgroundColor1Label.Text = "Primary Background Color:"
    BackgroundColor1Label.Font = Enum.Font.Gotham
    BackgroundColor1Label.TextColor3 = TEXT_COLOR
    BackgroundColor1Label.TextSize = 14
    BackgroundColor1Label.TextXAlignment = Enum.TextXAlignment.Left
    BackgroundColor1Label.Parent = BackgroundColor1Frame

    local BackgroundColor1Preview = Instance.new("Frame")
    BackgroundColor1Preview.Name = "BackgroundColor1Preview"
    BackgroundColor1Preview.Size = UDim2.new(0, 30, 0, 20)
    BackgroundColor1Preview.Position = UDim2.new(0.9, -30, 0.5, -10)
    BackgroundColor1Preview.BackgroundColor3 = BACKGROUND_COLOR1
    BackgroundColor1Preview.BorderSizePixel = 0
    BackgroundColor1Preview.Parent = BackgroundColor1Frame

    local BackgroundColor1PreviewCorner = Instance.new("UICorner")
    BackgroundColor1PreviewCorner.CornerRadius = UDim.new(0, 4)
    BackgroundColor1PreviewCorner.Parent = BackgroundColor1Preview

    local BackgroundColor2Frame = Instance.new("Frame")
    BackgroundColor2Frame.Name = "BackgroundColor2Frame"
    BackgroundColor2Frame.Size = UDim2.new(0.9, 0, 0, 30)
    BackgroundColor2Frame.BackgroundColor3 = SECONDARY_COLOR
    BackgroundColor2Frame.BorderSizePixel = 0
    BackgroundColor2Frame.Parent = BackgroundSettingsSection

    local BackgroundColor2FrameCorner = Instance.new("UICorner")
    BackgroundColor2FrameCorner.CornerRadius = UDim.new(0, 6)
    BackgroundColor2FrameCorner.Parent = BackgroundColor2Frame

    local BackgroundColor2Label = Instance.new("TextLabel")
    BackgroundColor2Label.Name = "BackgroundColor2Label"
    BackgroundColor2Label.Size = UDim2.new(0.6, 0, 1, 0)
    BackgroundColor2Label.BackgroundTransparency = 1
    BackgroundColor2Label.Text = "Secondary Background Color:"
    BackgroundColor2Label.Font = Enum.Font.Gotham
    BackgroundColor2Label.TextColor3 = TEXT_COLOR
    BackgroundColor2Label.TextSize = 14
    BackgroundColor2Label.TextXAlignment = Enum.TextXAlignment.Left
    BackgroundColor2Label.Parent = BackgroundColor2Frame

    local BackgroundColor2Preview = Instance.new("Frame")
    BackgroundColor2Preview.Name = "BackgroundColor2Preview"
    BackgroundColor2Preview.Size = UDim2.new(0, 30, 0, 20)
    BackgroundColor2Preview.Position = UDim2.new(0.9, -30, 0.5, -10)
    BackgroundColor2Preview.BackgroundColor3 = BACKGROUND_COLOR2
    BackgroundColor2Preview.BorderSizePixel = 0
    BackgroundColor2Preview.Parent = BackgroundColor2Frame

    local BackgroundColor2PreviewCorner = Instance.new("UICorner")
    BackgroundColor2PreviewCorner.CornerRadius = UDim.new(0, 4)
    BackgroundColor2PreviewCorner.Parent = BackgroundColor2Preview

    -- Image ID input (for image background)
    local BackgroundImageFrame = Instance.new("Frame")
    BackgroundImageFrame.Name = "BackgroundImageFrame"
    BackgroundImageFrame.Size = UDim2.new(0.9, 0, 0, 30)
    BackgroundImageFrame.BackgroundColor3 = SECONDARY_COLOR
    BackgroundImageFrame.BorderSizePixel = 0
    BackgroundImageFrame.Parent = BackgroundSettingsSection

    local BackgroundImageFrameCorner = Instance.new("UICorner")
    BackgroundImageFrameCorner.CornerRadius = UDim.new(0, 6)
    BackgroundImageFrameCorner.Parent = BackgroundImageFrame

    local BackgroundImageLabel = Instance.new("TextLabel")
    BackgroundImageLabel.Name = "BackgroundImageLabel"
    BackgroundImageLabel.Size = UDim2.new(0.4, 0, 1, 0)
    BackgroundImageLabel.BackgroundTransparency = 1
    BackgroundImageLabel.Text = "Background Image ID:"
    BackgroundImageLabel.Font = Enum.Font.Gotham
    BackgroundImageLabel.TextColor3 = TEXT_COLOR
    BackgroundImageLabel.TextSize = 14
    BackgroundImageLabel.TextXAlignment = Enum.TextXAlignment.Left
    BackgroundImageLabel.Parent = BackgroundImageFrame

    local BackgroundImageInput = Instance.new("TextBox")
    BackgroundImageInput.Name = "BackgroundImageInput"
    BackgroundImageInput.Size = UDim2.new(0.6, -10, 1, -6)
    BackgroundImageInput.Position = UDim2.new(0.4, 5, 0, 3)
    BackgroundImageInput.BackgroundColor3 = TERTIARY_COLOR
    BackgroundImageInput.BorderSizePixel = 0
    BackgroundImageInput.Text = BACKGROUND_IMAGE_ID
    BackgroundImageInput.Font = Enum.Font.Gotham
    BackgroundImageInput.TextColor3 = TEXT_COLOR
    BackgroundImageInput.TextSize = 14
    BackgroundImageInput.ClearTextOnFocus = false
    BackgroundImageInput.Parent = BackgroundImageFrame

    local BackgroundImageInputCorner = Instance.new("UICorner")
    BackgroundImageInputCorner.CornerRadius = UDim.new(0, 4)
    BackgroundImageInputCorner.Parent = BackgroundImageInput

    -- API functions
    local hub = {}

    hub.createTab = function(name)
        if ContentFrame:FindFirstChild(name .. "TabContent") then
            return
        end

        local order = 0
        for _, child in pairs(TabBar:GetChildren()) do
            if child:IsA("TextButton") then
                order = order + 1
            end
        end

        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = name .. "TabContent"
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.ScrollBarThickness = 4
        TabContent.ScrollBarImageColor3 = ACCENT_COLOR
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
        TabContent.Parent = ContentFrame
        TabContent.Visible = false

        local TabContentLayout = Instance.new("UIListLayout")
        TabContentLayout.Name = "TabContentLayout"
        TabContentLayout.Padding = UDim.new(0, 10)
        TabContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        TabContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        TabContentLayout.Parent = TabContent

        local TabContentPadding = Instance.new("UIPadding")
        TabContentPadding.PaddingTop = UDim.new(0, 15)
        TabContentPadding.PaddingBottom = UDim.new(0, 15)
        TabContentPadding.Parent = TabContent

        createTab(name, order + 1)

        return {
            instance = TabContent,
            createToggle = function(toggleName, callback)
                return createToggle(toggleName, callback, TabContent)
            end
        }
    end

    hub.createToggle = function(name, callback)
        return createToggle(name, callback)
    end

    hub.getConfigData = function()
        local data = {}
        for _, toggle in ipairs(toggleButtons) do
            data[toggle.name] = toggle.toggled
        end
        return data
    end

    hub.loadConfigData = function(data)
        for name, state in pairs(data) do
            for _, toggle in ipairs(toggleButtons) do
                if toggle.name == name then
                    if toggle.toggled ~= state then
                        -- Simulate a click
                        local targetPosition = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                        local targetColor = state and TOGGLE_ON_COLOR or TOGGLE_OFF_COLOR
                        
                        TweenService:Create(toggle.indicator, TweenInfo.new(0.2), {Position = targetPosition}):Play()
                        TweenService:Create(toggle.button, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
                        
                        toggle.toggled = state
                    end
                    break
                end
            end
        end
    end

    hub.saveConfig = function(name)
        local data = hub.getConfigData()
        local json = HttpService:JSONEncode(data)
        
        local success, err = pcall(function()
            writefile(SAVE_FOLDER .. "/" .. name .. CONFIG_EXTENSION, json)
        end)
        
        return success, err
    end

    hub.loadConfig = function(name)
        local success, content = pcall(function()
            return readfile(SAVE_FOLDER .. "/" .. name .. CONFIG_EXTENSION)
        end)
        
        if success then
            local data = HttpService:JSONDecode(content)
            hub.loadConfigData(data)
            return true
        end
        
        return false
    end

    hub.listConfigs = function()
        local configs = {}
        
        local success, files = pcall(function()
            return listfiles(SAVE_FOLDER)
        end)
        
        if success then
            for _, file in ipairs(files) do
                if file:sub(-#CONFIG_EXTENSION) == CONFIG_EXTENSION then
                    local name = file:match("[^/\\]+$"):sub(1, -(#CONFIG_EXTENSION + 1))
                    table.insert(configs, name)
                end
            end
        end
        
        return configs
    end

    -- Initialize configs folder
    pcall(function()
        if not isfolder(SAVE_FOLDER) then
            makefolder(SAVE_FOLDER)
        end
    end)

    -- Setup Config system
    local function refreshConfigList()
        for _, child in pairs(ConfigItems:GetChildren()) do
            if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
                child:Destroy()
            end
        end

        local configs = hub.listConfigs()
        
        for _, name in ipairs(configs) do
            local ConfigItem = Instance.new("Frame")
            ConfigItem.Name = name .. "Item"
            ConfigItem.Size = UDim2.new(0.95, 0, 0, 30)
            ConfigItem.BackgroundColor3 = TERTIARY_COLOR
            ConfigItem.BorderSizePixel = 0
            ConfigItem.Parent = ConfigItems

            local ConfigItemCorner = Instance.new("UICorner")
            ConfigItemCorner.CornerRadius = UDim.new(0, 6)
            ConfigItemCorner.Parent = ConfigItem

            local ConfigItemName = Instance.new("TextLabel")
            ConfigItemName.Name = "ConfigItemName"
            ConfigItemName.Size = UDim2.new(0.6, 0, 1, 0)
            ConfigItemName.BackgroundTransparency = 1
            ConfigItemName.Text = "  " .. name
            ConfigItemName.Font = Enum.Font.Gotham
            ConfigItemName.TextColor3 = TEXT_COLOR
            ConfigItemName.TextSize = 14
            ConfigItemName.TextXAlignment = Enum.TextXAlignment.Left
            ConfigItemName.Parent = ConfigItem

            local LoadButton = Instance.new("TextButton")
            LoadButton.Name = "LoadButton"
            LoadButton.Size = UDim2.new(0.2, -5, 1, -6)
            LoadButton.Position = UDim2.new(0.6, 0, 0, 3)
            LoadButton.BackgroundColor3 = ACCENT_COLOR
            LoadButton.BorderSizePixel = 0
            LoadButton.Text = "Load"
            LoadButton.Font = Enum.Font.Gotham
            LoadButton.TextColor3 = TEXT_COLOR
            LoadButton.TextSize = 14
            LoadButton.Parent = ConfigItem

            local LoadButtonCorner = Instance.new("UICorner")
            LoadButtonCorner.CornerRadius = UDim.new(0, 4)
            LoadButtonCorner.Parent = LoadButton

            local DeleteButton = Instance.new("TextButton")
            DeleteButton.Name = "DeleteButton"
            DeleteButton.Size = UDim2.new(0.2, -5, 1, -6)
            DeleteButton.Position = UDim2.new(0.8, 0, 0, 3)
            DeleteButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
            DeleteButton.BorderSizePixel = 0
            DeleteButton.Text = "Delete"
            DeleteButton.Font = Enum.Font.Gotham
            DeleteButton.TextColor3 = TEXT_COLOR
            DeleteButton.TextSize = 14
            DeleteButton.Parent = ConfigItem

            local DeleteButtonCorner = Instance.new("UICorner")
            DeleteButtonCorner.CornerRadius = UDim.new(0, 4)
            DeleteButtonCorner.Parent = DeleteButton

            LoadButton.MouseButton1Click:Connect(function()
                hub.loadConfig(name)
            end)

            DeleteButton.MouseButton1Click:Connect(function()
                pcall(function()
                    delfile(SAVE_FOLDER .. "/" .. name .. CONFIG_EXTENSION)
                end)
                refreshConfigList()
            end)
        end
    end

    SaveConfigButton.MouseButton1Click:Connect(function()
        local name = ConfigInput.Text
        if name:match("^%s*$") then return end
        
        hub.saveConfig(name)
        ConfigInput.Text = ""
        refreshConfigList()
    end)

    refreshConfigList()

    return hub
end

return SyferEngHubLibrary
