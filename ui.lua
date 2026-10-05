-- Arcane UI - reconstructed clean source
-- Rebuilt from the supplied 4,054-line envlogger/decompiler trace.
-- Keeps the Arcane-style API and visual layout without the logger/deobfuscator runtime.

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Arcane = {}
Arcane.__index = Arcane
Arcane.Flags = {}
Arcane.Windows = {}
Arcane.Connections = {}
Arcane.OpenFrames = {}
Arcane.CurrentTheme = "Dark"
Arcane.PreviousTheme = "Dark"
Arcane.MenuKeybind = Enum.KeyCode.RightControl
Arcane.Animation = {Time=.25, Style=Enum.EasingStyle.Quart, Direction=Enum.EasingDirection.Out}

Arcane.Theme = {
    Text = Color3.fromRGB(255,255,255),
    Accent = Color3.fromRGB(254,0,67),
    AccentDark = Color3.fromRGB(210,0,55),
    Background = Color3.fromRGB(16,16,18),
    Border = Color3.fromRGB(30,29,34),
    DimIcon = Color3.fromRGB(70,70,78),
    DimText = Color3.fromRGB(120,120,130),
    Divider = Color3.fromRGB(30,29,34),
    DropdownBack = Color3.fromRGB(27,26,33),
    DropdownSelected = Color3.fromRGB(37,36,43),
    Element = Color3.fromRGB(27,26,33),
    Inline = Color3.fromRGB(22,22,26),
    Section = Color3.fromRGB(21,20,25),
    Selected = Color3.fromRGB(29,28,37),
    SliderBack = Color3.fromRGB(27,26,33),
    SliderKnob = Color3.fromRGB(255,255,255),
    ToggleOff = Color3.fromRGB(35,25,38),
    ToggleOffCircle = Color3.fromRGB(78,73,84),
    ToggleOn = Color3.fromRGB(176,15,58),
    Topbar = Color3.fromRGB(22,22,26)
}

local function safe(fn,...)
    if type(fn)~="function" then return end
    local ok,err=pcall(fn,...)
    if not ok then warn("[Arcane callback]",err) end
end

local function inst(class, props)
    local o=Instance.new(class)
    for k,v in pairs(props or {}) do
        if k~="Parent" then pcall(function() o[k]=v end) end
    end
    if props and props.Parent then o.Parent=props.Parent end
    return o
end

local function corner(p,r)
    return inst("UICorner",{Parent=p,CornerRadius=UDim.new(0,r or 6)})
end
local function stroke(p,c,t)
    return inst("UIStroke",{Parent=p,Color=c or Arcane.Theme.Border,Transparency=t or 0,Thickness=1})
end
local function list(p,pad)
    return inst("UIListLayout",{Parent=p,Padding=UDim.new(0,pad or 6),SortOrder=Enum.SortOrder.LayoutOrder})
end
local function padding(p,l,r,t,b)
    return inst("UIPadding",{Parent=p,PaddingLeft=UDim.new(0,l or 0),PaddingRight=UDim.new(0,r or 0),PaddingTop=UDim.new(0,t or 0),PaddingBottom=UDim.new(0,b or 0)})
end
local function tw(o,props,time)
    local x=TweenService:Create(o,TweenInfo.new(time or Arcane.Animation.Time,Arcane.Animation.Style,Arcane.Animation.Direction),props)
    x:Play()
    return x
end

local parent
pcall(function() if gethui then parent=gethui() end end)
parent=parent or CoreGui

pcall(function()
    local old=parent:FindFirstChild("Arcane")
    if old then old:Destroy() end
end)

local Holder=inst("ScreenGui",{Name="Arcane",IgnoreGuiInset=true,ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Global,Parent=parent})
Arcane.Holder={Class="ScreenGui",Instance=Holder,Properties={Name="Arcane",IgnoreGuiInset=true,ResetOnSpawn=false}}
Arcane.UIScale={Class="UIScale",Instance=inst("UIScale",{Parent=Holder,Scale=1})}

local NotifHolder=inst("Frame",{Parent=Holder,Name="Notifications",AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-12,0,12),Size=UDim2.new(0,280,1,-24),BackgroundTransparency=1})
list(NotifHolder,8)
Arcane.NotifHolder={Class="Frame",Instance=NotifHolder}

