-- ====================================================================================
-- NEVERLOSE.CC - ULTIMATE INTEGRATED SUITE (Main.lua)
-- Standalone, high-performance compilation of Aimbot, Visuals, and Bhop systems
-- ====================================================================================

-- 1. Import Standalone UI Library
local cacheBypass = "?t=" .. tostring(os.time())
local NeverloseLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Neklx/test/main/NeverloseLib.lua" .. cacheBypass))()

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local CurrentCamera = Workspace.CurrentCamera

-- Global Feature Configurations
local Menu_Config = {
    -- Aim Settings
    AimEnabled = true,
    SilentAim = true,
    Autowall = true,
    TargetPart = "Head", -- Head, HumanoidRootPart, Random
    MaxFOV = 15,
    TeamCheck = true,
    AimBind = Enum.KeyCode.E,
    IsAimActive = true,
    
    -- ESP Settings
    EspEnabled = true,
    EspTeamCheck = true,
    ShowNames = true,
    ShowWeapons = true,
    ShowHealth = true,
    ShowDistance = true,
    HighlightTeammates = false,
    
    -- World Visual Trackers
    C4_ESP = true,
    Grenade_ESP = true,
    
    -- Colors
    EnemyColor = Color3.fromRGB(255, 45, 85),
    TeamColor = Color3.fromRGB(0, 190, 255),
    FovCircleColor = Color3.fromRGB(0, 190, 255),
    
    -- Movement
    BhopEnabled = false
}

-- Render Caches
local activeHighlights = {}
local activeBillboards = {}
local worldTrackers = {}
local CharacterController = nil

-- ====================================================================================
-- Locomotion & Target Helpers
-- ====================================================================================
local function getActivePlayerModel(player)
    if not player then return nil end
    local char = player.Character
    if char and char:IsDescendantOf(Workspace) and char:FindFirstChild("HumanoidRootPart") then
        return char
    end
    local debris = Workspace:FindFirstChild("Debris")
    if debris then
        local clientModel = debris:FindFirstChild(player.Name)
        if clientModel and clientModel:FindFirstChild("HumanoidRootPart") then
            return clientModel
        end
    end
    return nil
end

local function checkIsEnemy(player, isAimbotCheck)
    local checkEnabled = isAimbotCheck and Menu_Config.TeamCheck or Menu_Config.EspTeamCheck
    if not checkEnabled then return true end
    
    local myTeam = LocalPlayer:GetAttribute("Team")
    local playerTeam = player:GetAttribute("Team")
    if playerTeam == nil or myTeam == nil then
        return player.Team ~= LocalPlayer.Team
    end
    return playerTeam ~= myTeam
end

-- Simulates bullet penetration limits for Autowall
local function getShootablePart(model, partName)
    local part = model:FindFirstChild(partName)
    if not part then return nil end
    if not Menu_Config.Autowall then return part end

    local origin = CurrentCamera.CFrame.Position
    local targetPos = part.Position
    local dir = (targetPos - origin)
    
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LocalPlayer.Character, model }
    params.CollisionGroup = "Bullet"
    
    local res = Workspace:Raycast(origin, dir, params)
    if not res then
        return part
    else
        local depth = (targetPos - res.Position).Magnitude
        if depth < 10 then
            return part
        end
    end
    return nil
end

-- PC Target Selector
local function getAimTarget()
    if not Menu_Config.AimEnabled or not Menu_Config.IsAimActive then return nil end
    
    local bestTarget = nil
    local minimumDistance = math.huge
    local screenCenter = CurrentCamera.ViewportSize / 2

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and checkIsEnemy(player, true) then
            local model = getActivePlayerModel(player)
            if model then
                local chosenPartName = Menu_Config.TargetPart
                if chosenPartName == "Random" then
                    chosenPartName = (math.random() > 0.5) and "Head" or "HumanoidRootPart"
                end
                
                local targetPart = getShootablePart(model, chosenPartName)
                if targetPart then
                    local screenPos, onScreen = CurrentCamera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        local angle = (distance / CurrentCamera.ViewportSize.Y) * CurrentCamera.FieldOfView
                        
                        if angle <= Menu_Config.MaxFOV and distance < minimumDistance then
                            minimumDistance = distance
                            bestTarget = targetPart
                        end
                    end
                end
            end
        end
    end
    return bestTarget
