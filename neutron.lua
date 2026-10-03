-- test | Menu v2

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

-- ===== Кнопка открытия (круглая, с иконкой) =====
local ToggleBtn = Instance.new("ImageButton")
ToggleBtn.Size = UDim2.new(0, 54, 0, 54)
ToggleBtn.Position = UDim2.new(0, 15, 0.42, 0)
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

-- ===== Основное окно (компактнее, шире) =====
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 300, 0, 340)
Main.Position = UDim2.new(0.5, -150, 0.5, -170)
Main.BackgroundColor3 = Color3.fromRGB(12,12,16)
Main.BorderSizePixel = 0
Main.Active = true
Main.ClipsDescendants = true
Main.Parent = ScreenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0,18)
mainCorner.Parent = Main
local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(0,255,200)
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.5
mainStroke.Parent = Main

-- ===== Верхняя панель с градиентом =====
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 60)
TopBar.BackgroundColor3 = Color3.fromRGB(18,18,24)
TopBar.BorderSizePixel = 0
TopBar.Active = true
TopBar.Parent = Main

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0,18)
topCorner.Parent = TopBar
local topFix = Instance.new("Frame")
topFix.Size = UDim2.new(1, 0, 0, 20)
topFix.Position = UDim2.new(0, 0, 1, -20)
topFix.BackgroundColor3 = Color3.fromRGB(18,18,24)
topFix.BorderSizePixel = 0
topFix.Parent = TopBar

local TopIcon = Instance.new("ImageLabel")
TopIcon.Size = UDim2.new(0, 34, 0, 34)
TopIcon.Position = UDim2.new(0, 14, 0.5, -17)
TopIcon.BackgroundTransparency = 1
TopIcon.Image = IMAGE_URL
TopIcon.ScaleType = Enum.ScaleType.Fit
TopIcon.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -180, 0, 22)
Title.Position = UDim2.new(0, 56, 0, 12)
Title.BackgroundTransparency = 1
Title.Text = "test"
Title.TextColor3 = Color3.fromRGB(0,255,200)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, -180, 0, 16)
SubTitle.Position = UDim2.new(0, 56, 0, 32)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "menu v2"
SubTitle.TextColor3 = Color3.fromRGB(120,120,135)
SubTitle.TextSize = 11
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = TopBar

-- ✕ Крестик
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -40, 0.5, -16)
CloseBtn.BackgroundTransparency = 1
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255,80,80)
CloseBtn.TextSize = 24
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = TopBar

-- — Минус
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 32, 0, 32)
MinimizeBtn.Position = UDim2.new(1, -80, 0.5, -16)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.fromRGB(200,200,200)
MinimizeBtn.TextSize = 24
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.AutoButtonColor = false
MinimizeBtn.Parent = TopBar

-- ===== Вкладки (сверху, горизонтально) =====
local TabsBar = Instance.new("Frame")
TabsBar.Size = UDim2.new(1, -20, 0, 40)
TabsBar.Position = UDim2.new(0, 10, 0, 66)
TabsBar.BackgroundColor3 = Color3.fromRGB(18,18,24)
TabsBar.BorderSizePixel = 0
TabsBar.Parent = Main

local tabsBarCorner = Instance.new("UICorner")
tabsBarCorner.CornerRadius = UDim.new(0,12)
tabsBarCorner.Parent = TabsBar

local TabsLayout = Instance.new("UIListLayout")
TabsLayout.FillDirection = Enum.FillDirection.Horizontal
TabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TabsLayout.Padding = UDim.new(0, 6)
TabsLayout.Parent = TabsBar

-- ===== Контент =====
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -120)
Content.Position = UDim2.new(0, 10, 0, 112)
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
    btn.Size = UDim2.new(0, 80, 1, -10)
    btn.BackgroundColor3 = Color3.fromRGB(25,25,33)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200,200,200)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.Parent = TabsBar
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
    l.Padding = UDim.new(0, 8)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent = page
    local pd = Instance.new("UIPadding")
    pd.PaddingTop = UDim.new(0, 4)
    pd.PaddingBottom = UDim.new(0, 4)
    pd.Parent = page
    return {Button = btn, Page = page}
