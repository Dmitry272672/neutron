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
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 15, 0.4, 0)
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
tbStroke.Thickness = 2
tbStroke.Transparency = 0.2
tbStroke.Parent = ToggleBtn

-- ===== Основное окно =====
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 280, 0, 360)
Main.Position = UDim2.new(0.5, -140, 0.5, -180)
Main.BackgroundColor3 = Color3.fromRGB(15,15,20)
Main.BorderSizePixel = 0
Main.Active = true
Main.ClipsDescendants = true
Main.Parent = ScreenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0,16)
mainCorner.Parent = Main
local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(0,255,200)
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.4
mainStroke.Parent = Main

-- ===== Верхняя панель =====
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundColor3 = Color3.fromRGB(22,22,30)
TopBar.BorderSizePixel = 0
TopBar.Active = true
TopBar.Parent = Main

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0,16)
topCorner.Parent = TopBar
local topFix = Instance.new("Frame")
topFix.Size = UDim2.new(1, 0, 0, 16)
topFix.Position = UDim2.new(0, 0, 1, -16)
topFix.BackgroundColor3 = Color3.fromRGB(22,22,30)
topFix.BorderSizePixel = 0
topFix.Parent = TopBar

local TopIcon = Instance.new("ImageLabel")
TopIcon.Size = UDim2.new(0, 30, 0, 30)
TopIcon.Position = UDim2.new(0, 12, 0.5, -15)
TopIcon.BackgroundTransparency = 1
TopIcon.Image = IMAGE_URL
TopIcon.ScaleType = Enum.ScaleType.Fit
TopIcon.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -180, 1, 0)
Title.Position = UDim2.new(0, 50, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "test"
Title.TextColor3 = Color3.fromRGB(0,255,200)
Title.TextSize = 17
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- ✕ Крестик
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 34, 0, 34)
CloseBtn.Position = UDim2.new(1, -42, 0.5, -17)
CloseBtn.BackgroundTransparency = 1
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255,90,90)
CloseBtn.TextSize = 26
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = TopBar

-- — Минус
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 34, 0, 34)
MinimizeBtn.Position = UDim2.new(1, -92, 0.5, -17)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.fromRGB(200,200,200)
MinimizeBtn.TextSize = 26
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.AutoButtonColor = false
MinimizeBtn.Parent = TopBar

-- ===== Вкладки (слева) =====
local TabsFrame = Instance.new("Frame")
TabsFrame.Size = UDim2.new(0, 80, 1, -58)
TabsFrame.Position = UDim2.new(0, 8, 0, 54)
TabsFrame.BackgroundColor3 = Color3.fromRGB(18,18,24)
TabsFrame.BorderSizePixel = 0
TabsFrame.Parent = Main

local tabsCorner = Instance.new("UICorner")
tabsCorner.CornerRadius = UDim.new(0,12)
tabsCorner.Parent = TabsFrame

local TabsList = Instance.new("UIListLayout")
TabsList.Padding = UDim.new(0, 6)
TabsList.SortOrder = Enum.SortOrder.LayoutOrder
TabsList.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabsList.Parent = TabsFrame

local TabsPad = Instance.new("UIPadding")
TabsPad.PaddingTop = UDim.new(0, 10)
TabsPad.Parent = TabsFrame

-- ===== Контент =====
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -96, 1, -58)
Content.Position = UDim2.new(0, 92, 0, 54)
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
    if math.abs(delta.X) > 8 or math.abs(delta.Y) > 8 then btnMoved = true end
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

-- ===== Создание вкладок =====
local function makeTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -12, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(25,25,33)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200,200,200)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.Parent = TabsFrame
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,10)
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
    l.Padding = UDim.new(0, 6)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent = page
    local pd = Instance.new("UIPadding")
    pd.PaddingTop = UDim.new(0, 4)
    pd.PaddingRight = UDim.new(0, 8)
    pd.PaddingBottom = UDim.new(0, 4)
    pd.Parent = page
    return {Button = btn, Page = page}
end