end

-- Extracts CharacterController securely from active upvalues
local function findCharacterController()
    if typeof(getgc) ~= "function" then return nil end
    for _, v in ipairs(getgc(true)) do
        if typeof(v) == "table" and rawget(v, "getCurrentCharacter") and rawget(v, "jump") then
            return v
        end
    end
    return nil
end

-- ====================================================================================
-- Silent Aim Injection Hook
-- ====================================================================================
local function hookBulletSystem()
    if typeof(getgc) ~= "function" then return false end
    
    local hooked = false
    for _, v in ipairs(getgc(true)) do
        if typeof(v) == "table" and rawget(v, "create") and rawget(v, "getTrueSpread") then
            v.GetTarget = function() return getAimTarget() end
            
            local oldCreate = v.create
            v.create = function(self, aimingMode, isAiming)
                local targetPart = nil
                if typeof(self.GetTarget) == "function" then
                    targetPart = self:GetTarget()
                else
                    targetPart = getAimTarget()
                end

                if targetPart and Menu_Config.SilentAim then
                    local origin = CurrentCamera.CFrame.Position
                    local targetPos = targetPart.Position
                    local direction = (targetPos - origin).Unit
                    
                    local hits = {}
                    local rangeLimit = self.Properties.Range or 500
                    local ignoreList = { LocalPlayer.Character, targetPart.Parent }
                    local lastPos = origin
                    
                    for step = 1, 3 do
                        local params = RaycastParams.new()
                        params.FilterType = Enum.RaycastFilterType.Exclude
                        params.FilterDescendantsInstances = ignoreList
                        params.CollisionGroup = "Bullet"
                        
                        local res = Workspace:Raycast(lastPos, direction * rangeLimit, params)
                        if res then
                            table.insert(hits, {
                                Instance = res.Instance,
                                Position = res.Position,
                                Normal = res.Normal,
                                Material = res.Material.Name,
                                Distance = (res.Position - lastPos).Magnitude,
                                Exit = false
                            })
                            table.insert(ignoreList, res.Instance)
                            lastPos = res.Position
                        else
                            break
                        end
                    end
                    
                    table.insert(hits, {
                        Instance = targetPart,
                        Position = targetPos,
                        Normal = Vector3.new(0, 1, 0),
                        Material = "Plastic",
                        Distance = (targetPos - lastPos).Magnitude,
                        Exit = false
                    })
                    
                    self.LastShotTick = tick()
                    return {
                        Distance = (targetPos - origin).Magnitude,
                        Origin = origin,
                        Direction = direction,
                        Hits = hits
                    }
                end
                return oldCreate(self, aimingMode, isAiming)
            end
            hooked = true
        end
    end
    return hooked
end

task.spawn(function()
    while true do
        local success = pcall(hookBulletSystem)
        if success then break end
        task.wait(1.5)
    end
end)

task.spawn(function()
    while not CharacterController do
        CharacterController = findCharacterController()
        task.wait(1.5)
    end
end)

-- ====================================================================================
-- FOV Circle Drawing
-- ====================================================================================
local fovCircle = Drawing.new("Circle")
fovCircle.Color = Menu_Config.FovCircleColor
fovCircle.Thickness = 1.5
fovCircle.NumSides = 64
fovCircle.Filled = false
fovCircle.Transparency = 0.8
fovCircle.Visible = true

local function updateFOVCircle()
    if not Menu_Config.AimEnabled then
        fovCircle.Visible = false
        return
    end
    local size = CurrentCamera.ViewportSize
    fovCircle.Position = size / 2
    fovCircle.Radius = (Menu_Config.MaxFOV / CurrentCamera.FieldOfView) * size.Y
    fovCircle.Color = Menu_Config.FovCircleColor
    fovCircle.Visible = true
