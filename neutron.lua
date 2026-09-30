-- NEUTRON HUB | Mobile
local Players=game:GetService("Players")local RunService=game:GetService("RunService")local UIS=game:GetService("UserInputService")local WS=game:GetService("Workspace")local TweenService=game:GetService("TweenService")local Stats=game:GetService("Stats")local Camera=WS.CurrentCamera local LP=Players.LocalPlayer local Mouse=LP:GetMouse()
local isMobile=UIS.TouchEnabled
local IMG="rbxassetid://138823883244540" local TG_LINK="t.me/neutron_client"
local SCALE=1 local screenResText="0x0"
local function getScale() local vp=Camera.ViewportSize local diag=math.sqrt(vp.X*vp.X+vp.Y*vp.Y) local s=diag/(1920*1.4) if s<1 then s=1 end if s>3.5 then s=3.5 end screenResText=string.format("%dx%d",math.floor(vp.X),math.floor(vp.Y)) return s end
SCALE=getScale() Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function() SCALE=getScale() end)

local UI_SCALE = isMobile and 1.15 or 1.0
local MENU_W = math.floor(280 * UI_SCALE)
local MENU_H = math.floor(360 * UI_SCALE)
local BTN_SIZE = isMobile and 60 or 50
local TOP_H = isMobile and 50 or 42
local CB_SIZE = isMobile and 40 or 30
local TAB_W = isMobile and 80 or 72

local Config={
    ESP={Enabled=false,Box=true,Name=false,Distance=false,Health=false,Tracer=false,Skeleton=false,Head=false,TeamCheck=true,MaxDistance=500},
    Silent={Enabled=false,Tracer=false,VisibleOnly=false,TeamCheck=true,FOV=150,TargetPart="Head"},
}

local ESPObjects={} local FOVCircle=nil local Open=true local CompletelyClosed=false

local function isTeammate(player)
    if not player or player==LP then return true end
    local myTeam=LP.Team local myColor=LP.TeamColor
    if myTeam and player.Team and player.Team==myTeam then return true end
    if myColor and player.TeamColor and player.TeamColor==myColor then return true end
    local ok1,v1=pcall(function() return player:GetAttribute("Team") end)
    local ok2,v2=pcall(function() return LP:GetAttribute("Team") end)
    if ok1 and ok2 and v1 and v2 and v1==v2 then return true end
    return false
end

local function resolveTargetPart(char,name)
    if not char then return nil end
    if name=="Head" then return char:FindFirstChild("Head") end
    if name=="Torso" then return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("LowerTorso") or char:FindFirstChild("HumanoidRootPart") end
    return char:FindFirstChild(name)
end

