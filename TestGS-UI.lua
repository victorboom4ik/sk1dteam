--[[
    GamesenseUI - Pixel-Perfect 1:1 Gamesense Style UI Library for Roblox
--]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

--=============================
-- RIGID PIXEL-PERFECT THEME
--=============================
local Theme = {
    Background      = Color3.fromRGB(12, 12, 12),      -- Главный фон (очень темный)
    Panel           = Color3.fromRGB(16, 16, 16),      -- Фон внутри секций
    BorderOuter     = Color3.fromRGB(48, 48, 48),      -- Светло-серая тонкая рамка
    BorderInner     = Color3.fromRGB(28, 28, 28),      -- Темно-серая рамка элементов
    BorderBlack     = Color3.fromRGB(0, 0, 0),         -- Обязательная черная обводка для контраста
    
    TextPrimary     = Color3.fromRGB(245, 245, 245),   -- Белый текст элементов
    TextSecondary   = Color3.fromRGB(145, 145, 145),   -- Серый текст заголовков/неактивных элементов
    TextDark        = Color3.fromRGB(75, 75, 75),      -- Очень темный для выключенных состояний
    
    AccentGreen     = Color3.fromRGB(163, 224, 72),    -- Фирменный лаймовый Gamesense зеленый
    AccentGradient  = {
        Color3.fromRGB(55, 175, 225),  -- Синий
        Color3.fromRGB(205, 80, 180),  -- Розовый
        Color3.fromRGB(215, 215, 80),  -- Желто-зеленый
    },
    
    Font            = Enum.Font.UbuntuMono,            -- Идеальный моноширинный шрифт для пиксельного стиля
    FontBold        = Enum.Font.UbuntuMono,
    TextSize        = 12,                              -- Мелкий оригинальный размер текста
}

--=============================
-- UTILITY CREATOR
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

-- Создает 1px пиксельную контрастную обводку (черная + серая)
local function applyPixelBorder(parent, outerColor, innerColor)
    create("UIStroke", {
        Color = innerColor or Theme.BorderBlack,
        Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent
    })
    if outerColor then
        create("UIStroke", {
            Color = outerColor,
            Thickness = 2,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Parent = parent
        })
    end
end

--=============================
-- MAIN LIBRARY
--=============================
local Library = {}
Library.__index = Library

function Library.new(title)
    local self = setmetatable({}, Library)

    self.Title = title or "gamesense"
    self.Tabs = {}
    self.ActiveTab = nil
    self.Open = true

    self.ScreenGui = create("ScreenGui", {
        Name = "GamesenseUI_Ultimate",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999,
    })

    pcall(function() self.ScreenGui.Parent = game:GetService("CoreGui") end)
    if not self.ScreenGui.Parent then
        self.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    local winW, winH = 640, 500
    if IsMobile then winW, winH = 480, 340 end

    -- Главное окно (Строгий плоский прямоугольник)
    self.Main = create("Frame", {
        Name = "Main",
        Size = UDim2.fromOffset(winW, winH),
        Position = UDim2.new(0.5, -winW / 2, 0.5, -winH / 2),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 1,
        BorderColor3 = Theme.BorderOuter,
        Parent = self.ScreenGui,
    })
    applyPixelBorder(self.Main, Theme.BorderBlack)

    -- Фирменный верхний трехцветный градиент (толщина ровно 2 пикселя)
    self.TopStrip = create("Frame", {
        Name = "TopStrip",
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 0, 0),
        BorderSizePixel = 0,
        Parent = self.Main,
    })
    
    local sequence = {}
    local step = 1 / (#Theme.AccentGradient - 1)
    for i, c in ipairs(Theme.AccentGradient) do
        table.insert(sequence, ColorSequenceKeypoint.new(step * (i - 1), c))
    end
    create("UIGradient", {
        Color = ColorSequence.new(sequence),
        Rotation = 0,
        Parent = self.TopStrip,
    })

    -- Внутреннее тело с отступом (создает эффект двойной рамки)
    self.Body = create("Frame", {
        Size = UDim2.new(1, -12, 1, -20),
        Position = UDim2.new(0, 6, 0, 14),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 1,
        BorderColor3 = Theme.BorderInner,
        Parent = self.Main,
    })
    applyPixelBorder(self.Body)

    -- Левая панель вкладок (чисто иконки, строго вертикально)
    self.TabBar = create("Frame", {
        Size = UDim2.new(0, 50, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(10, 10, 10),
        BorderSizePixel = 1,
        BorderColor3 = Theme.BorderInner,
        Parent = self.Body
    })
    applyPixelBorder(self.TabBar)

    self.TabBarLayout = create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
        Parent = self.TabBar
    })

    -- Контейнер для страниц (справа от таббара)
    self.PageContainer = create("Frame", {
        Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.new(0, 50, 0, 0),
        BackgroundTransparency = 1,
        Parent = self.Body,
    })

    self:_setupDrag(self.Main)

    -- Скрытие по Insert
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or input.KeyCode ~= Enum.KeyCode.Insert then return end
        self:Toggle()
    end)

    if IsMobile then self:_createMobileToggle() end

    return self
