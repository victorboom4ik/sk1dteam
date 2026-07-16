--[[
    GamesenseUI - 1:1 gamesense style UI library for Roblox
--]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

--=============================
-- THEME
--=============================
local Theme = {
    Background      = Color3.fromRGB(18, 18, 20),
    Panel           = Color3.fromRGB(24, 24, 27),
    PanelAlt        = Color3.fromRGB(29, 29, 33),
    Border          = Color3.fromRGB(45, 45, 50),
    Accent          = Color3.fromRGB(0, 170, 255),
    
    TopBarGradient  = {
        Color3.fromRGB(255, 0, 150),
        Color3.fromRGB(0, 255, 255),
        Color3.fromRGB(255, 220, 0),
    },
    
    TextPrimary     = Color3.fromRGB(235, 235, 240),
    TextSecondary   = Color3.fromRGB(155, 155, 165),
    TabActive       = Color3.fromRGB(35, 35, 42),
    TabInactive     = Color3.fromRGB(24, 24, 27),
    ToggleOn        = Color3.fromRGB(0, 170, 255),
    ToggleOff       = Color3.fromRGB(55, 55, 62),
    SliderFill      = Color3.fromRGB(0, 170, 255),
    Font            = Enum.Font.Gotham,
    FontBold        = Enum.Font.GothamBold,
}

--=============================
-- UTIL
--=============================
local function create(class, props, children)
    local inst = Instance.new(class)
    for prop, value in pairs(props or {}) do
        inst[prop] = value
    end
    for _, child in ipairs(children or {}) do
        child.Parent = inst
    end
    return inst
end

local function tween(obj, info, props)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

local function corner(radius)
    return create("UICorner", {CornerRadius = UDim.new(0, radius or 5)})
end

local function stroke(color, thickness)
    return create("UIStroke", {
        Color = color or Theme.Border,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end

local function gradientBar(parent, colors)
    local sequence = {}
    local step = 1 / (#colors - 1)
    for i, c in ipairs(colors) do
        table.insert(sequence, ColorSequenceKeypoint.new(step * (i - 1), c))
    end
    return create("UIGradient", {
        Color = ColorSequence.new(sequence),
        Rotation = 0,
        Parent = parent,
    })
end

--=============================
-- LIBRARY
--=============================
local Library = {}
Library.__index = Library

function Library.new(title)
    local self = setmetatable({}, Library)

    self.Title = title or "gamesense"
    self.Tabs = {}
    self.ActiveTab = nil
    self.Open = true
    self.Orientation = "Horizontal"

    self.ScreenGui = create("ScreenGui", {
        Name = "GamesenseUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999,
    })

    pcall(function() self.ScreenGui.Parent = game:GetService("CoreGui") end)
    if not self.ScreenGui.Parent then
        self.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    local winW, winH = 680, 430
    if IsMobile then winW, winH = 380, 300 end

    self.Main = create("Frame", {
        Name = "Main",
        Size = UDim2.fromOffset(winW, winH),
        Position = UDim2.new(0.5, -winW / 2, 0.5, -winH / 2),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = self.ScreenGui,
    })
    corner(6).Parent = self.Main
    stroke(Theme.Border, 1).Parent = self.Main

    -- Top rainbow strip
    self.TopStrip = create("Frame", {
        Name = "TopStrip",
        Size = UDim2.new(1, 0, 0, 3),
        Position = UDim2.new(0, 0, 0, 0),
        BorderSizePixel = 0,
        Parent = self.Main,
    })
    gradientBar(self.TopStrip, Theme.TopBarGradient)

    -- Accent side lines
    create("Frame", {Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(0, 0, 0, 0), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Parent = self.Main})
    create("Frame", {Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, -1, 0, 0), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Parent = self.Main})

    -- Title bar
    self.TitleBar = create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 32),
        Position = UDim2.new(0, 0, 0, 3),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        Parent = self.Main,
    })

    self.TitleLabel = create("TextLabel", {
        Name = "TitleLabel",
        Size = UDim2.new(1, -90, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = self.Title,
        Font = Theme.FontBold,
        TextSize = 14,
        TextColor3 = Theme.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.TitleBar,
    })

    self.OrientBtn = create("TextButton", {
        Size = UDim2.fromOffset(24, 24),
        Position = UDim2.new(1, -68, 0, 4),
        BackgroundColor3 = Theme.PanelAlt,
        Text = "⇄",
        Font = Theme.Font,
        TextSize = 14,
        TextColor3 = Theme.TextSecondary,
        Parent = self.TitleBar,
    })
    corner(4).Parent = self.OrientBtn

    self.CloseBtn = create("TextButton", {
        Size = UDim2.fromOffset(24, 24),
        Position = UDim2.new(1, -36, 0, 4),
        BackgroundColor3 = Theme.PanelAlt,
        Text = "×",
        Font = Theme.Font,
        TextSize = 18,
        TextColor3 = Theme.TextSecondary,
        Parent = self.TitleBar,
    })
    corner(4).Parent = self.CloseBtn

    self.Body = create("Frame", {
        Size = UDim2.new(1, 0, 1, -35),
        Position = UDim2.new(0, 0, 0, 35),
        BackgroundTransparency = 1,
        Parent = self.Main,
    })

    self.TabBar = create("Frame", {BackgroundColor3 = Theme.Panel, BorderSizePixel = 0, Parent = self.Body})
    self.TabBarLayout = create("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Parent = self.TabBar})

    self.PageContainer = create("Frame", {BackgroundTransparency = 1, Parent = self.Body})

    self:SetOrientation(self.Orientation)
    self:_setupDrag(self.TitleBar)

    self.OrientBtn.MouseButton1Click:Connect(function()
        self:SetOrientation(self.Orientation == "Horizontal" and "Vertical" or "Horizontal")
    end)

    self.CloseBtn.MouseButton1Click:Connect(function() self:Toggle() end)

    if IsMobile then self:_createMobileToggle() end

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or input.KeyCode \~= Enum.KeyCode.Insert then return end
        self:Toggle()
    end)

    return self
end

function Library:SetOrientation(orientation)
    self.Orientation = orientation

    if orientation == "Horizontal" then
        self.TabBar.Size = UDim2.new(1, 0, 0, 36)
        self.TabBar.Position = UDim2.new(0, 0, 0, 0)
        self.TabBarLayout.FillDirection = Enum.FillDirection.Horizontal

        self.PageContainer.Size = UDim2.new(1, 0, 1, -36)
        self.PageContainer.Position = UDim2.new(0, 0, 0, 36)
    else
        self.TabBar.Size = UDim2.new(0, 140, 1, 0)
        self.TabBar.Position = UDim2.new(0, 0, 0, 0)
        self.TabBarLayout.FillDirection = Enum.FillDirection.Vertical

        self.PageContainer.Size = UDim2.new(1, -140, 1, 0)
        self.PageContainer.Position = UDim2.new(0, 140, 0, 0)
    end

    for _, tabData in ipairs(self.Tabs) do
        if orientation == "Horizontal" then
            tabData.Button.Size = UDim2.new(0, 100, 1, 0)
        else
            tabData.Button.Size = UDim2.new(1, 0, 0, 36)
        end
    end
end

function Library:_setupDrag(handle)
    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        self.Main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = self.Main.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

function Library:_createMobileToggle()
    local btn = create("TextButton", {
        Name = "MobileToggle",
        Size = UDim2.fromOffset(46, 46),
        Position = UDim2.new(0, 10, 0.5, -23),
        BackgroundColor3 = Theme.Panel,
        Text = "☰",
        TextColor3 = Theme.TextPrimary,
        Font = Theme.FontBold,
        TextSize = 20,
        Parent = self.ScreenGui,
    })
    corner(23).Parent = btn
    stroke(Theme.Border, 1).Parent = btn

    self:_setupDrag(btn)

    btn.MouseButton1Click:Connect(function()
        self:Toggle()
    end)

    self.MobileToggleBtn = btn
end

function Library:Toggle()
    self.Open = not self.Open

    if self.Open then
        self.Main.Visible = true
        self.Main.Size = UDim2.fromOffset(0, 0)
        self.Main.Position = UDim2.new(0.5, 0, 0.5, 0)
        local targetSize = IsMobile and UDim2.fromOffset(380, 300) or UDim2.fromOffset(680, 430)
        local targetPos = UDim2.new(0.5, -targetSize.X.Offset / 2, 0.5, -targetSize.Y.Offset / 2)

        tween(self.Main, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = targetSize,
            Position = targetPos,
        })
    else
        local currentSize = self.Main.Size
        tween(self.Main, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            Size = UDim2.fromOffset(0, 0),
            Position = UDim2.new(
                self.Main.Position.X.Scale, self.Main.Position.X.Offset + currentSize.X.Offset / 2,
                self.Main.Position.Y.Scale, self.Main.Position.Y.Offset + currentSize.Y.Offset / 2
            ),
        })
        task.delay(0.22, function()
            if not self.Open then
                self.Main.Visible = false
            end
        end)
    end