local KeybindHolder=inst("Frame",{Parent=Holder,Name="Keybinds",Position=UDim2.new(0,15,.5,-100),Size=UDim2.new(0,220,0,36),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=Arcane.Theme.Section,Visible=false})
corner(KeybindHolder,8); stroke(KeybindHolder)
local kbTitle=inst("TextLabel",{Parent=KeybindHolder,Size=UDim2.new(1,-20,0,30),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,Text="Keybinds",TextColor3=Arcane.Theme.Text,TextSize=14,Font=Enum.Font.GothamMedium})
local kbContent=inst("Frame",{Parent=KeybindHolder,Position=UDim2.new(0,10,0,34),Size=UDim2.new(1,-20,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1})
list(kbContent,3)
Arcane.KeybindList={Items={Holder={Instance=KeybindHolder},Title={Instance=kbTitle},Content={Instance=kbContent}}}
function Arcane.KeybindList:Add(name)
    local row=inst("TextLabel",{Parent=kbContent,Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,Text=tostring(name),TextColor3=Arcane.Theme.DimText,TextSize=13,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left})
    return row
end
function Arcane.KeybindList:SetVisibility(v)
    KeybindHolder.Visible = v==nil and not KeybindHolder.Visible or not not v
end

function Arcane:MakeDraggable(frame,handle)
    handle=handle or frame
    local dragging,startPos,startInput
    table.insert(self.Connections,handle.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true; startInput=i.Position; startPos=frame.Position
        end
    end))
    table.insert(self.Connections,UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-startInput
            frame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end))
    table.insert(self.Connections,UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end))
end

function Arcane:Notification(o)
    o=o or {}
    local box=inst("Frame",{Parent=NotifHolder,Size=UDim2.new(1,0,0,73),BackgroundColor3=Arcane.Theme.Section,ClipsDescendants=true})
    corner(box,10); stroke(box)
    inst("Frame",{Parent=box,Size=UDim2.new(0,3,1,0),BackgroundColor3=o.Color or Arcane.Theme.Accent,BorderSizePixel=0})
    inst("TextLabel",{Parent=box,Position=UDim2.new(0,14,0,10),Size=UDim2.new(1,-28,0,20),BackgroundTransparency=1,Text=o.Name or o.Title or "Notification",TextColor3=Arcane.Theme.Text,TextSize=14,Font=Enum.Font.GothamMedium,TextXAlignment=Enum.TextXAlignment.Left})
    inst("TextLabel",{Parent=box,Position=UDim2.new(0,14,0,34),Size=UDim2.new(1,-28,0,28),BackgroundTransparency=1,Text=o.Description or o.Content or "",TextColor3=Arcane.Theme.DimText,TextSize=13,Font=Enum.Font.Gotham,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top})
    task.delay(tonumber(o.Duration) or 3,function()
        if box.Parent then tw(box,{BackgroundTransparency=1},.2); task.wait(.22); box:Destroy() end
    end)
    return box
end
Arcane.Notify=Arcane.Notification

local function makeControl(section,h)
    return inst("Frame",{Parent=section.Content,Size=UDim2.new(1,0,0,h or 38),BackgroundTransparency=1})
end
local function label(parent,text,pos,size,color,align)
    return inst("TextLabel",{Parent=parent,Position=pos or UDim2.new(),Size=size or UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=tostring(text or ""),TextColor3=color or Arcane.Theme.Text,TextSize=14,Font=Enum.Font.Gotham,TextXAlignment=align or Enum.TextXAlignment.Left})
end

function Arcane:Button(section,o)
    o=o or {}
    local row=makeControl(section,46)
    local b=inst("TextButton",{Parent=row,AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,9),Size=UDim2.new(1,-24,0,28),BackgroundColor3=Arcane.Theme.Element,Text="",AutoButtonColor=false})
    corner(b,4)
    label(b,o.Name or o.Text or "Button",UDim2.new(0,10,0,0),UDim2.new(1,-20,1,0),Arcane.Theme.Text,Enum.TextXAlignment.Center)
    b.MouseButton1Click:Connect(function() tw(b,{BackgroundColor3=Arcane.Theme.Selected},.1); safe(o.Callback); task.delay(.12,function() if b.Parent then tw(b,{BackgroundColor3=Arcane.Theme.Element},.15) end end) end)
    return {Instance=b,Set=function(_,v) b.Text=tostring(v) end}
end

