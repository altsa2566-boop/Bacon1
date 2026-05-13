-- ============================================
-- MOBILE SUPPORT ADDON FOR UI LIBRARY
-- ============================================

-- Add this to your Library after the basic setup

-- ============================================
-- MOBILE DETECTION
-- ============================================
local UserInputService = game:GetService('UserInputService')
local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

Library.IsMobile = isMobile

print("📱 Mobile Mode: " .. tostring(isMobile))

-- ============================================
-- MOBILE BUTTON STYLE
-- ============================================
function Library:CreateMobileButton(Properties)
    local Button = self:Create('TextButton', {
        BackgroundColor3 = Properties.BackgroundColor3 or Color3.fromRGB(0, 85, 255),
        TextColor3 = Properties.TextColor3 or Color3.fromRGB(255, 255, 255),
        TextSize = isMobile and 14 or 13,
        Font = Enum.Font.GothamBold,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Parent = Properties.Parent,
        Size = Properties.Size or UDim2.new(1, 0, 0, isMobile and 45 or 30),
    })
    
    local Corner = self:Create('UICorner', {
        CornerRadius = UDim.new(0, isMobile and 12 or 8),
        Parent = Button,
    })
    
    return Button
end

-- ============================================
-- MOBILE TOGGLE STYLE
-- ============================================
function Library:CreateMobileToggle(Properties)
    local Container = self:Create('Frame', {
        Size = UDim2.new(1, 0, 0, isMobile and 50 or 30),
        BackgroundTransparency = 1,
        Parent = Properties.Parent,
    })
    
    local Toggle = self:Create('Frame', {
        Size = UDim2.new(0, isMobile and 50 or 30, 0, isMobile and 30 or 20),
        BackgroundColor3 = Properties.Value and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(50, 50, 60),
        BorderSizePixel = 0,
        Parent = Container,
    })
    
    local ToggleCorner = self:Create('UICorner', {
        CornerRadius = UDim.new(0, isMobile and 15 or 10),
        Parent = Toggle,
    })
    
    local Label = self:Create('TextLabel', {
        Size = UDim2.new(1, -isMobile and 60 or 40, 1, 0),
        Position = UDim2.new(0, isMobile and 60 or 40, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = isMobile and 14 or 12,
        Font = Enum.Font.Gotham,
        Text = Properties.Text or "Toggle",
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Container,
    })
    
    local state = Properties.Value or false
    
    local function updateToggle()
        Toggle.BackgroundColor3 = state and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(50, 50, 60)
    end
    
    local function toggleState()
        state = not state
        updateToggle()
        if Properties.Callback then
            Properties.Callback(state)
        end
    end
    
    Toggle.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            toggleState()
        end
    end)
    
    updateToggle()
    
    return Container, Toggle, state
end

-- ============================================
-- MOBILE SLIDER STYLE
-- ============================================
function Library:CreateMobileSlider(Properties)
    local Container = self:Create('Frame', {
        Size = UDim2.new(1, 0, 0, isMobile and 70 or 50),
        BackgroundTransparency = 1,
        Parent = Properties.Parent,
    })
    
    local Label = self:Create('TextLabel', {
        Size = UDim2.new(1, 0, 0, isMobile and 25 or 15),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = isMobile and 13 or 11,
        Font = Enum.Font.Gotham,
        Text = (Properties.Text or "Slider") .. ": " .. Properties.Default,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Container,
    })
    
    local SliderBg = self:Create('Frame', {
        Size = UDim2.new(1, 0, 0, isMobile and 30 or 15),
        Position = UDim2.new(0, 0, 0, isMobile and 35 or 20),
        BackgroundColor3 = Color3.fromRGB(50, 50, 60),
        BorderSizePixel = 0,
        Parent = Container,
    })
    
    local SliderCorner = self:Create('UICorner', {
        CornerRadius = UDim.new(0, isMobile and 15 or 8),
        Parent = SliderBg,
    })
    
    local SliderFill = self:Create('Frame', {
        Size = UDim2.new((Properties.Default - Properties.Min) / (Properties.Max - Properties.Min), 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 85, 255),
        BorderSizePixel = 0,
        Parent = SliderBg,
    })
    
    local FillCorner = self:Create('UICorner', {
        CornerRadius = UDim.new(0, isMobile and 15 or 8),
        Parent = SliderFill,
    })
    
    local currentValue = Properties.Default
    
    local function updateSlider(input)
        local mousePos = input.Position.X
        local sliderPos = SliderBg.AbsolutePosition.X
        local sliderSize = SliderBg.AbsoluteSize.X
        
        local percent = math.max(0, math.min(1, (mousePos - sliderPos) / sliderSize))
        currentValue = math.floor(Properties.Min + (Properties.Max - Properties.Min) * percent)
        
        SliderFill.Size = UDim2.new(percent, 0, 1, 0)
        Label.Text = (Properties.Text or "Slider") .. ": " .. currentValue
        
        if Properties.Callback then
            Properties.Callback(currentValue)
        end
    end
    
    SliderBg.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            updateSlider(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local mousePos = input.Position
            local sliderPos = SliderBg.AbsolutePosition
            local sliderSize = SliderBg.AbsoluteSize
            
            if mousePos.X >= sliderPos.X and mousePos.X <= sliderPos.X + sliderSize.X and
               mousePos.Y >= sliderPos.Y and mousePos.Y <= sliderPos.Y + sliderSize.Y then
                if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or 
                   (isMobile and input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input)
                end
            end
        end
    end)
    
    return Container, currentValue
