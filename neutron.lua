-- test | Menu

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local IMAGE_URL = "rbxassetid://138823883244540"
local TG_LINK = "t.me/neutron_client"

local SCALE = 1
local screenResText = "0x0"

local function getScale()
    local vp = Camera.ViewportSize
    local diag = math.sqrt(vp.X * vp.X + vp.Y * vp.Y)
    local scale = diag / (1920 * 1.4)
    if scale < 1 then scale = 1 end
    if scale > 3.5 then scale = 3.5 end
    screenResText = string.format("%dx%d", math.floor(vp.X), math.floor(vp.Y))
    return scale
end

SCALE = getScale()
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function() SCALE = getScale() end)

local Open = true
local CompletelyClosed = false

-- ===== UI =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "test"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui")

-- ===== Кнопка открытия =====
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

local tbCorner = Instance.new("UICorner")
tbCorner.CornerRadius = UDim.new(1,0)
tbCorner.Parent = ToggleBtn
local tbStroke = Instance.new("UIStroke")
tbStroke.Color = Color3.fromRGB(0,255,200)
tbStroke.Thickness = 1.5
tbStroke.Transparency = 0.3
tbStroke.Parent = ToggleBtn

-- ===== Основное окно =====
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 260, 0, 330)
Main.Position = UDim2.new(0.5, -130, 0.5, -165)
Main.BackgroundColor3 = Color3.fromRGB(15,15,20)
Main.BorderSizePixel = 0
Main.Active = true
Main.ClipsDescendants = true
Main.Parent = ScreenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0,14)
mainCorner.Parent = Main
local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(0,255,200)
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.4
mainStroke.Parent = Main

-- ===== Верхняя панель =====
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Color3.fromRGB(22,22,30)
TopBar.BorderSizePixel = 0
TopBar.Active = true
TopBar.Parent = Main

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0,14)
topCorner.Parent = TopBar
local topFix = Instance.new("Frame")
topFix.Size = UDim2.new(1, 0, 0, 14)
topFix.Position = UDim2.new(0, 0, 1, -14)
topFix.BackgroundColor3 = Color3.fromRGB(22,22,30)
topFix.BorderSizePixel = 0
topFix.Parent = TopBar

local TopIcon = Instance.new("ImageLabel")
TopIcon.Size = UDim2.new(0, 26, 0, 26)
TopIcon.Position = UDim2.new(0, 10, 0.5, -13)
TopIcon.BackgroundTransparency = 1
TopIcon.Image = IMAGE_URL
TopIcon.ScaleType = Enum.ScaleType.Fit
TopIcon.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -160, 1, 0)
Title.Position = UDim2.new(0, 42, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "test"
Title.TextColor3 = Color3.fromRGB(0,255,200)
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -36, 0.5, -15)
CloseBtn.BackgroundTransparency = 1
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255,90,90)
CloseBtn.TextSize = 24
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = TopBar

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -84, 0.5, -15)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(200,200,200)
MinimizeBtn.TextSize = 24
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.AutoButtonColor = false
MinimizeBtn.Parent = TopBar

-- ===== Вкладки =====
local TabsFrame = Instance.new("Frame")
TabsFrame.Size = UDim2.new(0, 72, 1, -50)
TabsFrame.Position = UDim2.new(0, 6, 0, 46)
TabsFrame.BackgroundColor3 = Color3.fromRGB(18,18,24)
TabsFrame.BorderSizePixel = 0
TabsFrame.Parent = Main

local tabsCorner = Instance.new("UICorner")
tabsCorner.CornerRadius = UDim.new(0,10)
tabsCorner.Parent = TabsFrame

local TabsList = Instance.new("UIListLayout")
TabsList.Padding = UDim.new(0, 4)
TabsList.SortOrder = Enum.SortOrder.LayoutOrder
TabsList.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabsList.Parent = TabsFrame

local TabsPad = Instance.new("UIPadding")
TabsPad.PaddingTop = UDim.new(0, 8)
TabsPad.Parent = TabsFrame

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -88, 1, -50)
Content.Position = UDim2.new(0, 82, 0, 46)
Content.BackgroundTransparency = 1
Content.ClipsDescendants = true
Content.Parent = Main

-- ===== Перетаскивание кнопки =====
local btnDragging = false
local btnDragStart = nil
local btnStartPos = nil
local btnMoved = false