end

--=============================
-- TABS
--=============================
function Library:CreateTab(name, icon)
    local index = #self.Tabs + 1

    local button = create("TextButton", {
        Name = name .. "Button",
        Size = self.Orientation == "Horizontal" and UDim2.new(0, 100, 1, 0) or UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Theme.TabInactive,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = index,
        Parent = self.TabBar,
    })

    create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = (icon and (icon .. "  ") or "") .. name,
        Font = Theme.Font,
        TextSize = 13,
        TextColor3 = Theme.TextSecondary,
        Parent = button,
    })

    local page = create("ScrollingFrame", {
        Name = name .. "Page",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = index == 1,
        Parent = self.PageContainer,
    })

    create("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        Parent = page,
    })

    local leftCol = create("Frame", {
        Name = "LeftColumn",
        Size = UDim2.new(0.5, -5, 1, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = page,
    })
    create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = leftCol,
    })

    local rightCol = create("Frame", {
        Name = "RightColumn",
        Size = UDim2.new(0.5, -5, 1, 0),
        Position = UDim2.new(0.5, 5, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = page,
    })
    create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = rightCol,
    })

    local tabData = {
        Name = name,
        Button = button,
        Page = page,
        LeftColumn = leftCol,
        RightColumn = rightCol,
    }

    button.MouseButton1Click:Connect(function()
        self:SelectTab(tabData)
    end)

    table.insert(self.Tabs, tabData)

    if index == 1 then
        self.ActiveTab = tabData
        button.BackgroundColor3 = Theme.TabActive
    end

    return TabAPI.new(self, tabData)