end

-- ====================================================================================
-- Visual ESP Engine
-- ====================================================================================
local function cleanPlayerESP(player)
    if activeHighlights[player] then activeHighlights[player]:Destroy() activeHighlights[player] = nil end
    if activeBillboards[player] then activeBillboards[player]:Destroy() activeBillboards[player] = nil end
end

local function clearAllESP()
    for player, _ in pairs(activeHighlights) do cleanPlayerESP(player) end
    for player, _ in pairs(activeBillboards) do cleanPlayerESP(player) end
    for obj, tracker in pairs(worldTrackers) do
        if tracker then tracker:Destroy() end
        worldTrackers[obj] = nil
    end
end

local function applyPlayerESP(player)
    if player == LocalPlayer then return end
    
    local character = getActivePlayerModel(player)
    if not character then
        cleanPlayerESP(player)
        return
    end

    local isEnemyPlr = checkIsEnemy(player, false)
    local espColor = isEnemyPlr and Menu_Config.EnemyColor or Menu_Config.TeamColor
    local shouldShow = Menu_Config.EspEnabled and (isEnemyPlr or Menu_Config.HighlightTeammates)

    -- Highlights Chams
    if shouldShow then
        local highlight = activeHighlights[player]
        if not highlight or highlight.Parent ~= character then
            if highlight then highlight:Destroy() end
            highlight = Instance.new("Highlight")
            highlight.Name = "NEVERLOSE_Cham"
            highlight.FillTransparency = 0.75
            highlight.OutlineTransparency = 0.25
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Parent = character
            activeHighlights[player] = highlight
        end
        highlight.FillColor = espColor
        highlight.OutlineColor = espColor
    else
        if activeHighlights[player] then activeHighlights[player]:Destroy() activeHighlights[player] = nil end
    end

    -- Name/Health/Gun labels
    local head = character:FindFirstChild("Head") or character:FindFirstChildOfClass("BasePart")
    if head and shouldShow and (Menu_Config.ShowNames or Menu_Config.ShowDistance or Menu_Config.ShowHealth or Menu_Config.ShowWeapons) then
        local billboard = activeBillboards[player]
        if not billboard or billboard.Parent ~= head then
            if billboard then billboard:Destroy() end
            billboard = Instance.new("BillboardGui")
            billboard.Name = "NEVERLOSE_Info"
            billboard.Size = UDim2.new(0, 180, 0, 75)
            billboard.StudsOffset = Vector3.new(0, 3.5, 0)
            billboard.AlwaysOnTop = true
            
            local container = Instance.new("Frame")
            container.Size = UDim2.fromScale(1, 1)
            container.BackgroundTransparency = 1
            container.Parent = billboard
            
            billboard.Parent = head
            activeBillboards[player] = billboard
        end
        
        local container = billboard:FindFirstChildOfClass("Frame")
        if container then
            container:ClearAllChildren()
            local layout = Instance.new("UIListLayout")
            layout.SortOrder = Enum.SortOrder.LayoutOrder
            layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            layout.Padding = UDim.new(0, 2)
            layout.Parent = container

            -- Health Bar
            if Menu_Config.ShowHealth then
                local hum = character:FindFirstChildOfClass("Humanoid")
                local hp = hum and hum.Health or 100
                local maxHp = hum and hum.MaxHealth or 100
                
                local hpFrame = Instance.new("Frame")
                hpFrame.Size = UDim2.new(0, 60, 0, 4)
                hpFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
                hpFrame.BorderSizePixel = 0
                hpFrame.LayoutOrder = 1
                hpFrame.Parent = container
                
                local hpFill = Instance.new("Frame")
                hpFill.Size = UDim2.fromScale(math.clamp(hp/maxHp, 0, 1), 1)
                hpFill.BackgroundColor3 = Color3.fromRGB(50, 220, 110)
                hpFill.BorderSizePixel = 0
                hpFill.Parent = hpFrame
            end

            -- Name
            if Menu_Config.ShowNames then
                local lbl = Instance.new("TextLabel")
                lbl.BackgroundTransparency = 1
                lbl.Text = player.Name
                lbl.Font = Enum.Font.GothamBold
                lbl.TextSize = 10
                lbl.TextColor3 = espColor
                lbl.Size = UDim2.new(1, 0, 0, 12)
                lbl.LayoutOrder = 2
                lbl.Parent = container
            end

            -- Equipped Weapon
            if Menu_Config.ShowWeapons then
                local curEquipped = player:GetAttribute("CurrentEquipped")
                local weaponText = "Knife"
                if typeof(curEquipped) == "string" then
                    weaponText = curEquipped:match("\"Name\"%s*:%s*\"([^\"]+)\"") or "Rifle"
                end
                
                local lbl = Instance.new("TextLabel")
                lbl.BackgroundTransparency = 1
                lbl.Text = "[" .. weaponText:upper() .. "]"
                lbl.Font = Enum.Font.GothamSemibold
                lbl.TextSize = 9
                lbl.TextColor3 = Color3.fromRGB(180, 190, 205)
                lbl.Size = UDim2.new(1, 0, 0, 12)
                lbl.LayoutOrder = 3
                lbl.Parent = container
            end

            -- Distance
            if Menu_Config.ShowDistance then
                local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local root = character:FindFirstChild("HumanoidRootPart")
                if myRoot and root then
                    local dist = math.floor((myRoot.Position - root.Position).Magnitude)
                    local lbl = Instance.new("TextLabel")
                    lbl.BackgroundTransparency = 1
                    lbl.Text = tostring(dist) .. "M"
                    lbl.Font = Enum.Font.GothamMedium
                    lbl.TextSize = 9
                    lbl.TextColor3 = Color3.fromRGB(130, 140, 155)
                    lbl.Size = UDim2.new(1, 0, 0, 12)
                    lbl.LayoutOrder = 4
                    lbl.Parent = container
                end
            end
        end
    else
        if activeBillboards[player] then activeBillboards[player]:Destroy() activeBillboards[player] = nil end
    end
