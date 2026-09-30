-- NEUTRON | Deagle Duels
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local IMAGE_URL = "rbxassetid://138823883244540"
local TG_LINK = "t.me/neutron_client"

local SCALE = 1
local function getScale()
    local vp = Camera.ViewportSize
    local diag = math.sqrt(vp.X * vp.X + vp.Y * vp.Y)
    local s = diag / (1920 * 1.4)
    if s < 1 then s = 1 end
    if s > 3.5 then s = 3.5 end
    return s
end
SCALE = getScale()
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function() SCALE = getScale() end)

local Config = {
    ESP = {
        Enabled = false,
        Box = true,
        Name = false,
        Distance = false,
        Health = false,
        TeamCheck = true,
        MaxDistance = 500,
    },
    Silent = {
        Enabled = false,
        TargetPart = "Head",
        TeamCheck = true,
        VisibleOnly = false,
        FOV = 150,
    },
}

local ESPObjects = {}
local FOVCircle = nil
local Open = true
local CompletelyClosed = false

local function isTeammate(player)
    if not player or player == LocalPlayer then return true end
    local myTeam = LocalPlayer.Team
    if myTeam and player.Team and player.Team == myTeam then return true end
    local myColor = LocalPlayer.TeamColor
    if myColor and player.TeamColor and player.TeamColor == myColor then return true end
    return false
end

local function resolveTargetPart(char, name)
    if not char then return nil end
    if name == "Head" then
        return char:FindFirstChild("Head")
    elseif name == "Torso" then
        return char:FindFirstChild("UpperTorso")
            or char:FindFirstChild("Torso")
            or char:FindFirstChild("LowerTorso")
            or char:FindFirstChild("HumanoidRootPart")
    end
    return char:FindFirstChild(name)
end

local function makeLine()
    local l = Drawing.new("Line")
    l.Thickness = math.max(1, math.floor(1.5 * SCALE))
    l.Color = Color3.fromRGB(255,255,255)
    l.Transparency = 1
    l.Visible = false
    return l
end

local function createESP(player)
    if player == LocalPlayer then return end
    if ESPObjects[player] then return end
    local d = {}
    d.Box = Drawing.new("Square")
    d.Box.Thickness = math.max(1, 1.5*SCALE)
    d.Box.Color = Color3.fromRGB(0,255,200)
    d.Box.Filled = false
    d.Box.Transparency = 1
    d.Box.Visible = false
    d.Name = Drawing.new("Text")
    d.Name.Size = math.floor(14*SCALE)
    d.Name.Center = true
    d.Name.Outline = true
    d.Name.Color = Color3.fromRGB(255,255,255)
    d.Name.Visible = false
    d.Distance = Drawing.new("Text")
    d.Distance.Size = math.floor(13*SCALE)
    d.Distance.Center = true
    d.Distance.Outline = true
    d.Distance.Color = Color3.fromRGB(200,200,200)
    d.Distance.Visible = false
    d.HealthBG = makeLine()
    d.HealthBG.Thickness = math.max(2, 3*SCALE)
    d.HealthBG.Color = Color3.fromRGB(0,0,0)
    d.HealthBar = makeLine()
    d.HealthBar.Thickness = math.max(2, 3*SCALE)
    d.HealthBar.Color = Color3.fromRGB(0,255,0)
    ESPObjects[player] = d
end

local function removeESP(player)
    local o = ESPObjects[player]
    if not o then return end
    for _, v in pairs(o) do
        if typeof(v) == "userdata" then pcall(function() v:Remove() end) end
    end
    ESPObjects[player] = nil
end

local function hideAll(o)
    o.Box.Visible = false
    o.Name.Visible = false
    o.Distance.Visible = false
    o.HealthBG.Visible = false
    o.HealthBar.Visible = false
end