end

function Library:SelectTab(tabData)
    if self.ActiveTab then
        self.ActiveTab.Page.Visible = false
        tween(self.ActiveTab.Button, TweenInfo.new(0.15), {BackgroundColor3 = Theme.TabInactive})
    end

    self.ActiveTab = tabData
    tabData.Page.Visible = true
    tween(tabData.Button, TweenInfo.new(0.15), {BackgroundColor3 = Theme.TabActive})
end
--=============================
-- TAB API
--=============================
TabAPI = {}
TabAPI.__index = TabAPI

function TabAPI.new(library, tabData)
    return setmetatable({
        Library = library,
        TabData = tabData,
    }, TabAPI)
end

local function pickColumn(self, side)
    if side == "Right" then
        return self.TabData.RightColumn
    end
    return self.TabData.LeftColumn
end

function TabAPI:AddSection(text, side)
    local column = pickColumn(self, side)

    local holder = create("Frame", {
        Name = "Section",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        LayoutOrder = #column:GetChildren(),
        Parent = column,
    })
    corner(5).Parent = holder
    stroke(Theme.Border, 1).Parent = holder

    create("TextLabel", {
        Size = UDim2.new(1, -16, 0, 22),
        Position = UDim2.new(0, 8, 0, 8),
        BackgroundTransparency = 1,
        Text = text,
        Font = Theme.FontBold,
        TextSize = 13,
        TextColor3 = Theme.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = holder,
    })

    local content = create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -16, 0, 0),
        Position = UDim2.new(0, 8, 0, 34),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = holder,
    })
    create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
        Parent = content,
    })
    create("UIPadding", {
        PaddingBottom = UDim.new(0, 10),
        Parent = content,
    })

    return SectionAPI.new(content)