function Arcane:Toggle(section,o)
    o=o or {}
    local row=makeControl(section,38)
    label(row,o.Name or "Toggle",UDim2.new(0,12,0,0),UDim2.new(1,-70,1,0))
    local bg=inst("TextButton",{Parent=row,AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-12,.5,0),Size=UDim2.new(0,38,0,20),BackgroundColor3=Arcane.Theme.ToggleOff,Text="",AutoButtonColor=false})
    corner(bg,10)
    local dot=inst("Frame",{Parent=bg,Position=UDim2.new(0,3,.5,-7),Size=UDim2.new(0,14,0,14),BackgroundColor3=Arcane.Theme.ToggleOffCircle})
    corner(dot,7)
    local state=not not (o.Default or o.Value)
    local flag=o.Flag
    local api={}
    local function set(v,fire)
        state=not not v
        if flag then Arcane.Flags[flag]=state end
        tw(bg,{BackgroundColor3=state and Arcane.Theme.ToggleOn or Arcane.Theme.ToggleOff})
        tw(dot,{Position=state and UDim2.new(1,-17,.5,-7) or UDim2.new(0,3,.5,-7),BackgroundColor3=state and Arcane.Theme.Text or Arcane.Theme.ToggleOffCircle})
        if fire~=false then safe(o.Callback,state) end
    end
    function api:Set(v) set(v,true) end
    function api:Get() return state end
    bg.MouseButton1Click:Connect(function() set(not state,true) end)
    set(state,false)
    return api
end

function Arcane:Textbox(section,o)
    o=o or {}
    local row=makeControl(section,54)
    label(row,o.Name or "Textbox",UDim2.new(0,12,0,2),UDim2.new(1,-24,0,20),Arcane.Theme.DimText)
    local box=inst("TextBox",{Parent=row,Position=UDim2.new(0,12,0,25),Size=UDim2.new(1,-24,0,26),BackgroundColor3=Arcane.Theme.Element,PlaceholderText=o.Placeholder or "Enter text...",Text=tostring(o.Default or ""),TextColor3=Arcane.Theme.Text,PlaceholderColor3=Arcane.Theme.DimText,TextSize=14,Font=Enum.Font.Gotham,ClearTextOnFocus=false})
    corner(box,4); padding(box,8,8,0,0)
    box.FocusLost:Connect(function(enter)
        if o.Flag then Arcane.Flags[o.Flag]=box.Text end
        safe(o.Callback,box.Text,enter)
    end)
    return {Instance=box,Set=function(_,v) box.Text=tostring(v or "") end,Get=function() return box.Text end}
end
Arcane.Input=Arcane.Textbox

