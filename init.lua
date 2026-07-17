-- Neverlose-Inspired Modern Glassmorphism UI Library
-- Designed for high-frequency execution and dynamic rendering

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local NeverloseLib = {}
NeverloseLib.__index = NeverloseLib

-- Helper: Safely applies smooth transitions
local function Tween(obj, info, target)
    local t = TweenService:Create(obj, info, target)
    t:Play()
    return t
end

function NeverloseLib.CreateWindow(title, subtitle)
    local self = setmetatable({}, NeverloseLib)
    
    -- Destroy any previous library instances to prevent overlay conflicts
    local oldUI = CoreGui:FindFirstChild("Neverlose_Premium_Dashboard")
    if oldUI then oldUI:Destroy() end
    
    -- Setup dynamic glass blur
    local blur = Lighting:FindFirstChild("Neverlose_Blur")
    if not blur then
        blur = Instance.new("BlurEffect")
        blur.Name = "Neverlose_Blur"
        blur.Size = 14
        blur.Parent = Lighting
    end
    
    -- Top-level ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Neverlose_Premium_Dashboard"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = CoreGui
    self.ScreenGui = ScreenGui
    
    -- Main Window using CanvasGroup for perfect glass group transparency
    local MainFrame = Instance.new("CanvasGroup")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 680, 0, 440)
    MainFrame.Position = UDim2.new(0.5, -340, 0.5, -220)
    MainFrame.BackgroundColor3 = Color3.fromRGB(8, 11, 23)
    MainFrame.GroupTransparency = 0.15 -- Real semi-transparent glass
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Parent = ScreenGui
    self.MainFrame = MainFrame
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame
    
    -- Realistic glass refraction borders using UIStroke Gradient
    local Border = Instance.new("UIStroke")
    Border.Thickness = 1
    Border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Border.Color = Color3.fromRGB(255, 255, 255)
    Border.Parent = MainFrame
    
    local BorderGradient = Instance.new("UIGradient")
    BorderGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 160, 255)),   -- Glowing top
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 25, 45)), -- Dark sides
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 160, 255))    -- Glowing bottom
    })
    BorderGradient.Rotation = 45
    BorderGradient.Parent = Border
    
    -- Premium Sidebar Panel
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 170, 1, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(4, 5, 12)
    Sidebar.BackgroundTransparency = 0.2
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    
    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 12)
    SidebarCorner.Parent = Sidebar
    
    -- Divider Line to clean up structural bounds
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
    LogoLabel.TextSize = 15
    LogoLabel.Font = Enum.Font.SourceSansBold
    LogoLabel.TextXAlignment = Enum.TextXAlignment.Left
    LogoLabel.Parent = Sidebar
    
    -- Navigation Scroll (Ensures buttons NEVER overflow or clip off-screen)
    local NavScroll = Instance.new("ScrollingFrame")
    NavScroll.Size = UDim2.new(1, -20, 1, -120) -- Leave strict padding for user card and logo
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
    Container.Size = UDim2.new(1, -190, 1, -20)
    Container.Position = UDim2.new(0, 180, 0, 10)
    Container.BackgroundTransparency = 1
    Container.Parent = MainFrame
    self.Container = Container
    
    self.Tabs = {}
    self.TabButtons = {}
    self.ActiveTab = nil
    
    -- Window Dragging Handler
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
    
    -- Render User Profile Card in Footer
    local Footer = Instance.new("Frame")
    Footer.Size = UDim2.new(1, 0, 0, 50)
    Footer.Position = UDim2.new(0, 0, 1, -55)
    Footer.BackgroundTransparency = 1
    Footer.Parent = Sidebar
    
    local Avatar = Instance.new("ImageLabel")
    Avatar.Size = UDim2.new(0, 32, 0, 32)
    Avatar.Position = UDim2.new(0, 12, 0.5, -16)
    Avatar.BackgroundColor3 = Color3.fromRGB(20, 25, 45)
    Avatar.Image = "rbxassetid://12608465063" -- Neon cyan placeholder avatar
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
    
    -- Add Navigation Button to Left Column
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
    
    -- Auto-select the first tab created
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
            BackgroundColor3 = Color3.fromRGB(0, 150, 255),
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

function NeverloseLib:AddToggle(section, text, callback)
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
    Indicator.Position = UDim2.new(0, 2, 0.5, -7)
    Indicator.BackgroundColor3 = Color3.fromRGB(70, 80, 100)
    Indicator.BorderSizePixel = 0
    Indicator.Parent = Switch
    
    local IndicatorCorner = Instance.new("UICorner")
    IndicatorCorner.CornerRadius = UDim.new(0, 7)
    IndicatorCorner.Parent = Indicator
    
    local active = false
    Switch.MouseButton1Click:Connect(function()
        active = not active
        if active then
            Tween(Indicator, TweenInfo.new(0.15), {Position = UDim2.new(0, 16, 0.5, -7), BackgroundColor3 = Color3.fromRGB(0, 150, 255)})
        else
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
    ValueLabel.TextColor3 = Color3.fromRGB(0, 150, 255)
    ValueLabel.TextSize = 10
    ValueLabel.Font = Enum.Font.SourceSansBold
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Row
    
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
    Fill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    Fill.BorderSizePixel = 0
    Fill.Parent = Track
    
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

return NeverloseLib