end

--=============================
-- SECTION API
--=============================
SectionAPI = {}
SectionAPI.__index = SectionAPI

function SectionAPI.new(content)
    return setmetatable({Content = content, _order = 0}, SectionAPI)
end

local function nextOrder(self)
    self._order = self._order + 1
    return self._order
end

function SectionAPI:AddCheckbox(text, default, callback)
    callback = callback or function() end
    local state = default or false

    local row = create("Frame", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        LayoutOrder = nextOrder(self),
        Parent = self.Content,
    })

    local box = create("Frame", {
        Size = UDim2.fromOffset(16, 16),
        Position = UDim2.new(0, 0, 0.5, -8),
        BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff,
        BorderSizePixel = 0,
        Parent = row,
    })
    corner(3).Parent = box

    create("TextLabel", {
        Size = UDim2.new(1, -24, 1, 0),
        Position = UDim2.new(0, 24, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        Font = Theme.Font,
        TextSize = 13,
        TextColor3 = Theme.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    local clickArea = create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = row,
    })

    clickArea.MouseButton1Click:Connect(function()
        state = not state
        tween(box, TweenInfo.new(0.1), {BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff})
        callback(state)
    end)

    return {
        Set = function(_, value)
            state = value
            box.BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff
        end,
        Get = function()
            return state
        end,
    }
end
function SectionAPI:AddSlider(text, min, max, default, callback)
    callback = callback or function() end
    min = min or 0
    max = max or 100
    default = math.clamp(default or min, min, max)

    local row = create("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        LayoutOrder = nextOrder(self),
        Parent = self.Content,
    })

    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = text,
        Font = Theme.Font,
        TextSize = 13,
        TextColor3 = Theme.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    local valueLabel = create("TextLabel", {
        Size = UDim2.new(0, 40, 0, 16),
        Position = UDim2.new(1, -40, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(default),
        Font = Theme.Font,
        TextSize = 12,
        TextColor3 = Theme.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = row,
    })

    local track = create("Frame", {
        Size = UDim2.new(1, 0, 0, 4),
        Position = UDim2.new(0, 0, 0, 24),
        BackgroundColor3 = Theme.ToggleOff,
        BorderSizePixel = 0,
        Parent = row,
    })
    corner(2).Parent = track

    local fill = create("Frame", {
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Theme.SliderFill,
        BorderSizePixel = 0,
        Parent = track,
    })
    corner(2).Parent = fill

    local dragging = false
    local function setFromX(xpos)
        local rel = math.clamp((xpos - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + rel * (max - min) + 0.5)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        valueLabel.Text = tostring(value)
        callback(value)
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setFromX(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            setFromX(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return {
        Set = function(_, value)
            value = math.clamp(value, min, max)
            local rel = (value - min) / (max - min)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            valueLabel.Text = tostring(value)
        end,
    }
end

function SectionAPI:AddDropdown(text, options, default, callback)
    callback = callback or function() end
    options = options or {}
    local selected = default or options[1]

    local row = create("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        LayoutOrder = nextOrder(self),
        Parent = self.Content,
    })

    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = text,
        Font = Theme.Font,
        TextSize = 13,
        TextColor3 = Theme.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    local box = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 22),
        Position = UDim2.new(0, 0, 0, 16),
        BackgroundColor3 = Theme.PanelAlt,
        Text = tostring(selected) .. "  ▾",
        Font = Theme.Font,
        TextSize = 12,
        TextColor3 = Theme.TextPrimary,
        AutoButtonColor = false,
        Parent = row,
    })
    corner(3).Parent = box
    stroke(Theme.Border, 1).Parent = box

    local listOpen = false
    local list = create("Frame", {
        Size = UDim2.new(1, 0, 0, #options * 22),
        Position = UDim2.new(0, 0, 1, 2),
        BackgroundColor3 = Theme.PanelAlt,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 5,
        Parent = box,
    })
    corner(3).Parent = list
    stroke(Theme.Border, 1).Parent = list
    create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Parent = list})

    for _, opt in ipairs(options) do
        local optBtn = create("TextButton", {
            Size = UDim2.new(1, 0, 0, 22),
            BackgroundColor3 = Theme.PanelAlt,
            Text = tostring(opt),
            Font = Theme.Font,
            TextSize = 12,
            TextColor3 = Theme.TextSecondary,
            AutoButtonColor = true,
            ZIndex = 5,
            Parent = list,
        })
        optBtn.MouseButton1Click:Connect(function()
            selected = opt
            box.Text = tostring(opt) .. "  ▾"
            list.Visible = false
            listOpen = false
            callback(opt)
        end)
    end

    box.MouseButton1Click:Connect(function()
        listOpen = not listOpen
        list.Visible = listOpen
    end)

    return {
        Set = function(_, value)
            selected = value
            box.Text = tostring(value) .. "  ▾"
        end,
        Get = function()
            return selected
        end,
    }