function Arcane:Slider(section,o)
    o=o or {}
    local min,max=tonumber(o.Min) or 0,tonumber(o.Max) or 100
    local value=math.clamp(tonumber(o.Default or o.Value) or min,min,max)
    local row=makeControl(section,52)
    local title=label(row,o.Name or "Slider",UDim2.new(0,12,0,0),UDim2.new(1,-80,0,24))
    local val=label(row,tostring(value),UDim2.new(1,-70,0,0),UDim2.new(0,58,0,24),Arcane.Theme.DimText,Enum.TextXAlignment.Right)
    local bar=inst("TextButton",{Parent=row,Position=UDim2.new(0,12,0,31),Size=UDim2.new(1,-24,0,6),BackgroundColor3=Arcane.Theme.SliderBack,Text="",AutoButtonColor=false})
    corner(bar,3)
    local fill=inst("Frame",{Parent=bar,Size=UDim2.new((value-min)/(max-min),0,1,0),BackgroundColor3=Arcane.Theme.Accent}); corner(fill,3)
    local dragging=false
    local api={}
    local function set(v,fire)
        value=math.clamp(tonumber(v) or min,min,max)
        if o.Rounding~=false then value=math.floor(value+.5) end
        local p=(value-min)/(max-min)
        fill.Size=UDim2.new(p,0,1,0); val.Text=tostring(value)
        if o.Flag then Arcane.Flags[o.Flag]=value end
        if fire~=false then safe(o.Callback,value) end
    end
    local function fromX(x) set(min+(max-min)*math.clamp((x-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1),true) end
    bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true; fromX(i.Position.X) end end)
    UIS.InputChanged:Connect(function(i) if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then fromX(i.Position.X) end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
    function api:Set(v) set(v,true) end
    function api:Get() return value end
    set(value,false)
    return api
end
Arcane.RangeSlider=Arcane.Slider

function Arcane:Dropdown(section,o)
    o=o or {}
    local items=o.Items or o.Options or {}
    local row=makeControl(section,44)
    local button=inst("TextButton",{Parent=row,Position=UDim2.new(0,12,0,8),Size=UDim2.new(1,-24,0,28),BackgroundColor3=Arcane.Theme.Element,Text="",AutoButtonColor=false})
    corner(button,4)
    local txt=label(button,o.Name or "Dropdown",UDim2.new(0,9,0,0),UDim2.new(1,-36,1,0))
    local arrow=label(button,"▼",UDim2.new(1,-28,0,0),UDim2.new(0,20,1,0),Arcane.Theme.DimText,Enum.TextXAlignment.Center)
    local pop=inst("Frame",{Parent=Holder,Visible=false,Size=UDim2.new(0,200,0,180),BackgroundColor3=Arcane.Theme.DropdownBack,ZIndex=100})
    corner(pop,6); stroke(pop)
    local search=inst("TextBox",{Parent=pop,Position=UDim2.new(0,6,0,6),Size=UDim2.new(1,-12,0,25),BackgroundColor3=Arcane.Theme.Element,Text="",PlaceholderText="Search...",TextColor3=Arcane.Theme.Text,PlaceholderColor3=Arcane.Theme.DimText,TextSize=13,Font=Enum.Font.Gotham,ClearTextOnFocus=false,ZIndex=101}); corner(search,4); padding(search,7,7)
    local scroll=inst("ScrollingFrame",{Parent=pop,Position=UDim2.new(0,5,0,36),Size=UDim2.new(1,-10,1,-41),BackgroundTransparency=1,BorderSizePixel=0,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=3,ScrollBarImageColor3=Arcane.Theme.DimText,ZIndex=101})
    list(scroll,3)
    local selected=o.Default
    local api={}
    local function choose(v,fire)
        selected=v
        txt.Text=(o.Name and (o.Name..": ") or "")..tostring(v)
        if o.Flag then Arcane.Flags[o.Flag]=v end
        pop.Visible=false
        if fire~=false then safe(o.Callback,v) end
    end
    local function rebuild(newItems)
        items=newItems or items
        for _,c in ipairs(scroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        local q=string.lower(search.Text)
        for _,v in ipairs(items) do
            local s=tostring(v)
            if q=="" or string.find(string.lower(s),q,1,true) then
                local b=inst("TextButton",{Parent=scroll,Size=UDim2.new(1,-2,0,26),BackgroundColor3=Arcane.Theme.Element,Text=s,TextColor3=Arcane.Theme.Text,TextSize=13,Font=Enum.Font.Gotham,AutoButtonColor=false,ZIndex=102})
                corner(b,4); b.MouseButton1Click:Connect(function() choose(v,true) end)
            end
        end
    end
    button.MouseButton1Click:Connect(function()
        pop.Position=UDim2.fromOffset(button.AbsolutePosition.X,button.AbsolutePosition.Y+button.AbsoluteSize.Y+4)
        pop.Size=UDim2.fromOffset(math.max(button.AbsoluteSize.X,180),180)
        pop.Visible=not pop.Visible
        rebuild(items)
    end)
    search:GetPropertyChangedSignal("Text"):Connect(function() rebuild(items) end)
    function api:Set(v) choose(v,true) end
    function api:Get() return selected end
    function api:Refresh(v) items=v or {}; rebuild(items) end
    api.SetOptions=api.Refresh
    if selected~=nil then choose(selected,false) end
    return api
end
Arcane.Selector=Arcane.Dropdown
Arcane.List=Arcane.Dropdown

function Arcane:Colorpicker(section,o)
    o=o or {}
    local row=makeControl(section,38)
    label(row,o.Name or "Color",UDim2.new(0,12,0,0),UDim2.new(1,-60,1,0))
    local color=o.Default or o.Color or Arcane.Theme.Accent
    local sw=inst("TextButton",{Parent=row,AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-12,.5,0),Size=UDim2.new(0,34,0,18),BackgroundColor3=color,Text=""}); corner(sw,4)
    return {Set=function(_,v) color=v; sw.BackgroundColor3=v; safe(o.Callback,v) end,Get=function() return color end}
end

function Arcane:Section(parent,o)
    o=type(o)=="table" and o or {Name=tostring(o or "Section")}
    local sec=inst("Frame",{Parent=parent.Content or parent,Size=UDim2.new(1,0,0,36),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=Arcane.Theme.Section})
    corner(sec,7); stroke(sec)
    label(sec,o.Name or "Section",UDim2.new(0,12,0,5),UDim2.new(1,-24,0,24),Arcane.Theme.Text)
    local content=inst("Frame",{Parent=sec,Position=UDim2.new(0,0,0,31),Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1})
    padding(content,0,0,0,8); list(content,0)
    local api={Instance=sec,Content=content}
    function api:Button(x) return Arcane:Button(api,x) end
    function api:Toggle(x) return Arcane:Toggle(api,x) end
    function api:Dropdown(x) return Arcane:Dropdown(api,x) end
    function api:Selector(x) return Arcane:Dropdown(api,x) end
    function api:List(x) return Arcane:Dropdown(api,x) end
    function api:Slider(x) return Arcane:Slider(api,x) end
    function api:RangeSlider(x) return Arcane:Slider(api,x) end
    function api:Textbox(x) return Arcane:Textbox(api,x) end
    function api:Input(x) return Arcane:Textbox(api,x) end
    function api:Colorpicker(x) return Arcane:Colorpicker(api,x) end
    function api:Label(x)
        local r=makeControl(api,30); local l=label(r,type(x)=="table" and (x.Name or x.Text) or x,UDim2.new(0,12,0,0),UDim2.new(1,-24,1,0),Arcane.Theme.DimText)
        return {Set=function(_,v) l.Text=tostring(v) end,Instance=l}
    end
    return api
end

local function buildPage(window,o,isSub)
    o=type(o)=="table" and o or {Name=tostring(o or "Page")}
    local name=o.Name or o.Title or (isSub and "SubPage" or "Page")
    local tab=inst("TextButton",{Parent=window.SidebarContent,Size=UDim2.new(1,0,0,30),BackgroundColor3=Arcane.Theme.Element,BackgroundTransparency=1,Text=name,TextColor3=Arcane.Theme.DimText,TextSize=13,Font=Enum.Font.Gotham,AutoButtonColor=false})
    corner(tab,5)
    local page=inst("ScrollingFrame",{Parent=window.Pages,Visible=false,Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),ScrollBarThickness=3,ScrollBarImageColor3=Arcane.Theme.DimText})
    padding(page,8,8,8,8); list(page,8)
    local api={Instance=page,Content=page,Tab=tab,Name=name,Window=window}
    function api:Section(x) return Arcane:Section(api,x) end
    function api:SubPage(x) return buildPage(window,x,true) end
    function api:Button(x) window._defaultSection=window._defaultSection or api:Section({Name="Main"}); return window._defaultSection:Button(x) end
    function api:Toggle(x) window._defaultSection=window._defaultSection or api:Section({Name="Main"}); return window._defaultSection:Toggle(x) end
    function api:Dropdown(x) window._defaultSection=window._defaultSection or api:Section({Name="Main"}); return window._defaultSection:Dropdown(x) end
    function api:Slider(x) window._defaultSection=window._defaultSection or api:Section({Name="Main"}); return window._defaultSection:Slider(x) end
    function api:Textbox(x) window._defaultSection=window._defaultSection or api:Section({Name="Main"}); return window._defaultSection:Textbox(x) end
    function api:Select()
        for _,p in ipairs(window._pages) do p.Instance.Visible=false; p.Tab.TextColor3=Arcane.Theme.DimText; p.Tab.BackgroundTransparency=1 end
        page.Visible=true; tab.TextColor3=Arcane.Theme.Text; tab.BackgroundTransparency=0
        window.Title.Text=name
    end
    tab.MouseButton1Click:Connect(api.Select)
    table.insert(window._pages,api)
    if #window._pages==1 then api:Select() end
    return api