local function btnUpdateDrag(input)
    local delta = input.Position - btnDragStart
    if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then btnMoved = true end
    ToggleBtn.Position = UDim2.new(
        btnStartPos.X.Scale, btnStartPos.X.Offset + delta.X,
        btnStartPos.Y.Scale, btnStartPos.Y.Offset + delta.Y
    )
end

ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        btnDragging = true; btnMoved = false
        btnDragStart = input.Position; btnStartPos = ToggleBtn.Position
    end
end)
ToggleBtn.InputChanged:Connect(function(input)
    if btnDragging and (input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch) then btnUpdateDrag(input) end
end)
ToggleBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then btnDragging = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if btnDragging and (input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch) then btnUpdateDrag(input) end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then btnDragging = false end
end)

-- ===== Перетаскивание меню =====
local menuDragging = false
local menuDragStart = nil
local menuStartPos = nil

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        menuDragging = true
        menuDragStart = input.Position
        menuStartPos = Main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if menuDragging and (input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - menuDragStart
        Main.Position = UDim2.new(
            menuStartPos.X.Scale, menuStartPos.X.Offset + delta.X,
            menuStartPos.Y.Scale, menuStartPos.Y.Offset + delta.Y
        )
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then menuDragging = false end
end)

-- ===== Вкладки =====
local function makeTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(25,25,33)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200,200,200)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.Parent = TabsFrame
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,8)
    c.Parent = btn
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Color3.fromRGB(0,255,200)
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = Content
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, 5)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent = page
    local pd = Instance.new("UIPadding")
    pd.PaddingTop = UDim.new(0, 4)
    pd.PaddingRight = UDim.new(0, 6)
    pd.PaddingBottom = UDim.new(0, 4)
    pd.Parent = page
    return {Button = btn, Page = page}
end

local Visual = makeTab("ESP")
local Combat = makeTab("AIM")
local Misc = makeTab("MISC")
local allTabs = {Visual, Combat, Misc}

local function selectTab(tab)
    for _, t in pairs(allTabs) do
        t.Page.Visible = false
        TweenService:Create(t.Button, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(25,25,33),
            TextColor3 = Color3.fromRGB(200,200,200),
        }):Play()
    end
    tab.Page.Visible = true
    TweenService:Create(tab.Button, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(0,255,200),
        TextColor3 = Color3.fromRGB(15,15,20),
    }):Play()
end

Visual.Button.MouseButton1Click:Connect(function() selectTab(Visual) end)
Combat.Button.MouseButton1Click:Connect(function() selectTab(Combat) end)
Misc.Button.MouseButton1Click:Connect(function() selectTab(Misc) end)
selectTab(Visual)

-- ===== Элементы =====
local function addToggle(parent, text, default, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 34)
    holder.BackgroundColor3 = Color3.fromRGB(22,22,30)
    holder.BorderSizePixel = 0
    holder.Parent = parent.Page
    local hc = Instance.new("UICorner")
    hc.CornerRadius = UDim.new(0,8)
    hc.Parent = holder
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(220,220,220)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = holder
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 40, 0, 20)
    toggle.Position = UDim2.new(1, -50, 0.5, -10)
    toggle.BackgroundColor3 = Color3.fromRGB(40,40,50)
    toggle.BorderSizePixel = 0
    toggle.Text = ""
    toggle.AutoButtonColor = false
    toggle.Parent = holder
    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(1,0)
    tc.Parent = toggle
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(200,200,200)
    knob.BorderSizePixel = 0
    knob.Parent = toggle
    local kc = Instance.new("UICorner")
    kc.CornerRadius = UDim.new(1,0)
    kc.Parent = knob
    local state = default or false
    local function refresh()
        if state then
            TweenService:Create(toggle, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(0,255,200) }):Play()
            TweenService:Create(knob, TweenInfo.new(0.15), {
                Position = UDim2.new(1, -18, 0.5, -8),
                BackgroundColor3 = Color3.fromRGB(15,15,20),
            }):Play()
        else
            TweenService:Create(toggle, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(40,40,50) }):Play()
            TweenService:Create(knob, TweenInfo.new(0.15), {
                Position = UDim2.new(0, 2, 0.5, -8),
                BackgroundColor3 = Color3.fromRGB(200,200,200),
            }):Play()
        end
    end
    refresh()
    toggle.MouseButton1Click:Connect(function()
        state = not state
        refresh()
        if callback then callback(state) end
    end)