local function getBodyFrame(char)
    local h = char:FindFirstChild("Head")
    local r = char:FindFirstChild("HumanoidRootPart")
    if not h or not r then return nil end
    local hp, hon = Camera:WorldToViewportPoint(h.Position)
    if not hon then return nil end
    local lowY = nil
    for _, n in ipairs({"LeftFoot","RightFoot","LeftLowerLeg","RightLowerLeg","LeftLeg","RightLeg","LowerTorso","Torso","HumanoidRootPart"}) do
        local p = char:FindFirstChild(n)
        if p then
            local sp, on = Camera:WorldToViewportPoint(p.Position)
            if on and (lowY == nil or sp.Y > lowY) then lowY = sp.Y end
        end
    end
    if not lowY then
        local sp, on = Camera:WorldToViewportPoint(r.Position)
        if on then lowY = sp.Y else return nil end
    end
    local hgt = math.abs(lowY - hp.Y)
    if hgt < 4 then hgt = 6*SCALE end
    local w = hgt * 0.55
    local cx = hp.X
    return {
        top = Vector2.new(cx - w/2, hp.Y),
        bottom = Vector2.new(cx + w/2, hp.Y + hgt),
        centerX = cx,
    }
end

local function updateESP()
    for p, o in pairs(ESPObjects) do
        if not Config.ESP.Enabled then hideAll(o); continue end
        local c = p.Character
        if not c then hideAll(o); continue end
        local r = c:FindFirstChild("HumanoidRootPart")
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not r or not hum or hum.Health <= 0 then hideAll(o); continue end
        if Config.ESP.TeamCheck and isTeammate(p) then hideAll(o); continue end
        local dist = (Camera.CFrame.Position - r.Position).Magnitude
        if dist > Config.ESP.MaxDistance then hideAll(o); continue end
        local f = getBodyFrame(c)
        if f then
            local t = f.top
            local b = f.bottom
            if Config.ESP.Box then
                o.Box.Size = Vector2.new(b.X - t.X, b.Y - t.Y)
                o.Box.Position = t
                o.Box.Visible = true
            else o.Box.Visible = false end
            if Config.ESP.Name then
                o.Name.Text = p.Name
                o.Name.Position = Vector2.new(f.centerX, t.Y - 20*SCALE)
                o.Name.Visible = true
            else o.Name.Visible = false end
            if Config.ESP.Distance then
                o.Distance.Text = string.format("[%d m]", math.floor(dist))
                o.Distance.Position = Vector2.new(f.centerX, b.Y + 2*SCALE)
                o.Distance.Visible = true
            else o.Distance.Visible = false end
            if Config.ESP.Health then
                local pc = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                local bh = b.Y - t.Y
                local off = 6*SCALE
                o.HealthBG.From = Vector2.new(t.X - off, t.Y)
                o.HealthBG.To = Vector2.new(t.X - off, b.Y)
                o.HealthBG.Visible = true
                o.HealthBar.From = Vector2.new(t.X - off, b.Y - bh * pc)
                o.HealthBar.To = Vector2.new(t.X - off, b.Y)
                o.HealthBar.Color = Color3.fromRGB(math.floor(255*(1-pc)), math.floor(255*pc), 0)
                o.HealthBar.Visible = true
            else
                o.HealthBar.Visible = false
                o.HealthBG.Visible = false
            end
        else
            hideAll(o)
        end
    end
end

local SilentTarget = nil

local function getVisibleCheck(targetChar)
    if not Config.Silent.VisibleOnly then return true end
    local myChar = LocalPlayer.Character
    if not myChar then return false end
    local myHead = myChar:FindFirstChild("Head") or myChar:FindFirstChild("HumanoidRootPart")
    if not myHead then return false end
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {myChar, targetChar, Camera}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.IgnoreWater = true
    local points = {}
    for _, n in ipairs({"Head","UpperTorso","Torso","LowerTorso","HumanoidRootPart"}) do
        local p = targetChar:FindFirstChild(n)
        if p then table.insert(points, p.Position) end
    end
    if #points == 0 then return false end
    for _, tp in ipairs(points) do
        if Workspace:Raycast(myHead.Position, tp - myHead.Position, rayParams) == nil then
            return true
        end
    end
    return false
end

local function findSilentTarget()
    local closest, shortest = nil, math.huge
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    for _, p in pairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        local c = p.Character
        if not c then continue end
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        if Config.Silent.TeamCheck and isTeammate(p) then continue end
        local part = resolveTargetPart(c, Config.Silent.TargetPart)
        if not part then continue end
        if not getVisibleCheck(c) then continue end
        local sp, on = Camera:WorldToViewportPoint(part.Position)
        if not on then continue end
        local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
        if d < shortest and d <= Config.Silent.FOV then
            shortest = d
            closest = part
        end
    end
    return closest
end