end

function Arcane:Window(o)
    o=o or {}
    local size=o.Size or UDim2.fromOffset(650,430)
    local root=inst("Frame",{Parent=Holder,Name=o.Name or "Window",AnchorPoint=Vector2.new(.5,.5),Position=o.Position or UDim2.fromScale(.5,.5),Size=size,BackgroundColor3=Arcane.Theme.Background,ClipsDescendants=true})
    corner(root,10); stroke(root)
    local top=inst("Frame",{Parent=root,Size=UDim2.new(1,0,0,42),BackgroundColor3=Arcane.Theme.Topbar})
    local accent=inst("Frame",{Parent=top,Position=UDim2.new(0,0,1,-2),Size=UDim2.new(1,0,0,2),BackgroundColor3=Arcane.Theme.Accent,BorderSizePixel=0})
    local title=label(top,o.Name or o.Title or "Arcane",UDim2.new(0,14,0,0),UDim2.new(1,-100,1,0),Arcane.Theme.Text)
    title.Font=Enum.Font.GothamMedium
    local user=label(top,o.User or (LocalPlayer and LocalPlayer.Name) or "User",UDim2.new(1,-190,0,0),UDim2.new(0,140,1,0),Arcane.Theme.DimText,Enum.TextXAlignment.Right)
    local close=inst("TextButton",{Parent=top,AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-10,.5,0),Size=UDim2.new(0,28,0,28),BackgroundColor3=Arcane.Theme.Selected,Text="×",TextColor3=Arcane.Theme.Text,TextSize=18,Font=Enum.Font.Gotham})
    corner(close,6)
    local side=inst("Frame",{Parent=root,Position=UDim2.new(0,0,0,42),Size=UDim2.new(0,150,1,-42),BackgroundColor3=Arcane.Theme.Inline})
    local sideContent=inst("Frame",{Parent=side,Position=UDim2.new(0,8,0,10),Size=UDim2.new(1,-16,1,-20),BackgroundTransparency=1}); list(sideContent,5)
    local pages=inst("Frame",{Parent=root,Position=UDim2.new(0,150,0,42),Size=UDim2.new(1,-150,1,-42),BackgroundTransparency=1})
    local api={Instance=root,Topbar=top,Title=title,Sidebar=side,SidebarContent=sideContent,Pages=pages,_pages={}}
    function api:Page(x) return buildPage(api,x,false) end
    function api:SubPage(x) return buildPage(api,x,true) end
    function api:SetVisibility(v) root.Visible=v==nil and not root.Visible or not not v end
    function api:Toggle() root.Visible=not root.Visible end
    function api:Destroy() root:Destroy() end
    close.MouseButton1Click:Connect(function() root.Visible=false end)
    Arcane:MakeDraggable(root,top)
    table.insert(Arcane.Windows,api)
    return api
