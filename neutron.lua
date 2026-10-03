-- UNIVERSAL SILENT AIM | Decay (mkrejd)
-- Поддержка: Raycast, FindPartOnRay, FindPartOnRayWithWhitelist, FindPartOnRayWithIgnoreList, Mouse.Hit/Target

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Настройки
local Config = {
    Enabled = false,
    TeamCheck = false,
    VisibleCheck = false,
    TargetPart = "Head",  -- "Head" / "HumanoidRootPart" / "Random"
    FOV = 150,
    HitChance = 100,
    Method = "Mouse.Hit/Target"  -- Raycast / FindPartOnRayWithIgnoreList / Mouse.Hit/Target
}

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 60
FOVCircle.Radius = Config.FOV
FOVCircle.Filled = false
FOVCircle.Color = Color3.fromRGB(255, 60, 60)
FOVCircle.Transparency = 0.7
FOVCircle.Visible = false

-- Выбор цели
local SelectedPart = nil

local function IsVisible(Player, PartName)
    local character = Player.Character
    local localChar = LocalPlayer.Character
    if not character or not localChar then return false end
    
    local target = character:FindFirstChild(PartName) or character:FindFirstChild("HumanoidRootPart")
    if not target then return false end
    
    local parts = Camera:GetPartsObscuringTarget({target.Position}, {localChar, character})
    return #parts == 0
end

local function FindTarget()
    local best, bestDist = nil, math.huge
    local mousePos = UserInputService:GetMouseLocation()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if Config.TeamCheck and player.Team == LocalPlayer.Team then continue end
        if not player.Character then continue end
        
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        
        if Config.VisibleCheck and not IsVisible(player, Config.TargetPart) then continue end
        
        local part = player.Character:FindFirstChild(Config.TargetPart)
        if not part then continue end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end
        
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        if dist <= Config.FOV and dist < bestDist then
            best = part
            bestDist = dist
        end
    end
    
    return best
end

-- Хук на Mouse.Hit / Mouse.Target
local mt = getrawmetatable(game)
local oldIndex = mt.__index
setreadonly(mt, false)

mt.__index = function(self, key)
    if not checkcaller() and Config.Enabled and self == Mouse then
        if (key == "Hit" or key == "Target") and SelectedPart then
            if key == "Hit" then
                return SelectedPart.CFrame
            else
                return SelectedPart
            end
        end
    end
    return oldIndex(self, key)
end

setreadonly(mt, true)

-- Хук на Raycast методы (FindPartOnRayWithIgnoreList и т.д.)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = function(self, ...)
    local method = getnamecallmethod()
    
    if not checkcaller() and Config.Enabled and SelectedPart then
        -- Raycast
        if method == "Raycast" and self == Workspace then
            local args = {...}
            local origin = args[1]
            local direction = args[2]
            if origin and direction then
                local newDir = (SelectedPart.Position - origin).Unit * direction.Magnitude
                return oldNamecall(self, origin, newDir, select(3, ...))
            end
        end
        
        -- FindPartOnRayWithIgnoreList / Whitelist
        if (method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRayWithWhitelist") and self == Workspace then
            local args = {...}
            local ray = args[1]
            if ray then
                local newRay = Ray.new(ray.Origin, (SelectedPart.Position - ray.Origin).Unit * ray.Direction.Magnitude)
                return oldNamecall(self, newRay, select(2, ...))
            end
        end
    end
    
    return oldNamecall(self, ...)
end

setreadonly(mt, true)

-- Главный цикл
RunService.RenderStepped:Connect(function()
    if Config.Enabled then
        SelectedPart = FindTarget()
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOVCircle.Radius = Config.FOV
        FOVCircle.Visible = true
    else
        SelectedPart = nil
        FOVCircle.Visible = false
    end
end)

-- Включение/выключение (привязка к клавише или через GUI)
-- Config.Enabled = true  -- раскомментируй для автостарта

print("Universal Silent Aim loaded for Decay!")
