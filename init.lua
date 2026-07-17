-- Neverlose-Inspired Premium Glassmorphism UI Library
-- Optimized for clean dynamic scaling, theme customizability, and safe execution

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local NeverloseLib = {}
NeverloseLib.__index = NeverloseLib

-- Global Theme State
NeverloseLib.AccentColor = Color3.fromRGB(0, 150, 255)
NeverloseLib.ActiveObjects = {} -- Tracks active accents for real-time coloring

local function Tween(obj, info, target)
    local t = TweenService:Create(obj, info, target)
    t:Play()
    return t
end

-- Safely register objects that change color when the theme changes
local function RegisterAccent(obj, prop)
    table.insert(NeverloseLib.ActiveObjects, {Object = obj, Property = prop})
    obj[prop] = NeverloseLib.AccentColor
end

local function UpdateThemeColor(newColor)
    NeverloseLib.AccentColor = newColor
    for _, item in ipairs(NeverloseLib.ActiveObjects) do
        if item.Object and item.Object.Parent then
            item.Object[item.Property] = newColor
        end
    end
end

function NeverloseLib.CreateWindow(title, subtitle)
    local self = setmetatable({}, NeverloseLib)
    
    -- Clean previous visual overlays
    local oldUI = CoreGui:FindFirstChild("Neverlose_Premium_Dashboard")
    if oldUI then oldUI:Destroy() end
    
    -- Setup Blur Effect
    local blur = Lighting:FindFirstChild("Neverlose_Blur")
    if not blur then
        blur = Instance.new("BlurEffect")
        blur.Name = "Neverlose_Blur"
        blur.Size = 14
        blur.Parent = Lighting
    end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Neverlose_Premium_Dashboard"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = CoreGui
    self.ScreenGui = ScreenGui
    
    -- CanvasGroup base frame
    local MainFrame = Instance.new("CanvasGroup")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 780, 0, 520)
    MainFrame.Position = UDim2.new(0.5, -340, 0.5, -220)
    MainFrame.BackgroundColor3 = Color3.fromRGB(8, 11, 23)
    MainFrame.GroupTransparency = 0.12 -- Clean glass transparency
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Parent = ScreenGui
    self.MainFrame = MainFrame
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = MainFrame
    
    -- UIScale: Handles dynamic GUI resizing
    local ScaleObj = Instance.new("UIScale")
    ScaleObj.Scale = 1.0
    ScaleObj.Parent = MainFrame
    self.ScaleObj = ScaleObj
    
    -- Glowing Border
    local Border = Instance.new("UIStroke")
    Border.Thickness = 1
    Border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Border.Parent = MainFrame
    RegisterAccent(Border, "Color")
    
    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 180, 1, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(4, 5, 12)
    Sidebar.BackgroundTransparency = 0.2
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    
    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 10)
    SidebarCorner.Parent = Sidebar
    
    -- Visual Divider
    local SidebarDivider = Instance.new("Frame")
    SidebarDivider.Size = UDim2.new(0, 1, 1, 0)
    SidebarDivider.Position = UDim2.new(1, 0, 0, 0)
    SidebarDivider.BackgroundColor3 = Color3.fromRGB(20, 25, 45)
    SidebarDivider.BorderSizePixel = 0
    SidebarDivider.Parent = Sidebar
    
    -- Logo
    local LogoLabel = Instance.new("TextLabel")
    LogoLabel.Size = UDim2.new(1, 0, 0, 50)
    LogoLabel.BackgroundTransparency = 1
    LogoLabel.Text = "  NEVERLOSE"
    LogoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    LogoLabel.TextSize = 16
    LogoLabel.Font = Enum.Font.SourceSansBold
    LogoLabel.TextXAlignment = Enum.TextXAlignment.Left
    LogoLabel.Parent = Sidebar
    
    -- Navigation Scroll (Ensures buttons NEVER overflow or clip off-screen)
    local NavScroll = Instance.new("ScrollingFrame")
    NavScroll.Size = UDim2.new(1, -20, 1, -120) -- Strict padding constraint
    NavScroll.Position = UDim2.new(0, 10, 0, 55)
    NavScroll.BackgroundTransparency = 1
    NavScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    NavScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    NavScroll.ScrollBarThickness = 0
    NavScroll.Parent = Sidebar
    self.NavScroll = NavScroll
    
    local NavLayout = Instance.new("UIListLayout")
    NavLayout.Padding = UDim.new(0, 4)
    NavLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    NavLayout.Parent = NavScroll
    
    -- Right Container Workspace
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -200, 1, -20)
    Container.Position = UDim2.new(0, 190, 0, 10)
    Container.BackgroundTransparency = 1
    Container.Parent = MainFrame
    self.Container = Container
    
    self.Tabs = {}
    self.TabButtons = {}
    self.ActiveTab = nil
    
    -- Simple Drag Handler
    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
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
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- User Profile Card (Sidebar Footer)
    local Footer = Instance.new("Frame")
    Footer.Size = UDim2.new(1, 0, 0, 50)
    Footer.Position = UDim2.new(0, 0, 1, -55)
    Footer.BackgroundTransparency = 1
    Footer.Parent = Sidebar
    
    local Avatar = Instance.new("ImageLabel")
    Avatar.Size = UDim2.new(0, 32, 0, 32)
    Avatar.Position = UDim2.new(0, 12, 0.5, -16)
    Avatar.BackgroundColor3 = Color3.fromRGB(20, 25, 45)
    
    -- Query player headshot thumbnail
    local content, isReady = Players:GetUserThumbnailAsync(Players.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    Avatar.Image = isReady and content or "rbxassetid://12608465063"
    Avatar.Parent = Footer
    
    local AvatarCorner = Instance.new("UICorner")
    AvatarCorner.CornerRadius = UDim.new(0, 16)
    AvatarCorner.Parent = Avatar
    
    local UserTitle = Instance.new("TextLabel")
    UserTitle.Size = UDim2.new(1, -55, 0.5, 0)
    UserTitle.Position = UDim2.new(0, 50, 0, 10)
    UserTitle.BackgroundTransparency = 1
    UserTitle.Text = Players.LocalPlayer.Name
    UserTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    UserTitle.TextSize = 11
    UserTitle.Font = Enum.Font.SourceSansBold
    UserTitle.TextXAlignment = Enum.TextXAlignment.Left
    UserTitle.Parent = Footer
    
    local UserSub = Instance.new("TextLabel")
    UserSub.Size = UDim2.new(1, -55, 0.5, 0)
    UserSub.Position = UDim2.new(0, 50, 0.5, -2)
    UserSub.BackgroundTransparency = 1
    UserSub.Text = subtitle or "Till: Unlimited"
    UserSub.TextColor3 = Color3.fromRGB(100, 110, 130)
    UserSub.TextSize = 9
    UserSub.Font = Enum.Font.SourceSans
    UserSub.TextXAlignment = Enum.TextXAlignment.Left
    UserSub.Parent = Footer
    
    return self
end

function NeverloseLib:CreateTab(name)
    local TabFrame = Instance.new("ScrollingFrame")
    TabFrame.Size = UDim2.new(1, 0, 1, 0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.Visible = false
    TabFrame.ScrollBarThickness = 0
    TabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabFrame.Parent = self.Container
    
    local Grid = Instance.new("UIGridLayout")
    Grid.CellSize = UDim2.new(0.5, -10, 0, 360)
    Grid.CellPadding = UDim2.new(0, 15, 0, 15)
    Grid.FillDirectionMaxCells = 2
    Grid.SortOrder = Enum.SortOrder.LayoutOrder
    Grid.Parent = TabFrame
    
    self.Tabs[name] = TabFrame
    
    local NavBtn = Instance.new("TextButton")
    NavBtn.Size = UDim2.new(1, 0, 0, 30)
    NavBtn.BackgroundColor3 = Color3.fromRGB(12, 15, 28)
    NavBtn.BackgroundTransparency = 0.5
    NavBtn.BorderSizePixel = 0
    NavBtn.Text = "   " .. name
    NavBtn.TextColor3 = Color3.fromRGB(140, 150, 170)
    NavBtn.TextSize = 11
    NavBtn.Font = Enum.Font.SourceSansSemibold
    NavBtn.TextXAlignment = Enum.TextXAlignment.Left
    NavBtn.Parent = self.NavScroll
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = NavBtn
    
    self.TabButtons[name] = NavBtn
    
    NavBtn.MouseButton1Click:Connect(function()
        self:SelectTab(name)
    end)
    
    if not self.ActiveTab then
        self:SelectTab(name)
    end
    
    return TabFrame
end

function NeverloseLib:SelectTab(name)
    if self.ActiveTab then
        self.Tabs[self.ActiveTab].Visible = false
        local prevBtn = self.TabButtons[self.ActiveTab]
        if prevBtn then
            Tween(prevBtn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(12, 15, 28),
                BackgroundTransparency = 0.5,
                TextColor3 = Color3.fromRGB(140, 150, 170)
            })
        end
    end
    
    self.ActiveTab = name
    self.Tabs[name].Visible = true
    
    local nextBtn = self.TabButtons[name]
    if nextBtn then
        Tween(nextBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = NeverloseLib.AccentColor,
            BackgroundTransparency = 0,
            TextColor3 = Color3.fromRGB(255, 255, 255)
        })
    end
