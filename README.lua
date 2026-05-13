-- ============================================
-- ORGANIZED UI LIBRARY - PROFISSIONAL
-- ============================================

local InputService = game:GetService('UserInputService')
local TextService = game:GetService('TextService')
local CoreGui = game:GetService('CoreGui')
local Teams = game:GetService('Teams')
local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local TweenService = game:GetService('TweenService')

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ============================================
-- PROTECTIONS
-- ============================================
local ProtectGui = protectgui or (syn and syn.protect_gui) or (function() end)

-- ============================================
-- SCREEN GUI
-- ============================================
local ScreenGui = Instance.new('ScreenGui')
ProtectGui(ScreenGui)
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.Parent = CoreGui

-- ============================================
-- GLOBAL TABLES
-- ============================================
getgenv().Toggles = {}
getgenv().Options = {}

-- ============================================
-- LIBRARY CORE
-- ============================================
local Library = {
    Registry = {},
    RegistryMap = {},
    HudRegistry = {},
    
    FontColor = Color3.fromRGB(255, 255, 255),
    MainColor = Color3.fromRGB(28, 28, 28),
    BackgroundColor = Color3.fromRGB(20, 20, 20),
    AccentColor = Color3.fromRGB(0, 85, 255),
    OutlineColor = Color3.fromRGB(50, 50, 50),
    RiskColor = Color3.fromRGB(255, 50, 50),
    
    Black = Color3.new(0, 0, 0),
    Font = Enum.Font.Code,
    
    OpenedFrames = {},
    DependencyBoxes = {},
    Signals = {},
    ScreenGui = ScreenGui,
}

-- ============================================
-- RAINBOW EFFECT
-- ============================================
local RainbowStep = 0
local Hue = 0

table.insert(Library.Signals, RunService.RenderStepped:Connect(function(Delta)
    RainbowStep = RainbowStep + Delta
    
    if RainbowStep >= (1 / 60) then
        RainbowStep = 0
        Hue = Hue + (1 / 400)
        
        if Hue > 1 then
            Hue = 0
        end
        
        Library.CurrentRainbowHue = Hue
        Library.CurrentRainbowColor = Color3.fromHSV(Hue, 0.8, 1)
    end
end))

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================
function Library:Create(Class, Properties)
    local _Instance = Class
    
    if type(Class) == 'string' then
        _Instance = Instance.new(Class)
    end
    
    for Property, Value in next, Properties do
        _Instance[Property] = Value
    end
    
    return _Instance
end

function Library:SafeCallback(f, ...)
    if not f then
        return
    end
    
    if not Library.NotifyOnError then
        return f(...)
    end
    
    local success, event = pcall(f, ...)
    
    if not success then
        local _, i = event:find(":%d+: ")
        if not i then
            return Library:Notify(event)
        end
        return Library:Notify(event:sub(i + 1), 3)
    end
end

function Library:GetTextBounds(Text, Font, Size, Resolution)
    local Bounds = TextService:GetTextSize(Text, Size, Font, Resolution or Vector2.new(1920, 1080))
    return Bounds.X, Bounds.Y
end

function Library:GetDarkerColor(Color)
    local H, S, V = Color3.toHSV(Color)
    return Color3.fromHSV(H, S, V / 1.5)
end

Library.AccentColorDark = Library:GetDarkerColor(Library.AccentColor)

function Library:ApplyTextStroke(Inst)
    Inst.TextStrokeTransparency = 1
    
    Library:Create('UIStroke', {
        Color = Color3.new(0, 0, 0),
        Thickness = 1,
        LineJoinMode = Enum.LineJoinMode.Miter,
        Parent = Inst,
    })
end

function Library:CreateLabel(Properties, IsHud)
    local _Instance = Library:Create('TextLabel', {
        BackgroundTransparency = 1,
        Font = Library.Font,
        TextColor3 = Library.FontColor,
        TextSize = 16,
        TextStrokeTransparency = 0,
    })
    
    Library:ApplyTextStroke(_Instance)
    Library:AddToRegistry(_Instance, {
        TextColor3 = 'FontColor',
    }, IsHud)
    
    return Library:Create(_Instance, Properties)
end