local SKELETON_BONES={
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},
    {"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"UpperTorso","RightUpperArm"},
    {"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},{"LowerTorso","LeftUpperLeg"},
    {"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},{"LowerTorso","RightUpperLeg"},
    {"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}
}
local function isR15(c) return c:FindFirstChild("UpperTorso")~=nil end
local function makeLine() local l=Drawing.new("Line") l.Thickness=math.max(1,math.floor(1.5*SCALE)) l.Color=Color3.fromRGB(255,255,255) l.Transparency=1 l.Visible=false return l end

local function createESP(player)
    if player==LP then return end
    if ESPObjects[player] then return end
    local d={}
    d.Box=Drawing.new("Square") d.Box.Thickness=math.max(1,1.5*SCALE) d.Box.Color=Color3.fromRGB(0,255,200) d.Box.Filled=false d.Box.Transparency=1 d.Box.Visible=false
    d.Name=Drawing.new("Text") d.Name.Size=math.floor(14*SCALE) d.Name.Center=true d.Name.Outline=true d.Name.Color=Color3.fromRGB(255,255,255) d.Name.Visible=false
    d.Distance=Drawing.new("Text") d.Distance.Size=math.floor(13*SCALE) d.Distance.Center=true d.Distance.Outline=true d.Distance.Color=Color3.fromRGB(200,200,200) d.Distance.Visible=false
    d.HealthBG=makeLine() d.HealthBG.Thickness=math.max(2,3*SCALE) d.HealthBG.Color=Color3.fromRGB(0,0,0)
    d.HealthBar=makeLine() d.HealthBar.Thickness=math.max(2,3*SCALE) d.HealthBar.Color=Color3.fromRGB(0,255,0)
    d.Tracer=makeLine() d.Tracer.Color=Color3.fromRGB(0,255,200)
    d.SkeletonLines={}
    for i=1,#SKELETON_BONES do d.SkeletonLines[i]=makeLine() end
    d.HeadCircle=Drawing.new("Circle") d.HeadCircle.Thickness=math.max(1,1.5*SCALE) d.HeadCircle.NumSides=24 d.HeadCircle.Radius=10*SCALE d.HeadCircle.Filled=false d.HeadCircle.Color=Color3.fromRGB(255,255,255) d.HeadCircle.Transparency=1 d.HeadCircle.Visible=false
    ESPObjects[player]=d
end

local function removeESP(player)
    local o=ESPObjects[player]
    if not o then return end
    for _,v in pairs(o) do
        if typeof(v)=="table" then for _,x in pairs(v) do pcall(function() x:Remove() end) end
        elseif typeof(v)=="userdata" then pcall(function() v:Remove() end) end
    end
    ESPObjects[player]=nil
end

local function hideAll(o)
    o.Box.Visible=false o.Name.Visible=false o.Distance.Visible=false o.HealthBG.Visible=false o.HealthBar.Visible=false o.Tracer.Visible=false o.HeadCircle.Visible=false
    for _,l in pairs(o.SkeletonLines) do l.Visible=false end
end

local function getBodyFrame(char)
    local h=char:FindFirstChild("Head") local r=char:FindFirstChild("HumanoidRootPart")
    if not h or not r then return nil end
    local hp,hon=Camera:WorldToViewportPoint(h.Position) if not hon then return nil end
    local lowY=nil
    for _,n in ipairs({"LeftFoot","RightFoot","LeftLowerLeg","RightLowerLeg","LeftLeg","RightLeg","LowerTorso","Torso","HumanoidRootPart"}) do
        local p=char:FindFirstChild(n)
        if p then local sp,on=Camera:WorldToViewportPoint(p.Position) if on and (lowY==nil or sp.Y>lowY) then lowY=sp.Y end end
    end
    if not lowY then local sp,on=Camera:WorldToViewportPoint(r.Position) if on then lowY=sp.Y else return nil end end
    local hgt=math.abs(lowY-hp.Y) if hgt<4 then hgt=6*SCALE end
    local w=hgt*0.55 local cx=hp.X
    return {top=Vector2.new(cx-w/2,hp.Y),bottom=Vector2.new(cx+w/2,hp.Y+hgt),centerX=cx,height=hgt}
end
local function w2s(p) local sp,on=Camera:WorldToViewportPoint(p) if on then return Vector2.new(sp.X,sp.Y) end return nil end

local function updateESP()
    for p,o in pairs(ESPObjects) do
        if not Config.ESP.Enabled then hideAll(o); continue end
        local c=p.Character if not c then hideAll(o); continue end
        local r=c:FindFirstChild("HumanoidRootPart") local hum=c:FindFirstChildOfClass("Humanoid")
        if not r or not hum or hum.Health<=0 then hideAll(o); continue end
        if Config.ESP.TeamCheck and isTeammate(p) then hideAll(o); continue end
        local dist=(Camera.CFrame.Position-r.Position).Magnitude
        if dist>Config.ESP.MaxDistance then hideAll(o); continue end
        local f=getBodyFrame(c)
        if f then
            local t=f.top local b=f.bottom
            if Config.ESP.Box then o.Box.Size=Vector2.new(b.X-t.X,b.Y-t.Y) o.Box.Position=t o.Box.Visible=true else o.Box.Visible=false end
            if Config.ESP.Name then o.Name.Text=p.Name o.Name.Position=Vector2.new(f.centerX,t.Y-20*SCALE) o.Name.Visible=true else o.Name.Visible=false end
            if Config.ESP.Distance then o.Distance.Text=string.format("[%d m]",math.floor(dist)) o.Distance.Position=Vector2.new(f.centerX,b.Y+2*SCALE) o.Distance.Visible=true else o.Distance.Visible=false end
            if Config.ESP.Health then
                local pc=math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1) local bh=b.Y-t.Y local off=6*SCALE
                o.HealthBG.From=Vector2.new(t.X-off,t.Y) o.HealthBG.To=Vector2.new(t.X-off,b.Y) o.HealthBG.Visible=true
                o.HealthBar.From=Vector2.new(t.X-off,b.Y-bh*pc) o.HealthBar.To=Vector2.new(t.X-off,b.Y)
                o.HealthBar.Color=Color3.fromRGB(math.floor(255*(1-pc)),math.floor(255*pc),0) o.HealthBar.Visible=true
            else o.HealthBar.Visible=false o.HealthBG.Visible=false end
            if Config.ESP.Tracer then
                o.Tracer.From=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y)
                o.Tracer.To=Vector2.new(f.centerX,b.Y) o.Tracer.Visible=true
            else o.Tracer.Visible=false end
        else
            o.Box.Visible=false o.Name.Visible=false o.Distance.Visible=false o.HealthBar.Visible=false o.HealthBG.Visible=false o.Tracer.Visible=false
        end
        if Config.ESP.Skeleton and isR15(c) then
            for i,bone in ipairs(SKELETON_BONES) do
                local a=c:FindFirstChild(bone[1]) local bb=c:FindFirstChild(bone[2]) local ln=o.SkeletonLines[i]
                if a and bb then
                    local pa=w2s(a.Position) local pb=w2s(bb.Position)
                    if pa and pb then ln.From=pa ln.To=pb ln.Visible=true else ln.Visible=false end
                else ln.Visible=false end
            end
        else for _,l in pairs(o.SkeletonLines) do l.Visible=false end end
        if Config.ESP.Head then
            local hd=c:FindFirstChild("Head")
            if hd then
                local pt=w2s(hd.Position)
                if pt and f then o.HeadCircle.Position=pt o.HeadCircle.Radius=math.max(f.height*0.16,8*SCALE) o.HeadCircle.Visible=true
                else o.HeadCircle.Visible=false end
            else o.HeadCircle.Visible=false end
        else o.HeadCircle.Visible=false end
    end
end

-- SILENT AIM (исправленный)
local SilentTarget=nil

local function getVisibleCheck(targetChar)
    if not Config.Silent.VisibleOnly then return true end
    local myChar=LP.Character if not myChar then return false end
    local myHead=myChar:FindFirstChild("Head") or myChar:FindFirstChild("HumanoidRootPart")
    if not myHead then return false end
    local rp=RaycastParams.new()
    rp.FilterDescendantsInstances={myChar,targetChar,Camera} rp.FilterType=Enum.RaycastFilterType.Exclude rp.IgnoreWater=true
    local pts={}
    for _,n in ipairs({"Head","UpperTorso","Torso","LowerTorso","HumanoidRootPart"}) do
        local p=targetChar:FindFirstChild(n) if p then table.insert(pts,p.Position) end
    end
    if #pts==0 then return false end
    for _,tp in ipairs(pts) do
        if WS:Raycast(myHead.Position,tp-myHead.Position,rp)==nil then return true end
    end
    return false
end

local function findSilentTarget()
    local closest,shortest=nil,math.huge
    local center=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
    for _,p in pairs(Players:GetPlayers()) do
        if p==LP then continue end
        local c=p.Character if not c then continue end
        local hum=c:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health<=0 then continue end
        if Config.Silent.TeamCheck and isTeammate(p) then continue end
        local part=resolveTargetPart(c,Config.Silent.TargetPart) if not part then continue end
        if not getVisibleCheck(c) then continue end
        local sp,on=Camera:WorldToViewportPoint(part.Position) if not on then continue end
        local d=(Vector2.new(sp.X,sp.Y)-center).Magnitude
        if d<shortest and d<=Config.Silent.FOV then shortest=d closest=part end
    end
    return closest
end

-- ХУК 1: Mouse.Hit / Mouse.Target
local mt=getrawmetatable(game) setreadonly(mt,false)
local oldIndex=mt.__index
mt.__index=newcclosure(function(self,key)
    if not checkcaller() and Config.Silent.Enabled and self==Mouse then
        if key=="Hit" or key=="Target" then
            if SilentTarget then
                if key=="Hit" then return CFrame.new(SilentTarget.Position)
                else return SilentTarget end
            end
        end
    end
    return oldIndex(self,key)
end)

-- ХУК 2: __namecall (RemoteEvent FireServer/InvokeServer)
local oldNamecall=mt.__namecall
mt.__namecall=newcclosure(function(self,...)
    local method=getnamecallmethod()
    if not checkcaller() and Config.Silent.Enabled and SilentTarget then
        if method=="FireServer" or method=="InvokeServer" then
            local args={...}
            for i,arg in ipairs(args) do
                if typeof(arg)=="CFrame" then
                    args[i]=CFrame.new(arg.Position,SilentTarget.Position)
                elseif typeof(arg)=="Vector3" then
                    local dir=(SilentTarget.Position-Camera.CFrame.Position).Unit
                    args[i]=dir*arg.Magnitude
                end
            end
            return oldNamecall(self,table.unpack(args))
        end
    end
    return oldNamecall(self,...)
end)
setreadonly(mt,true)

-- ХУК 3: Camera:ViewportPointToRay
local oldVPR=Camera.ViewportPointToRay
Camera.ViewportPointToRay=newcclosure(function(self,x,y,depth)
    if not checkcaller() and Config.Silent.Enabled and SilentTarget then
        local cx=Camera.ViewportSize.X/2 local cy=Camera.ViewportSize.Y/2
        if math.abs(x-cx)<5 and math.abs(y-cy)<5 then
            local dir=(SilentTarget.Position-Camera.CFrame.Position).Unit
            return Ray.new(Camera.CFrame.Position,dir*(depth or 1000))
        end
    end
    return oldVPR(self,x,y,depth)
end)

-- ХУК 4: Camera:ScreenPointToRay
local oldSPR=Camera.ScreenPointToRay
Camera.ScreenPointToRay=newcclosure(function(self,x,y,depth)
    if not checkcaller() and Config.Silent.Enabled and SilentTarget then
        local cx=Camera.ViewportSize.X/2 local cy=Camera.ViewportSize.Y/2
        if math.abs(x-cx)<5 and math.abs(y-cy)<5 then
            local dir=(SilentTarget.Position-Camera.CFrame.Position).Unit
            return Ray.new(Camera.CFrame.Position,dir*(depth or 1000))
        end
    end
    return oldSPR(self,x,y,depth)
end)

local function createFOVCircle()
    if FOVCircle then FOVCircle:Remove() end
    FOVCircle=Drawing.new("Circle") FOVCircle.Thickness=math.max(1,1.5*SCALE) FOVCircle.NumSides=60 FOVCircle.Radius=Config.Silent.FOV FOVCircle.Filled=false FOVCircle.Color=Color3.fromRGB(255,60,60) FOVCircle.Transparency=0.7 FOVCircle.Visible=false
end
createFOVCircle()

local ScreenGui=Instance.new("ScreenGui") ScreenGui.Name="NeutronHub" ScreenGui.ResetOnSpawn=false ScreenGui.IgnoreGuiInset=true ScreenGui.DisplayOrder=999 ScreenGui.Parent=(gethui and gethui()) or LP:WaitForChild("PlayerGui")

local ToggleBtn=Instance.new("ImageButton") ToggleBtn.Size=UDim2.new(0,BTN_SIZE,0,BTN_SIZE) ToggleBtn.Position=UDim2.new(0,12,0.4,0) ToggleBtn.BackgroundColor3=Color3.fromRGB(15,15,20) ToggleBtn.BorderSizePixel=0 ToggleBtn.Image=IMG ToggleBtn.ScaleType=Enum.ScaleType.Fit ToggleBtn.AutoButtonColor=false ToggleBtn.Active=true ToggleBtn.Parent=ScreenGui
local tbc=Instance.new("UICorner") tbc.CornerRadius=UDim.new(1,0) tbc.Parent=ToggleBtn
local tbs=Instance.new("UIStroke") tbs.Color=Color3.fromRGB(0,255,200) tbs.Thickness=2 tbs.Transparency=0.3 tbs.Parent=ToggleBtn

local Main=Instance.new("Frame") Main.Size=UDim2.new(0,MENU_W,0,MENU_H) Main.Position=UDim2.new(0.5,-MENU_W/2,0.5,-MENU_H/2) Main.BackgroundColor3=Color3.fromRGB(15,15,20) Main.BorderSizePixel=0 Main.Active=true Main.ClipsDescendants=true Main.Parent=ScreenGui
local mc=Instance.new("UICorner") mc.CornerRadius=UDim.new(0,16) mc.Parent=Main
local ms=Instance.new("UIStroke") ms.Color=Color3.fromRGB(0,255,200) ms.Thickness=1.5 ms.Transparency=0.4 ms.Parent=Main

local TopBar=Instance.new("Frame") TopBar.Size=UDim2.new(1,0,0,TOP_H) TopBar.BackgroundColor3=Color3.fromRGB(22,22,30) TopBar.BorderSizePixel=0 TopBar.Active=true TopBar.Parent=Main
local tc2=Instance.new("UICorner") tc2.CornerRadius=UDim.new(0,16) tc2.Parent=TopBar
local tf=Instance.new("Frame") tf.Size=UDim2.new(1,0,0,16) tf.Position=UDim2.new(0,0,1,-16) tf.BackgroundColor3=Color3.fromRGB(22,22,30) tf.BorderSizePixel=0 tf.Parent=TopBar

local Ttl=Instance.new("TextLabel") Ttl.Size=UDim2.new(1,-160,1,0) Ttl.Position=UDim2.new(0,48,0,0) Ttl.BackgroundTransparency=1 Ttl.Text="NEUTRON HUB" Ttl.TextColor3=Color3.fromRGB(0,255,200) Ttl.TextSize=isMobile and 16 or 15 Ttl.Font=Enum.Font.GothamBold Ttl.TextXAlignment=Enum.TextXAlignment.Left Ttl.Parent=TopBar

local CB=Instance.new("TextButton") CB.Size=UDim2.new(0,CB_SIZE,0,CB_SIZE) CB.Position=UDim2.new(1,-CB_SIZE-8,0.5,-CB_SIZE/2) CB.BackgroundTransparency=1 CB.Text="X" CB.TextColor3=Color3.fromRGB(255,90,90) CB.TextSize=isMobile and 28 or 24 CB.Font=Enum.Font.GothamBold CB.AutoButtonColor=false CB.Parent=TopBar
local MB=Instance.new("TextButton") MB.Size=UDim2.new(0,CB_SIZE,0,CB_SIZE) MB.Position=UDim2.new(1,-CB_SIZE*2-16,0.5,-CB_SIZE/2) MB.BackgroundTransparency=1 MB.Text="-" MB.TextColor3=Color3.fromRGB(200,200,200) MB.TextSize=isMobile and 28 or 24 MB.Font=Enum.Font.GothamBold MB.AutoButtonColor=false MB.Parent=TopBar

local TabsFrame=Instance.new("Frame") TabsFrame.Size=UDim2.new(0,TAB_W,1,-(TOP_H+8)) TabsFrame.Position=UDim2.new(0,6,0,TOP_H+4) TabsFrame.BackgroundColor3=Color3.fromRGB(18,18,24) TabsFrame.BorderSizePixel=0 TabsFrame.Parent=Main
local tfc=Instance.new("UICorner") tfc.CornerRadius=UDim.new(0,10) tfc.Parent=TabsFrame
local TL=Instance.new("UIListLayout") TL.Padding=UDim.new(0,5) TL.SortOrder=Enum.SortOrder.LayoutOrder TL.HorizontalAlignment=Enum.HorizontalAlignment.Center TL.Parent=TabsFrame
local TPD=Instance.new("UIPadding") TPD.PaddingTop=UDim.new(0,8) TPD.Parent=TabsFrame

local Content=Instance.new("Frame") Content.Size=UDim2.new(1,-TAB_W-16,1,-(TOP_H+8)) Content.Position=UDim2.new(0,TAB_W+10,0,TOP_H+4) Content.BackgroundTransparency=1 Content.ClipsDescendants=true Content.Parent=Main

local bDr=false local bDS=nil local bSP=nil local bMv=false
local function bUpd(i) local d=i.Position-bDS if math.abs(d.X)>8 or math.abs(d.Y)>8 then bMv=true end ToggleBtn.Position=UDim2.new(bSP.X.Scale,bSP.X.Offset+d.X,bSP.Y.Scale,bSP.Y.Offset+d.Y) end
ToggleBtn.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then bDr=true bMv=false bDS=i.Position bSP=ToggleBtn.Position end end)
ToggleBtn.InputChanged:Connect(function(i) if bDr and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then bUpd(i) end end)
ToggleBtn.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then bDr=false end end)
UIS.InputChanged:Connect(function(i) if bDr and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then bUpd(i) end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then bDr=false end end)

