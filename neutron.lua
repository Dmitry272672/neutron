-- test | New Menu

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
local ACCENT = Color3.fromRGB(160, 100, 255)   -- фиолетовый
local ACCENT2 = Color3.fromRGB(90, 60, 180)     -- тёмно-фиолетовый
local BG_DARK = Color3.fromRGB(14, 14, 18)
local BG_MID = Color3.fromRGB(22, 22, 28)
local BG_LIGHT = Color3.fromRGB(30, 30, 38)
local TEXT_MAIN = Color3.fromRGB(235, 235, 245)
local TEXT_SUB = Color3.fromRGB(140, 140, 155)

local Open = true
local CompletelyClosed = false

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "test"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui")

-- ===== Кнопка открытия =====
local ToggleBtn = Instance.new("ImageButton")
ToggleBtn.Size = UDim2.new(0, 56, 0, 56)
ToggleBtn.Position = UDim2.new(0, 16, 0.45, 0)
ToggleBtn.BackgroundColor3 = BG_DARK
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Image = IMAGE_URL
ToggleBtn.ScaleType = Enum.ScaleType.Fit
ToggleBtn.AutoButtonColor = false
ToggleBtn.Active = true
ToggleBtn.Parent = ScreenGui

local tbCorner = Instance.new("UICorner")
tbCorner.CornerRadius = UDim.new(1, 0)
tbCorner.Parent = ToggleBtn
local tbStroke = Instance.new("UIStroke")
tbStroke.Color = ACCENT
tbStroke.Thickness = 2
tbStroke.Parent = ToggleBtn

-- ===== Основное окно =====
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 340, 0, 360)
Main.Position = UDim2.new(0.5, -170, 0.5, -180)
Main.BackgroundColor3 = BG_DARK
Main.BorderSizePixel = 0
Main.Active = true
Main.ClipsDescendants = true
Main.Parent = ScreenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 20)
mainCorner.Parent = Main
local mainStroke = Instance.new("UIStroke")
mainStroke.Color = ACCENT
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.4
mainStroke.Parent = Main

-- ===== Сайдбар (слева, узкий) =====
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 70, 1, 0)
Sidebar.BackgroundColor3 = BG_MID
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

local sbCorner = Instance.new("UICorner")
sbCorner.CornerRadius = UDim.new(0, 20)
sbCorner.Parent = Sidebar
local sbFix = Instance.new("Frame")
sbFix.Size = UDim2.new(0, 20, 1, 0)
sbFix.Position = UDim2.new(1, -20, 0, 0)
sbFix.BackgroundColor3 = BG_MID
sbFix.BorderSizePixel = 0
sbFix.Parent = Sidebar

-- Логотип сверху сайдбара
local LogoIcon = Instance.new("ImageLabel")
LogoIcon.Size = UDim2.new(0, 40, 0, 40)
LogoIcon.Position = UDim2.new(0.5, -20, 0, 18)
LogoIcon.BackgroundTransparency = 1
LogoIcon.Image = IMAGE_URL
LogoIcon.ScaleType = Enum.ScaleType.Fit
LogoIcon.Parent = Sidebar

-- Разделитель
local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(0, 40, 0, 1)
Divider.Position = UDim2.new(0.5, -20, 0, 72)
Divider.BackgroundColor3 = BG_LIGHT
Divider.BorderSizePixel = 0
Divider.Parent = Sidebar

-- Кнопки разделов (иконки)
local SidebarButtons = {}

local function makeSidebarButton(text, order, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 46, 0, 46)
    btn.LayoutOrder = order
    btn.BackgroundColor3 = BG_LIGHT
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = TEXT_SUB
    btn.TextSize = 20
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.Parent = Sidebar
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 12)
    c.Parent = btn
    return btn
end

-- Layout для кнопок
local SidebarList = Instance.new("Frame")
SidebarList.Size = UDim2.new(1, 0, 1, -110)
SidebarList.Position = UDim2.new(0, 0, 0, 90)
SidebarList.BackgroundTransparency = 1
SidebarList.Parent = Sidebar

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 8)
ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Parent = SidebarList

-- Временная функция создания кнопок на сайдбар (изменим parent)
local function makeSidebarIcon(text, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 46, 0, 46)
    btn.LayoutOrder = order
    btn.BackgroundColor3 = BG_LIGHT
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = TEXT_SUB
    btn.TextSize = 22
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.Parent = SidebarList
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 12)
    c.Parent = btn
    return btn
end