end

-- Planted C4 & Active Grenades Tracker
local function applyWorldEsp(instance, name, color)
    local tracker = worldTrackers[instance]
    if not tracker then
        tracker = Instance.new("BillboardGui")
        tracker.Name = "WorldEspTracker"
        tracker.Size = UDim2.new(0, 100, 0, 25)
        tracker.AlwaysOnTop = true
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.TextColor3 = color
        textLabel.TextStrokeTransparency = 0.3
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextSize = 9
        textLabel.Parent = tracker
        
        tracker.Parent = instance
        worldTrackers[instance] = tracker
    end
    
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local distance = myRoot and math.floor((myRoot.Position - instance.Position).Magnitude) or 0
    
    local label = tracker:FindFirstChildOfClass("TextLabel")
    if label then
        label.Text = name:upper() .. " [" .. distance .. "M]"
    end
end

local function updateWorldObjects()
    local debris = Workspace:FindFirstChild("Debris")
    if not debris then return end

    for _, child in ipairs(debris:GetChildren()) do
        if Menu_Config.C4_ESP and child:HasTag("C4") then
            applyWorldEsp(child, "Planted C4", Color3.fromRGB(255, 60, 60))
        elseif Menu_Config.Grenade_ESP and child.Name:find("Grenade") or child.Name:find("Flash") or child.Name:find("Smoke") then
            applyWorldEsp(child, "Active Utility", Color3.fromRGB(230, 210, 50))
        end
    end
end

-- ====================================================================================
-- Bunnyhop Mechanics
-- ====================================================================================
local function processBhop()
    if not Menu_Config.BhopEnabled or not CharacterController then return end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        -- Execute immediate jump kinematics via official controller pipeline
        pcall(CharacterController.jump)
    end
end