function Library:AddToRegistry(Instance, Properties, IsHud)
    local Idx = #Library.Registry + 1
    local Data = {
        Instance = Instance,
        Properties = Properties,
        Idx = Idx,
    }
    
    table.insert(Library.Registry, Data)
    Library.RegistryMap[Instance] = Data
    
    if IsHud then
        table.insert(Library.HudRegistry, Data)
    end
end

function Library:RemoveFromRegistry(Instance)
    local Data = Library.RegistryMap[Instance]
    
    if Data then
        for Idx = #Library.Registry, 1, -1 do
            if Library.Registry[Idx] == Data then
                table.remove(Library.Registry, Idx)
            end
        end
        
        for Idx = #Library.HudRegistry, 1, -1 do
            if Library.HudRegistry[Idx] == Data then
                table.remove(Library.HudRegistry, Idx)
            end
        end
        
        Library.RegistryMap[Instance] = nil
    end
end

function Library:UpdateColorsUsingRegistry()
    for Idx, Object in next, Library.Registry do
        for Property, ColorIdx in next, Object.Properties do
            if type(ColorIdx) == 'string' then
                Object.Instance[Property] = Library[ColorIdx]
            elseif type(ColorIdx) == 'function' then
                Object.Instance[Property] = ColorIdx()
            end
        end
    end
end

function Library:MakeDraggable(Instance, Cutoff)
    Instance.Active = true
    
    Instance.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            local ObjPos = Vector2.new(
                Mouse.X - Instance.AbsolutePosition.X,
                Mouse.Y - Instance.AbsolutePosition.Y
            )
            
            if ObjPos.Y > (Cutoff or 40) then
                return
            end
            
            while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                Instance.Position = UDim2.new(
                    0,
                    Mouse.X - ObjPos.X + (Instance.Size.X.Offset * Instance.AnchorPoint.X),
                    0,
                    Mouse.Y - ObjPos.Y + (Instance.Size.Y.Offset * Instance.AnchorPoint.Y)
                )
                
                RunService.RenderStepped:Wait()
            end
        end
    end)
end

function Library:IsMouseOverFrame(Frame)
    local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize
    
    if Mouse.X >= AbsPos.X and Mouse.X <= AbsPos.X + AbsSize.X
        and Mouse.Y >= AbsPos.Y and Mouse.Y <= AbsPos.Y + AbsSize.Y then
        
        return true
    end
end

function Library:MouseIsOverOpenedFrame()
    for Frame, _ in next, Library.OpenedFrames do
        if Library:IsMouseOverFrame(Frame) then
            return true
        end
    end
end

function Library:MapValue(Value, MinA, MaxA, MinB, MaxB)
    return (1 - ((Value - MinA) / (MaxA - MinA))) * MinB + ((Value - MinA) / (MaxA - MinA)) * MaxB
end

function Library:GiveSignal(Signal)
    table.insert(Library.Signals, Signal)
end

function Library:Unload()
    for Idx = #Library.Signals, 1, -1 do
        local Connection = table.remove(Library.Signals, Idx)
        Connection:Disconnect()
    end
    
    if Library.OnUnload then
        Library.OnUnload()
    end
    
    ScreenGui:Destroy()
end

function Library:OnUnload(Callback)
    Library.OnUnload = Callback
end

-- ============================================
-- NOTIFICATION SYSTEM
-- ============================================
Library.NotificationArea = Library:Create('Frame', {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 0, 40),
    Size = UDim2.new(0, 300, 0, 200),
    ZIndex = 100,
    Parent = ScreenGui,
})

Library:Create('UIListLayout', {
    Padding = UDim.new(0, 4),
    FillDirection = Enum.FillDirection.Vertical,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = Library.NotificationArea,
})