end

local TabHome = makeTab("HOME")
local TabInfo = makeTab("INFO")
local TabAbout = makeTab("ABOUT")
local allTabs = {TabHome, TabInfo, TabAbout}

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
        TextColor3 = Color3.fromRGB(12,12,16),
    }):Play()
end

TabHome.Button.MouseButton1Click:Connect(function() selectTab(TabHome) end)
TabInfo.Button.MouseButton1Click:Connect(function() selectTab(TabInfo) end)
TabAbout.Button.MouseButton1Click:Connect(function() selectTab(TabAbout) end)
selectTab(TabHome)

-- ===== HOME: карточка приветствия =====
local HomeCard = Instance.new("Frame")
HomeCard.Size = UDim2.new(1, 0, 0, 130)
HomeCard.BackgroundColor3 = Color3.fromRGB(18,18,24)
HomeCard.BorderSizePixel = 0
HomeCard.Parent = TabHome.Page

local homeCorner = Instance.new("UICorner")
homeCorner.CornerRadius = UDim.new(0,12)
homeCorner.Parent = HomeCard

local HomeIcon = Instance.new("ImageLabel")
HomeIcon.Size = UDim2.new(0, 46, 0, 46)
HomeIcon.Position = UDim2.new(0.5, -23, 0, 14)
HomeIcon.BackgroundTransparency = 1
HomeIcon.Image = IMAGE_URL
HomeIcon.ScaleType = Enum.ScaleType.Fit
HomeIcon.Parent = HomeCard

local HomeTitle = Instance.new("TextLabel")
HomeTitle.Size = UDim2.new(1, -20, 0, 24)
HomeTitle.Position = UDim2.new(0, 10, 0, 66)
HomeTitle.BackgroundTransparency = 1
HomeTitle.Text = "Welcome, " .. LocalPlayer.DisplayName
HomeTitle.TextColor3 = Color3.fromRGB(0,255,200)
HomeTitle.TextSize = 15
HomeTitle.Font = Enum.Font.GothamBold
HomeTitle.TextXAlignment = Enum.TextXAlignment.Center
HomeTitle.Parent = HomeCard

local HomeSub = Instance.new("TextLabel")
HomeSub.Size = UDim2.new(1, -20, 0, 20)
HomeSub.Position = UDim2.new(0, 10, 0, 92)
HomeSub.BackgroundTransparency = 1
HomeSub.Text = "v2 menu • no functions"
HomeSub.TextColor3 = Color3.fromRGB(120,120,135)
HomeSub.TextSize = 12
HomeSub.Font = Enum.Font.Gotham
HomeSub.TextXAlignment = Enum.TextXAlignment.Center
HomeSub.Parent = HomeCard

-- Кнопка Telegram (карточка)
local TgCard = Instance.new("TextButton")
TgCard.Size = UDim2.new(1, 0, 0, 50)
TgCard.BackgroundColor3 = Color3.fromRGB(18,18,24)
TgCard.BorderSizePixel = 0
TgCard.Text = "  ✈   Join Telegram Channel"
TgCard.TextColor3 = Color3.fromRGB(0,255,200)
TgCard.TextSize = 13
TgCard.Font = Enum.Font.GothamBold
TgCard.TextXAlignment = Enum.TextXAlignment.Left
TgCard.AutoButtonColor = false
TgCard.Parent = TabHome.Page

local tgCardCorner = Instance.new("UICorner")
tgCardCorner.CornerRadius = UDim.new(0,12)
tgCardCorner.Parent = TgCard

local tgCardPad = Instance.new("UIPadding")
tgCardPad.PaddingLeft = UDim.new(0, 12)
tgCardPad.Parent = TgCard

TgCard.MouseEnter:Connect(function()
    TweenService:Create(TgCard, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(0,255,200),
        TextColor3 = Color3.fromRGB(12,12,16),
    }):Play()