end

-- ============================================
-- MOBILE FLOATING BUTTON
-- ============================================
function Library:CreateFloatingButton(Config)
    local FloatingButton = self:Create('TextButton', {
        Size = UDim2.new(0, isMobile and 60 or 50, 0, isMobile and 60 or 50),
        Position = UDim2.new(1, isMobile and -80 or -70, 1, isMobile and -80 or -70),
        BackgroundColor3 = Config.Color or Color3.fromRGB(0, 85, 255),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = isMobile and 28 or 24,
        Font = Enum.Font.GothamBold,
        Text = Config.Text or '☰',
        BorderSizePixel = 0,
        ZIndex = 500,
        Parent = self.ScreenGui,
    })
    
    local Corner = self:Create('UICorner', {
        CornerRadius = UDim.new(0, isMobile and 30 or 25),
        Parent = FloatingButton,
    })
    
    -- Draggable
    local dragging = false
    local dragStart = nil
    
    FloatingButton.InputBegan:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input, gameProcessed)
        if dragging and dragStart then
            local delta = input.Position - dragStart
            local newPos = FloatingButton.Position + UDim2.new(0, delta.X, 0, delta.Y)
            FloatingButton.Position = newPos
        end
    end)
    
    return FloatingButton
end

-- ============================================
-- MOBILE MENU PANEL
-- ============================================
function Library:CreateMobileMenuPanel(Config)
    local MenuPanel = self:Create('Frame', {
        Size = UDim2.new(0, isMobile and 320 or 280, 0, isMobile and 500 or 400),
        Position = UDim2.new(1, isMobile and -340 or -300, 1, isMobile and -520 or -420),
        BackgroundColor3 = self.MainColor,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 400,
        Parent = self.ScreenGui,
    })
    
    local PanelCorner = self:Create('UICorner', {
        CornerRadius = UDim.new(0, isMobile and 20 or 15),
        Parent = MenuPanel,
    })
    
    -- Header
    local Header = self:Create('Frame', {
        Size = UDim2.new(1, 0, 0, isMobile and 50 or 40),
        BackgroundColor3 = self.BackgroundColor,
        BorderSizePixel = 0,
        Parent = MenuPanel,
    })
    
    local HeaderCorner = self:Create('UICorner', {
        CornerRadius = UDim.new(0, isMobile and 20 or 15),
        Parent = Header,
    })
    
    local HeaderLabel = self:Create('TextLabel', {
        Size = UDim2.new(1, isMobile and -60 or -50, 1, 0),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = isMobile and 16 or 14,
        Font = Enum.Font.GothamBold,
        Text = Config.Title or "Menu",
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.new(0, isMobile and 15 or 10, 0, 0),
        Parent = Header,
    })
    
    local CloseBtn = self:CreateMobileButton({
        Size = UDim2.new(0, isMobile and 50 or 40, 0, isMobile and 40 or 30),
        BackgroundColor3 = Color3.fromRGB(255, 50, 50),
        Parent = Header,
    })
    CloseBtn.Position = UDim2.new(1, isMobile and -60 or -50, 0.5, isMobile and -20 or -15)
    CloseBtn.Text = "✕"
    
    -- Scroll
    local ScrollFrame = self:Create('ScrollingFrame', {
        Size = UDim2.new(1, 0, 1, isMobile and -50 or -40),
        Position = UDim2.new(0, 0, 0, isMobile and 50 or 40),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = isMobile and 6 or 4,
        Parent = MenuPanel,
    })
    
    local Layout = self:Create('UIListLayout', {
        Padding = UDim.new(0, isMobile and 12 or 8),
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = ScrollFrame,
    })
    
    local Padding = self:Create('UIPadding', {
        PaddingLeft = UDim.new(0, isMobile and 15 or 10),
        PaddingRight = UDim.new(0, isMobile and 15 or 10),
        PaddingTop = UDim.new(0, isMobile and 12 or 8),
        PaddingBottom = UDim.new(0, isMobile and 12 or 8),
        Parent = ScrollFrame,
    })
    
    CloseBtn.MouseButton1Click:Connect(function()
        MenuPanel.Visible = false
    end)
    
    CloseBtn.TouchTap:Connect(function()
        MenuPanel.Visible = false
    end)
    
    return MenuPanel, ScrollFrame
end

-- ============================================
-- ADJUST WINDOW SIZE FOR MOBILE
-- ============================================
local originalCreateWindow = Library.CreateWindow

function Library:CreateWindow(Config)
    if isMobile then
        Config.Size = UDim2.fromOffset(math.min(350, 0.9 * 1920), math.min(600, 0.9 * 1080))
        Config.Position = UDim2.fromScale(0.5, 0.5)
        Config.Center = true
    end
    
    return originalCreateWindow(self, Config)
end

print("✅ Mobile Support Added to UI Library!")