function Library:Notify(Text, Time)
    local XSize, YSize = Library:GetTextBounds(Text, Library.Font, 14)
    YSize = YSize + 7
    
    local NotifyOuter = Library:Create('Frame', {
        BorderColor3 = Color3.new(0, 0, 0),
        Position = UDim2.new(0, 100, 0, 10),
        Size = UDim2.new(0, 0, 0, YSize),
        ClipsDescendants = true,
        ZIndex = 100,
        Parent = Library.NotificationArea,
    })
    
    local NotifyInner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor,
        BorderColor3 = Library.OutlineColor,
        BorderMode = Enum.BorderMode.Inset,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 101,
        Parent = NotifyOuter,
    })
    
    Library:AddToRegistry(NotifyInner, {
        BackgroundColor3 = 'MainColor',
        BorderColor3 = 'OutlineColor',
    }, true)
    
    local NotifyLabel = Library:CreateLabel({
        Position = UDim2.new(0, 4, 0, 0),
        Size = UDim2.new(1, -4, 1, 0),
        Text = Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 14,
        ZIndex = 103,
        Parent = NotifyInner,
    })
    
    pcall(NotifyOuter.TweenSize, NotifyOuter, UDim2.new(0, XSize + 8 + 4, 0, YSize), 'Out', 'Quad', 0.4, true)
    
    task.spawn(function()
        wait(Time or 5)
        pcall(NotifyOuter.TweenSize, NotifyOuter, UDim2.new(0, 0, 0, YSize), 'Out', 'Quad', 0.4, true)
        wait(0.4)
        NotifyOuter:Destroy()
    end)
end

-- ============================================
-- WATERMARK
-- ============================================
local WatermarkOuter = Library:Create('Frame', {
    BorderColor3 = Color3.new(0, 0, 0),
    Position = UDim2.new(0, 100, 0, -25),
    Size = UDim2.new(0, 213, 0, 20),
    ZIndex = 200,
    Visible = false,
    Parent = ScreenGui,
})

local WatermarkInner = Library:Create('Frame', {
    BackgroundColor3 = Library.MainColor,
    BorderColor3 = Library.AccentColor,
    BorderMode = Enum.BorderMode.Inset,
    Size = UDim2.new(1, 0, 1, 0),
    ZIndex = 201,
    Parent = WatermarkOuter,
})

Library:AddToRegistry(WatermarkInner, {
    BorderColor3 = 'AccentColor',
})

local WatermarkLabel = Library:CreateLabel({
    Position = UDim2.new(0, 5, 0, 0),
    Size = UDim2.new(1, -4, 1, 0),
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 203,
    Parent = WatermarkInner,
})

Library.Watermark = WatermarkOuter
Library.WatermarkText = WatermarkLabel
Library:MakeDraggable(Library.Watermark)

function Library:SetWatermark(Text)
    local X, Y = Library:GetTextBounds(Text, Library.Font, 14)
    Library.Watermark.Size = UDim2.new(0, X + 15, 0, (Y * 1.5) + 3)
    Library.Watermark.Visible = true
    Library.WatermarkText.Text = Text
end