end

local function addSlider(parent, text, max, min, default, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 48)
    holder.BackgroundColor3 = Color3.fromRGB(22,22,30)
    holder.BorderSizePixel = 0
    holder.Parent = parent.Page
    local hc = Instance.new("UICorner")
    hc.CornerRadius = UDim.new(0,8)
    hc.Parent = holder
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 0, 20)
    lbl.Position = UDim2.new(0, 10, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(220,220,220)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = holder
    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 50, 0, 20)
    valLbl.Position = UDim2.new(1, -56, 0, 4)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(default)
    valLbl.TextColor3 = Color3.fromRGB(0,255,200)
    valLbl.TextSize = 12
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = holder
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -20, 0, 6)
    bar.Position = UDim2.new(0, 10, 0, 30)
    bar.BackgroundColor3 = Color3.fromRGB(40,40,50)
    bar.BorderSizePixel = 0
    bar.Parent = holder
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(1,0)
    bc.Parent = bar
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0,255,200)
    fill.BorderSizePixel = 0
    fill.Parent = bar
    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(1,0)
    fc.Parent = fill
    local drag = false
    local function upd(input)
        local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local cur = math.floor(min + (max - min) * rel + 0.5)
        valLbl.Text = tostring(cur)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        if callback then callback(cur) end
    end
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then drag = true; upd(input) end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if drag and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then upd(input) end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then drag = false end
    end)
end

local function addDropdown(parent, text, options, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 34)
    holder.BackgroundColor3 = Color3.fromRGB(22,22,30)
    holder.BorderSizePixel = 0
    holder.ClipsDescendants = true
    holder.Parent = parent.Page
    local hc = Instance.new("UICorner")
    hc.CornerRadius = UDim.new(0,8)
    hc.Parent = holder
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundTransparency = 1
    btn.Text = text .. ": " .. options[1]
    btn.TextColor3 = Color3.fromRGB(220,220,220)
    btn.TextSize = 12
    btn.Font = Enum.Font.Gotham
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = holder
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 10)
    pad.Parent = btn
    local open = false
    btn.MouseButton1Click:Connect(function()
        open = not open
        holder.Size = open and UDim2.new(1, 0, 0, 34 + #options * 26) or UDim2.new(1, 0, 0, 34)
    end)
    for i, opt in ipairs(options) do
        local ob = Instance.new("TextButton")
        ob.Size = UDim2.new(1, -10, 0, 24)
        ob.Position = UDim2.new(0, 5, 0, 34 + (i - 1) * 26)
        ob.BackgroundColor3 = Color3.fromRGB(30,30,40)
        ob.BorderSizePixel = 0
        ob.Text = opt
        ob.TextColor3 = Color3.fromRGB(200,200,200)
        ob.TextSize = 11
        ob.Font = Enum.Font.Gotham
        ob.Parent = holder
        local oc = Instance.new("UICorner")
        oc.CornerRadius = UDim.new(0,6)
        oc.Parent = ob
        ob.MouseButton1Click:Connect(function()
            btn.Text = text .. ": " .. opt
            open = false
            holder.Size = UDim2.new(1, 0, 0, 34)
            if callback then callback(opt) end
        end)
    end
end

-- ===== ESP Tab =====
addToggle(Visual, "ESP Enabled", false, function(s) end)
addToggle(Visual, "Box", true, function(s) end)
addToggle(Visual, "Name", false, function(s) end)
addToggle(Visual, "Distance", false, function(s) end)
addToggle(Visual, "Health Bar", false, function(s) end)
addToggle(Visual, "Tracer", false, function(s) end)
addToggle(Visual, "Skeleton", false, function(s) end)
addToggle(Visual, "Head Circle", false, function(s) end)
addSlider(Visual, "Max Distance", 2000, 50, 500, function(v) end)

-- ===== AIM Tab =====
addToggle(Combat, "Aimbot Enabled", false, function(s) end)
addToggle(Combat, "Visible Only", true, function(s) end)
addSlider(Combat, "Smoothness", 10, 1, 8, function(v) end)
addSlider(Combat, "FOV", 200, 30, 100, function(v) end)
addDropdown(Combat, "Target", {"Head", "Torso"}, function(v) end)

-- ===== MISC: TG =====
local TgHolder = Instance.new("Frame")
TgHolder.Size = UDim2.new(1, 0, 0, 96)
TgHolder.BackgroundColor3 = Color3.fromRGB(22,22,30)
TgHolder.BorderSizePixel = 0
TgHolder.Parent = Misc.Page

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

local function copyToClipboard(text)
    local ok = false
    if setclipboard then pcall(function() setclipboard(text); ok = true end) end
    if not ok and toclipboard then pcall(function() toclipboard(text); ok = true end) end
    return ok
end

TgLink.MouseButton1Click:Connect(function()
    local c = copyToClipboard(TG_LINK)
    TgHint.Visible = false
    if c then
        TgNotify.Text = "Copied!"
        TgNotify.TextColor3 = Color3.fromRGB(0,255,200)
    else
        TgNotify.Text = "Copy failed"
        TgNotify.TextColor3 = Color3.fromRGB(255,90,90)
    end
    pcall(function()
        game:GetService("GuiService"):OpenBrowserWindow("https://www.google.com/url?q=https://" .. TG_LINK)
    end)
    task.delay(3, function()
        TgNotify.Text = ""
        TgHint.Visible = true
    end)
end)
TgLink.MouseEnter:Connect(function()
    TweenService:Create(TgLink, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(0,255,200),
        TextColor3 = Color3.fromRGB(15,15,20),
    }):Play()
end)
TgLink.MouseLeave:Connect(function()
    TweenService:Create(TgLink, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(30,30,40),
        TextColor3 = Color3.fromRGB(0,255,200),
    }):Play()
