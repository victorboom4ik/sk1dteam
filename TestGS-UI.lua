--[[
    GamesenseUI - Authentic 1:1 Gamesense Style UI Library for Roblox
--]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

--=============================
-- THEME & PALETTE (1:1 Gamesense)
--=============================
local Theme = {
    Background      = Color3.fromRGB(12, 12, 12),      -- Глубокий темный
    Panel           = Color3.fromRGB(17, 17, 17),      -- Фон секций
    PanelAlt        = Color3.fromRGB(22, 22, 22),      -- Кнопки, инпуты
    BorderOuter     = Color3.fromRGB(40, 40, 40),      -- Внешняя рамка
    BorderInner     = Color3.fromRGB(25, 25, 25),      -- Внутренняя рамка секций
    Accent          = Color3.fromRGB(150, 200, 60),    -- Тот самый фирменный зеленый/лаймовый
    
    TopBarGradient  = {
        Color3.fromRGB(55, 175, 225),  -- Сине-голубой
        Color3.fromRGB(200, 80, 185),  -- Розовый
        Color3.fromRGB(200, 200, 80),  -- Желто-зеленый
    },
    
    TextPrimary     = Color3.fromRGB(240, 240, 240),
    TextSecondary   = Color3.fromRGB(130, 130, 130),
    TextDark        = Color3.fromRGB(80, 80, 80),
    
    ToggleOn        = Color3.fromRGB(153, 204, 0),     -- Чистый Gamesense Зеленый
    ToggleOff       = Color3.fromRGB(35, 35, 35),
    
    Font            = Enum.Font.SourceSans,
    FontBold        = Enum.Font.SourceSansBold,
}

--=============================
-- UTILITY FUNCTIONS
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

--=============================
-- MAIN LIBRARY CLASS
--=============================
local Library = {}
Library.__index = Library

function Library.new(title)
    local self = setmetatable({}, Library)

    self.Title = title or "gamesense"
    self.Tabs = {}
    self.ActiveTab = nil
    self.Open = true
    self.Orientation = "Vertical" -- По умолчанию 1:1 оригинальный вертикальный вид

    self.ScreenGui = create("ScreenGui", {
        Name = "GamesenseUI_Actual",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999,
    })

    pcall(function() self.ScreenGui.Parent = game:GetService("CoreGui") end)
    if not self.ScreenGui.Parent then
        self.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    local winW, winH = 640, 480
    if IsMobile then winW, winH = 450, 320 end

    -- Main Container (Тонкая двойная обводка как в CS)
    self.Main = create("Frame", {
        Name = "Main",
        Size = UDim2.fromOffset(winW, winH),
        Position = UDim2.new(0.5, -winW / 2, 0.5, -winH / 2),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 1,
        BorderColor3 = Theme.BorderOuter,
        ClipsDescendants = false,
        Parent = self.ScreenGui,
    })

    -- Внутренний темный контур для имитации 1:1 рамки
    create("UIStroke", {
        Color = Color3.fromRGB(0, 0, 0),
        Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = self.Main
    })

    -- Градиентная полоса сверху
    self.TopStrip = create("Frame", {
        Name = "TopStrip",
        Size = UDim2.new(1, 0, 0, 3),
        Position = UDim2.new(0, 0, 0, 0),
        BorderSizePixel = 0,
        Parent = self.Main,
    })
    
    local sequence = {}
    local step = 1 / (#Theme.TopBarGradient - 1)
    for i, c in ipairs(Theme.TopBarGradient) do
        table.insert(sequence, ColorSequenceKeypoint.new(step * (i - 1), c))
    end
    create("UIGradient", {
        Color = ColorSequence.new(sequence),
        Rotation = 0,
        Parent = self.TopStrip,
    })

    -- Заголовок меню
    self.TitleBar = create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 24),
        Position = UDim2.new(0, 0, 0, 3),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Parent = self.Main,
    })

    self.TitleLabel = create("TextLabel", {
        Name = "TitleLabel",
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = self.Title,
        Font = Theme.FontBold,
        TextSize = 13,
        TextColor3 = Theme.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.TitleBar,
    })

    -- Кнопка смены ориентации (адаптив)
    self.OrientBtn = create("TextButton", {
        Size = UDim2.fromOffset(18, 18),
        Position = UDim2.new(1, -50, 0, 3),
        BackgroundColor3 = Theme.PanelAlt,
        BorderSizePixel = 1,
        BorderColor3 = Theme.BorderOuter,
        Text = "⇄",
        Font = Theme.Font,
        TextSize = 12,
        TextColor3 = Theme.TextSecondary,
        Parent = self.TitleBar,
    })

    -- Кнопка закрытия
    self.CloseBtn = create("TextButton", {
        Size = UDim2.fromOffset(18, 18),
        Position = UDim2.new(1, -26, 0, 3),
        BackgroundColor3 = Theme.PanelAlt,
        BorderSizePixel = 1,
        BorderColor3 = Theme.BorderOuter,
        Text = "×",
        Font = Theme.FontBold,
        TextSize = 14,
        TextColor3 = Theme.TextSecondary,
        Parent = self.TitleBar,
    })

    self.Body = create("Frame", {
        Size = UDim2.new(1, -12, 1, -40),
        Position = UDim2.new(0, 6, 0, 32),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 1,
        BorderColor3 = Theme.BorderInner,
        Parent = self.Main,
    })

    -- Панель вкладок (Левый сайдбар / Верхний сайдбар)
    self.TabBar = create("Frame", {
        BackgroundColor3 = Color3.fromRGB(14, 14, 14),
        BorderSizePixel = 1,
        BorderColor3 = Theme.BorderInner,
        Parent = self.Body
    })
    
    self.TabBarLayout = create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 0),
        Parent = self.TabBar
    })

    -- Контейнер страниц
    self.PageContainer = create("Frame", {
        BackgroundTransparency = 1,
        Parent = self.Body,
    })

    self:SetOrientation(self.Orientation)
    self:_setupDrag(self.TitleBar)

    self.OrientBtn.MouseButton1Click:Connect(function()
        self:SetOrientation(self.Orientation == "Horizontal" and "Vertical" or "Horizontal")
    end)

    self.CloseBtn.MouseButton1Click:Connect(function() self:Toggle() end)

    if IsMobile then self:_createMobileToggle() end

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or input.KeyCode ~= Enum.KeyCode.Insert then return end
        self:Toggle()
    end)

    return self