end

function SectionAPI:AddButton(text, callback)
    callback = callback or function() end

    local btn = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundColor3 = Theme.PanelAlt,
        Text = text,
        Font = Theme.Font,
        TextSize = 13,
        TextColor3 = Theme.TextPrimary,
        AutoButtonColor = false,
        LayoutOrder = nextOrder(self),
        Parent = self.Content,
    })
    corner(4).Parent = btn
    stroke(Theme.Border, 1).Parent = btn

    btn.MouseEnter:Connect(function()
        tween(btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.TabActive})
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.PanelAlt})
    end)
    btn.MouseButton1Click:Connect(callback)

    return btn
end

function SectionAPI:AddLabel(text)
    local label = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = text,
        Font = Theme.Font,
        TextSize = 12,
        TextColor3 = Theme.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = nextOrder(self),
        Parent = self.Content,
    })
    return label
end

--=============================
-- NOTIFICATIONS
--=============================
local NotificationHolder

local function ensureNotificationHolder(screenGui)
    if NotificationHolder and NotificationHolder.Parent then return NotificationHolder end

    NotificationHolder = create("Frame", {
        Name = "Notifications",
        Size = UDim2.fromOffset(280, 500),
        Position = UDim2.new(1, -290, 1, -510),
        BackgroundTransparency = 1,
        Parent = screenGui,
    })
    create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 6),
        Parent = NotificationHolder,
    })
    return NotificationHolder
end

function Library:Notify(title, text, duration, notifType)
    duration = duration or 4
    notifType = notifType or "info"

    local accentColors = {
        info = Color3.fromRGB(0, 170, 255),
        success = Color3.fromRGB(60, 220, 130),
        warning = Color3.fromRGB(255, 200, 0),
        error = Color3.fromRGB(255, 70, 70),
    }
    local accent = accentColors[notifType] or accentColors.info

    local holder = ensureNotificationHolder(self.ScreenGui)

    local notif = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = holder,
    })
    corner(5).Parent = notif
    stroke(Theme.Border, 1).Parent = notif

    create("Frame", {
        Size = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
        Parent = notif,
    })

    local textHolder = create("Frame", {
        Size = UDim2.new(1, -13, 0, 0),
        Position = UDim2.new(0, 10, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = notif,
    })
    create("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), Parent = textHolder})
    create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = textHolder})

    create("TextLabel", {Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Text = title, Font = Theme.FontBold, TextSize = 13, TextColor3 = Theme.TextPrimary, TextXAlignment = Enum.TextXAlignment.Left, Parent = textHolder})
    create("TextLabel", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Text = text, Font = Theme.Font, TextSize = 12, TextColor3 = Theme.TextSecondary, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = textHolder})

    notif.Position = UDim2.new(1.2, 0, 0, 0)
    tween(notif, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)})

    task.delay(duration, function()
        tween(notif, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Position = UDim2.new(1.2, 0, 0, 0)}).Completed:Wait()
        notif:Destroy()
    end)
end

return Library