-- ===== Контент (справа) =====
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -86, 1, -20)
Content.Position = UDim2.new(0, 76, 0, 10)
Content.BackgroundTransparency = 1
Content.ClipsDescendants = true
Content.Parent = Main

-- Заголовок внутри контента
local PageTitle = Instance.new("TextLabel")
PageTitle.Size = UDim2.new(1, -20, 0, 26)
PageTitle.Position = UDim2.new(0, 12, 0, 6)
PageTitle.BackgroundTransparency = 1
PageTitle.Text = "HOME"
PageTitle.TextColor3 = ACCENT
PageTitle.TextSize = 18
PageTitle.Font = Enum.Font.GothamBold
PageTitle.TextXAlignment = Enum.TextXAlignment.Left
PageTitle.Parent = Content

local PageSub = Instance.new("TextLabel")
PageSub.Size = UDim2.new(1, -20, 0, 16)
PageSub.Position = UDim2.new(0, 12, 0, 32)
PageSub.BackgroundTransparency = 1
PageSub.Text = "welcome back"
PageSub.TextColor3 = TEXT_SUB
PageSub.TextSize = 11
PageSub.Font = Enum.Font.Gotham
PageSub.TextXAlignment = Enum.TextXAlignment.Left
PageSub.Parent = Content

-- Разделитель под заголовком
local TitleLine = Instance.new("Frame")
TitleLine.Size = UDim2.new(1, -24, 0, 1)
TitleLine.Position = UDim2.new(0, 12, 0, 54)
TitleLine.BackgroundColor3 = BG_LIGHT
TitleLine.BorderSizePixel = 0
TitleLine.Parent = Content

-- Контейнер страниц
local Pages = Instance.new("Frame")
Pages.Size = UDim2.new(1, -20, 1, -70)
Pages.Position = UDim2.new(0, 10, 0, 62)
Pages.BackgroundTransparency = 1
Pages.ClipsDescendants = true
Pages.Parent = Content

-- ===== Кнопки закрытия =====
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -36, 0, 8)
CloseBtn.BackgroundTransparency = 1
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.TextSize = 20
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = Main

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 28, 0, 28)
MinimizeBtn.Position = UDim2.new(1, -68, 0, 8)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = TEXT_SUB
MinimizeBtn.TextSize = 20
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.AutoButtonColor = false
MinimizeBtn.Parent = Main

-- ===== Перетаскивание (весь Main + TopArea) =====
local DragArea = Instance.new("Frame")
DragArea.Size = UDim2.new(1, 0, 0, 40)
DragArea.Position = UDim2.new(0, 0, 0, 0)
DragArea.BackgroundTransparency = 1
DragArea.Active = true
DragArea.Parent = Main

local menuDragging = false
local menuDragStart = nil
local menuStartPos = nil