end

function Library:SetOrientation(orientation)
    self.Orientation = orientation

    if orientation == "Horizontal" then
        self.TabBar.Size = UDim2.new(1, 0, 0, 40)
        self.TabBar.Position = UDim2.new(0, 0, 0, 0)
        self.TabBarLayout.FillDirection = Enum.FillDirection.Horizontal

        self.PageContainer.Size = UDim2.new(1, 0, 1, -40)
        self.PageContainer.Position = UDim2.new(0, 0, 0, 40)
    else
        -- Оригинальный Gamesense стиль (Узкая вертикальная полоса слева)
        self.TabBar.Size = UDim2.new(0, 54, 1, 0)
        self.TabBar.Position = UDim2.new(0, 0, 0, 0)
        self.TabBarLayout.FillDirection = Enum.FillDirection.Vertical

        self.PageContainer.Size = UDim2.new(1, -54, 1, 0)
        self.PageContainer.Position = UDim2.new(0, 54, 0, 0)
    end

    for _, tabData in ipairs(self.Tabs) do
        if orientation == "Horizontal" then
            tabData.Button.Size = UDim2.new(0, 100, 1, 0)
            tabData.IconLabel.Visible = false
            tabData.TextLabel.Visible = true
            tabData.TextLabel.Size = UDim2.new(1, 0, 1, 0)
        else
            -- 1:1 Вкладка слева (Только большая иконка по центру, как в оригинале)
            tabData.Button.Size = UDim2.new(1, 0, 0, 54)
            tabData.IconLabel.Visible = true
            tabData.TextLabel.Visible = false
        end
    end