end

function NeverloseLib:CreateSection(tab, title)
    local Section = Instance.new("Frame")
    Section.BackgroundColor3 = Color3.fromRGB(12, 15, 28)
    Section.BackgroundTransparency = 0.4
    Section.BorderSizePixel = 0
    Section.Parent = tab
    
    local SectionCorner = Instance.new("UICorner")
    SectionCorner.CornerRadius = UDim.new(0, 6)
    SectionCorner.Parent = Section
    
    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 8)
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Layout.Parent = Section
    
    local Padding = Instance.new("UIPadding")
    Padding.PaddingTop = UDim.new(0, 12)
    Padding.PaddingBottom = UDim.new(0, 12)
    Padding.Parent = Section
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0.9, 0, 0, 20)
    Title.BackgroundTransparency = 1
    Title.Text = title
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 11
    Title.Font = Enum.Font.SourceSansBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Section
    
    local TitleDivider = Instance.new("Frame")
    TitleDivider.Size = UDim2.new(0.9, 0, 0, 1)
    TitleDivider.BackgroundColor3 = Color3.fromRGB(20, 25, 45)
    TitleDivider.BorderSizePixel = 0
    TitleDivider.Parent = Section
    
    -- Auto-adjust parent height based on items
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Section.Size = UDim2.new(0.5, -10, 0, Layout.AbsoluteContentSize.Y + 24)
    end)
    
    return Section