local function startMenuDrag(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        menuDragging = true
        menuDragStart = input.Position
        menuStartPos = Main.Position
    end
end
local function stopMenuDrag(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        menuDragging = false
    end
end

DragArea.InputBegan:Connect(startMenuDrag)
DragArea.InputEnded:Connect(stopMenuDrag)
Sidebar.InputBegan:Connect(startMenuDrag)
Sidebar.InputEnded:Connect(stopMenuDrag)

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
UserInputService.InputEnded:Connect(stopMenuDrag)

-- ===== Перетаскивание кнопки =====
local btnDragging = false
local btnDragStart = nil
local btnStartPos = nil
local btnMoved = false

ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        btnDragging = true; btnMoved = false
        btnDragStart = input.Position; btnStartPos = ToggleBtn.Position
    end
end)
ToggleBtn.InputChanged:Connect(function(input)
    if btnDragging and (input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - btnDragStart
        if math.abs(delta.X) > 8 or math.abs(delta.Y) > 8 then btnMoved = true end
        ToggleBtn.Position = UDim2.new(
            btnStartPos.X.Scale, btnStartPos.X.Offset + delta.X,
            btnStartPos.Y.Scale, btnStartPos.Y.Offset + delta.Y
        )
    end
end)
ToggleBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then btnDragging = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if btnDragging and (input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - btnDragStart
        if math.abs(delta.X) > 8 or math.abs(delta.Y) > 8 then btnMoved = true end
        ToggleBtn.Position = UDim2.new(
            btnStartPos.X.Scale, btnStartPos.X.Offset + delta.X,
            btnStartPos.Y.Scale, btnStartPos.Y.Offset + delta.Y
        )
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then btnDragging = false end
end)

-- ===== Создание страниц =====
local PagesData = {}

local function createPage(name, title, subtitle)
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = ACCENT
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = Pages
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 4)
    pad.PaddingRight = UDim.new(0, 6)
    pad.PaddingBottom = UDim.new(0, 4)
    pad.Parent = page
    return { Page = page, Title = title, Subtitle = subtitle, Name = name }
end

local HomePage = createPage("HOME", "HOME", "welcome back")
local InfoPage = createPage("INFO", "INFO", "system stats")
local AboutPage = createPage("ABOUT", "ABOUT", "about menu")
local TgPage = createPage("TG", "TELEGRAM", "join channel")

PagesData = {HomePage, InfoPage, AboutPage, TgPage}

-- ===== Иконки на сайдбаре =====
local Icons = {
    { Icon = "🏠", Page = HomePage },
    { Icon = "📊", Page = InfoPage },
    { Icon = "ℹ",  Page = AboutPage },
    { Icon = "✈",  Page = TgPage },
}

local iconButtons = {}

for i, data in ipairs(Icons) do
    local btn = makeSidebarIcon(data.Icon, i)
    table.insert(iconButtons, { btn = btn, page = data.Page })
end

local function selectPage(entry)
    for _, tab in ipairs(PagesData) do
        tab.Page.Visible = false
    end
    entry.page.Page.Visible = true
    PageTitle.Text = entry.page.Title
    PageSub.Text = entry.page.Subtitle

    for _, ib in ipairs(iconButtons) do
        TweenService:Create(ib.btn, TweenInfo.new(0.15), {
            BackgroundColor3 = BG_LIGHT,
            TextColor3 = TEXT_SUB,
        }):Play()
    end
    TweenService:Create(entry.btn, TweenInfo.new(0.15), {
        BackgroundColor3 = ACCENT,
        TextColor3 = Color3.fromRGB(255,255,255),
    }):Play()
end

for _, ib in ipairs(iconButtons) do
    ib.btn.MouseButton1Click:Connect(function()
        selectPage(ib)
    end)
end

selectPage(iconButtons[1])

-- ===== HOME страница =====
local HomeCard = Instance.new("Frame")
HomeCard.Size = UDim2.new(1, 0, 0, 110)
HomeCard.BackgroundColor3 = BG_MID
HomeCard.BorderSizePixel = 0
HomeCard.Parent = HomePage.Page

local hc = Instance.new("UICorner")
hc.CornerRadius = UDim.new(0, 14)
hc.Parent = HomeCard

local HelloTxt = Instance.new("TextLabel")
HelloTxt.Size = UDim2.new(1, -20, 0, 28)
HelloTxt.Position = UDim2.new(0, 12, 0, 16)
HelloTxt.BackgroundTransparency = 1
HelloTxt.Text = "Hello, " .. LocalPlayer.DisplayName
HelloTxt.TextColor3 = ACCENT
HelloTxt.TextSize = 16
HelloTxt.Font = Enum.Font.GothamBold
HelloTxt.TextXAlignment = Enum.TextXAlignment.Left
HelloTxt.Parent = HomeCard

local HelloSub = Instance.new("TextLabel")
HelloSub.Size = UDim2.new(1, -20, 0, 20)
HelloSub.Position = UDim2.new(0, 12, 0, 46)
HelloSub.BackgroundTransparency = 1
HelloSub.Text = "Welcome to test menu"
HelloSub.TextColor3 = TEXT_MAIN
HelloSub.TextSize = 13
HelloSub.Font = Enum.Font.Gotham
HelloSub.TextXAlignment = Enum.TextXAlignment.Left
HelloSub.Parent = HomeCard

local HelloHint = Instance.new("TextLabel")
HelloHint.Size = UDim2.new(1, -20, 0, 18)
HelloHint.Position = UDim2.new(0, 12, 0, 72)
HelloHint.BackgroundTransparency = 1
HelloHint.Text = "Use sidebar icons to navigate"
HelloHint.TextColor3 = TEXT_SUB
HelloHint.TextSize = 11
HelloHint.Font = Enum.Font.Gotham
HelloHint.TextXAlignment = Enum.TextXAlignment.Left
HelloHint.Parent = HomeCard

-- Кнопка-карточка Telegram
local TgCard = Instance.new("TextButton")
TgCard.Size = UDim2.new(1, 0, 0, 48)
TgCard.BackgroundColor3 = BG_MID
TgCard.BorderSizePixel = 0
TgCard.Text = "  ✈   Join Telegram Channel"
TgCard.TextColor3 = ACCENT
TgCard.TextSize = 13
TgCard.Font = Enum.Font.GothamBold
TgCard.TextXAlignment = Enum.TextXAlignment.Left
TgCard.AutoButtonColor = false
TgCard.Parent = HomePage.Page

local tgc = Instance.new("UICorner")
tgc.CornerRadius = UDim.new(0, 14)
tgc.Parent = TgCard

local tgPad = Instance.new("UIPadding")
tgPad.PaddingLeft = UDim.new(0, 12)
tgPad.Parent = TgCard

TgCard.MouseEnter:Connect(function()
    TweenService:Create(TgCard, TweenInfo.new(0.15), {
        BackgroundColor3 = ACCENT,
        TextColor3 = Color3.fromRGB(255,255,255),
    }):Play()
end)
TgCard.MouseLeave:Connect(function()
    TweenService:Create(TgCard, TweenInfo.new(0.15), {
        BackgroundColor3 = BG_MID,
        TextColor3 = ACCENT,
    }):Play()
end)
TgCard.MouseButton1Click:Connect(function()
    if setclipboard then pcall(function() setclipboard(TG_LINK) end) end
    pcall(function()
        game:GetService("GuiService"):OpenBrowserWindow("https://www.google.com/url?q=https://" .. TG_LINK)
    end)
end)

-- ===== INFO страница =====
local function makeStatCard(parent, order, icon, label, initial)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 52)
    card.LayoutOrder = order
    card.BackgroundColor3 = BG_MID
    card.BorderSizePixel = 0
    card.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 12)
    c.Parent = card

    local iconLbl = Instance.new("TextLabel")
    iconLbl.Size = UDim2.new(0, 40, 1, 0)
    iconLbl.Position = UDim2.new(0, 4, 0, 0)
    iconLbl.BackgroundTransparency = 1
    iconLbl.Text = icon
    iconLbl.TextColor3 = ACCENT
    iconLbl.TextSize = 20
    iconLbl.Font = Enum.Font.GothamBold
    iconLbl.Parent = card

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, -50, 1, 0)
    lbl.Position = UDim2.new(0, 46, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = TEXT_MAIN
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = card

    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(0.5, -14, 1, 0)
    val.Position = UDim2.new(0.5, 0, 0, 0)
    val.BackgroundTransparency = 1
    val.Text = initial
    val.TextColor3 = ACCENT
    val.TextSize = 13
    val.Font = Enum.Font.GothamBold
    val.TextXAlignment = Enum.TextXAlignment.Right
    val.Parent = card

    return val
end

local ResVal = makeStatCard(InfoPage.Page, 1, "📺", "Resolution", "0x0")
local FpsVal = makeStatCard(InfoPage.Page, 2, "⚡", "FPS", "0")
local PingVal = makeStatCard(InfoPage.Page, 3, "📶", "Ping", "--")
local UserVal = makeStatCard(InfoPage.Page, 4, "👤", "Username", LocalPlayer.Name)
local IdVal = makeStatCard(InfoPage.Page, 5, "🆔", "User ID", tostring(LocalPlayer.UserId))

-- ===== ABOUT страница =====
local AboutCard = Instance.new("Frame")
AboutCard.Size = UDim2.new(1, 0, 0, 150)
AboutCard.BackgroundColor3 = BG_MID
AboutCard.BorderSizePixel = 0
AboutCard.Parent = AboutPage.Page

local ac = Instance.new("UICorner")
ac.CornerRadius = UDim.new(0, 14)
ac.Parent = AboutCard

local At = Instance.new("TextLabel")
At.Size = UDim2.new(1, -24, 0, 22)
At.Position = UDim2.new(0, 14, 0, 12)
At.BackgroundTransparency = 1
At.Text = "test menu"
At.TextColor3 = ACCENT
At.TextSize = 15
At.Font = Enum.Font.GothamBold
At.TextXAlignment = Enum.TextXAlignment.Left
At.Parent = AboutCard

local Atx = Instance.new("TextLabel")
Atx.Size = UDim2.new(1, -28, 0, 100)
Atx.Position = UDim2.new(0, 14, 0, 40)
Atx.BackgroundTransparency = 1
Atx.Text = "Version 2.0\n\n• Clean sidebar design\n• Smooth animations\n• Touch-friendly controls\n• No cheat functions"
Atx.TextColor3 = TEXT_MAIN
Atx.TextSize = 12
Atx.Font = Enum.Font.Gotham
Atx.TextXAlignment = Enum.TextXAlignment.Left
Atx.TextYAlignment = Enum.TextYAlignment.Top
Atx.Parent = AboutCard

-- ===== TG страница =====
local TgBigCard = Instance.new("Frame")
TgBigCard.Size = UDim2.new(1, 0, 0, 140)
TgBigCard.BackgroundColor3 = BG_MID
TgBigCard.BorderSizePixel = 0
TgBigCard.Parent = TgPage.Page

local tbc = Instance.new("UICorner")
tbc.CornerRadius = UDim.new(0, 14)
tbc.Parent = TgBigCard

local TgIcon = Instance.new("TextLabel")
TgIcon.Size = UDim2.new(1, 0, 0, 50)
TgIcon.Position = UDim2.new(0, 0, 0, 14)
TgIcon.BackgroundTransparency = 1
TgIcon.Text = "✈"
TgIcon.TextColor3 = ACCENT
TgIcon.TextSize = 42
TgIcon.Font = Enum.Font.GothamBold
TgIcon.Parent = TgBigCard

local TgTitle = Instance.new("TextLabel")
TgTitle.Size = UDim2.new(1, -20, 0, 24)
TgTitle.Position = UDim2.new(0, 10, 0, 70)
TgTitle.BackgroundTransparency = 1
TgTitle.Text = "Telegram Channel"
TgTitle.TextColor3 = TEXT_MAIN
TgTitle.TextSize = 15
TgTitle.Font = Enum.Font.GothamBold
TgTitle.Parent = TgBigCard

local TgLinkTxt = Instance.new("TextLabel")
TgLinkTxt.Size = UDim2.new(1, -20, 0, 20)
TgLinkTxt.Position = UDim2.new(0, 10, 0, 96)
TgLinkTxt.BackgroundTransparency = 1
TgLinkTxt.Text = TG_LINK
TgLinkTxt.TextColor3 = TEXT_SUB
TgLinkTxt.TextSize = 12
TgLinkTxt.Font = Enum.Font.Gotham
TgLinkTxt.Parent = TgBigCard

local TgOpenBtn = Instance.new("TextButton")
TgOpenBtn.Size = UDim2.new(1, 0, 0, 46)
TgOpenBtn.BackgroundColor3 = ACCENT
TgOpenBtn.BorderSizePixel = 0
TgOpenBtn.Text = "OPEN TELEGRAM"
TgOpenBtn.TextColor3 = Color3.fromRGB(255,255,255)
TgOpenBtn.TextSize = 13
TgOpenBtn.Font = Enum.Font.GothamBold
TgOpenBtn.AutoButtonColor = false
TgOpenBtn.Parent = TgPage.Page

local tobc = Instance.new("UICorner")
tobc.CornerRadius = UDim.new(0, 14)
tobc.Parent = TgOpenBtn

TgOpenBtn.MouseEnter:Connect(function()
    TweenService:Create(TgOpenBtn, TweenInfo.new(0.15), { BackgroundColor3 = ACCENT2 }):Play()
end)
TgOpenBtn.MouseLeave:Connect(function()
    TweenService:Create(TgOpenBtn, TweenInfo.new(0.15), { BackgroundColor3 = ACCENT }):Play()
end)
TgOpenBtn.MouseButton1Click:Connect(function()
    if setclipboard then pcall(function() setclipboard(TG_LINK) end) end
    pcall(function()
        game:GetService("GuiService"):OpenBrowserWindow("https://www.google.com/url?q=https://" .. TG_LINK)
    end)
end)

-- ===== FPS / Ping =====
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
        local vp = Camera.ViewportSize
        ResVal.Text = string.format("%dx%d", math.floor(vp.X), math.floor(vp.Y))
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

-- ===== Открытие / закрытие =====
local function setOpen(state)
    Open = state
    if state then
        Main.Visible = true
        Main.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 340, 0, 360)
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
MinimizeBtn.MouseEnter:Connect(function() MinimizeBtn.TextColor3 = ACCENT end)
MinimizeBtn.MouseLeave:Connect(function() MinimizeBtn.TextColor3 = TEXT_SUB end)
CloseBtn.MouseButton1Click:Connect(function() fullyClose() end)
CloseBtn.MouseEnter:Connect(function() CloseBtn.TextColor3 = Color3.fromRGB(255, 30, 30) end)
CloseBtn.MouseLeave:Connect(function() CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80) end)

print("test menu loaded!")