end

function Library:_setupDrag(handle)
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

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
        Size = UDim2.fromOffset(40, 40),
        Position = UDim2.new(0, 15, 0.3, 0),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 1,
        BorderColor3 = Theme.BorderOuter,
        Text = "GS",
        TextColor3 = Theme.Accent,
        Font = Theme.FontBold,
        TextSize = 14,
        Parent = self.ScreenGui,
    })
    
    self:_setupDrag(btn)
    btn.MouseButton1Click:Connect(function() self:Toggle() end)
end

function Library:Toggle()
    self.Open = not self.Open
    self.Main.Visible = self.Open
end

--=============================
-- TABS IMPLEMENTATION
--=============================
function Library:CreateTab(name, icon)
    local index = #self.Tabs + 1
    icon = icon or "🎯"

    local button = create("TextButton", {
        Name = name .. "Button",
        Size = UDim2.new(1, 0, 0, 54),
        BackgroundColor3 = Color3.fromRGB(14, 14, 14),
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = index,
        Parent = self.TabBar,
    })

    -- Индикатор активной вкладки слева (зеленая вертикальная микро-полоска)
    local activeIndicator = create("Frame", {
        Size = UDim2.new(0, 2, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Visible = index == 1,
        Parent = button
    })

    local iconLabel = create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = icon,
        Font = Theme.Font,
        TextSize = 24,
        TextColor3 = index == 1 and Theme.TextPrimary or Theme.TextSecondary,
        Parent = button,
    })

    local textLabel = create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = name,
        Font = Theme.FontBold,
        TextSize = 13,
        TextColor3 = index == 1 and Theme.TextPrimary or Theme.TextSecondary,
        Visible = false,
        Parent = button,
    })

    local page = create("ScrollingFrame", {
        Name = name .. "Page",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.BorderOuter,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = index == 1,
        Parent = self.PageContainer,
    })

    create("UIPadding", {
        PaddingTop = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingBottom = UDim.new(0, 12),
        Parent = page,
    })

    -- 1:1 Сетка колонок Gamesense
    local leftCol = create("Frame", {
        Name = "LeftColumn",
        Size = UDim2.new(0.5, -7, 1, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = page,
    })
    create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 14),
        Parent = leftCol,
    })

    local rightCol = create("Frame", {
        Name = "RightColumn",
        Size = UDim2.new(0.5, -7, 1, 0),
        Position = UDim2.new(0.5, 7, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = page,
    })
    create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 14),
        Parent = rightCol,
    })

    local tabData = {
        Name = name,
        Button = button,
        Page = page,
        LeftColumn = leftCol,
        RightColumn = rightCol,
        IconLabel = iconLabel,
        TextLabel = textLabel,
        Indicator = activeIndicator,
    }

    button.MouseButton1Click:Connect(function()
        self:SelectTab(tabData)
    end)

    table.insert(self.Tabs, tabData)

    if index == 1 then
        self.ActiveTab = tabData
    end

    return TabAPI.new(self, tabData)
end

function Library:SelectTab(tabData)
    if self.ActiveTab then
        self.ActiveTab.Page.Visible = false
        self.ActiveTab.Indicator.Visible = false
        self.ActiveTab.IconLabel.TextColor3 = Theme.TextSecondary
        self.ActiveTab.TextLabel.TextColor3 = Theme.TextSecondary
    end

    self.ActiveTab = tabData
    tabData.Page.Visible = true
    tabData.Indicator.Visible = true
    tabData.IconLabel.TextColor3 = Theme.TextPrimary
    tabData.TextLabel.TextColor3 = Theme.TextPrimary
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