end

function NeverloseLib:AddToggle(section, text, defaultState, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(0.9, 0, 0, 26)
    Row.BackgroundTransparency = 1
    Row.Parent = section
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(190, 200, 220)
    Label.TextSize = 11
    Label.Font = Enum.Font.SourceSansSemibold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row
    
    local Switch = Instance.new("TextButton")
    Switch.Size = UDim2.new(0, 32, 0, 18)
    Switch.Position = UDim2.new(1, -32, 0.5, -9)
    Switch.BackgroundColor3 = Color3.fromRGB(20, 25, 45)
    Switch.BorderSizePixel = 0
    Switch.Text = ""
    Switch.Parent = Row
    
    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(0, 9)
    SwitchCorner.Parent = Switch
    
    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 14, 0, 14)
    Indicator.Position = defaultState and UDim2.new(0, 16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    Indicator.BorderSizePixel = 0
    Indicator.Parent = Switch
    
    if defaultState then
        RegisterAccent(Indicator, "BackgroundColor3")
    else
        Indicator.BackgroundColor3 = Color3.fromRGB(70, 80, 100)
    end
    
    local IndicatorCorner = Instance.new("UICorner")
    IndicatorCorner.CornerRadius = UDim.new(0, 7)
    IndicatorCorner.Parent = Indicator
    
    local active = defaultState
    Switch.MouseButton1Click:Connect(function()
        active = not active
        if active then
            RegisterAccent(Indicator, "BackgroundColor3")
            Tween(Indicator, TweenInfo.new(0.15), {Position = UDim2.new(0, 16, 0.5, -7)})
        else
            -- Clean out accent list
            for i, item in ipairs(NeverloseLib.ActiveObjects) do
                if item.Object == Indicator then
                    table.remove(NeverloseLib.ActiveObjects, i)
                    break
                end
            end
            Tween(Indicator, TweenInfo.new(0.15), {Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = Color3.fromRGB(70, 80, 100)})
        end
        callback(active)
    end)
end

function NeverloseLib:AddSlider(section, text, minVal, maxVal, defaultVal, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(0.9, 0, 0, 35)
    Row.BackgroundTransparency = 1
    Row.Parent = section
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 0, 15)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(190, 200, 220)
    Label.TextSize = 11
    Label.Font = Enum.Font.SourceSansSemibold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.35, 0, 0, 15)
    ValueLabel.Position = UDim2.new(0.65, 0, 0, 0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(defaultVal)
    ValueLabel.TextSize = 10
    ValueLabel.Font = Enum.Font.SourceSansBold
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Row
    RegisterAccent(ValueLabel, "TextColor3")
    
    local Track = Instance.new("TextButton")
    Track.Size = UDim2.new(1, 0, 0, 4)
    Track.Position = UDim2.new(0, 0, 0, 22)
    Track.BackgroundColor3 = Color3.fromRGB(20, 25, 45)
    Track.BorderSizePixel = 0
    Track.Text = ""
    Track.Parent = Row
    
    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(0, 2)
    TrackCorner.Parent = Track
    
    local Fill = Instance.new("Frame")
    local pct = (defaultVal - minVal) / (maxVal - minVal)
    Fill.Size = UDim2.new(pct, 0, 1, 0)
    Fill.BorderSizePixel = 0
    Fill.Parent = Track
    RegisterAccent(Fill, "BackgroundColor3")
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 2)
    FillCorner.Parent = Fill
    
    local dragging = false
    local function UpdateSliderInput(input)
        local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        Fill.Size = UDim2.new(pos, 0, 1, 0)
        local value = math.round(minVal + (maxVal - minVal) * pos)
        ValueLabel.Text = tostring(value)
        callback(value)
    end
    
    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            UpdateSliderInput(input)
        end
    end)
    Track.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            UpdateSliderInput(input)
        end
    end)