end

function Library:_setupDrag(handle)
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

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
            local delta = input.Position - dragStart
            self.Main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function Library:_createMobileToggle()
    local btn = create("TextButton", {
        Name = "MobileToggle",
        Size = UDim2.fromOffset(36, 36),
        Position = UDim2.new(0, 10, 0.2, 0),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 1,
        BorderColor3 = Theme.BorderOuter,
        Text = "GS",
        TextColor3 = Theme.AccentGreen,
        Font = Theme.FontBold,
        TextSize = 12,
        Parent = self.ScreenGui,
    })
    applyPixelBorder(btn)
    btn.MouseButton1Click:Connect(function() self:Toggle() end)
end

function Library:Toggle()
    self.Open = not self.Open
    self.Main.Visible = self.Open
end

--=============================
-- TABS (Vertical Icon Only)
--=============================
function Library:CreateTab(name, icon)
    local index = #self.Tabs + 1
    icon = icon or "🎯"

    -- Кнопка вкладки
    local button = create("TextButton", {
        Name = name .. "Tab",
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundTransparency = 1,
        Text = "",
        LayoutOrder = index,
        Parent = self.TabBar,
    })

    -- Микро-полоска активности слева
    local indicator = create("Frame", {
        Size = UDim2.new(0, 2, 0, 24),
        Position = UDim2.new(0, 0, 0.5, -12),
        BackgroundColor3 = Theme.AccentGreen,
        BorderSizePixel = 0,
        Visible = index == 1,
        Parent = button
    })

    local iconLabel = create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = icon,
        Font = Theme.Font,
        TextSize = 20,
        TextColor3 = index == 1 and Theme.TextPrimary or Theme.TextSecondary,
        Parent = button,
    })

    -- Контент страницы (Scrolling)
    local page = create("ScrollingFrame", {
        Name = name .. "Page",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 1,
        ScrollBarImageColor3 = Theme.BorderOuter,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = index == 1,
        Parent = self.PageContainer,
    })

    create("UIPadding", {
        PaddingTop = UDim.new(0, 16),
        PaddingLeft = UDim.new(0, 14),
        PaddingRight = UDim.new(0, 14),
        PaddingBottom = UDim.new(0, 16),
        Parent = page,
    })

    -- Две равноправные колонки для идеальной сетки секций
    local leftCol = create("Frame", {
        Name = "LeftColumn",
        Size = UDim2.new(0.5, -8, 1, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = page,
    })
    create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 16),
        Parent = leftCol,
    })

    local rightCol = create("Frame", {
        Name = "RightColumn",
        Size = UDim2.new(0.5, -8, 1, 0),
        Position = UDim2.new(0.5, 8, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = page,
    })
    create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 16),
        Parent = rightCol,
    })

    local tabData = {
        Name = name,
        Button = button,
        Page = page,
        LeftColumn = leftCol,
        RightColumn = rightCol,
        IconLabel = iconLabel,
        Indicator = indicator,
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
    end

    self.ActiveTab = tabData
    tabData.Page.Visible = true
    tabData.Indicator.Visible = true
    tabData.IconLabel.TextColor3 = Theme.TextPrimary
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

    -- Секция с врезанной рамкой
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
    applyPixelBorder(holder)

    -- Контейнер для текста заголовка, перекрывающий рамку секции сверху
    local label = create("TextLabel", {
        Size = UDim2.fromOffset(0, 12),
        Position = UDim2.new(0, 10, 0, -6),
        BackgroundColor3 = Theme.Background, -- Перекрывает рамку фоном
        Text = " " .. text .. " ",
        Font = Theme.FontBold,
        TextSize = Theme.TextSize,
        TextColor3 = Theme.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutomaticSize = Enum.AutomaticSize.X,
        ZIndex = 3,
        Parent = holder,
    })

    local content = create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -16, 0, 0),
        Position = UDim2.new(0, 8, 0, 12),
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