local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldIndex = mt.__index
mt.__index = newcclosure(function(self, key)
    if not checkcaller() and Config.Silent.Enabled and self == Mouse then
        if key == "Hit" or key == "Target" then
            if SilentTarget then return SilentTarget end
        end
    end
    return oldIndex(self, key)
end)
setreadonly(mt, true)

local function createFOVCircle()
    if FOVCircle then FOVCircle:Remove() end
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = math.max(1, 1.5*SCALE)
    FOVCircle.NumSides = 60
    FOVCircle.Radius = Config.Silent.FOV
    FOVCircle.Filled = false
    FOVCircle.Color = Color3.fromRGB(255, 60, 60)
    FOVCircle.Transparency = 0.7
    FOVCircle.Visible = false
end
createFOVCircle()

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NeutronDD"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui")

local ToggleBtn = Instance.new("ImageButton")
ToggleBtn.Size = UDim2.new(0, 46, 0, 46)
ToggleBtn.Position = UDim2.new(0, 12, 0.4, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(15,15,20)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Image = IMAGE_URL
ToggleBtn.ScaleType = Enum.ScaleType.Fit
ToggleBtn.AutoButtonColor = false
ToggleBtn.Active = true
ToggleBtn.Parent = ScreenGui
local tbc = Instance.new("UICorner")
tbc.CornerRadius = UDim.new(1,0)
tbc.Parent = ToggleBtn
local tbs = Instance.new("UIStroke")
tbs.Color = Color3.fromRGB(0,255,200)
tbs.Thickness = 1.5
tbs.Transparency = 0.3
tbs.Parent = ToggleBtn

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 260, 0, 330)
Main.Position = UDim2.new(0.5, -130, 0.5, -165)
Main.BackgroundColor3 = Color3.fromRGB(15,15,20)
Main.BorderSizePixel = 0
Main.Active = true
Main.ClipsDescendants = true
Main.Parent = ScreenGui
local mc = Instance.new("UICorner")
mc.CornerRadius = UDim.new(0,14)
mc.Parent = Main
local ms = Instance.new("UIStroke")
ms.Color = Color3.fromRGB(0,255,200)
ms.Thickness = 1.5
ms.Transparency = 0.4
ms.Parent = Main

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Color3.fromRGB(22,22,30)
TopBar.BorderSizePixel = 0
TopBar.Active = true
TopBar.Parent = Main
local tc2 = Instance.new("UICorner")
tc2.CornerRadius = UDim.new(0,14)
tc2.Parent = TopBar
local tf = Instance.new("Frame")
tf.Size = UDim2.new(1, 0, 0, 14)
tf.Position = UDim2.new(0, 0, 1, -14)
tf.BackgroundColor3 = Color3.fromRGB(22,22,30)
tf.BorderSizePixel = 0
tf.Parent = TopBar

local Ttl = Instance.new("TextLabel")
Ttl.Size = UDim2.new(1,-160,1,0)
Ttl.Position = UDim2.new(0,42,0,0)
Ttl.BackgroundTransparency = 1
Ttl.Text = "NEUTRON | DD"
Ttl.TextColor3 = Color3.fromRGB(0,255,200)
Ttl.TextSize = 15
Ttl.Font = Enum.Font.GothamBold
Ttl.TextXAlignment = Enum.TextXAlignment.Left
Ttl.Parent = TopBar

local CB = Instance.new("TextButton")
CB.Size = UDim2.new(0,30,0,30)
CB.Position = UDim2.new(1,-36,0.5,-15)
CB.BackgroundTransparency = 1
CB.Text = "X"
CB.TextColor3 = Color3.fromRGB(255,90,90)
CB.TextSize = 24
CB.Font = Enum.Font.GothamBold
CB.AutoButtonColor = false
CB.Parent = TopBar

local MB = Instance.new("TextButton")
MB.Size = UDim2.new(0,30,0,30)
MB.Position = UDim2.new(1,-84,0.5,-15)
MB.BackgroundTransparency = 1
MB.Text = "-"
MB.TextColor3 = Color3.fromRGB(200,200,200)
MB.TextSize = 24
MB.Font = Enum.Font.GothamBold
MB.AutoButtonColor = false
MB.Parent = TopBar

