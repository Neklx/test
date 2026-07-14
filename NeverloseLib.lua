-- ====================================================================================
-- NEVERLOSE.CC UI LIBRARY (Standalone Module)
-- High-Performance Cyan/Dark Theme Dashboard with Responsive Micro-Animations
-- ====================================================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Library = {
    Theme = {
        MainBg = Color3.fromRGB(6, 9, 14),
        PanelBg = Color3.fromRGB(9, 13, 20),
        CardBg = Color3.fromRGB(12, 17, 26),
        Accent = Color3.fromRGB(0, 162, 255),
        AccentGlow = Color3.fromRGB(0, 220, 255),
        Text = Color3.fromRGB(240, 245, 255),
        MutedText = Color3.fromRGB(115, 125, 140),
        Border = Color3.fromRGB(20, 25, 35),
        Hover = Color3.fromRGB(24, 31, 44),
        FontBold = Enum.Font.GothamBold,
        FontMedium = Enum.Font.GothamSemibold,
        FontRegular = Enum.Font.Gotham
    },
    CurrentTab = nil,
    CurrentPage = nil,
    UIConnection = nil
}

-- Ensure clean reloads
local oldUI = PlayerGui:FindFirstChild("NeverloseCC_Standalone")
if oldUI then oldUI:Destroy() end

-- ====================================================================================
-- Internal Helper: Smooth Window Dragging
-- ====================================================================================
local function makeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