local mDr=false local mDS=nil local mSP=nil
local function mUpd(i) local d=i.Position-mDS Main.Position=UDim2.new(mSP.X.Scale,mSP.X.Offset+d.X,mSP.Y.Scale,mSP.Y.Offset+d.Y) end
TopBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then mDr=true mDS=i.Position mSP=Main.Position end end)
TopBar.InputChanged:Connect(function(i) if mDr and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then mUpd(i) end end)
TopBar.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then mDr=false end end)
UIS.InputChanged:Connect(function(i) if mDr and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then mUpd(i) end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then mDr=false end end)

local function mkTab(n)
    local b=Instance.new("TextButton") b.Size=UDim2.new(1,-12,0,isMobile and 42 or 38) b.BackgroundColor3=Color3.fromRGB(25,25,33) b.BorderSizePixel=0 b.Text=n b.TextColor3=Color3.fromRGB(200,200,200) b.TextSize=isMobile and 13 or 12 b.Font=Enum.Font.GothamBold b.AutoButtonColor=false b.Parent=TabsFrame
    local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,8) c.Parent=b
    local pg=Instance.new("ScrollingFrame") pg.Size=UDim2.new(1,0,1,0) pg.BackgroundTransparency=1 pg.BorderSizePixel=0 pg.ScrollBarThickness=4 pg.ScrollBarImageColor3=Color3.fromRGB(0,255,200) pg.CanvasSize=UDim2.new(0,0,0,0) pg.AutomaticCanvasSize=Enum.AutomaticSize.Y pg.Visible=false pg.Parent=Content
    local l=Instance.new("UIListLayout") l.Padding=UDim.new(0,6) l.SortOrder=Enum.SortOrder.LayoutOrder l.Parent=pg
    local pd=Instance.new("UIPadding") pd.PaddingTop=UDim.new(0,4) pd.PaddingRight=UDim.new(0,8) pd.PaddingBottom=UDim.new(0,4) pd.Parent=pg
    return {B=b,P=pg}