-- ====================================================================================
-- 3. Create Neverlose Window Instance
-- ====================================================================================
local Window = NeverloseLib:CreateWindow({
    Title = "NEVERLOSE.CC",
    Subtitle = "CS2 CHEAT SUITE"
})

-- Set Up Menu Tabs
local aimPage = Window:CreateTab("Aimbot")
local rageCard = aimPage:CreateCard("Ragebot Settings", "Left")
rageCard:AddToggle("Enable Silent Aim", Menu_Config.AimEnabled, function(state) Menu_Config.AimEnabled = state end)
rageCard:AddToggle("Autowall Penetration", Menu_Config.Autowall, function(state) Menu_Config.Autowall = state end)
rageCard:AddKeybind("Aim Action Bind", Menu_Config.AimBind, function(key) Menu_Config.AimBind = key end)

local selectCard = aimPage:CreateCard("Selection Rules", "Right")
selectCard:AddDropdown("Target Hitbox", {"Head", "HumanoidRootPart", "Random"}, Menu_Config.TargetPart, function(val) Menu_Config.TargetPart = val end)
selectCard:AddSlider("Aimbot FOV Range", 2, 60, Menu_Config.MaxFOV, function(val) Menu_Config.MaxFOV = val end)

local visualPage = Window:CreateTab("Visuals")
local espCard = visualPage:CreateCard("Active ESP Players", "Left")
espCard:AddToggle("Master ESP Enable", Menu_Config.EspEnabled, function(state) Menu_Config.EspEnabled = state end)
espCard:AddToggle("Show Player Names", Menu_Config.ShowNames, function(state) Menu_Config.ShowNames = state end)
espCard:AddToggle("Display Health Bars", Menu_Config.ShowHealth, function(state) Menu_Config.ShowHealth = state end)
espCard:AddToggle("Reveal Active Weapon", Menu_Config.ShowWeapons, function(state) Menu_Config.ShowWeapons = state end)
espCard:AddToggle("Render Distance Metres", Menu_Config.ShowDistance, function(state) Menu_Config.ShowDistance = state end)

local worldCard = visualPage:CreateCard("Active ESP World", "Right")
worldCard:AddToggle("Planted C4 Esp", Menu_Config.C4_ESP, function(state) Menu_Config.C4_ESP = state end)
worldCard:AddToggle("Grenades In-Flight Esp", Menu_Config.Grenade_ESP, function(state) Menu_Config.Grenade_ESP = state end)

local themeCard = visualPage:CreateCard("ESP Theme Colors", "Right")
themeCard:AddColorPicker("Allied Chams Color", Menu_Config.TeamColor, function(color) Menu_Config.TeamColor = color end)
themeCard:AddColorPicker("Hostile Chams Color", Menu_Config.EnemyColor, function(color) Menu_Config.EnemyColor = color end)

local miscPage = Window:CreateTab("Miscellaneous")
local moveCard = miscPage:CreateCard("Movement Customization", "Left")
moveCard:AddToggle("Bunnyhop (Bhop)", Menu_Config.BhopEnabled, function(state) Menu_Config.BhopEnabled = state end)

-- Handle Keybind states
local bindConnection = UserInputService.InputBegan:Connect(function(input, processed)
    if not processed then
        if input.KeyCode == Menu_Config.AimBind then
            Menu_Config.IsAimActive = not Menu_Config.IsAimActive
        end
    end
end)

-- Master Loop
local updateConnection = RunService.RenderStepped:Connect(function()
    pcall(processBhop)
    updateFOVCircle()

    if Menu_Config.EspEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            pcall(applyPlayerESP, player)
        end
        pcall(updateWorldObjects)
    else
        clearAllESP()
    end
end)

Players.PlayerRemoving:Connect(cleanPlayerESP)

-- Terminate connection cleanly on UI close
NeverloseLib.ScreenGui.AncestryChanged:Connect(function(_, parent)
    if not parent then
        if updateConnection then updateConnection:Disconnect() end
        if bindConnection then bindConnection:Disconnect() end
        fovCircle:Destroy()
        clearAllESP()
    end
end)