-- ============================================
-- WINDOW CREATION
-- ============================================
function Library:CreateWindow(Config)
    if type(Config.Title) ~= 'string' then Config.Title = 'No title' end
    if type(Config.TabPadding) ~= 'number' then Config.TabPadding = 0 end
    if type(Config.MenuFadeTime) ~= 'number' then Config.MenuFadeTime = 0.2 end
    
    if typeof(Config.Position) ~= 'UDim2' then Config.Position = UDim2.fromOffset(175, 50) end
    if typeof(Config.Size) ~= 'UDim2' then Config.Size = UDim2.fromOffset(550, 600) end
    
    if Config.Center then
        Config.AnchorPoint = Vector2.new(0.5, 0.5)
        Config.Position = UDim2.fromScale(0.5, 0.5)
    end
    
    local Window = {
        Tabs = {},
    }
    
    local Outer = Library:Create('Frame', {
        AnchorPoint = Config.AnchorPoint or Vector2.zero,
        BackgroundColor3 = Color3.new(0, 0, 0),
        BorderSizePixel = 0,
        Position = Config.Position,
        Size = Config.Size,
        Visible = false,
        ZIndex = 1,
        Parent = ScreenGui,
    })
    
    Library:MakeDraggable(Outer, 25)
    
    local Inner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor,
        BorderColor3 = Library.AccentColor,
        BorderMode = Enum.BorderMode.Inset,
        Position = UDim2.new(0, 1, 0, 1),
        Size = UDim2.new(1, -2, 1, -2),
        ZIndex = 1,
        Parent = Outer,
    })
    
    Library:AddToRegistry(Inner, {
        BackgroundColor3 = 'MainColor',
        BorderColor3 = 'AccentColor',
    })
    
    local WindowLabel = Library:CreateLabel({
        Position = UDim2.new(0, 7, 0, 0),
        Size = UDim2.new(0, 0, 0, 25),
        Text = Config.Title or '',
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 1,
        Parent = Inner,
    })
    
    local MainSectionOuter = Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor,
        BorderColor3 = Library.OutlineColor,
        Position = UDim2.new(0, 8, 0, 25),
        Size = UDim2.new(1, -16, 1, -33),
        ZIndex = 1,
        Parent = Inner,
    })
    
    Library:AddToRegistry(MainSectionOuter, {
        BackgroundColor3 = 'BackgroundColor',
        BorderColor3 = 'OutlineColor',
    })
    
    local MainSectionInner = Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor,
        BorderColor3 = Color3.new(0, 0, 0),
        BorderMode = Enum.BorderMode.Inset,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 1,
        Parent = MainSectionOuter,
    })
    
    Library:AddToRegistry(MainSectionInner, {
        BackgroundColor3 = 'BackgroundColor',
    })
    
    local TabArea = Library:Create('Frame', {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 8),
        Size = UDim2.new(1, -16, 0, 21),
        ZIndex = 1,
        Parent = MainSectionInner,
    })
    
    local TabListLayout = Library:Create('UIListLayout', {
        Padding = UDim.new(0, Config.TabPadding),
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = TabArea,
    })
    
    local TabContainer = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor,
        BorderColor3 = Library.OutlineColor,
        Position = UDim2.new(0, 8, 0, 30),
        Size = UDim2.new(1, -16, 1, -38),
        ZIndex = 2,
        Parent = MainSectionInner,
    })
    
    Library:AddToRegistry(TabContainer, {
        BackgroundColor3 = 'MainColor',
        BorderColor3 = 'OutlineColor',
    })
    
    function Window:AddTab(Name)
        local Tab = {
            Groupboxes = {},
            Tabboxes = {},
        }
        
        local TabButtonWidth = Library:GetTextBounds(Name, Library.Font, 16)
        
        local TabButton = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor,
            BorderColor3 = Library.OutlineColor,
            Size = UDim2.new(0, TabButtonWidth + 8 + 4, 1, 0),
            ZIndex = 1,
            Parent = TabArea,
        })
        
        Library:AddToRegistry(TabButton, {
            BackgroundColor3 = 'BackgroundColor',
            BorderColor3 = 'OutlineColor',
        })
        
        local TabButtonLabel = Library:CreateLabel({
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, -1),
            Text = Name,
            ZIndex = 1,
            Parent = TabButton,
        })
        
        local Blocker = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 1, 0),
            Size = UDim2.new(1, 0, 0, 1),
            BackgroundTransparency = 1,
            ZIndex = 3,
            Parent = TabButton,
        })
        
        Library:AddToRegistry(Blocker, {
            BackgroundColor3 = 'MainColor',
        })
        
        local TabFrame = Library:Create('Frame', {
            Name = 'TabFrame',
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false,
            ZIndex = 2,
            Parent = TabContainer,
        })
        
        function Tab:ShowTab()
            for _, OtherTab in next, Window.Tabs do
                OtherTab:HideTab()
            end
            
            Blocker.BackgroundTransparency = 0
            TabButton.BackgroundColor3 = Library.MainColor
            Library.RegistryMap[TabButton].Properties.BackgroundColor3 = 'MainColor'
            TabFrame.Visible = true
        end
        
        function Tab:HideTab()
            Blocker.BackgroundTransparency = 1
            TabButton.BackgroundColor3 = Library.BackgroundColor
            Library.RegistryMap[TabButton].Properties.BackgroundColor3 = 'BackgroundColor'
            TabFrame.Visible = false
        end
        
        TabButton.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                Tab:ShowTab()
            end
        end)
        
        if #TabContainer:GetChildren() == 1 then
            Tab:ShowTab()
        end
        
        Window.Tabs[Name] = Tab
        return Tab
    end
    
    Window.Holder = Outer
    return Window
end

-- ============================================
-- EXPORT
-- ============================================
getgenv().Library = Library
return Library