end

local V=mkTab("ESP") local S=mkTab("AIM") local MS=mkTab("MISC") local Tabs={V,S,MS}

local function selTab(t)
    for _,x in pairs(Tabs) do
        x.P.Visible=false
        TweenService:Create(x.B,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(25,25,33),TextColor3=Color3.fromRGB(200,200,200)}):Play()
    end
    t.P.Visible=true
    TweenService:Create(t.B,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(0,255,200),TextColor3=Color3.fromRGB(15,15,20)}):Play()
end
V.B.MouseButton1Click:Connect(function() selTab(V) end) S.B.MouseButton1Click:Connect(function() selTab(S) end) MS.B.MouseButton1Click:Connect(function() selTab(MS) end) selTab(V)

local function addTgl(parent,text,default,cb)
    local ROW_H = isMobile and 42 or 36
    local h=Instance.new("Frame") h.Size=UDim2.new(1,0,0,ROW_H) h.BackgroundColor3=Color3.fromRGB(22,22,30) h.BorderSizePixel=0 h.Parent=parent.P
    local hc=Instance.new("UICorner") hc.CornerRadius=UDim.new(0,8) hc.Parent=h
    local l=Instance.new("TextLabel") l.Size=UDim2.new(1,-70,1,0) l.Position=UDim2.new(0,12,0,0) l.BackgroundTransparency=1 l.Text=text l.TextColor3=Color3.fromRGB(220,220,220) l.TextSize=isMobile and 13 or 12 l.Font=Enum.Font.Gotham l.TextXAlignment=Enum.TextXAlignment.Left l.Parent=h
    local SW_W = isMobile and 46 or 42
    local SW_H = isMobile and 24 or 22
    local tg=Instance.new("TextButton") tg.Size=UDim2.new(0,SW_W,0,SW_H) tg.Position=UDim2.new(1,-SW_W-10,0.5,-SW_H/2) tg.BackgroundColor3=Color3.fromRGB(40,40,50) tg.BorderSizePixel=0 tg.Text="" tg.AutoButtonColor=false tg.Parent=h
    local tc=Instance.new("UICorner") tc.CornerRadius=UDim.new(1,0) tc.Parent=tg
    local K_SIZE = isMobile and 18 or 16
    local k=Instance.new("Frame") k.Size=UDim2.new(0,K_SIZE,0,K_SIZE) k.Position=UDim2.new(0,3,0.5,-K_SIZE/2) k.BackgroundColor3=Color3.fromRGB(200,200,200) k.BorderSizePixel=0 k.Parent=tg
    local kc=Instance.new("UICorner") kc.CornerRadius=UDim.new(1,0) kc.Parent=k
    local st=default or false
    local function rf()
        if st then
            TweenService:Create(tg,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(0,255,200)}):Play()
            TweenService:Create(k,TweenInfo.new(0.15),{Position=UDim2.new(1,-K_SIZE-3,0.5,-K_SIZE/2),BackgroundColor3=Color3.fromRGB(15,15,20)}):Play()
        else
            TweenService:Create(tg,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(40,40,50)}):Play()
            TweenService:Create(k,TweenInfo.new(0.15),{Position=UDim2.new(0,3,0.5,-K_SIZE/2),BackgroundColor3=Color3.fromRGB(200,200,200)}):Play()
        end
    end
    rf()
    tg.MouseButton1Click:Connect(function() st=not st rf() if cb then cb(st) end end)
