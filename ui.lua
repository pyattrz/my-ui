-- Arcane-style clean UI replacement
-- Reconstructed to avoid corrupted decompiler/envlogger arg### values.

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local parent
if type(gethui) == "function" then
    local ok, result = pcall(gethui)
    if ok then parent = result end
end
parent = parent or player:WaitForChild("PlayerGui")

local old = parent:FindFirstChild("ArcaneFixedUI")
if old then old:Destroy() end

local Theme = {
    Background = Color3.fromRGB(16,16,18),
    Topbar = Color3.fromRGB(22,22,26),
    Section = Color3.fromRGB(21,20,25),
    Element = Color3.fromRGB(27,26,33),
    Border = Color3.fromRGB(30,29,34),
    Accent = Color3.fromRGB(254,0,67),
    Text = Color3.fromRGB(255,255,255),
    DimText = Color3.fromRGB(120,120,130)
}

local function new(class, props)
    local obj = Instance.new(class)
    for k,v in pairs(props or {}) do obj[k] = v end
    return obj
end

local function corner(obj, radius)
    new("UICorner", {CornerRadius = UDim.new(0, radius or 6), Parent = obj})
end

local function stroke(obj)
    new("UIStroke", {Color = Theme.Border, Thickness = 1, Transparency = 0, Parent = obj})
end

local function list(parentObj, padding)
    return new("UIListLayout", {
        Padding = UDim.new(0,padding or 7),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = parentObj
    })
end

local function label(parentObj, text, size, dim)
    return new("TextLabel", {
        BackgroundTransparency = 1,
        Size = size or UDim2.new(1,0,0,20),
        Font = Enum.Font.Gotham,
        Text = tostring(text or ""),
        TextSize = 13,
        TextColor3 = dim and Theme.DimText or Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = parentObj
    })
end

local Library = {Theme = Theme}