local Tab1 = makeTab("Home")
local Tab2 = makeTab("Info")
local Tab3 = makeTab("About")
local allTabs = {Tab1, Tab2, Tab3}

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

Tab1.Button.MouseButton1Click:Connect(function() selectTab(Tab1) end)
Tab2.Button.MouseButton1Click:Connect(function() selectTab(Tab2) end)
Tab3.Button.MouseButton1Click:Connect(function() selectTab(Tab3) end)
selectTab(Tab1)

-- ===== Home Tab: приветствие =====
local HelloFrame = Instance.new("Frame")
HelloFrame.Size = UDim2.new(1, 0, 0, 120)
HelloFrame.BackgroundColor3 = Color3.fromRGB(22,22,30)
HelloFrame.BorderSizePixel = 0
HelloFrame.Parent = Tab1.Page

local helloCorner = Instance.new("UICorner")
helloCorner.CornerRadius = UDim.new(0,10)
helloCorner.Parent = HelloFrame

local HelloIcon = Instance.new("ImageLabel")
HelloIcon.Size = UDim2.new(0, 50, 0, 50)
HelloIcon.Position = UDim2.new(0.5, -25, 0, 15)
HelloIcon.BackgroundTransparency = 1
HelloIcon.Image = IMAGE_URL
HelloIcon.ScaleType = Enum.ScaleType.Fit
HelloIcon.Parent = HelloFrame

local HelloTitle = Instance.new("TextLabel")
HelloTitle.Size = UDim2.new(1, -20, 0, 25)
HelloTitle.Position = UDim2.new(0, 10, 0, 70)
HelloTitle.BackgroundTransparency = 1
HelloTitle.Text = "Welcome to test!"
HelloTitle.TextColor3 = Color3.fromRGB(0,255,200)
HelloTitle.TextSize = 15
HelloTitle.Font = Enum.Font.GothamBold
HelloTitle.TextXAlignment = Enum.TextXAlignment.Center
HelloTitle.Parent = HelloFrame

local HelloSub = Instance.new("TextLabel")
HelloSub.Size = UDim2.new(1, -20, 0, 20)
HelloSub.Position = UDim2.new(0, 10, 0, 95)
HelloSub.BackgroundTransparency = 1
HelloSub.Text = "Use tabs to navigate"
HelloSub.TextColor3 = Color3.fromRGB(150,150,165)
HelloSub.TextSize = 12
HelloSub.Font = Enum.Font.Gotham
HelloSub.TextXAlignment = Enum.TextXAlignment.Center
HelloSub.Parent = HelloFrame

-- Кнопка Telegram
local TgBtn = Instance.new("TextButton")
TgBtn.Size = UDim2.new(1, 0, 0, 40)
TgBtn.BackgroundColor3 = Color3.fromRGB(30,30,40)
TgBtn.BorderSizePixel = 0
TgBtn.Text = "Join Telegram"
TgBtn.TextColor3 = Color3.fromRGB(0,255,200)
TgBtn.TextSize = 14
TgBtn.Font = Enum.Font.GothamBold
TgBtn.AutoButtonColor = false
TgBtn.Parent = Tab1.Page

local tgBtnCorner = Instance.new("UICorner")
tgBtnCorner.CornerRadius = UDim.new(0,10)
tgBtnCorner.Parent = TgBtn

TgBtn.MouseEnter:Connect(function()
    TweenService:Create(TgBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(0,255,200),
        TextColor3 = Color3.fromRGB(15,15,20),
    }):Play()
end)
TgBtn.MouseLeave:Connect(function()
    TweenService:Create(TgBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(30,30,40),
        TextColor3 = Color3.fromRGB(0,255,200),
    }):Play()
end)
TgBtn.MouseButton1Click:Connect(function()
    if setclipboard then pcall(function() setclipboard(TG_LINK) end) end
    pcall(function()
        game:GetService("GuiService"):OpenBrowserWindow("https://www.google.com/url?q=https://" .. TG_LINK)
    end)
end)