local TabsFrame = Instance.new("Frame")
TabsFrame.Size = UDim2.new(0, 72, 1, -50)
TabsFrame.Position = UDim2.new(0, 6, 0, 46)
TabsFrame.BackgroundColor3 = Color3.fromRGB(18,18,24)
TabsFrame.BorderSizePixel = 0
TabsFrame.Parent = Main
local tfc = Instance.new("UICorner")
tfc.CornerRadius = UDim.new(0,10)
tfc.Parent = TabsFrame
local TL = Instance.new("UIListLayout")
TL.Padding = UDim.new(0, 4)
TL.SortOrder = Enum.SortOrder.LayoutOrder
TL.HorizontalAlignment = Enum.HorizontalAlignment.Center
TL.Parent = TabsFrame
local TPD = Instance.new("UIPadding")
TPD.PaddingTop = UDim.new(0, 8)
TPD.Parent = TabsFrame

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -88, 1, -50)
Content.Position = UDim2.new(0, 82, 0, 46)
Content.BackgroundTransparency = 1
Content.ClipsDescendants = true
Content.Parent = Main

local bDr = false
local bDS, bSP = nil, nil
local bMv = false
local function bUpd(i)
    local d = i.Position - bDS
    if math.abs(d.X) > 5 or math.abs(d.Y) > 5 then bMv = true end
    ToggleBtn.Position = UDim2.new(bSP.X.Scale, bSP.X.Offset + d.X, bSP.Y.Scale, bSP.Y.Offset + d.Y)
end
ToggleBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        bDr = true; bMv = false; bDS = i.Position; bSP = ToggleBtn.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if bDr and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then bUpd(i) end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then bDr = false end
end)

local mDr = false
local mDS, mSP = nil, nil
TopBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        mDr = true; mDS = i.Position; mSP = Main.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if mDr and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - mDS
        Main.Position = UDim2.new(mSP.X.Scale, mSP.X.Offset + d.X, mSP.Y.Scale, mSP.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then mDr = false end
end)

local function mkTab(n)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,-10,0,34)
    b.BackgroundColor3 = Color3.fromRGB(25,25,33)
    b.BorderSizePixel = 0
    b.Text = n
    b.TextColor3 = Color3.fromRGB(200,200,200)
    b.TextSize = 13
    b.Font = Enum.Font.GothamBold
    b.AutoButtonColor = false
    b.Parent = TabsFrame
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,8)
    c.Parent = b
    local pg = Instance.new("ScrollingFrame")
    pg.Size = UDim2.new(1,0,1,0)
    pg.BackgroundTransparency = 1
    pg.BorderSizePixel = 0
    pg.ScrollBarThickness = 3
    pg.ScrollBarImageColor3 = Color3.fromRGB(0,255,200)
    pg.CanvasSize = UDim2.new(0,0,0,0)
    pg.AutomaticCanvasSize = Enum.AutomaticSize.Y
    pg.Visible = false
    pg.Parent = Content
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0,5)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent = pg
    local pd = Instance.new("UIPadding")
    pd.PaddingTop = UDim.new(0,4)
    pd.PaddingRight = UDim.new(0,6)
    pd.PaddingBottom = UDim.new(0,4)
    pd.Parent = pg
    return {B = b, P = pg}
end

local V = mkTab("ESP")
local S = mkTab("SILENT")
local MS = mkTab("MISC")
local Tabs = {V, S, MS}

local function selTab(t)
    for _, x in pairs(Tabs) do
        x.P.Visible = false
        TweenService:Create(x.B, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(25,25,33),
            TextColor3 = Color3.fromRGB(200,200,200)
        }):Play()
    end
    t.P.Visible = true
    TweenService:Create(t.B, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(0,255,200),
        TextColor3 = Color3.fromRGB(15,15,20)
    }):Play()
end
V.B.MouseButton1Click:Connect(function() selTab(V) end)
S.B.MouseButton1Click:Connect(function() selTab(S) end)
MS.B.MouseButton1Click:Connect(function() selTab(MS) end)
selTab(V)