end
Arcane.CreateWindow=Arcane.Window

function Arcane:Page(window,o) return buildPage(window,o,false) end
function Arcane:SubPage(window,o) return buildPage(window,o,true) end
function Arcane:SetTheme(name)
    self.PreviousTheme=self.CurrentTheme
    self.CurrentTheme=tostring(name or "Dark")
end
function Arcane:ChangeTheme(name) return self:SetTheme(name) end
function Arcane:ApplyTheme() end
function Arcane:ApplyThemeInstant() end
function Arcane:GetScreenScale() return self.UIScale.Instance.Scale end
function Arcane:GetTweenProperty() return nil end
function Arcane:Round(n,p) local m=10^(p or 0); return math.floor(n*m+.5)/m end
function Arcane:SafeCall(fn,...) return safe(fn,...) end
function Arcane:Thread(fn,...) return task.spawn(fn,...) end
function Arcane:Tween(obj,props) return tw(obj,props) end
function Arcane:Config() return self.Flags end
function Arcane:GetConfig()
    local clean={}
    for k,v in pairs(self.Flags) do
        if type(v)=="boolean" or type(v)=="number" or type(v)=="string" then clean[k]=v end
    end
    return HttpService:JSONEncode(clean)
end
function Arcane:LoadConfig(data)
    local ok,t=pcall(HttpService.JSONDecode,HttpService,data)
    if ok and type(t)=="table" then for k,v in pairs(t) do self.Flags[k]=v end end
    return ok
end
function Arcane:GetConfigsList(dropdown) if dropdown and dropdown.Refresh then dropdown:Refresh({}) end end
function Arcane:Unload()
    for _,c in ipairs(self.Connections) do pcall(function() c:Disconnect() end) end
    table.clear(self.Connections)
    if Holder then Holder:Destroy() end
end

table.insert(Arcane.Connections,UIS.InputBegan:Connect(function(i,gp)
    if gp then return end
    local key=Arcane.MenuKeybind
    if type(key)=="string" then key=Enum.KeyCode[key:gsub("Enum.KeyCode.","")] end
    if i.KeyCode==key then
        for _,w in ipairs(Arcane.Windows) do if w.Instance and w.Instance.Parent then w:Toggle() end end
    end
end))

getgenv().Arcane=Arcane
return Arcane