-- 1:1 Маленький квадратный чекбокс
function SectionAPI:AddCheckbox(text, default, callback)
    callback = callback or function() end
    local state = default or false

    local row = create("Frame", {
        Size = UDim2.new(1, 0, 0, 14),
        BackgroundTransparency = 1,
        LayoutOrder = nextOrder(self),
        Parent = self.Content,
    })

    -- Квадратный бокс
    local box = create("Frame", {
        Size = UDim2.fromOffset(8, 8),
        Position = UDim2.new(0, 0, 0.5, -4),
        BackgroundColor3 = state and Theme.AccentGreen or Theme.ToggleOff,
        BorderSizePixel = 1,
        BorderColor3 = Theme.BorderBlack,
        Parent = row,
    })

    local label = create("TextLabel", {
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        Font = Theme.Font,
        TextSize = Theme.TextSize,
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
        box.BackgroundColor3 = state and Theme.AccentGreen or Theme.ToggleOff
        label.TextColor3 = state and Theme.TextPrimary or Theme.TextSecondary
        callback(state)
    end)

    return {
        Set = function(_, value)
            state = value
            box.BackgroundColor3 = state and Theme.AccentGreen or Theme.ToggleOff
            label.TextColor3 = state and Theme.TextPrimary or Theme.TextSecondary
        end,
        Get = function() return state end,
    }
end

-- 1:1 Ультратонкий слайдер со значением прямо на полосе
function SectionAPI:AddSlider(text, min, max, default, callback)
    callback = callback or function() end
    min = min or 0
    max = max or 100
    default = math.clamp(default or min, min, max)

    local row = create("Frame", {
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        LayoutOrder = nextOrder(self),
        Parent = self.Content,
    })

    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 12),
        BackgroundTransparency = 1,
        Text = text,
        Font = Theme.Font,
        TextSize = Theme.TextSize,
        TextColor3 = Theme.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    -- Трек (полоска) слайдера
    local track = create("Frame", {
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 0, 14),
        BackgroundColor3 = Theme.ToggleOff,
        BorderSizePixel = 1,
        BorderColor3 = Theme.BorderBlack,
        Parent = row,
    })

    local fill = create("Frame", {
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Theme.AccentGreen,
        BorderSizePixel = 0,
        Parent = track,
    })

    -- Отображение процентов/значений прямо внутри слайдера
    local valueLabel = create("TextLabel", {
        Size = UDim2.new(0, 40, 0, 12),
        Position = UDim2.new(1, -40, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(default),
        Font = Theme.Font,
        TextSize = 11,
        TextColor3 = Theme.TextPrimary,
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

-- 1:1 Плоский строгий дропдаун
function SectionAPI:AddDropdown(text, options, default, callback)
    callback = callback or function() end
    options = options or {}
    local selected = default or options[1]

    local row = create("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        LayoutOrder = nextOrder(self),
        Parent = self.Content,
    })

    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 12),
        BackgroundTransparency = 1,
        Text = text,
        Font = Theme.Font,
        TextSize = Theme.TextSize,
        TextColor3 = Theme.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    local box = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.new(0, 0, 0, 14),
        BackgroundColor3 = Theme.BorderInner,
        BorderSizePixel = 1,
        BorderColor3 = Theme.BorderBlack,
        Text = "  " .. tostring(selected),
        Font = Theme.Font,
        TextSize = 11,
        TextColor3 = Theme.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
        Parent = row,
    })

    local arrow = create("TextLabel", {
        Size = UDim2.new(0, 14, 1, 0),
        Position = UDim2.new(1, -14, 0, 0),
        BackgroundTransparency = 1,
        Text = "▼",
        Font = Theme.Font,
        TextSize = 8,
        TextColor3 = Theme.TextSecondary,
        Parent = box
    })

    local listOpen = false
    local list = create("Frame", {
        Size = UDim2.new(1, 0, 0, #options * 16),
        Position = UDim2.new(0, 0, 1, 1),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 1,
        BorderColor3 = Theme.BorderBlack,
        Visible = false,
        ZIndex = 10,
        Parent = box,
    })
    create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Parent = list})

    for _, opt in ipairs(options) do
        local optBtn = create("TextButton", {
            Size = UDim2.new(1, 0, 0, 16),
            BackgroundColor3 = Theme.Background,
            BorderSizePixel = 0,
            Text = "  " .. tostring(opt),
            Font = Theme.Font,
            TextSize = 11,
            TextColor3 = (opt == selected) and Theme.AccentGreen or Theme.TextSecondary,
            TextXAlignment = Enum.TextXAlignment.Left,
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
                    btn.TextColor3 = (btn.Text == "  " .. tostring(opt)) and Theme.AccentGreen or Theme.TextSecondary
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

-- 1:1 Плоская серая кнопка
function SectionAPI:AddButton(text, callback)
    callback = callback or function() end

    local btn = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundColor3 = Theme.BorderInner,
        BorderSizePixel = 1,
        BorderColor3 = Theme.BorderBlack,
        Text = text,
        Font = Theme.Font,
        TextSize = 11,
        TextColor3 = Theme.TextPrimary,
        AutoButtonColor = false,
        LayoutOrder = nextOrder(self),
        Parent = self.Content,
    })

    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(36, 36, 36) end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Theme.BorderInner end)
    btn.MouseButton1Click:Connect(callback)

    return btn
