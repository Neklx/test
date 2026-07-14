-- ====================================================================================
-- NEVERLOSE.CC - STANDALONE HUB BOOTSTRAPPER (Main.lua)
-- ====================================================================================

-- 1. Import Standalone UI Library
local NeverloseLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Neklx/test/main/NeverloseLib.lua"))()

-- 2. Import External Cheat Modules
local Aimbot = loadstring(game:HttpGet("https://raw.githubusercontent.com/Neklx/test/main/Aimbot.lua"))()
local Visuals = loadstring(game:HttpGet("https://raw.githubusercontent.com/Neklx/test/main/Visuals.lua"))()
local Movement = loadstring(game:HttpGet("https://raw.githubusercontent.com/Neklx/test/main/Movement.lua"))()

-- Initialize Movement Controller
Movement:Initialize()

-- 3. Create Neverlose Window Instance
local Window = NeverloseLib:CreateWindow({
    Title = "NEVERLOSE.CC",
    Subtitle = "CS2 CHEAT SUITE"
})

-- 4. Set Up Menu Navigation Tabs
local aimPage = Window:CreateTab("Aimbot")
local rageCard = aimPage:CreateCard("Ragebot Settings", "Left")
rageCard:AddToggle("Enable Silent Aim", Aimbot.Enabled, function(state) Aimbot.Enabled = state end)
rageCard:AddToggle("Autowall Penetration", Aimbot.Autowall, function(state) Aimbot.Autowall = state end)
rageCard:AddKeybind("Aim Action Bind", Aimbot.AimBind, function(key) Aimbot.AimBind = key end)

local selectCard = aimPage:CreateCard("Selection Rules", "Right")
selectCard:AddDropdown("Target Hitbox", {"Head", "HumanoidRootPart", "Random"}, Aimbot.TargetPart, function(val) Aimbot.TargetPart = val end)
selectCard:AddSlider("Aimbot FOV Range", 2, 60, Aimbot.MaxFOV, function(val) Aimbot.MaxFOV = val end)

local visualPage = Window:CreateTab("Visuals")
local espCard = visualPage:CreateCard("Active ESP Players", "Left")
espCard:AddToggle("Master ESP Enable", Visuals.Enabled, function(state) Visuals.Enabled = state end)
espCard:AddToggle("Show Player Names", Visuals.ShowNames, function(state) Visuals.ShowNames = state end)
espCard:AddToggle("Display Health Bars", Visuals.ShowHealth, function(state) Visuals.ShowHealth = state end)
espCard:AddToggle("Reveal Active Weapon", Visuals.ShowWeapons, function(state) Visuals.ShowWeapons = state end)
espCard:AddToggle("Render Distance Metres", Visuals.ShowDistance, function(state) Visuals.ShowDistance = state end)

local worldCard = visualPage:CreateCard("Active ESP World", "Right")
worldCard:AddToggle("Planted C4 Esp", Visuals.C4_ESP, function(state) Visuals.C4_ESP = state end)
worldCard:AddToggle("Grenades In-Flight Esp", Visuals.Grenade_ESP, function(state) Visuals.Grenade_ESP = state end)

local themeCard = visualPage:CreateCard("ESP Theme Colors", "Right")
themeCard:AddColorPicker("Allied Chams Color", Visuals.TeamColor, function(color) Visuals.TeamColor = color end)
themeCard:AddColorPicker("Hostile Chams Color", Visuals.EnemyColor, function(color) Visuals.EnemyColor = color end)

local miscPage = Window:CreateTab("Miscellaneous")
local moveCard = miscPage:CreateCard("Movement Customization", "Left")
moveCard:AddToggle("Bunnyhop (Bhop)", Movement.BhopEnabled, function(state) Movement.BhopEnabled = state end)

-- 5. Master Render Stepped Thread
local RunService = game:GetService("RunService")
local updateConnection = RunService.RenderStepped:Connect(function()
    -- Process Bunnyhop calculations
    if Movement.BhopEnabled then
        pcall(function() Movement:ProcessBhop() end)
    end

    -- Process ESP calculations
    if Visuals.Enabled then
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            pcall(function() Visuals:ApplyESP(player) end)
        end
        pcall(function() Visuals:UpdateWorldObjects() end)
    else
        Visuals:ClearAll()
    end
end)

-- Terminate connection cleanly on UI close
NeverloseLib.ScreenGui.AncestryChanged:Connect(function(_, parent)
    if not parent then
        if updateConnection then updateConnection:Disconnect() end
        Visuals:ClearAll()
    end
end)
