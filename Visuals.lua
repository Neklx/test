-- ====================================================================================
-- NEVERLOSE.CC - VISUALS MODULE (Visuals.lua)
-- ====================================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local Visuals = {
    Enabled = true,
    TeamCheck = true,
    ShowNames = true,
    ShowWeapons = true,
    ShowHealth = true,
    ShowDistance = true,
    HighlightTeammates = false,
    EnemyColor = Color3.fromRGB(255, 45, 85),
    TeamColor = Color3.fromRGB(0, 190, 255)
}

local activeHighlights = {}
local activeBillboards = {}

local function getPlayerModel(player)
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

local function checkIsEnemy(player)
    if not Visuals.TeamCheck then return true end
    local myTeam = LocalPlayer:GetAttribute("Team")
    local playerTeam = player:GetAttribute("Team")
    if playerTeam == nil or myTeam == nil then
        return player.Team ~= LocalPlayer.Team
    end
    return playerTeam ~= myTeam
end

function Visuals:CleanESP(player)
    if activeHighlights[player] then activeHighlights[player]:Destroy() activeHighlights[player] = nil end
    if activeBillboards[player] then activeBillboards[player]:Destroy() activeBillboards[player] = nil end
end

function Visuals:ApplyESP(player)
    if player == LocalPlayer then return end
    
    local character = getPlayerModel(player)
    if not character then
        self:CleanESP(player)
        return
    end

    local isEnemyPlr = checkIsEnemy(player)
    local espColor = isEnemyPlr and self.EnemyColor or self.TeamColor
    local shouldShow = self.Enabled and (isEnemyPlr or self.HighlightTeammates)

    -- Highlights/Chams
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

    -- Overhead labels
    local head = character:FindFirstChild("Head") or character:FindFirstChildOfClass("BasePart")
    if head and shouldShow and (self.ShowNames or self.ShowDistance or self.ShowHealth or self.ShowWeapons) then
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
            if self.ShowHealth then
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
            if self.ShowNames then
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
            if self.ShowWeapons then
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
            if self.ShowDistance then
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

function Visuals:ClearAll()
    for player, _ in pairs(activeHighlights) do self:CleanESP(player) end
    for player, _ in pairs(activeBillboards) do self:CleanESP(player) end
end

return Visuals