end

function SectionAPI:AddLabel(text)
    return create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 12),
        BackgroundTransparency = 1,
        Text = text,
        Font = Theme.Font,
        TextSize = 11,
        TextColor3 = Theme.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = nextOrder(self),
        Parent = self.Content,
    })
end

--=============================
-- 1:1 NOTIFICATIONS
--=============================
local NotificationHolder

local function ensureNotificationHolder(screenGui)
    if NotificationHolder and NotificationHolder.Parent then return NotificationHolder end
    NotificationHolder = create("Frame", {
        Name = "Notifications",
        Size = UDim2.fromOffset(220, 500),
        Position = UDim2.new(1, -230, 1, -510),
        BackgroundTransparency = 1,
        Parent = screenGui,
    })
    create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 4),
        Parent = NotificationHolder,
    })
    return NotificationHolder
end

function Library:Notify(title, text, duration, notifType)
    duration = duration or 4
    notifType = notifType or "info"

    local colors = {
        info = Color3.fromRGB(55, 175, 225),
        success = Theme.AccentGreen,
        warning = Color3.fromRGB(215, 215, 80),
        error = Color3.fromRGB(220, 60, 60),
    }
    local accent = colors[notifType] or colors.info

    local holder = ensureNotificationHolder(self.ScreenGui)

    local notif = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 1,
        BorderColor3 = Theme.BorderInner,
        Parent = holder,
    })
    applyPixelBorder(notif)

    -- Полоска акцента слева
    create("Frame", {
        Size = UDim2.new(0, 2, 1, 0),
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
        Parent = notif,
    })

    local textHolder = create("Frame", {
        Size = UDim2.new(1, -8, 0, 0),
        Position = UDim2.new(0, 6, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = notif,
    })
    create("UIPadding", {PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), Parent = textHolder})
    create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = textHolder})

    create("TextLabel", {Size = UDim2.new(1, 0, 0, 12), BackgroundTransparency = 1, Text = title, Font = Theme.FontBold, TextSize = 11, TextColor3 = Theme.TextPrimary, TextXAlignment = Enum.TextXAlignment.Left, Parent = textHolder})
    create("TextLabel", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Text = text, Font = Theme.Font, TextSize = 10, TextColor3 = Theme.TextSecondary, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = textHolder})

    notif.Position = UDim2.new(1.2, 0, 0, 0)
    TweenService:Create(notif, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()

    task.delay(duration, function()
        local t = TweenService:Create(notif, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1.2, 0, 0, 0)})
        t:Play()
        t.Completed:Wait()
        notif:Destroy()
    end)
end

return Library