function TabAPI:AddSection(text, side)
    local column = (side == "Right") and self.TabData.RightColumn or self.TabData.LeftColumn

    -- Секция с 1:1 рамкой, врезающейся в заголовок
    local holder = create("Frame", {
        Name = "Section",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 1,
        BorderColor3 = Theme.BorderInner,
        LayoutOrder = #column:GetChildren(),
        Parent = column,
    })

    -- Фирменная обводка секции в стиле Gamesense
    create("UIStroke", {
        Color = Color3.fromRGB(0, 0, 0),
        Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = holder
    })

    -- Лейбл секции (врезается в рамку сверху)
    local label = create("TextLabel", {
        Size = UDim2.fromOffset(0, 14),
        Position = UDim2.new(0, 12, 0, -8),
        BackgroundColor3 = Theme.Background,
        Text = "  " .. text .. "  ",
        Font = Theme.FontBold,
        TextSize = 12,
        TextColor3 = Theme.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutomaticSize = Enum.AutomaticSize.X,
        Parent = holder,
    })

    local content = create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -20, 0, 0),
        Position = UDim2.new(0, 10, 0, 10),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = holder,
    })
    
    create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = content,
    })
    
    create("UIPadding", {
        PaddingBottom = UDim.new(0, 12),
        Parent = content,
    })

    return SectionAPI.new(content)
end

--=============================
-- SECTION API (1:1 Controls)
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
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        LayoutOrder = nextOrder(self),
        Parent = self.Content,
    })

    -- 1:1 Квадратный чекбокс с черным бордером
    local box = create("Frame", {
        Size = UDim2.fromOffset(10, 10),
        Position = UDim2.new(0, 0, 0.5, -5),
        BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff,
        BorderSizePixel = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Parent = row,
    })

    create("TextLabel", {
        Size = UDim2.new(1, -18, 1, 0),
        Position = UDim2.new(0, 18, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        Font = Theme.Font,
        TextSize = 13,
        TextColor3 = state and Theme.TextPrimary or Theme.TextSecondary,
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
        box.BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff
        row.TextLabel.TextColor3 = state and Theme.TextPrimary or Theme.TextSecondary
        callback(state)
    end)

    return {
        Set = function(_, value)
            state = value
            box.BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff
            row.TextLabel.TextColor3 = state and Theme.TextPrimary or Theme.TextSecondary
        end,
        Get = function() return state end,
    }
end

function SectionAPI:AddSlider(text, min, max, default, callback)
    callback = callback or function() end
    min = min or 0
    max = max or 100
    default = math.clamp(default or min, min, max)

    local row = create("Frame", {
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
        LayoutOrder = nextOrder(self),
        Parent = self.Content,
    })

    local label = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14),
        BackgroundTransparency = 1,
        Text = text,
        Font = Theme.Font,
        TextSize = 13,
        TextColor3 = Theme.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    -- Трек слайдера (тонкий, плоский)
    local track = create("Frame", {
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 0, 16),
        BackgroundColor3 = Theme.ToggleOff,
        BorderSizePixel = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Parent = row,
    })

    local fill = create("Frame", {
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = track,
    })

    -- Текст значения на самом слайдере (справа в углу)
    local valueLabel = create("TextLabel", {
        Size = UDim2.fromOffset(40, 14),
        Position = UDim2.new(1, -40, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(default),
        Font = Theme.Font,
        TextSize = 12,
        TextColor3 = Theme.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = row,
    })

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
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundTransparency = 1,
        LayoutOrder = nextOrder(self),
        Parent = self.Content,
    })

    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14),
        BackgroundTransparency = 1,
        Text = text,
        Font = Theme.Font,
        TextSize = 13,
        TextColor3 = Theme.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    -- Кнопка дропдауна (1:1 плоская плашка)
    local box = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 18),
        Position = UDim2.new(0, 0, 0, 16),
        BackgroundColor3 = Theme.PanelAlt,
        BorderSizePixel = 1,
        BorderColor3 = Theme.BorderOuter,
        Text = "  " .. tostring(selected),
        Font = Theme.Font,
        TextSize = 12,
        TextColor3 = Theme.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
        Parent = row,
    })
    
    local arrow = create("TextLabel", {
        Size = UDim2.new(0, 18, 1, 0),
        Position = UDim2.new(1, -18, 0, 0),
        BackgroundTransparency = 1,
        Text = "▼",
        Font = Theme.Font,
        TextSize = 8,
        TextColor3 = Theme.TextSecondary,
        Parent = box
    })

    local listOpen = false
    local list = create("Frame", {
        Size = UDim2.new(1, 0, 0, #options * 18),
        Position = UDim2.new(0, 0, 1, 1),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 1,
        BorderColor3 = Theme.BorderOuter,
        Visible = false,
        ZIndex = 10,
        Parent = box,
    })
    create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Parent = list})

    for _, opt in ipairs(options) do
        local optBtn = create("TextButton", {
            Size = UDim2.new(1, 0, 0, 18),
            BackgroundColor3 = Theme.Panel,
            BorderSizePixel = 0,
            Text = "  " .. tostring(opt),
            Font = Theme.Font,
            TextSize = 12,
            TextColor3 = (opt == selected) and Theme.Accent or Theme.TextSecondary,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = true,
            ZIndex = 10,
            Parent = list,
        })
        
        optBtn.MouseButton1Click:Connect(function()
            selected = opt
            box.Text = "  " .. tostring(opt)
            list.Visible = false
            listOpen = false
            
            for _, btn in ipairs(list:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.TextColor3 = (btn.Text == "  " .. tostring(opt)) and Theme.Accent or Theme.TextSecondary
                end
            end
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
            box.Text = "  " .. tostring(value)
        end,
        Get = function() return selected end,
    }
end

function SectionAPI:AddButton(text, callback)
    callback = callback or function() end

    local btn = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundColor3 = Theme.PanelAlt,
        BorderSizePixel = 1,
        BorderColor3 = Theme.BorderOuter,
        Text = text,
        Font = Theme.Font,
        TextSize = 12,
        TextColor3 = Theme.TextPrimary,
        AutoButtonColor = false,
        LayoutOrder = nextOrder(self),
        Parent = self.Content,
    })

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Theme.PanelAlt
    end)
    btn.MouseButton1Click:Connect(callback)

    return btn