end

local function addSld(parent,text,mx,mn,df,cb)
    local ROW_H = isMobile and 58 or 50
    local h=Instance.new("Frame") h.Size=UDim2.new(1,0,0,ROW_H) h.BackgroundColor3=Color3.fromRGB(22,22,30) h.BorderSizePixel=0 h.Parent=parent.P
    local hc=Instance.new("UICorner") hc.CornerRadius=UDim.new(0,8) hc.Parent=h
    local l=Instance.new("TextLabel") l.Size=UDim2.new(1,-70,0,22) l.Position=UDim2.new(0,12,0,6) l.BackgroundTransparency=1 l.Text=text l.TextColor3=Color3.fromRGB(220,220,220) l.TextSize=isMobile and 13 or 12 l.Font=Enum.Font.Gotham l.TextXAlignment=Enum.TextXAlignment.Left l.Parent=h
    local vl=Instance.new("TextLabel") vl.Size=UDim2.new(0,55,0,22) vl.Position=UDim2.new(1,-65,0,6) vl.BackgroundTransparency=1 vl.Text=tostring(df) vl.TextColor3=Color3.fromRGB(0,255,200) vl.TextSize=isMobile and 13 or 12 vl.Font=Enum.Font.GothamBold vl.TextXAlignment=Enum.TextXAlignment.Right vl.Parent=h
    local BAR_H = isMobile and 8 or 6
    local b=Instance.new("Frame") b.Size=UDim2.new(1,-24,0,BAR_H) b.Position=UDim2.new(0,12,0,ROW_H-16) b.BackgroundColor3=Color3.fromRGB(40,40,50) b.BorderSizePixel=0 b.Parent=h
    local bc=Instance.new("UICorner") bc.CornerRadius=UDim.new(1,0) bc.Parent=b
    local f=Instance.new("Frame") f.Size=UDim2.new((df-mn)/(mx-mn),0,1,0) f.BackgroundColor3=Color3.fromRGB(0,255,200) f.BorderSizePixel=0 f.Parent=b
    local fc=Instance.new("UICorner") fc.CornerRadius=UDim.new(1,0) fc.Parent=f
    local dr=false
    local function upd(i)
        local r=math.clamp((i.Position.X-b.AbsolutePosition.X)/b.AbsoluteSize.X,0,1)
        local c=math.floor(mn+(mx-mn)*r+0.5)
        vl.Text=tostring(c) f.Size=UDim2.new(r,0,1,0)
        if cb then cb(c) end
    end
    b.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dr=true upd(i) end end)
    UIS.InputChanged:Connect(function(i) if dr and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then upd(i) end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dr=false end end)