end

function NeverloseLib:AddDropdown(section, text, options, defaultVal, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(0.9, 0, 0, 42)
    Row.BackgroundTransparency = 1
    Row.Parent = section
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 15)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(150, 160, 180)
    Label.TextSize = 10
    Label.Font = Enum.Font.SourceSansSemibold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row
    
    local Combo = Instance.new("TextButton")
    Combo.Size = UDim2.new(1, 0, 0, 22)
    Combo.Position = UDim2.new(0, 0, 0, 18)
    Combo.BackgroundColor3 = Color3.fromRGB(20, 25, 45)
    Combo.BorderSizePixel = 0
    Combo.Text = "  " .. defaultVal
    Combo.TextColor3 = Color3.fromRGB(220, 220, 235)
    Combo.TextSize = 11
    Combo.Font = Enum.Font.SourceSansSemibold
    Combo.TextXAlignment = Enum.TextXAlignment.Left
    Combo.Parent = Row
    
    local ComboCorner = Instance.new("UICorner")
    ComboCorner.CornerRadius = UDim.new(0, 4)
    ComboCorner.Parent = Combo
    
    local Indicator = Instance.new("TextLabel")
    Indicator.Size = UDim2.new(0, 20, 1, 0)
    Indicator.Position = UDim2.new(1, -22, 0, 0)
    Indicator.BackgroundTransparency = 1
    Indicator.Text = "▼"
    Indicator.TextColor3 = Color3.fromRGB(100, 110, 130)
    Indicator.TextSize = 8
    Indicator.Parent = Combo
    
    local currentIdx = table.find(options, defaultVal) or 1
    Combo.MouseButton1Click:Connect(function()
        currentIdx = currentIdx % #options + 1
        local selected = options[currentIdx]
        Combo.Text = "  " .. selected
        callback(selected)
    end)
end