end)

-- ===== MISC: Info =====
local InfoHolder = Instance.new("Frame")
InfoHolder.Size = UDim2.new(1, 0, 0, 96)
InfoHolder.BackgroundColor3 = Color3.fromRGB(22,22,30)
InfoHolder.BorderSizePixel = 0
InfoHolder.Parent = Misc.Page

local ihc = Instance.new("UICorner")
ihc.CornerRadius = UDim.new(0,8)
ihc.Parent = InfoHolder

local InfoTitle = Instance.new("TextLabel")
InfoTitle.Size = UDim2.new(1, -20, 0, 18)
InfoTitle.Position = UDim2.new(0, 10, 0, 6)
InfoTitle.BackgroundTransparency = 1
InfoTitle.Text = "Info:"
InfoTitle.TextColor3 = Color3.fromRGB(220,220,220)
InfoTitle.TextSize = 12
InfoTitle.Font = Enum.Font.Gotham
InfoTitle.TextXAlignment = Enum.TextXAlignment.Left
InfoTitle.Parent = InfoHolder

local ResLbl = Instance.new("TextLabel")
ResLbl.Size = UDim2.new(1, -20, 0, 20)
ResLbl.Position = UDim2.new(0, 10, 0, 26)
ResLbl.BackgroundTransparency = 1
ResLbl.Text = "Resolution:"
ResLbl.TextColor3 = Color3.fromRGB(200,200,200)
ResLbl.TextSize = 12
ResLbl.Font = Enum.Font.Gotham
ResLbl.TextXAlignment = Enum.TextXAlignment.Left
ResLbl.Parent = InfoHolder

local ResValue = Instance.new("TextLabel")
ResValue.Size = UDim2.new(0, 100, 0, 20)
ResValue.Position = UDim2.new(1, -110, 0, 26)
ResValue.BackgroundTransparency = 1
ResValue.Text = "0x0"
ResValue.TextColor3 = Color3.fromRGB(0,255,200)
ResValue.TextSize = 12
ResValue.Font = Enum.Font.GothamBold
ResValue.TextXAlignment = Enum.TextXAlignment.Right
ResValue.Parent = InfoHolder

local FpsLbl = Instance.new("TextLabel")
FpsLbl.Size = UDim2.new(1, -20, 0, 20)
FpsLbl.Position = UDim2.new(0, 10, 0, 46)
FpsLbl.BackgroundTransparency = 1
FpsLbl.Text = "FPS:"
FpsLbl.TextColor3 = Color3.fromRGB(200,200,200)
FpsLbl.TextSize = 12
FpsLbl.Font = Enum.Font.Gotham
FpsLbl.TextXAlignment = Enum.TextXAlignment.Left
FpsLbl.Parent = InfoHolder