end

local function addDd(parent,text,opts,cb)
    local ROW_H = isMobile and 42 or 36
    local OPT_H = isMobile and 32 or 26
    local h=Instance.new("Frame") h.Size=UDim2.new(1,0,0,ROW_H) h.BackgroundColor3=Color3.fromRGB(22,22,30) h.BorderSizePixel=0 h.ClipsDescendants=true h.Parent=parent.P
    local hc=Instance.new("UICorner") hc.CornerRadius=UDim.new(0,8) hc.Parent=h
    local b=Instance.new("TextButton") b.Size=UDim2.new(1,0,0,ROW_H) b.BackgroundTransparency=1 b.Text=text..": "..opts[1] b.TextColor3=Color3.fromRGB(220,220,220) b.TextSize=isMobile and 13 or 12 b.Font=Enum.Font.Gotham b.TextXAlignment=Enum.TextXAlignment.Left b.Parent=h
    local pd=Instance.new("UIPadding") pd.PaddingLeft=UDim.new(0,12) pd.Parent=b
    local op=false
    b.MouseButton1Click:Connect(function() op=not op h.Size=op and UDim2.new(1,0,0,ROW_H+#opts*OPT_H) or UDim2.new(1,0,0,ROW_H) end)
    for i,o in ipairs(opts) do
        local ob=Instance.new("TextButton") ob.Size=UDim2.new(1,-12,0,OPT_H-4) ob.Position=UDim2.new(0,6,0,ROW_H+(i-1)*OPT_H) ob.BackgroundColor3=Color3.fromRGB(30,30,40) ob.BorderSizePixel=0 ob.Text=o ob.TextColor3=Color3.fromRGB(200,200,200) ob.TextSize=isMobile and 12 or 11 ob.Font=Enum.Font.Gotham ob.Parent=h
        local oc=Instance.new("UICorner") oc.CornerRadius=UDim.new(0,6) oc.Parent=ob
        ob.MouseButton1Click:Connect(function() b.Text=text..": "..o op=false h.Size=UDim2.new(1,0,0,ROW_H) if cb then cb(o) end end)
    end
end

addTgl(V,"ESP Enabled",false,function(s) Config.ESP.Enabled=s end)
addTgl(V,"Box",true,function(s) Config.ESP.Box=s end)
addTgl(V,"Name",false,function(s) Config.ESP.Name=s end)
addTgl(V,"Distance",false,function(s) Config.ESP.Distance=s end)
addTgl(V,"Health Bar",false,function(s) Config.ESP.Health=s end)
addTgl(V,"Tracer",false,function(s) Config.ESP.Tracer=s end)
addTgl(V,"Skeleton",false,function(s) Config.ESP.Skeleton=s end)
addTgl(V,"Head Circle",false,function(s) Config.ESP.Head=s end)
addTgl(V,"Team Check",true,function(s) Config.ESP.TeamCheck=s end)
addSld(V,"Max Distance",2000,50,500,function(v) Config.ESP.MaxDistance=v end)

addTgl(S,"Silent Aim Enabled",false,function(s)
    Config.Silent.Enabled=s
    if FOVCircle then FOVCircle.Visible=s end
end)
addTgl(S,"Tracer",false,function(s) Config.Silent.Tracer=s end)
addTgl(S,"Visible Only",false,function(s) Config.Silent.VisibleOnly=s end)
addTgl(S,"Team Check",true,function(s) Config.Silent.TeamCheck=s end)
addSld(S,"FOV",180,30,150,function(v)
    Config.Silent.FOV=v
    if FOVCircle then FOVCircle.Radius=v end
end)
addDd(S,"Target Part",{"Head","Torso"},function(v) Config.Silent.TargetPart=v end)

local TG_H = isMobile and 110 or 96
local TgHolder=Instance.new("Frame") TgHolder.Size=UDim2.new(1,0,0,TG_H) TgHolder.BackgroundColor3=Color3.fromRGB(22,22,30) TgHolder.BorderSizePixel=0 TgHolder.Parent=MS.P
local tghc=Instance.new("UICorner") tghc.CornerRadius=UDim.new(0,8) tghc.Parent=TgHolder
local TgLabel=Instance.new("TextLabel") TgLabel.Size=UDim2.new(1,-24,0,20) TgLabel.Position=UDim2.new(0,12,0,8) TgLabel.BackgroundTransparency=1 TgLabel.Text="Support author:" TgLabel.TextColor3=Color3.fromRGB(220,220,220) TgLabel.TextSize=isMobile and 13 or 12 TgLabel.Font=Enum.Font.Gotham TgLabel.TextXAlignment=Enum.TextXAlignment.Left TgLabel.Parent=TgHolder
local TG_BTN_H = isMobile and 34 or 28
local TgLink=Instance.new("TextButton") TgLink.Size=UDim2.new(1,-24,0,TG_BTN_H) TgLink.Position=UDim2.new(0,12,0,32) TgLink.BackgroundColor3=Color3.fromRGB(30,30,40) TgLink.BorderSizePixel=0 TgLink.Text=TG_LINK TgLink.TextColor3=Color3.fromRGB(0,255,200) TgLink.TextSize=isMobile and 14 or 13 TgLink.Font=Enum.Font.GothamBold TgLink.AutoButtonColor=false TgLink.Parent=TgHolder
local tgc=Instance.new("UICorner") tgc.CornerRadius=UDim.new(0,6) tgc.Parent=TgLink
local TgHint=Instance.new("TextLabel") TgHint.Size=UDim2.new(1,-24,0,18) TgHint.Position=UDim2.new(0,12,0,32+TG_BTN_H+6) TgHint.BackgroundTransparency=1 TgHint.Text="(tap to copy)" TgHint.TextColor3=Color3.fromRGB(150,150,165) TgHint.TextSize=isMobile and 12 or 11 TgHint.Font=Enum.Font.Gotham TgHint.TextXAlignment=Enum.TextXAlignment.Center TgHint.Parent=TgHolder
local TgNotify=Instance.new("TextLabel") TgNotify.Size=UDim2.new(1,-24,0,18) TgNotify.Position=UDim2.new(0,12,0,32+TG_BTN_H+6) TgNotify.BackgroundTransparency=1 TgNotify.Text="" TgNotify.TextColor3=Color3.fromRGB(0,255,200) TgNotify.TextSize=isMobile and 12 or 11 TgNotify.Font=Enum.Font.GothamBold TgNotify.TextXAlignment=Enum.TextXAlignment.Center TgNotify.Parent=TgHolder
local function cp(t)
    local ok=false
    if setclipboard then pcall(function() setclipboard(t) ok=true end) end
    if not ok and toclipboard then pcall(function() toclipboard(t) ok=true end) end
    return ok
end
TgLink.MouseButton1Click:Connect(function()
    local c=cp(TG_LINK)
    TgHint.Visible=false
    if c then TgNotify.Text="Copied!" TgNotify.TextColor3=Color3.fromRGB(0,255,200)
    else TgNotify.Text="Failed" TgNotify.TextColor3=Color3.fromRGB(255,90,90) end
    pcall(function() game:GetService("GuiService"):OpenBrowserWindow("https://www.google.com/url?q=https://"..TG_LINK) end)
    task.delay(3,function() TgNotify.Text="" TgHint.Visible=true end)
end)
TgLink.MouseEnter:Connect(function() TweenService:Create(TgLink,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(0,255,200),TextColor3=Color3.fromRGB(15,15,20)}):Play() end)
TgLink.MouseLeave:Connect(function() TweenService:Create(TgLink,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(30,30,40),TextColor3=Color3.fromRGB(0,255,200)}):Play() end)