end

function SectionAPI:AddLabel(text)
    local label = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14),
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
-- 1:1 NOTIFICATIONS
--=============================
local NotificationHolder

local function ensureNotificationHolder(screenGui)
    if NotificationHolder and NotificationHolder.Parent then return NotificationHolder end

    NotificationHolder = create("Frame", {
        Name = "Notifications",
        Size = UDim2.fromOffset(240, 500),
        Position = UDim2.new(1, -250, 1, -510),
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
        info = Color3.fromRGB(55, 175, 225),
        success = Color3.fromRGB(153, 204, 0),
        warning = Color3.fromRGB(220, 180, 50),
        error = Color3.fromRGB(220, 60, 60),
    }
    local accent = accentColors[notifType] or accentColors.info

    local holder = ensureNotificationHolder(self.ScreenGui)

    local notif = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 1,
        BorderColor3 = Theme.BorderOuter,
        ClipsDescendants = true,
        Parent = holder,
    })
    
    create("UIStroke", {
        Color = Color3.fromRGB(0, 0, 0),
        Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = notif
    })

    -- Полоска акцента слева
    create("Frame", {
        Size = UDim2.new(0, 2, 1, 0),
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
        Parent = notif,
    })

    local textHolder = create("Frame", {
        Size = UDim2.new(1, -10, 0, 0),
        Position = UDim2.new(0, 8, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = notif,
    })
    create("UIPadding", {PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), Parent = textHolder})
    create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = textHolder})

    create("TextLabel", {Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1, Text = title, Font = Theme.FontBold, TextSize = 12, TextColor3 = Theme.TextPrimary, TextXAlignment = Enum.TextXAlignment.Left, Parent = textHolder})
    create("TextLabel", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Text = text, Font = Theme.Font, TextSize = 11, TextColor3 = Theme.TextSecondary, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = textHolder})

    notif.Position = UDim2.new(1.2, 0, 0, 0)
    tween(notif, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)})

    task.delay(duration, function()
        tween(notif, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1.2, 0, 0, 0)}).Completed:Wait()
        notif:Destroy()
    end)
end

return Library