local function addTgl(parent, text, default, cb)
    local h = Instance.new("Frame")
    h.Size = UDim2.new(1,0,0,34)
    h.BackgroundColor3 = Color3.fromRGB(22,22,30)
    h.BorderSizePixel = 0
    h.Parent = parent.P
    local hc = Instance.new("UICorner")
    hc.CornerRadius = UDim.new(0,8)
    hc.Parent = h
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,-60,1,0)
    l.Position = UDim2.new(0,10,0,0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(220,220,220)
    l.TextSize = 12
    l.Font = Enum.Font.Gotham
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = h
    local tg = Instance.new("TextButton")
    tg.Size = UDim2.new(0,40,0,20)
    tg.Position = UDim2.new(1,-50,0.5,-10)
    tg.BackgroundColor3 = Color3.fromRGB(40,40,50)
    tg.BorderSizePixel = 0
    tg.Text = ""
    tg.AutoButtonColor = false
    tg.Parent = h
    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(1,0)
    tc.Parent = tg
    local k = Instance.new("Frame")
    k.Size = UDim2.new(0,16,0,16)
    k.Position = UDim2.new(0,2,0.5,-8)
    k.BackgroundColor3 = Color3.fromRGB(200,200,200)
    k.BorderSizePixel = 0
    k.Parent = tg
    local kc = Instance.new("UICorner")
    kc.CornerRadius = UDim.new(1,0)
    kc.Parent = k
    local st = default or false
    local function rf()
        if st then
            TweenService:Create(tg, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0,255,200)}):Play()
            TweenService:Create(k, TweenInfo.new(0.15), {
                Position = UDim2.new(1,-18,0.5,-8),
                BackgroundColor3 = Color3.fromRGB(15,15,20)
            }):Play()
        else
            TweenService:Create(tg, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40,40,50)}):Play()
            TweenService:Create(k, TweenInfo.new(0.15), {
                Position = UDim2.new(0,2,0.5,-8),
                BackgroundColor3 = Color3.fromRGB(200,200,200)
            }):Play()
        end
    end
    rf()
    tg.MouseButton1Click:Connect(function()
        st = not st
        rf()
        if cb then cb(st) end
    end)
end

local function addSld(parent, text, mx, mn, df, cb)
    local h = Instance.new("Frame")
    h.Size = UDim2.new(1,0,0,48)
    h.BackgroundColor3 = Color3.fromRGB(22,22,30)
    h.BorderSizePixel = 0
    h.Parent = parent.P
    local hc = Instance.new("UICorner")
    hc.CornerRadius = UDim.new(0,8)
    hc.Parent = h
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,-60,0,20)
    l.Position = UDim2.new(0,10,0,4)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(220,220,220)
    l.TextSize = 12
    l.Font = Enum.Font.Gotham
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = h
    local vl = Instance.new("TextLabel")
    vl.Size = UDim2.new(0,50,0,20)
    vl.Position = UDim2.new(1,-56,0,4)
    vl.BackgroundTransparency = 1
    vl.Text = tostring(df)
    vl.TextColor3 = Color3.fromRGB(0,255,200)
    vl.TextSize = 12
    vl.Font = Enum.Font.GothamBold
    vl.TextXAlignment = Enum.TextXAlignment.Right
    vl.Parent = h
    local b = Instance.new("Frame")
    b.Size = UDim2.new(1,-20,0,6)
    b.Position = UDim2.new(0,10,0,30)
    b.BackgroundColor3 = Color3.fromRGB(40,40,50)
    b.BorderSizePixel = 0
    b.Parent = h
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(1,0)
    bc.Parent = b
    local f = Instance.new("Frame")
    f.Size = UDim2.new((df-mn)/(mx-mn),0,1,0)
    f.BackgroundColor3 = Color3.fromRGB(0,255,200)
    f.BorderSizePixel = 0
    f.Parent = b
    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(1,0)
    fc.Parent = f
    local dr = false
    local function upd(i)
        local r = math.clamp((i.Position.X - b.AbsolutePosition.X) / b.AbsoluteSize.X, 0, 1)
        local c = math.floor(mn + (mx-mn)*r + 0.5)
        vl.Text = tostring(c)
        f.Size = UDim2.new(r,0,1,0)
        if cb then cb(c) end
    end
    b.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dr = true; upd(i)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dr and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then upd(i) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dr = false end
    end)
end