function Library:Window(options)
    options = options or {}

    local gui = new("ScreenGui", {
        Name = "ArcaneFixedUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = parent
    })

    local main = new("Frame", {
        Name = "Window",
        Size = options.Size or UDim2.fromOffset(680,440),
        Position = UDim2.new(0.5,-340,0.5,-220),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Parent = gui
    })
    corner(main,10); stroke(main)

    local top = new("Frame", {
        Size = UDim2.new(1,0,0,48),
        BackgroundColor3 = Theme.Topbar,
        BorderSizePixel = 0,
        Parent = main
    })
    corner(top,10)
    new("Frame", {Position=UDim2.new(0,0,1,-10),Size=UDim2.new(1,0,0,10),BackgroundColor3=Theme.Topbar,BorderSizePixel=0,Parent=top})

    label(top, options.Name or "Arcane", UDim2.new(1,-30,1,0), false).Position = UDim2.fromOffset(15,0)

    local tabs = new("Frame", {
        Position = UDim2.fromOffset(12,60),
        Size = UDim2.new(0,145,1,-72),
        BackgroundTransparency = 1,
        Parent = main
    })
    list(tabs,7)

    local pagesHolder = new("Frame", {
        Position = UDim2.fromOffset(169,60),
        Size = UDim2.new(1,-181,1,-72),
        BackgroundTransparency = 1,
        Parent = main
    })

    -- drag
    local dragging, dragStart, startPos
    top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = main.Position
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)

    local Window = {Pages = {}, Gui = gui, Main = main}

    function Window:Destroy() gui:Destroy() end

    function Window:Page(pageOptions)
        if type(pageOptions) == "string" then pageOptions = {Name=pageOptions} end
        pageOptions = pageOptions or {}
        local name = pageOptions.Name or "Page"

        local tab = new("TextButton", {
            Size = UDim2.new(1,0,0,38),
            BackgroundColor3 = Theme.Element,
            BackgroundTransparency = 0.35,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Text = "  "..name,
            TextColor3 = Theme.DimText,
            TextSize = 13,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = tabs
        })
        corner(tab,7)

        local pageFrame = new("Frame", {
            Size = UDim2.fromScale(1,1),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = pagesHolder
        })

        local subTabs = new("Frame", {
            Size = UDim2.new(1,0,0,38),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = pageFrame
        })
        list(subTabs,6).FillDirection = Enum.FillDirection.Horizontal

        local subHolder = new("Frame", {
            Position = UDim2.fromOffset(0,0),
            Size = UDim2.fromScale(1,1),
            BackgroundTransparency = 1,
            Parent = pageFrame
        })

        local Page = {SubPages={}, Frame=pageFrame, Button=tab}

        function Page:Switch(state)
            pageFrame.Visible = state
            tab.TextColor3 = state and Theme.Text or Theme.DimText
            tab.BackgroundTransparency = state and 0 or 0.35
        end

        local function makeSectionAPI(container, sectionOptions)
            sectionOptions = sectionOptions or {}
            local section = new("Frame", {
                AutomaticSize = Enum.AutomaticSize.Y,
                Size = UDim2.new(1,0,0,0),
                BackgroundColor3 = Theme.Section,
                BorderSizePixel = 0,
                Parent = container
            })
            corner(section,8); stroke(section)
            new("UIPadding", {PaddingTop=UDim.new(0,10),PaddingBottom=UDim.new(0,10),PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10),Parent=section})
            list(section,7)
            local title = label(section, sectionOptions.Name or "Section", UDim2.new(1,0,0,20), false)
            title.Font = Enum.Font.GothamMedium

            local Section = {}

            function Section:Label(data)
                if type(data)=="string" then data={Name=data} end
                return label(section, (data and (data.Name or data.Text)) or "Label", UDim2.new(1,0,0,24), true)
            end

            function Section:Button(data)
                data = data or {}
                local b = new("TextButton", {Size=UDim2.new(1,0,0,34),BackgroundColor3=Theme.Element,BorderSizePixel=0,AutoButtonColor=false,Text=data.Name or "Button",TextColor3=Theme.Text,TextSize=13,Font=Enum.Font.Gotham,Parent=section})
                corner(b,6)
                b.MouseButton1Click:Connect(function()
                    if type(data.Callback)=="function" then task.spawn(data.Callback) end
                end)
                return b
            end

            function Section:Toggle(data)
                data = data or {}
                local state = data.Default == true
                local b = new("TextButton", {Size=UDim2.new(1,0,0,34),BackgroundColor3=Theme.Element,BorderSizePixel=0,AutoButtonColor=false,Text="",Parent=section})
                corner(b,6)
                local t = label(b,data.Name or "Toggle",UDim2.new(1,-55,1,0),false); t.Position=UDim2.fromOffset(10,0)
                local box = new("Frame", {AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-9,0.5,0),Size=UDim2.fromOffset(34,18),BackgroundColor3=state and Theme.Accent or Theme.Border,BorderSizePixel=0,Parent=b}); corner(box,9)
                local dot = new("Frame", {AnchorPoint=Vector2.new(0,0.5),Position=state and UDim2.new(1,-16,0.5,0) or UDim2.new(0,3,0.5,0),Size=UDim2.fromOffset(12,12),BackgroundColor3=Theme.Text,BorderSizePixel=0,Parent=box}); corner(dot,6)
                local api={}
                function api:Set(v, fire)
                    state = v == true
                    TweenService:Create(box,TweenInfo.new(.15),{BackgroundColor3=state and Theme.Accent or Theme.Border}):Play()
                    TweenService:Create(dot,TweenInfo.new(.15),{Position=state and UDim2.new(1,-16,.5,0) or UDim2.new(0,3,.5,0)}):Play()
                    if fire ~= false and type(data.Callback)=="function" then task.spawn(data.Callback,state) end
                end
                b.MouseButton1Click:Connect(function() api:Set(not state,true) end)
                return api
            end

            function Section:Textbox(data)
                data = data or {}
                local wrap = new("Frame", {Size=UDim2.new(1,0,0,54),BackgroundColor3=Theme.Element,BorderSizePixel=0,Parent=section}); corner(wrap,6)
                local n=label(wrap,data.Name or "Textbox",UDim2.new(1,-20,0,20),false); n.Position=UDim2.fromOffset(10,3)
                local box=new("TextBox", {Position=UDim2.fromOffset(10,25),Size=UDim2.new(1,-20,0,22),BackgroundTransparency=1,ClearTextOnFocus=false,Text=tostring(data.Default or ""),PlaceholderText=data.Placeholder or "",PlaceholderColor3=Theme.DimText,TextColor3=Theme.Text,TextSize=13,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,Parent=wrap})
                box.FocusLost:Connect(function(enter)
                    if type(data.Callback)=="function" then task.spawn(data.Callback,box.Text,enter) end
                end)
                return {Instance=box, Set=function(_,v) box.Text=tostring(v) end}
            end

            function Section:Dropdown(data)
                data = data or {}; local items=data.Items or {}; local current=data.Default or items[1] or "None"
                local b=new("TextButton", {Size=UDim2.new(1,0,0,34),BackgroundColor3=Theme.Element,BorderSizePixel=0,AutoButtonColor=false,Text=(data.Name or "Dropdown")..":  "..tostring(current),TextColor3=Theme.Text,TextSize=13,Font=Enum.Font.Gotham,Parent=section}); corner(b,6)
                local index=table.find(items,current) or 1
                local api={}
                function api:Set(v,fire)
                    current=v; b.Text=(data.Name or "Dropdown")..":  "..tostring(v)
                    if fire ~= false and type(data.Callback)=="function" then task.spawn(data.Callback,v) end
                end
                function api:Refresh(newItems)
                    items=newItems or {}; index=1
                    if items[1] then api:Set(items[1],false) end
                end
                b.MouseButton1Click:Connect(function()
                    if #items==0 then return end
                    index=index+1; if index>#items then index=1 end
                    api:Set(items[index],true)
                end)
                return api
            end

            Section.Selector = Section.Dropdown
            return Section
        end

        local directLeft = new("ScrollingFrame", {Size=UDim2.new(.5,-7,1,0),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=0,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),Parent=subHolder})
        local directRight = new("ScrollingFrame", {AnchorPoint=Vector2.new(1,0),Position=UDim2.fromScale(1,0),Size=UDim2.new(.5,-7,1,0),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=0,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),Parent=subHolder})
        list(directLeft,10); list(directRight,10)

        function Page:Section(opts)
            opts=opts or {}; return makeSectionAPI(opts.Side==2 and directRight or directLeft,opts)
        end

        function Page:SubPage(subOptions)
            if type(subOptions)=="string" then subOptions={Name=subOptions} end
            subOptions=subOptions or {}; subTabs.Visible=true; subHolder.Position=UDim2.fromOffset(0,46); subHolder.Size=UDim2.new(1,0,1,-46)
            directLeft.Visible=false; directRight.Visible=false
            local sb=new("TextButton", {AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.fromOffset(90,32),BackgroundColor3=Theme.Element,BorderSizePixel=0,AutoButtonColor=false,Text="  "..(subOptions.Name or "SubPage").."  ",TextColor3=Theme.DimText,TextSize=12,Font=Enum.Font.Gotham,Parent=subTabs}); corner(sb,6)
            local frame=new("Frame", {Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false,Parent=subHolder})
            local left=new("ScrollingFrame", {Size=UDim2.new(.5,-7,1,0),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=0,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),Parent=frame})
            local right=new("ScrollingFrame", {AnchorPoint=Vector2.new(1,0),Position=UDim2.fromScale(1,0),Size=UDim2.new(.5,-7,1,0),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=0,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),Parent=frame})
            list(left,10); list(right,10)
            local SubPage={Frame=frame,Button=sb}
            function SubPage:Switch(v) frame.Visible=v; sb.TextColor3=v and Theme.Text or Theme.DimText end
            function SubPage:Section(opts) opts=opts or {}; return makeSectionAPI(opts.Side==2 and right or left,opts) end
            sb.MouseButton1Click:Connect(function() for _,p in ipairs(Page.SubPages) do p:Switch(false) end; SubPage:Switch(true) end)
            table.insert(Page.SubPages,SubPage)
            if #Page.SubPages==1 then SubPage:Switch(true) end
            return SubPage
        end

        tab.MouseButton1Click:Connect(function()
            for _,p in ipairs(Window.Pages) do p:Switch(false) end
            Page:Switch(true)
        end)
        table.insert(Window.Pages,Page)
        if #Window.Pages==1 then Page:Switch(true) end
        return Page
    end

    return Window
end

return Library