local INFO_H = isMobile and 110 or 96
local IH=Instance.new("Frame") IH.Size=UDim2.new(1,0,0,INFO_H) IH.BackgroundColor3=Color3.fromRGB(22,22,30) IH.BorderSizePixel=0 IH.Parent=MS.P
local ihc=Instance.new("UICorner") ihc.CornerRadius=UDim.new(0,8) ihc.Parent=IH
local ROW1_Y = 28
local ROW2_Y = isMobile and 52 or 46
local ROW3_Y = isMobile and 76 or 66
local IT=Instance.new("TextLabel") IT.Size=UDim2.new(1,-24,0,20) IT.Position=UDim2.new(0,12,0,6) IT.BackgroundTransparency=1 IT.Text="Info:" IT.TextColor3=Color3.fromRGB(220,220,220) IT.TextSize=isMobile and 13 or 12 IT.Font=Enum.Font.Gotham IT.TextXAlignment=Enum.TextXAlignment.Left IT.Parent=IH
local RL=Instance.new("TextLabel") RL.Size=UDim2.new(1,-24,0,22) RL.Position=UDim2.new(0,12,0,ROW1_Y) RL.BackgroundTransparency=1 RL.Text="Resolution:" RL.TextColor3=Color3.fromRGB(200,200,200) RL.TextSize=isMobile and 13 or 12 RL.Font=Enum.Font.Gotham RL.TextXAlignment=Enum.TextXAlignment.Left RL.Parent=IH
local RV=Instance.new("TextLabel") RV.Size=UDim2.new(0,110,0,22) RV.Position=UDim2.new(1,-122,0,ROW1_Y) RV.BackgroundTransparency=1 RV.Text="0x0" RV.TextColor3=Color3.fromRGB(0,255,200) RV.TextSize=isMobile and 13 or 12 RV.Font=Enum.Font.GothamBold RV.TextXAlignment=Enum.TextXAlignment.Right RV.Parent=IH
local FL=Instance.new("TextLabel") FL.Size=UDim2.new(1,-24,0,22) FL.Position=UDim2.new(0,12,0,ROW2_Y) FL.BackgroundTransparency=1 FL.Text="FPS:" FL.TextColor3=Color3.fromRGB(200,200,200) FL.TextSize=isMobile and 13 or 12 FL.Font=Enum.Font.Gotham FL.TextXAlignment=Enum.TextXAlignment.Left FL.Parent=IH
local FV=Instance.new("TextLabel") FV.Size=UDim2.new(0,110,0,22) FV.Position=UDim2.new(1,-122,0,ROW2_Y) FV.BackgroundTransparency=1 FV.Text="0" FV.TextColor3=Color3.fromRGB(0,255,200) FV.TextSize=isMobile and 13 or 12 FV.Font=Enum.Font.GothamBold FV.TextXAlignment=Enum.TextXAlignment.Right FV.Parent=IH
local PL=Instance.new("TextLabel") PL.Size=UDim2.new(1,-24,0,22) PL.Position=UDim2.new(0,12,0,ROW3_Y) PL.BackgroundTransparency=1 PL.Text="Ping:" PL.TextColor3=Color3.fromRGB(200,200,200) PL.TextSize=isMobile and 13 or 12 PL.Font=Enum.Font.Gotham PL.TextXAlignment=Enum.TextXAlignment.Left PL.Parent=IH
local PV=Instance.new("TextLabel") PV.Size=UDim2.new(0,110,0,22) PV.Position=UDim2.new(1,-122,0,ROW3_Y) PV.BackgroundTransparency=1 PV.Text="0 ms" PV.TextColor3=Color3.fromRGB(0,255,200) PV.TextSize=isMobile and 13 or 12 PV.Font=Enum.Font.GothamBold PV.TextXAlignment=Enum.TextXAlignment.Right PV.Parent=IH