local function addDd(parent, text, opts, cb)
    local h = Instance.new("Frame")
    h.Size = UDim2.new(1,0,0,34)
    h.BackgroundColor3 = Color3.fromRGB(22,22,30)
    h.BorderSizePixel = 0
    h.ClipsDescendants = true
    h.Parent = parent.P
    local hc = Instance.new("UICorner")
    hc.CornerRadius = UDim.new(0,8)
    hc.Parent = h
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,0,0,34)
    b.BackgroundTransparency = 1
    b.Text = text .. ": " .. opts[1]
    b.TextColor3 = Color3.fromRGB(220,220,220)
    b.TextSize = 12
    b.Font = Enum.Font.Gotham
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.Parent = h
    local pd = Instance.new("UIPadding")
    pd.PaddingLeft = UDim.new(0,10)
    pd.Parent = b
    local op = false
    b.MouseButton1Click:Connect(function()
        op = not op
        h.Size = op and UDim2.new(1,0,0,34 + #opts*26) or UDim2.new(1,0,0,34)
    end)
    for i, o in ipairs(opts) do
        local ob = Instance.new("TextButton")
        ob.Size = UDim2.new(1,-10,0,24)
        ob.Position = UDim2.new(0,5,0,34 + (i-1)*26)
        ob.BackgroundColor3 = Color3.fromRGB(30,30,40)
        ob.BorderSizePixel = 0
        ob.Text = o
        ob.TextColor3 = Color3.fromRGB(200,200,200)
        ob.TextSize = 11
        ob.Font = Enum.Font.Gotham
        ob.Parent = h
        local oc = Instance.new("UICorner")
        oc.CornerRadius = UDim.new(0,6)
        oc.Parent = ob
        ob.MouseButton1Click:Connect(function()
            b.Text = text .. ": " .. o
            op = false
            h.Size = UDim2.new(1,0,0,34)
            if cb then cb(o) end
        end)
    end
end

addTgl(V, "ESP Enabled", false, function(s) Config.ESP.Enabled = s end)
addTgl(V, "Box", true, function(s) Config.ESP.Box = s end)
addTgl(V, "Name", false, function(s) Config.ESP.Name = s end)
addTgl(V, "Distance", false, function(s) Config.ESP.Distance = s end)
addTgl(V, "Health Bar", false, function(s) Config.ESP.Health = s end)
addTgl(V, "Team Check", true, function(s) Config.ESP.TeamCheck = s end)
addSld(V, "Max Distance", 2000, 50, 500, function(v) Config.ESP.MaxDistance = v end)

addTgl(S, "Silent Aim Enabled", false, function(s)
    Config.Silent.Enabled = s
    if FOVCircle then FOVCircle.Visible = s end
end)
addTgl(S, "Team Check", true, function(s) Config.Silent.TeamCheck = s end)
addTgl(S, "Visible Only", false, function(s) Config.Silent.VisibleOnly = s end)
addSld(S, "FOV", 180, 30, 150, function(v)
    Config.Silent.FOV = v
    if FOVCircle then FOVCircle.Radius = v end
end)
addDd(S, "Target Part", {"Head", "Torso"}, function(v) Config.Silent.TargetPart = v end)

local TgHolder = Instance.new("Frame")
TgHolder.Size = UDim2.new(1, 0, 0, 96)
TgHolder.BackgroundColor3 = Color3.fromRGB(22,22,30)
TgHolder.BorderSizePixel = 0
TgHolder.Parent = MS.P
local tghc = Instance.new("UICorner")
tghc.CornerRadius = UDim.new(0,8)
tghc.Parent = TgHolder
local TgLabel = Instance.new("TextLabel")
TgLabel.Size = UDim2.new(1, -20, 0, 18)
TgLabel.Position = UDim2.new(0, 10, 0, 6)
TgLabel.BackgroundTransparency = 1
TgLabel.Text = "Support author:"
TgLabel.TextColor3 = Color3.fromRGB(220,220,220)
TgLabel.TextSize = 12
TgLabel.Font = Enum.Font.Gotham
TgLabel.TextXAlignment = Enum.TextXAlignment.Left
TgLabel.Parent = TgHolder
local TgLink = Instance.new("TextButton")
TgLink.Size = UDim2.new(1, -20, 0, 26)
TgLink.Position = UDim2.new(0, 10, 0, 28)
TgLink.BackgroundColor3 = Color3.fromRGB(30,30,40)
TgLink.BorderSizePixel = 0
TgLink.Text = TG_LINK
TgLink.TextColor3 = Color3.fromRGB(0,255,200)
TgLink.TextSize = 13
TgLink.Font = Enum.Font.GothamBold
TgLink.AutoButtonColor = false
TgLink.Parent = TgHolder
local tgc = Instance.new("UICorner")
tgc.CornerRadius = UDim.new(0,6)
tgc.Parent = TgLink
local TgHint = Instance.new("TextLabel")
TgHint.Size = UDim2.new(1, -20, 0, 18)
TgHint.Position = UDim2.new(0, 10, 0, 58)
TgHint.BackgroundTransparency = 1
TgHint.Text = "(tap to copy)"
TgHint.TextColor3 = Color3.fromRGB(150,150,165)
TgHint.TextSize = 11
TgHint.Font = Enum.Font.Gotham
TgHint.TextXAlignment = Enum.TextXAlignment.Center
TgHint.Parent = TgHolder
local TgNotify = Instance.new("TextLabel")
TgNotify.Size = UDim2.new(1, -20, 0, 18)
TgNotify.Position = UDim2.new(0, 10, 0, 58)
TgNotify.BackgroundTransparency = 1
TgNotify.Text = ""
TgNotify.TextColor3 = Color3.fromRGB(0,255,200)
TgNotify.TextSize = 11
TgNotify.Font = Enum.Font.GothamBold
TgNotify.TextXAlignment = Enum.TextXAlignment.Center
TgNotify.Parent = TgHolder

local function cp(t)
    local ok = false
    if setclipboard then pcall(function() setclipboard(t); ok = true end) end
    if not ok and toclipboard then pcall(function() toclipboard(t); ok = true end) end
    return ok
end
TgLink.MouseButton1Click:Connect(function()
    local c = cp(TG_LINK)
    TgHint.Visible = false
    if c then TgNotify.Text = "Copied!"; TgNotify.TextColor3 = Color3.fromRGB(0,255,200)
    else TgNotify.Text = "Failed"; TgNotify.TextColor3 = Color3.fromRGB(255,90,90) end
    pcall(function() game:GetService("GuiService"):OpenBrowserWindow("https://www.google.com/url?q=https://" .. TG_LINK) end)
    task.delay(3, function() TgNotify.Text = ""; TgHint.Visible = true end)
end)
TgLink.MouseEnter:Connect(function()
    TweenService:Create(TgLink, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(0,255,200),
        TextColor3 = Color3.fromRGB(15,15,20)
    }):Play()
end)
TgLink.MouseLeave:Connect(function()
    TweenService:Create(TgLink, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(30,30,40),
        TextColor3 = Color3.fromRGB(0,255,200)
    }):Play()