-- ===== Info Tab =====
local InfoFrame = Instance.new("Frame")
InfoFrame.Size = UDim2.new(1, 0, 0, 110)
InfoFrame.BackgroundColor3 = Color3.fromRGB(22,22,30)
InfoFrame.BorderSizePixel = 0
InfoFrame.Parent = Tab2.Page

local infoCorner = Instance.new("UICorner")
infoCorner.CornerRadius = UDim.new(0,10)
infoCorner.Parent = InfoFrame

local InfoTitle = Instance.new("TextLabel")
InfoTitle.Size = UDim2.new(1, -20, 0, 20)
InfoTitle.Position = UDim2.new(0, 12, 0, 8)
InfoTitle.BackgroundTransparency = 1
InfoTitle.Text = "System Info"
InfoTitle.TextColor3 = Color3.fromRGB(0,255,200)
InfoTitle.TextSize = 13
InfoTitle.Font = Enum.Font.GothamBold
InfoTitle.TextXAlignment = Enum.TextXAlignment.Left
InfoTitle.Parent = InfoFrame

local function makeInfoRow(parent, y, label, initial)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.6, -12, 0, 22)
    lbl.Position = UDim2.new(0, 12, 0, y)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(200,200,200)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent

    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(0.4, -12, 0, 22)
    val.Position = UDim2.new(0.6, 0, 0, y)
    val.BackgroundTransparency = 1
    val.Text = initial
    val.TextColor3 = Color3.fromRGB(0,255,200)
    val.TextSize = 12
    val.Font = Enum.Font.GothamBold
    val.TextXAlignment = Enum.TextXAlignment.Right
    val.Parent = parent

    return val
end

local ResVal = makeInfoRow(InfoFrame, 32, "Resolution:", "0x0")
local FpsVal = makeInfoRow(InfoFrame, 56, "FPS:", "0")
local PingVal = makeInfoRow(InfoFrame, 80, "Ping:", "--")

-- ===== About Tab =====
local AboutFrame = Instance.new("Frame")
AboutFrame.Size = UDim2.new(1, 0, 0, 100)
AboutFrame.BackgroundColor3 = Color3.fromRGB(22,22,30)
AboutFrame.BorderSizePixel = 0
AboutFrame.Parent = Tab3.Page

local aboutCorner = Instance.new("UICorner")
aboutCorner.CornerRadius = UDim.new(0,10)
aboutCorner.Parent = AboutFrame

local AboutTitle = Instance.new("TextLabel")
AboutTitle.Size = UDim2.new(1, -20, 0, 20)
AboutTitle.Position = UDim2.new(0, 12, 0, 8)
AboutTitle.BackgroundTransparency = 1
AboutTitle.Text = "About"
AboutTitle.TextColor3 = Color3.fromRGB(0,255,200)
AboutTitle.TextSize = 13
AboutTitle.Font = Enum.Font.GothamBold
AboutTitle.TextXAlignment = Enum.TextXAlignment.Left
AboutTitle.Parent = AboutFrame

local AboutText = Instance.new("TextLabel")
AboutText.Size = UDim2.new(1, -24, 0, 60)
AboutText.Position = UDim2.new(0, 12, 0, 32)
AboutText.BackgroundTransparency = 1
AboutText.Text = "test menu v1.0\nCreated for UI demonstration\nNo cheat functions included"
AboutText.TextColor3 = Color3.fromRGB(200,200,200)
AboutText.TextSize = 12
AboutText.Font = Enum.Font.Gotham
AboutText.TextXAlignment = Enum.TextXAlignment.Left
AboutText.TextYAlignment = Enum.TextYAlignment.Top
AboutText.Parent = AboutFrame

-- ===== FPS/Ping update =====
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
        if ResVal then ResVal.Text = screenResText end
        if FpsVal then FpsVal.Text = tostring(fpsCurrent) end
        if PingVal then
            local ping = getPing()
            if ping > 0 then
                PingVal.Text = tostring(ping) .. " ms"
            else
                PingVal.Text = "--"
            end
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
        TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 280, 0, 360)
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
        ToggleBtn.Visible = false
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