local FpsValue = Instance.new("TextLabel")
FpsValue.Size = UDim2.new(0, 100, 0, 20)
FpsValue.Position = UDim2.new(1, -110, 0, 46)
FpsValue.BackgroundTransparency = 1
FpsValue.Text = "0"
FpsValue.TextColor3 = Color3.fromRGB(0,255,200)
FpsValue.TextSize = 12
FpsValue.Font = Enum.Font.GothamBold
FpsValue.TextXAlignment = Enum.TextXAlignment.Right
FpsValue.Parent = InfoHolder

local PingLbl = Instance.new("TextLabel")
PingLbl.Size = UDim2.new(1, -20, 0, 20)
PingLbl.Position = UDim2.new(0, 10, 0, 66)
PingLbl.BackgroundTransparency = 1
PingLbl.Text = "Ping:"
PingLbl.TextColor3 = Color3.fromRGB(200,200,200)
PingLbl.TextSize = 12
PingLbl.Font = Enum.Font.Gotham
PingLbl.TextXAlignment = Enum.TextXAlignment.Left
PingLbl.Parent = InfoHolder

local PingValue = Instance.new("TextLabel")
PingValue.Size = UDim2.new(0, 100, 0, 20)
PingValue.Position = UDim2.new(1, -110, 0, 66)
PingValue.BackgroundTransparency = 1
PingValue.Text = "0 ms"
PingValue.TextColor3 = Color3.fromRGB(0,255,200)
PingValue.TextSize = 12
PingValue.Font = Enum.Font.GothamBold
PingValue.TextXAlignment = Enum.TextXAlignment.Right
PingValue.Parent = InfoHolder

-- ===== FPS/Ping =====
local fpsFrames = 0
local fpsTime = os.clock()
local fpsCurrent = 0

RunService.RenderStepped:Connect(function()
    fpsFrames = fpsFrames + 1
    local now = os.clock()
    if now - fpsTime >= 1 then
        fpsCurrent = fpsFrames
        fpsFrames = 0
        fpsTime = now
    end
end)

local function getPing()
    local ok, ping = pcall(function() return LocalPlayer:GetNetworkPing() end)
    if ok and ping and ping > 0 then return math.floor(ping * 1000) end
    local ok2, val = pcall(function()
        local ss = Stats.Network.ServerStatsItem
        if ss and ss["Data Ping"] then return math.floor(ss["Data Ping"]:GetValue()) end
    end)
    if ok2 and type(val) == "number" then return val end
    return 0
end

task.spawn(function()
    while not CompletelyClosed do
        ResValue.Text = screenResText
        FpsValue.Text = tostring(fpsCurrent)
        local ping = getPing()
        if ping > 0 then
            PingValue.Text = tostring(ping) .. " ms"
        else
            PingValue.Text = "--"
        end
        task.wait(0.5)
    end
end)

-- ===== Открытие/закрытие =====
local function setOpen(state)
    Open = state
    if state then
        Main.Visible = true
        Main.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 260, 0, 330)
        }):Play()
    else
        local t = TweenService:Create(Main, TweenInfo.new(0.15), { Size = UDim2.new(0, 0, 0, 0) })
        t:Play()
        t.Completed:Connect(function() Main.Visible = false end)
    end
end

local function fullyClose()
    CompletelyClosed = true
    Open = false
    local t = TweenService:Create(Main, TweenInfo.new(0.15), { Size = UDim2.new(0, 0, 0, 0) })
    t:Play()
    t.Completed:Connect(function()
        Main.Visible = false
        if ToggleBtn then ToggleBtn.Visible = false end
    end)
end

setOpen(true)

ToggleBtn.MouseButton1Click:Connect(function()
    if CompletelyClosed then return end
    if not btnMoved then setOpen(not Open) end
end)
MinimizeBtn.MouseButton1Click:Connect(function()
    if CompletelyClosed then return end
    setOpen(false)
end)
MinimizeBtn.MouseEnter:Connect(function() MinimizeBtn.TextColor3 = Color3.fromRGB(0,255,200) end)
MinimizeBtn.MouseLeave:Connect(function() MinimizeBtn.TextColor3 = Color3.fromRGB(200,200,200) end)
CloseBtn.MouseButton1Click:Connect(function() fullyClose() end)
CloseBtn.MouseEnter:Connect(function() CloseBtn.TextColor3 = Color3.fromRGB(255,30,30) end)
CloseBtn.MouseLeave:Connect(function() CloseBtn.TextColor3 = Color3.fromRGB(255,90,90) end)

print("test loaded!")