-- Feature: Hardware Keybind Capturing
function NeverloseLib:AddKeybind(section, text, defaultKey, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(0.9, 0, 0, 26)
    Row.BackgroundTransparency = 1
    Row.Parent = section
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(190, 200, 220)
    Label.TextSize = 11
    Label.Font = Enum.Font.SourceSansSemibold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row
    
    local BindBtn = Instance.new("TextButton")
    BindBtn.Size = UDim2.new(0, 42, 0, 18)
    BindBtn.Position = UDim2.new(1, -42, 0.5, -9)
    BindBtn.BackgroundColor3 = Color3.fromRGB(20, 25, 45)
    BindBtn.BorderSizePixel = 0
    BindBtn.Text = defaultKey and defaultKey.Name or "[NONE]"
    BindBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
    BindBtn.TextSize = 8
    BindBtn.Font = Enum.Font.SourceSansBold
    BindBtn.Parent = Row
    
    local BindCorner = Instance.new("UICorner")
    BindCorner.CornerRadius = UDim.new(0, 4)
    BindCorner.Parent = BindBtn
    
    local currentKey = defaultKey
    local waiting = false
    
    BindBtn.MouseButton1Click:Connect(function()
        waiting = true
        BindBtn.Text = "..."
        BindBtn.TextColor3 = Color3.fromRGB(0, 150, 255)
    end)
    
    UserInputService.InputBegan:Connect(function(input)
        if waiting then
            local key = (input.KeyCode ~= Enum.KeyCode.Unknown) and input.KeyCode or input.UserInputType
            if key ~= Enum.UserInputType.MouseMovement then
                currentKey = key
                waiting = false
                BindBtn.Text = key.Name
                BindBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
                callback(key)
            end
        end
    end)
end

-- Feature: Style/Color Picker Components
function NeverloseLib:AddColorPicker(section, text, defaultColor, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(0.9, 0, 0, 26)
    Row.BackgroundTransparency = 1
    Row.Parent = section
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(190, 200, 220)
    Label.TextSize = 11
    Label.Font = Enum.Font.SourceSansSemibold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row
    
    local PickerBtn = Instance.new("TextButton")
    PickerBtn.Size = UDim2.new(0, 18, 0, 18)
    PickerBtn.Position = UDim2.new(1, -18, 0.5, -9)
    PickerBtn.BackgroundColor3 = defaultColor
    PickerBtn.BorderSizePixel = 0
    PickerBtn.Text = ""
    PickerBtn.Parent = Row
    
    local PickerCorner = Instance.new("UICorner")
    PickerCorner.CornerRadius = UDim.new(0, 9)
    PickerCorner.Parent = PickerBtn
    
    local Palette = {
        Color3.fromRGB(0, 150, 255),  -- Default Cyan
        Color3.fromRGB(255, 80, 80),   -- Soft Red
        Color3.fromRGB(80, 255, 80),   -- Lime Green
        Color3.fromRGB(255, 180, 0),   -- Gold
        Color3.fromRGB(220, 80, 255)   -- Purple
    }
    local paletteIdx = table.find(Palette, defaultColor) or 1
    
    PickerBtn.MouseButton1Click:Connect(function()
        paletteIdx = paletteIdx % #Palette + 1
        local newColor = Palette[paletteIdx]
        PickerBtn.BackgroundColor3 = newColor
        
        UpdateThemeColor(newColor)
        callback(newColor)
    end)
end

-- Feature: High-Tech Rotating 3D Viewport Character/Model Preview
function NeverloseLib:Add3DAvatar(section)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(0.9, 0, 0, 180) -- Fixed vertical space constraint inside list
    Row.BackgroundTransparency = 1
    Row.Parent = section
    
    local Viewport = Instance.new("ViewportFrame")
    Viewport.Size = UDim2.new(1, 0, 1, 0)
    Viewport.BackgroundTransparency = 1
    Viewport.BorderSizePixel = 0
    Viewport.Parent = Row
    
    -- Generate character visual clone safely
    local dummy = Instance.new("Model")
    dummy.Name = "Neverlose_Viewport_Dummy"
    
    local character = Players.LocalPlayer.Character
    if character then
        character.Archivable = true
        for _, obj in ipairs(character:GetChildren()) do
            -- Clone purely visual elements and geometries to prevent running scripts or mechanics
            if obj:IsA("BasePart") or obj:IsA("Humanoid") or obj:IsA("CharacterAppearance") or obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("BodyColors") or obj:IsA("Accessory") then
                local cloned = obj:Clone()
                cloned.Parent = dummy
                if cloned:IsA("BasePart") then
                    cloned.Anchored = true
                end
            end
        end
    else
        -- Fallback Blocky Dummy if Character is missing/loading
        local root = Instance.new("Part")
        root.Size = Vector3.new(2, 2, 1)
        root.Name = "HumanoidRootPart"
        root.Anchored = true
        root.Parent = dummy
        dummy.PrimaryPart = root
    end
    
    dummy:PivotTo(CFrame.new(0, 0, 0))
    dummy.Parent = Viewport
    
    -- Dedicated Camera Projection Angle Setup
    local camera = Instance.new("Camera")
    camera.FieldOfView = 50
    Viewport.CurrentCamera = camera
    camera.Parent = Viewport
    
    -- Anchor Camera target focusing UpperTorso/Chest
    local cameraDistance = 5.2
    local angleY = 0
    
    -- Smooth Heartbeat Rotation Loop
    local connection = RunService.Heartbeat:Connect(function(dt)
        if not Viewport or not Viewport.Parent then return end
        angleY = angleY + dt * 0.5 -- 0.5 Rads per second rotation speed
        local rotCFrame = CFrame.Angles(0, angleY, 0)
        camera.CFrame = CFrame.new(Vector3.new(0, 0.5, 0)) * rotCFrame * CFrame.new(0, 0, cameraDistance)
    end)
    
    -- Auto-clean thread connection when destroyed
    section.Destroying:Connect(function()
        connection:Disconnect()
    end)
end

return NeverloseLib
