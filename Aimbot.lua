-- ====================================================================================
-- NEVERLOSE.CC - AIMBOT MODULE (Aimbot.lua)
-- ====================================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CurrentCamera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Aimbot = {
    Enabled = true,
    SilentAim = true,
    Autowall = true,
    TargetPart = "Head",
    MaxFOV = 15,
    TeamCheck = true,
    IsAimActive = true
}

-- Custom target model resolver
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
    if not Aimbot.TeamCheck then return true end
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
    if not Aimbot.Autowall then return part end

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
function Aimbot:GetTarget()
    if not Aimbot.Enabled or not Aimbot.IsAimActive then return nil end
    
    local bestTarget = nil
    local minimumDistance = math.huge
    local screenCenter = CurrentCamera.ViewportSize / 2

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and checkIsEnemy(player) then
            local model = getPlayerModel(player)
            if model then
                local chosenPartName = Aimbot.TargetPart
                if chosenPartName == "Random" then
                    chosenPartName = (math.random() > 0.5) and "Head" or "HumanoidRootPart"
                end
                
                local targetPart = getShootablePart(model, chosenPartName)
                if targetPart then
                    local screenPos, onScreen = CurrentCamera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        local angle = (distance / CurrentCamera.ViewportSize.Y) * CurrentCamera.FieldOfView
                        
                        if angle <= Aimbot.MaxFOV and distance < minimumDistance then
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

-- Inject hook into standard Components.Bullet trajectories
function Aimbot:HookSystem()
    if typeof(getgc) ~= "function" then return false end
    
    for _, v in ipairs(getgc(true)) do
        if typeof(v) == "table" and rawget(v, "create") and rawget(v, "getTrueSpread") then
            local oldCreate = v.create
            v.create = function(self, aimingMode, isAiming)
                local targetPart = self:GetTarget() -- Target redirection check
                if targetPart and Aimbot.SilentAim then
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
            return true
        end
    end
    return false
end

-- Attach the target verification hook directly
v.GetTarget = function() return Aimbot:GetTarget() end

return Aimbot