-- ====================================================================================
-- Window Creator
-- ====================================================================================
function Library:CreateWindow(config)
    config = config or {}
    local titleText = config.Title or "NEVERLOSE.CC"
    local subtitleText = config.Subtitle or "CS2 CHEAT SUITE"
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NeverloseCC_Standalone"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui
    Library.ScreenGui = ScreenGui

    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 680, 0, 430)
    MainFrame.Position = UDim2.new(0.5, -340, 0.5, -215)
    MainFrame.BackgroundColor3 = Library.Theme.MainBg
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 6)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Thickness = 1.2
    MainStroke.Color = Library.Theme.Border
    MainStroke.Parent = MainFrame

    -- Sidebar Container
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 160, 1, 0)
    Sidebar.BackgroundColor3 = Library.Theme.PanelBg
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame

    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 6)
    SidebarCorner.Parent = Sidebar

    local SidebarPatch = Instance.new("Frame")
    SidebarPatch.Size = UDim2.new(0, 15, 1, 0)
    SidebarPatch.Position = UDim2.new(1, -15, 0, 0)
    SidebarPatch.BackgroundColor3 = Library.Theme.PanelBg
    SidebarPatch.BorderSizePixel = 0
    SidebarPatch.Parent = Sidebar

    -- Drag Handle Header
    local HeaderHandle = Instance.new("Frame")
    HeaderHandle.Name = "HeaderHandle"
    HeaderHandle.Size = UDim2.new(1, 0, 0, 50)
    HeaderHandle.BackgroundTransparency = 1
    HeaderHandle.Parent = MainFrame
    makeDraggable(MainFrame, HeaderHandle)

    local LogoLabel = Instance.new("TextLabel")
    LogoLabel.Size = UDim2.new(1, 0, 0, 50)
    LogoLabel.Position = UDim2.new(0, 0, 0, 5)
    LogoLabel.Text = titleText:upper()
    LogoLabel.Font = Library.Theme.FontBold
    LogoLabel.TextSize = 14
    LogoLabel.TextColor3 = Library.Theme.Accent
    LogoLabel.BackgroundTransparency = 1
    LogoLabel.Parent = Sidebar

    -- Tab Button Scroll Area
    local TabScroll = Instance.new("ScrollingFrame")
    TabScroll.Size = UDim2.new(1, -16, 1, -110)
    TabScroll.Position = UDim2.new(0, 8, 0, 60)
    TabScroll.BackgroundTransparency = 1
    TabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabScroll.ScrollBarThickness = 0
    TabScroll.Parent = Sidebar

    local TabList = Instance.new("UIListLayout")
    TabList.Padding = UDim.new(0, 6)
    TabList.Parent = TabScroll

    -- Profile Card Area (Bottom Left)
    local ProfileCard = Instance.new("Frame")
    ProfileCard.Size = UDim2.new(1, -16, 0, 45)
    ProfileCard.Position = UDim2.new(0, 8, 1, -55)
    ProfileCard.BackgroundColor3 = Library.Theme.CardBg
    ProfileCard.BorderSizePixel = 0
    ProfileCard.Parent = Sidebar

    local ProfileCorner = Instance.new("UICorner")
    ProfileCorner.CornerRadius = UDim.new(0, 4)
    ProfileCorner.Parent = ProfileCard

    local ProfileStroke = Instance.new("UIStroke")
    ProfileStroke.Color = Library.Theme.Border
    ProfileStroke.Parent = ProfileCard

    local UsernameLabel = Instance.new("TextLabel")
    UsernameLabel.Size = UDim2.new(1, -20, 0, 20)
    UsernameLabel.Position = UDim2.new(0, 10, 0, 4)
    UsernameLabel.Text = LocalPlayer.Name
    UsernameLabel.Font = Library.Theme.FontBold
    UsernameLabel.TextSize = 11
    UsernameLabel.TextColor3 = Library.Theme.Text
    UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    UsernameLabel.BackgroundTransparency = 1
    UsernameLabel.Parent = ProfileCard

    local SubLabel = Instance.new("TextLabel")
    SubLabel.Size = UDim2.new(1, -20, 0, 15)
    SubLabel.Position = UDim2.new(0, 10, 0, 22)
    SubLabel.Text = "EXPIRED: 07.07.2026"
    SubLabel.Font = Library.Theme.FontMedium
    SubLabel.TextSize = 9
    SubLabel.TextColor3 = Library.Theme.MutedText
    SubLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubLabel.BackgroundTransparency = 1
    SubLabel.Parent = ProfileCard

    -- Pages Container
    local PagesContainer = Instance.new("Frame")
    PagesContainer.Size = UDim2.new(1, -175, 1, -20)
    PagesContainer.Position = UDim2.new(0, 165, 0, 10)
    PagesContainer.BackgroundTransparency = 1
    PagesContainer.Parent = MainFrame

    -- Toggle Menu Bind
    Library.UIConnection = UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.Insert then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    -- Toggle Screen Canvas Window
    local windowAPI = {}

    -- ================================================================================
    -- Category Tab Creator
    -- ================================================================================
    function windowAPI:CreateTab(tabName)
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(1, 0, 0, 32)
        tabButton.BackgroundTransparency = 1
        tabButton.Text = tabName:upper()
        tabButton.Font = Library.Theme.FontBold
        tabButton.TextSize = 11
        tabButton.TextColor3 = Library.Theme.MutedText
        tabButton.AutoButtonColor = false
        tabButton.Parent = TabScroll

        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 4)
        TabCorner.Parent = tabButton

        -- Dynamic Dual-Column Page Architecture
        local Page = Instance.new("Frame")
        Page.Size = UDim2.fromScale(1, 1)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.Parent = PagesContainer

        local LeftColumn = Instance.new("ScrollingFrame")
        LeftColumn.Size = UDim2.fromScale(0.485, 1)
        LeftColumn.BackgroundTransparency = 1
        LeftColumn.CanvasSize = UDim2.new(0, 0, 0, 0)
        LeftColumn.ScrollBarThickness = 0
        LeftColumn.Parent = Page

        local LeftLayout = Instance.new("UIListLayout")
        LeftLayout.Padding = UDim.new(0, 10)
        LeftLayout.Parent = LeftColumn

        LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            LeftColumn.CanvasSize = UDim2.new(0, 0, 0, LeftLayout.AbsoluteContentSize.Y + 15)
        end)

        local RightColumn = Instance.new("ScrollingFrame")
        RightColumn.Size = UDim2.fromScale(0.485, 1)
        RightColumn.Position = UDim2.fromScale(0.515, 0)
        RightColumn.BackgroundTransparency = 1
        RightColumn.CanvasSize = UDim2.new(0, 0, 0, 0)
        RightColumn.ScrollBarThickness = 0
        RightColumn.Parent = Page

        local RightLayout = Instance.new("UIListLayout")
        RightLayout.Padding = UDim.new(0, 10)
        RightLayout.Parent = RightColumn

        RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            RightColumn.CanvasSize = UDim2.new(0, 0, 0, RightLayout.AbsoluteContentSize.Y + 15)
        end)

        -- Handle selection transitions
        tabButton.MouseButton1Click:Connect(function()
            if Library.CurrentPage then Library.CurrentPage.Visible = false end
            if Library.CurrentTab then
                TweenService:Create(Library.CurrentTab, TweenInfo.new(0.12), {
                    BackgroundTransparency = 1,
                    TextColor3 = Library.Theme.MutedText
                }):Play()
            end

            Page.Visible = true
            Library.CurrentPage = Page
            Library.CurrentTab = tabButton

            TweenService:Create(tabButton, TweenInfo.new(0.12), {
                BackgroundTransparency = 0.9,
                BackgroundColor3 = Library.Theme.Accent,
                TextColor3 = Library.Theme.Text
            }):Play()
        end)

        -- Default Page setup
        if not Library.CurrentPage then
            Page.Visible = true
            Library.CurrentPage = Page
            Library.CurrentTab = tabButton
            tabButton.BackgroundTransparency = 0.9
            tabButton.BackgroundColor3 = Library.Theme.Accent
            tabButton.TextColor3 = Library.Theme.Text
        end

        local pageAPI = {}

        -- ============================================================================
        -- Card Section Box Creator
        -- ============================================================================
        function pageAPI:CreateCard(cardName, columnSide)
            local targetColumn = (columnSide == "Right") and RightColumn or LeftColumn

            local CardFrame = Instance.new("Frame")
            CardFrame.Size = UDim2.new(1, -4, 0, 40)
            CardFrame.BackgroundColor3 = Library.Theme.CardBg
            CardFrame.BorderSizePixel = 0
            CardFrame.Parent = targetColumn

            local CardCorner = Instance.new("UICorner")
            CardCorner.CornerRadius = UDim.new(0, 5)
            CardCorner.Parent = CardFrame

            local CardStroke = Instance.new("UIStroke")
            CardStroke.Color = Library.Theme.Border
            CardStroke.Parent = CardFrame

            local HeaderLabel = Instance.new("TextLabel")
            HeaderLabel.Size = UDim2.new(1, -20, 0, 25)
            HeaderLabel.Position = UDim2.new(0, 10, 0, 4)
            HeaderLabel.Text = cardName:upper()
            HeaderLabel.Font = Library.Theme.FontBold
            HeaderLabel.TextSize = 10
            HeaderLabel.TextColor3 = Library.Theme.MutedText
            HeaderLabel.BackgroundTransparency = 1
            HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
            HeaderLabel.Parent = CardFrame

            local CardList = Instance.new("Frame")
            CardList.Size = UDim2.new(1, 0, 1, -30)
            CardList.Position = UDim2.new(0, 0, 0, 30)
            CardList.BackgroundTransparency = 1
            CardList.Parent = CardFrame

            local CardListLayout = Instance.new("UIListLayout")
            CardListLayout.Padding = UDim.new(0, 8)
            CardListLayout.Parent = CardList

            CardListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                CardFrame.Size = UDim2.new(1, -4, 0, CardListLayout.AbsoluteContentSize.Y + 40)
            end)

            local cardAPI = {}

            -- ========================================================================
            -- INTERACTIVE ELEMENTS: Toggle
            -- ========================================================================
            function cardAPI:AddToggle(name, defaultState, callback)
                defaultState = defaultState or false
                local active = defaultState

                local Row = Instance.new("Frame")
                Row.Size = UDim2.new(1, 0, 0, 28)
                Row.BackgroundTransparency = 1
                Row.Parent = CardList

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -55, 1, 0)
                Label.Position = UDim2.new(0, 10, 0, 0)
                Label.Text = name
                Label.Font = Library.Theme.FontMedium
                Label.TextSize = 11
                Label.TextColor3 = Library.Theme.Text
                Label.BackgroundTransparency = 1
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = Row

                local Box = Instance.new("TextButton")
                Box.Size = UDim2.new(0, 26, 0, 15)
                Box.Position = UDim2.new(1, -36, 0.5, -7)
                Box.BackgroundColor3 = active and Library.Theme.Accent or Library.Theme.Border
                Box.Text = ""
                Box.AutoButtonColor = false
                Box.Parent = Row

                local BoxCorner = Instance.new("UICorner")
                BoxCorner.CornerRadius = UDim.new(0, 8)
                BoxCorner.Parent = Box

                local Pin = Instance.new("Frame")
                Pin.Size = UDim2.new(0, 11, 0, 11)
                Pin.Position = active and UDim2.new(1, -13, 0.5, -5) or UDim2.new(0, 2, 0.5, -5)
                Pin.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Pin.BorderSizePixel = 0
                Pin.Parent = Box

                local PinCorner = Instance.new("UICorner")
                PinCorner.CornerRadius = UDim.new(0, 6)
                PinCorner.Parent = Pin

                local function setToggleState(state)
                    active = state
                    local col = active and Library.Theme.Accent or Library.Theme.Border
                    local pos = active and UDim2.new(1, -13, 0.5, -5) or UDim2.new(0, 2, 0.5, -5)
                    TweenService:Create(Box, TweenInfo.new(0.12), {BackgroundColor3 = col}):Play()
                    TweenService:Create(Pin, TweenInfo.new(0.12), {Position = pos}):Play()
                    if callback then callback(active) end
                end

                Box.MouseButton1Click:Connect(function()
                    setToggleState(not active)
                end)

                return { Set = setToggleState }
            end

            -- ========================================================================
            -- INTERACTIVE ELEMENTS: Slider
            -- ========================================================================
            function cardAPI:AddSlider(name, minVal, maxVal, defaultVal, callback)
                local currentVal = math.clamp(defaultVal or minVal, minVal, maxVal)

                local Row = Instance.new("Frame")
                Row.Size = UDim2.new(1, 0, 0, 36)
                Row.BackgroundTransparency = 1
                Row.Parent = CardList

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(0.6, 0, 0, 18)
                Label.Position = UDim2.new(0, 10, 0, 0)
                Label.Text = name
                Label.Font = Library.Theme.FontMedium
                Label.TextSize = 11
                Label.TextColor3 = Library.Theme.Text
                Label.BackgroundTransparency = 1
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = Row

                local Val = Instance.new("TextLabel")
                Val.Size = UDim2.new(0.4, -10, 0, 18)
                Val.Position = UDim2.new(0.6, 0, 0, 0)
                Val.Text = tostring(currentVal)
                Val.Font = Library.Theme.FontBold
                Val.TextSize = 11
                Val.TextColor3 = Library.Theme.Accent
                Val.BackgroundTransparency = 1
                Val.TextXAlignment = Enum.TextXAlignment.Right
                Val.Parent = Row

                local Bar = Instance.new("TextButton")
                Bar.Size = UDim2.new(1, -20, 0, 4)
                Bar.Position = UDim2.new(0, 10, 1, -8)
                Bar.BackgroundColor3 = Library.Theme.Border
                Bar.Text = ""
                Bar.AutoButtonColor = false
                Bar.Parent = Row

                local Fill = Instance.new("Frame")
                Fill.Size = UDim2.fromScale((currentVal - minVal)/(maxVal - minVal), 1)
                Fill.BackgroundColor3 = Library.Theme.Accent
                Fill.BorderSizePixel = 0
                Fill.Parent = Bar

                local sliding = false
                local function slide(input)
                    local rX = math.clamp(input.Position.X - Bar.AbsolutePosition.X, 0, Bar.AbsoluteSize.X)
                    local ratio = rX / Bar.AbsoluteSize.X
                    local out = math.round(minVal + ratio * (maxVal - minVal))
                    currentVal = out
                    Val.Text = tostring(out)
                    Fill.Size = UDim2.fromScale(ratio, 1)
                    if callback then callback(out) end
                end

                Bar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true slide(input) end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then slide(input) end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
                end)

                return {
                    Set = function(val)
                        currentVal = math.clamp(val, minVal, maxVal)
                        Val.Text = tostring(currentVal)
                        Fill.Size = UDim2.fromScale((currentVal - minVal)/(maxVal - minVal), 1)
                        if callback then callback(currentVal) end
                    end
                }
            end

            -- ========================================================================
            -- INTERACTIVE ELEMENTS: Dropdown
            -- ========================================================================
            function cardAPI:AddDropdown(name, options, defaultVal, callback)
                local currentVal = defaultVal or options[1]

                local Row = Instance.new("Frame")
                Row.Size = UDim2.new(1, 0, 0, 44)
                Row.BackgroundTransparency = 1
                Row.ClipsDescendants = false
                Row.Parent = CardList

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -20, 0, 18)
                Label.Position = UDim2.new(0, 10, 0, 0)
                Label.Text = name
                Label.Font = Library.Theme.FontMedium
                Label.TextSize = 11
                Label.TextColor3 = Library.Theme.Text
                Label.BackgroundTransparency = 1
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = Row

                local Box = Instance.new("TextButton")
                Box.Size = UDim2.new(1, -20, 0, 22)
                Box.Position = UDim2.new(0, 10, 0, 18)
                Box.BackgroundColor3 = Library.Theme.PanelBg
                Box.Text = tostring(currentVal)
                Box.Font = Library.Theme.FontBold
                Box.TextSize = 10
                Box.TextColor3 = Library.Theme.Accent
                Box.AutoButtonColor = false
                Box.Parent = Row

                local BoxCorner = Instance.new("UICorner")
                BoxCorner.CornerRadius = UDim.new(0, 4)
                BoxCorner.Parent = Box

                local Menu = Instance.new("Frame")
                Menu.Size = UDim2.new(1, 0, 0, #options * 22)
                Menu.Position = UDim2.new(0, 0, 1, 2)
                Menu.BackgroundColor3 = Library.Theme.CardBg
                Menu.BorderSizePixel = 0
                Menu.Visible = false
                Menu.ZIndex = 50
                Menu.Parent = Box

                local MenuCorner = Instance.new("UICorner")
                MenuCorner.CornerRadius = UDim.new(0, 4)
                MenuCorner.Parent = Menu

                local MenuStroke = Instance.new("UIStroke")
                MenuStroke.Color = Library.Theme.Border
                MenuStroke.Parent = Menu

                local MenuList = Instance.new("UIListLayout")
                MenuList.Parent = Menu

                for _, opt in ipairs(options) do
                    local OptBtn = Instance.new("TextButton")
                    OptBtn.Size = UDim2.new(1, 0, 0, 22)
                    OptBtn.Text = tostring(opt)
                    OptBtn.Font = Library.Theme.FontMedium
                    OptBtn.TextSize = 10
                    OptBtn.TextColor3 = Library.Theme.Text
                    OptBtn.BackgroundTransparency = 1
                    OptBtn.ZIndex = 51
                    OptBtn.Parent = Menu

                    OptBtn.MouseButton1Click:Connect(function()
                        currentVal = opt
                        Box.Text = tostring(opt)
                        Menu.Visible = false
                        if callback then callback(opt) end
                    end)
                end

                Box.MouseButton1Click:Connect(function()
                    Menu.Visible = not Menu.Visible
                end)

                return {
                    Set = function(val)
                        currentVal = val
                        Box.Text = tostring(val)
                        if callback then callback(currentVal) end
                    end
                }
            end

            -- ========================================================================
            -- INTERACTIVE ELEMENTS: Color Picker
            -- ========================================================================
            function cardAPI:AddColorPicker(name, defaultColor, callback)
                local currentVal = defaultColor or Library.Theme.Accent

                local Row = Instance.new("Frame")
                Row.Size = UDim2.new(1, 0, 0, 28)
                Row.BackgroundTransparency = 1
                Row.Parent = CardList

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -60, 1, 0)
                Label.Position = UDim2.new(0, 10, 0, 0)
                Label.Text = name
                Label.Font = Library.Theme.FontMedium
                Label.TextSize = 11
                Label.TextColor3 = Library.Theme.Text
                Label.BackgroundTransparency = 1
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = Row

                local Box = Instance.new("TextButton")
                Box.Size = UDim2.new(0, 22, 0, 14)
                Box.Position = UDim2.new(1, -32, 0.5, -7)
                Box.BackgroundColor3 = currentVal
                Box.Text = ""
                Box.Parent = Row

                local BoxCorner = Instance.new("UICorner")
                BoxCorner.CornerRadius = UDim.new(0, 3)
                BoxCorner.Parent = Box

                -- Presets Sequencer
                local presets = { Library.Theme.Accent, Color3.fromRGB(255, 45, 85), Color3.fromRGB(70, 240, 110), Color3.fromRGB(240, 240, 245) }
                local idx = 1
                Box.MouseButton1Click:Connect(function()
                    idx = (idx % #presets) + 1
                    currentVal = presets[idx]
                    Box.BackgroundColor3 = currentVal
                    if callback then callback(currentVal) end
                end)

                return {
                    Set = function(val)
                        currentVal = val
                        Box.BackgroundColor3 = val
                        if callback then callback(currentVal) end
                    end
                }
            end

            -- ========================================================================
            -- INTERACTIVE ELEMENTS: Keybind Button
            -- ========================================================================
            function cardAPI:AddKeybind(name, defaultKey, callback)
                local currentVal = defaultKey or Enum.KeyCode.E

                local Row = Instance.new("Frame")
                Row.Size = UDim2.new(1, 0, 0, 28)
                Row.BackgroundTransparency = 1
                Row.Parent = CardList

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -90, 1, 0)
                Label.Position = UDim2.new(0, 10, 0, 0)
                Label.Text = name
                Label.Font = Library.Theme.FontMedium
                Label.TextSize = 11
                Label.TextColor3 = Library.Theme.Text
                Label.BackgroundTransparency = 1
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = Row

                local Box = Instance.new("TextButton")
                Box.Size = UDim2.new(0, 60, 0, 18)
                Box.Position = UDim2.new(1, -70, 0.5, -9)
                Box.BackgroundColor3 = Library.Theme.PanelBg
                Box.Text = currentVal.Name
                Box.Font = Library.Theme.FontBold
                Box.TextSize = 9
                Box.TextColor3 = Library.Theme.Accent
                Box.Parent = Row

                local BoxCorner = Instance.new("UICorner")
                BoxCorner.CornerRadius = UDim.new(0, 3)
                BoxCorner.Parent = Box

                local listening = false
                Box.MouseButton1Click:Connect(function()
                    listening = true
                    Box.Text = "..."
                end)

                UserInputService.InputBegan:Connect(function(input)
                    if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                        listening = false
                        currentVal = input.KeyCode
                        Box.Text = input.KeyCode.Name
                        if callback then callback(currentVal) end
                    end
                end)

                return {
                    Set = function(val)
                        currentVal = val
                        Box.Text = val.Name
                        if callback then callback(currentVal) end
                    end
                }
            end

            return cardAPI
        end

        return pageAPI
    end

    -- Window Close Logic
    function windowAPI:Destroy()
        if Library.UIConnection then Library.UIConnection:Disconnect() end
        ScreenGui:Destroy()
    end

    return windowAPI
end

return Library