end)
TgCard.MouseLeave:Connect(function()
    TweenService:Create(TgCard, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(18,18,24),
        TextColor3 = Color3.fromRGB(0,255,200),
    }):Play()
end)
TgCard.MouseButton1Click:Connect(function()
    if setclipboard then pcall(function() setclipboard(TG_LINK) end) end
    pcall(function()
        game:GetService("GuiService"):OpenBrowserWindow("https://www.google.com/url?q=https://" .. TG_LINK)
    end)
end)

-- ===== INFO: карточки с инфо =====
local function makeInfoCard(parent, y, label, initial)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 42)
    card.Position = UDim2.new(0, 0, 0, y)
    card.BackgroundColor3 = Color3.fromRGB(18,18,24)
    card.BorderSizePixel = 0
    card.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,10)
    c.Parent = card

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, -12, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(180,180,195)
    lbl.TextSize = 13
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = card

    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(0.5, -14, 1, 0)
    val.Position = UDim2.new(0.5, 0, 0, 0)
    val.BackgroundTransparency = 1
    val.Text = initial
    val.TextColor3 = Color3.fromRGB(0,255,200)
    val.TextSize = 13
    val.Font = Enum.Font.GothamBold
    val.TextXAlignment = Enum.TextXAlignment.Right
    val.Parent = card

    return val
end

local ResVal = makeInfoCard(TabInfo.Page, 0, "Resolution", "0x0")
local FpsVal = makeInfoCard(TabInfo.Page, 50, "FPS", "0")
local PingVal = makeInfoCard(TabInfo.Page, 100, "Ping", "--")
local UserVal = makeInfoCard(TabInfo.Page, 150, "User", LocalPlayer.Name)
local IdVal = makeInfoCard(TabInfo.Page, 200, "User ID", tostring(LocalPlayer.UserId))

-- ===== ABOUT =====
local AboutCard = Instance.new("Frame")
AboutCard.Size = UDim2.new(1, 0, 0, 130)
AboutCard.BackgroundColor3 = Color3.fromRGB(18,18,24)
AboutCard.BorderSizePixel = 0
AboutCard.Parent = TabAbout.Page

local aboutCorner = Instance.new("UICorner")
aboutCorner.CornerRadius = UDim.new(0,12)
aboutCorner.Parent = AboutCard

local AboutTitle = Instance.new("TextLabel")
AboutTitle.Size = UDim2.new(1, -24, 0, 22)
AboutTitle.Position = UDim2.new(0, 14, 0, 10)
AboutTitle.BackgroundTransparency = 1
AboutTitle.Text = "About"
AboutTitle.TextColor3 = Color3.fromRGB(0,255,200)
AboutTitle.TextSize = 14
AboutTitle.Font = Enum.Font.GothamBold
AboutTitle.TextXAlignment = Enum.TextXAlignment.Left
AboutTitle.Parent = AboutCard

local AboutText = Instance.new("TextLabel")
AboutText.Size = UDim2.new(1, -28, 0, 80)
AboutText.Position = UDim2.new(0, 14, 0, 36)
AboutText.BackgroundTransparency = 1
AboutText.Text = "test menu v2\n\n• Clean UI design\n• No cheat functions\n• Mobile-friendly layout\n• Draggable window and button"
AboutText.TextColor3 = Color3.fromRGB(200,200,210)
AboutText.TextSize = 12
AboutText.Font = Enum.Font.Gotham
AboutText.TextXAlignment = Enum.TextXAlignment.Left
AboutText.TextYAlignment = Enum.TextYAlignment.Top
AboutText.Parent = AboutCard

-- ===== Обновление Info =====
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
        ResVal.Text = screenResText
        FpsVal.Text = tostring(fpsCurrent)
        local ping = getPing()
        if ping > 0 then
            PingVal.Text = tostring(ping) .. " ms"
        else
            PingVal.Text = "--"
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
            Size = UDim2.new(0, 300, 0, 340)
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

print("test v2 loaded!")