end)

local function setOpen(s)
    Open = s
    if s then
        Main.Visible = true
        Main.Size = UDim2.new(0,0,0,0)
        TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0,260,0,330)
        }):Play()
    else
        local t = TweenService:Create(Main, TweenInfo.new(0.15), {Size = UDim2.new(0,0,0,0)})
        t:Play()
        t.Completed:Connect(function() Main.Visible = false end)
    end
end
local function fullClose()
    CompletelyClosed = true
    Open = false
    local t = TweenService:Create(Main, TweenInfo.new(0.15), {Size = UDim2.new(0,0,0,0)})
    t:Play()
    t.Completed:Connect(function()
        Main.Visible = false
        ToggleBtn.Visible = false
        Config.ESP.Enabled = false
        Config.Silent.Enabled = false
        if FOVCircle then FOVCircle.Visible = false end
        for _, o in pairs(ESPObjects) do hideAll(o) end
    end)
end
setOpen(true)
ToggleBtn.MouseButton1Click:Connect(function()
    if CompletelyClosed then return end
    if not bMv then setOpen(not Open) end
end)
MB.MouseButton1Click:Connect(function()
    if CompletelyClosed then return end
    setOpen(false)
end)
MB.MouseEnter:Connect(function() MB.TextColor3 = Color3.fromRGB(0,255,200) end)
MB.MouseLeave:Connect(function() MB.TextColor3 = Color3.fromRGB(200,200,200) end)
CB.MouseButton1Click:Connect(function() fullClose() end)
CB.MouseEnter:Connect(function() CB.TextColor3 = Color3.fromRGB(255,30,30) end)
CB.MouseLeave:Connect(function() CB.TextColor3 = Color3.fromRGB(255,90,90) end)

for _, p in pairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

RunService.RenderStepped:Connect(function()
    if CompletelyClosed then return end
    if Config.Silent.Enabled then
        SilentTarget = findSilentTarget()
    else
        SilentTarget = nil
    end
    updateESP()
    if FOVCircle and FOVCircle.Visible then
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    end
end)

print("NEUTRON DD loaded!")