local fpsFrames=0 local fpsTime=os.clock() local fpsCurrent=0
RunService.RenderStepped:Connect(function()
    fpsFrames=fpsFrames+1
    local now=os.clock()
    if now-fpsTime>=1 then fpsCurrent=fpsFrames fpsFrames=0 fpsTime=now end
end)
local function getPing()
    local ok,ping=pcall(function() return LP:GetNetworkPing() end)
    if ok and ping and ping>0 then return math.floor(ping*1000) end
    local ok2,val=pcall(function()
        local ss=Stats.Network.ServerStatsItem
        if ss and ss["Data Ping"] then return math.floor(ss["Data Ping"]:GetValue()) end
    end)
    if ok2 and type(val)=="number" then return val end
    return 0
end
task.spawn(function()
    while not CompletelyClosed do
        RV.Text=screenResText
        FV.Text=tostring(fpsCurrent)
        local ping=getPing()
        if ping>0 then PV.Text=tostring(ping).." ms" else PV.Text="--" end
        task.wait(0.5)
    end
end)

local function setOpen(s)
    Open=s
    if s then
        Main.Visible=true Main.Size=UDim2.new(0,0,0,0)
        TweenService:Create(Main,TweenInfo.new(0.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,MENU_W,0,MENU_H)}):Play()
    else
        local t=TweenService:Create(Main,TweenInfo.new(0.15),{Size=UDim2.new(0,0,0,0)})
        t:Play() t.Completed:Connect(function() Main.Visible=false end)
    end
end
local function fullClose()
    CompletelyClosed=true Open=false
    local t=TweenService:Create(Main,TweenInfo.new(0.15),{Size=UDim2.new(0,0,0,0)})
    t:Play() t.Completed:Connect(function()
        Main.Visible=false ToggleBtn.Visible=false
        Config.ESP.Enabled=false Config.Silent.Enabled=false
        if FOVCircle then FOVCircle.Visible=false end
        for _,o in pairs(ESPObjects) do hideAll(o) end
    end)
end
setOpen(true)
ToggleBtn.MouseButton1Click:Connect(function() if CompletelyClosed then return end if not bMv then setOpen(not Open) end end)
MB.MouseButton1Click:Connect(function() if CompletelyClosed then return end setOpen(false) end)
MB.MouseEnter:Connect(function() MB.TextColor3=Color3.fromRGB(0,255,200) end)
MB.MouseLeave:Connect(function() MB.TextColor3=Color3.fromRGB(200,200,200) end)
CB.MouseButton1Click:Connect(function() fullClose() end)
CB.MouseEnter:Connect(function() CB.TextColor3=Color3.fromRGB(255,30,30) end)
CB.MouseLeave:Connect(function() CB.TextColor3=Color3.fromRGB(255,90,90) end)

for _,p in pairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

RunService.RenderStepped:Connect(function()
    if CompletelyClosed then return end
    if Config.Silent.Enabled then SilentTarget=findSilentTarget() else SilentTarget=nil end
    updateESP()
    if FOVCircle and FOVCircle.Visible then
        FOVCircle.Position=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
    end
end)

print("NEUTRON HUB loaded!")
