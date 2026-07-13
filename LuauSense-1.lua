--[[
	LuauSense UI Library
	----------------------------------------------------
	Библиотека интерфейса для Roblox (Luau).
	Реализует только визуальные компоненты (окно, вкладки,
	секции, чекбоксы, слайдеры, кнопки, дропдауны, цвет-пикер,
	списки, уведомления). Никакой игровой логики внутри нет —
	это конструктор, из которого ты сам собираешь свой UI.

	Использование (пример в самом низу файла, закомментирован).
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--=========================================================
-- НАСТРОЙКИ ОФОРМЛЕНИЯ (можно менять на своё усмотрение)
--=========================================================

local Theme = {
	Background      = Color3.fromRGB(18, 18, 20),
	Panel           = Color3.fromRGB(24, 24, 27),
	PanelLight      = Color3.fromRGB(32, 32, 36),
	Border          = Color3.fromRGB(45, 45, 50),
	Sidebar         = Color3.fromRGB(14, 14, 16),
	Text            = Color3.fromRGB(210, 210, 215),
	SubText         = Color3.fromRGB(140, 140, 145),
	ButtonIdle      = Color3.fromRGB(40, 40, 44),
	ButtonHover     = Color3.fromRGB(52, 52, 58),
	ButtonPressed   = Color3.fromRGB(30, 30, 33),
	Accent          = Color3.fromRGB(0, 170, 255), -- общий акцентный цвет (настраиваемый)
}

local Font = Enum.Font.Gotham
local FontBold = Enum.Font.GothamBold
local FontSemibold = Enum.Font.GothamSemibold

--=========================================================
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
--=========================================================

local function new(class, props)
	local inst = Instance.new(class)
	for prop, value in pairs(props or {}) do
		if prop ~= "Parent" then
			inst[prop] = value
		end
	end
	if props and props.Parent then
		inst.Parent = props.Parent
	end
	return inst
end

local function corner(parent, radius)
	return new("UICorner", {
		CornerRadius = UDim.new(0, radius or 4),
		Parent = parent,
	})
end

local function stroke(parent, color, thickness)
	return new("UIStroke", {
		Color = color or Theme.Border,
		Thickness = thickness or 1,
		Parent = parent,
	})
end

local function tween(inst, props, duration, style)
	local info = TweenInfo.new(duration or 0.15, style or Enum.EasingStyle.Quad)
	local t = TweenService:Create(inst, info, props)
	t:Play()
	return t
end

--=========================================================
-- КОРНЕВОЙ ScreenGui
--=========================================================

local Library = {}
Library.__index = Library
Library.AccentColor = Theme.Accent

function Library:SetAccentColor(color3)
	Library.AccentColor = color3
end

-- Настройки картинок (по умолчанию выключены — используются заглушки)
function Library:SetUseImages(value)
	self.UseImages = value and true or false
end

function Library:SetPreloadTimeout(seconds)
	self.PreloadTimeout = seconds
end

--=========================================================
-- УВЕДОМЛЕНИЯ (своя реализация, выезжают снизу справа)
--=========================================================

local NotifyHolder

local function ensureNotifyHolder(screenGui)
	if NotifyHolder then return NotifyHolder end
	NotifyHolder = new("Frame", {
		Name = "Notifications",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -16, 1, -16),
		Size = UDim2.new(0, 280, 1, -32),
		Parent = screenGui,
	})
	new("UIListLayout", {
		Parent = NotifyHolder,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	return NotifyHolder
end

function Library:Notify(title, text, duration)
	duration = duration or 4

	local holder = ensureNotifyHolder(self.ScreenGui)

	local frame = new("Frame", {
		BackgroundColor3 = Theme.Panel,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ClipsDescendants = true,
		Parent = holder,
	})
	corner(frame, 6)
	stroke(frame, Theme.Border, 1)

	local accentBar = new("Frame", {
		BackgroundColor3 = Library.AccentColor,
		Size = UDim2.new(0, 3, 1, 0),
		Parent = frame,
	})
	corner(accentBar, 2)

	local pad = new("UIPadding", {
		PaddingLeft = UDim.new(0, 14),
		PaddingRight = UDim.new(0, 12),
		PaddingTop = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 10),
		Parent = frame,
	})

	local titleLabel = new("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		Font = FontBold,
		Text = title or "Уведомление",
		TextColor3 = Theme.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = frame,
	})

	local textLabel = new("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 18),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Font = Font,
		Text = text or "",
		TextColor3 = Theme.SubText,
		TextSize = 13,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = frame,
	})

	frame.Size = UDim2.new(1, 0, 0, 0)
	frame.BackgroundTransparency = 1
	accentBar.BackgroundTransparency = 1
	titleLabel.TextTransparency = 1
	textLabel.TextTransparency = 1

	tween(frame, {BackgroundTransparency = 0}, 0.2)
	tween(accentBar, {BackgroundTransparency = 0}, 0.2)
	tween(titleLabel, {TextTransparency = 0}, 0.2)
	tween(textLabel, {TextTransparency = 0}, 0.2)

	task.delay(duration, function()
		if not frame or not frame.Parent then return end
		tween(frame, {BackgroundTransparency = 1}, 0.25)
		tween(accentBar, {BackgroundTransparency = 1}, 0.25)
		tween(titleLabel, {TextTransparency = 1}, 0.25)
		tween(textLabel, {TextTransparency = 1}, 0.25)
		task.wait(0.25)
		frame:Destroy()
	end)
end

--=========================================================
-- СОЗДАНИЕ ОКНА
--=========================================================

function Library.new(windowTitle)
	local self = setmetatable({}, Library)

	local screenGui = new("ScreenGui", {
		Name = "LuauSense",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = PlayerGui,
	})
	self.ScreenGui = screenGui

	-- настройки картинок: по умолчанию выключены (используются заглушки).
	-- включаются через Library:SetUseImages(true), список картинок для
	-- прелоада собирается автоматически при AddTab(name, imageId)
	self.UseImages = false
	self.PreloadTimeout = 5
	self.PendingImages = {}

	-- главное окно (скрыто, пока не вызван Library:Show())
	local main = new("Frame", {
		Name = "Main",
		BackgroundColor3 = Theme.Background,
		Position = UDim2.new(0.5, -360, 0.5, -220),
		Size = UDim2.new(0, 720, 0, 440),
		Visible = false,
		Parent = screenGui,
	})
	corner(main, 6)
	stroke(main, Theme.Border, 1)
	self.Main = main

	-- радужная полоса сверху
	local rainbow = new("Frame", {
		Name = "RainbowBar",
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 3),
		BorderSizePixel = 0,
		Parent = main,
	})
	corner(rainbow, 6)
	local gradient = new("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 255, 255)),
			ColorSequenceKeypoint.new(0.25, Color3.fromRGB(0, 120, 255)),
			ColorSequenceKeypoint.new(0.50, Color3.fromRGB(255, 0, 220)),
			ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 120, 0)),
			ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 0)),
		}),
		Parent = rainbow,
	})
	-- лёгкая анимация переливания
	task.spawn(function()
		local offset = 0
		while rainbow.Parent do
			offset = (offset + 0.002) % 1
			gradient.Offset = Vector2.new(offset, 0)
			RunService.Heartbeat:Wait()
		end
	end)

	-- заголовок (перетаскивание окна)
	local titleBar = new("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 3),
		Size = UDim2.new(1, 0, 0, 26),
		Parent = main,
	})
	new("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 0),
		Size = UDim2.new(1, -24, 1, 0),
		Font = FontSemibold,
		Text = windowTitle or "LuauSense",
		TextColor3 = Theme.SubText,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = titleBar,
	})

	do
		local dragging, dragStart, startPos
		titleBar.Active = true
		titleBar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = main.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch) then
				local delta = input.Position - dragStart
				main.Position = UDim2.new(
					startPos.X.Scale, startPos.X.Offset + delta.X,
					startPos.Y.Scale, startPos.Y.Offset + delta.Y
				)
			end
		end)
	end

	-- боковая панель вкладок
	local sidebar = new("Frame", {
		Name = "Sidebar",
		BackgroundColor3 = Theme.Sidebar,
		Position = UDim2.new(0, 0, 0, 32),
		Size = UDim2.new(0, 52, 1, -32),
		Parent = main,
	})
	local sidebarLayout = new("UIListLayout", {
		Parent = sidebar,
		Padding = UDim.new(0, 6),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	new("UIPadding", {
		PaddingTop = UDim.new(0, 10),
		Parent = sidebar,
	})
	self.Sidebar = sidebar

	-- контейнер контента вкладок
	local content = new("Frame", {
		Name = "Content",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 52, 0, 32),
		Size = UDim2.new(1, -52, 1, -32),
		Parent = main,
	})
	self.Content = content

	self.Tabs = {}
	self.CurrentTab = nil

	-- переключение видимости: Insert / Delete на ПК
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == Enum.KeyCode.Insert or input.KeyCode == Enum.KeyCode.Delete then
			self:Toggle()
		end
	end)

	-- кнопка "LS" для телефонов
	if UserInputService.TouchEnabled then
		local mobileBtn = new("TextButton", {
			Name = "LS_MobileToggle",
			BackgroundColor3 = Theme.Panel,
			Position = UDim2.new(0, 16, 0.5, -22),
			Size = UDim2.new(0, 44, 0, 44),
			Font = FontBold,
			Text = "LS",
			TextColor3 = Theme.Text,
			TextSize = 15,
			Parent = screenGui,
		})
		corner(mobileBtn, 22)
		stroke(mobileBtn, Theme.Border, 1)
		mobileBtn.Active = true
		mobileBtn.Draggable = true
		mobileBtn.MouseButton1Click:Connect(function()
			self:Toggle()
		end)
	end

	return self
end

function Library:Toggle()
	self.Main.Visible = not self.Main.Visible
end

--[[
	Показывает меню.
	Если Library.UseImages == false — открывается сразу (заглушки).
	Если Library.UseImages == true и есть картинки для прелоада —
	меню появится только когда все картинки загрузятся (ContentProvider),
	либо по истечении PreloadTimeout секунд (чтобы не зависнуть навсегда,
	если ссылка на картинку мёртвая/битая).
]]
function Library:Show()
	local main = self.Main
	local function reveal()
		if main.Visible then return end
		main.Visible = true
		main.BackgroundTransparency = 1
		tween(main, {BackgroundTransparency = 0}, 0.15)
	end

	if self.UseImages and #self.PendingImages > 0 then
		local ContentProvider = game:GetService("ContentProvider")
		local done = false

		task.spawn(function()
			pcall(function()
				ContentProvider:PreloadAsync(self.PendingImages)
			end)
			if not done then
				done = true
				reveal()
			end
		end)

		task.delay(self.PreloadTimeout, function()
			if not done then
				done = true
				reveal()
			end
		end)
	else
		reveal()
	end
end

--=========================================================
-- ВКЛАДКИ
--=========================================================

local Tab = {}
Tab.__index = Tab

function Library:AddTab(name, imageId)
	local library = self

	local tabButton = new("TextButton", {
		BackgroundColor3 = Theme.Sidebar,
		Size = UDim2.new(0, 38, 0, 38),
		AutoButtonColor = false,
		Text = "",
		Parent = self.Sidebar,
	})
	corner(tabButton, 8)

	-- заглушка вместо иконки: кружок с первой буквой названия вкладки.
	-- если включены картинки (Library:SetUseImages(true)) и передан imageId —
	-- заглушка скрывается и вместо неё показывается картинка
	local iconPlaceholder = new("Frame", {
		BackgroundColor3 = Theme.PanelLight,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 22, 0, 22),
		Parent = tabButton,
	})
	corner(iconPlaceholder, 11)
	local letterLabel = new("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Font = FontBold,
		Text = string.upper(string.sub(name, 1, 1)),
		TextColor3 = Theme.SubText,
		TextSize = 12,
		Parent = iconPlaceholder,
	})

	if imageId then
		table.insert(self.PendingImages, imageId)
		if self.UseImages then
			letterLabel.Visible = false
			new("ImageLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
				Image = imageId,
				Parent = iconPlaceholder,
			})
		end
	end

	local page = new("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Visible = false,
		Parent = self.Content,
	})
	new("UIPadding", {
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		PaddingTop = UDim.new(0, 12),
		PaddingBottom = UDim.new(0, 12),
		Parent = page,
	})
	local pageLayout = new("UIListLayout", {
		Parent = page,
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 12),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local tabObj = setmetatable({
		Library = library,
		Button = tabButton,
		Page = page,
		Columns = {},
	}, Tab)

	local function selectTab()
		for _, t in ipairs(library.Tabs) do
			t.Page.Visible = false
			tween(t.Button, {BackgroundColor3 = Theme.Sidebar}, 0.12)
			t.IconPlaceholder.BackgroundColor3 = Theme.PanelLight
		end
		page.Visible = true
		tween(tabButton, {BackgroundColor3 = Theme.PanelLight}, 0.12)
		library.CurrentTab = tabObj
	end
	tabObj.IconPlaceholder = iconPlaceholder

	tabButton.MouseButton1Click:Connect(selectTab)

	table.insert(self.Tabs, tabObj)
	if #self.Tabs == 1 then
		selectTab()
	end

	return tabObj
end

--=========================================================
-- КОЛОНКИ / СЕКЦИИ (groupbox-панели как "Aimbot" / "Other")
--=========================================================

local Section = {}
Section.__index = Section

function Tab:AddColumn()
	local column = new("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0.5, -6, 1, 0),
		Parent = self.Page,
	})
	local layout = new("UIListLayout", {
		Parent = column,
		Padding = UDim.new(0, 12),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	return column
end

function Tab:AddSection(name, column)
	column = column or self:AddColumn()

	local section = new("Frame", {
		BackgroundColor3 = Theme.Panel,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = column,
	})
	corner(section, 6)
	stroke(section, Theme.Border, 1)

	new("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 8),
		Size = UDim2.new(1, -20, 0, 16),
		Font = FontSemibold,
		Text = name,
		TextColor3 = Theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = section,
	})

	local body = new("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 30),
		Size = UDim2.new(1, -20, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = section,
	})
	new("UIListLayout", {
		Parent = body,
		Padding = UDim.new(0, 10),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	new("UIPadding", {
		PaddingBottom = UDim.new(0, 10),
		Parent = body,
	})

	return setmetatable({ Body = body }, Section)
end

--=========================================================
-- ЧЕКБОКС
--=========================================================

function Section:AddCheckbox(text, default, callback)
	local holder = new("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		Parent = self.Body,
	})

	local box = new("Frame", {
		BackgroundColor3 = Theme.PanelLight,
		Size = UDim2.new(0, 16, 0, 16),
		Position = UDim2.new(0, 0, 0, 1),
		Parent = holder,
	})
	corner(box, 3)
	stroke(box, Theme.Border, 1)

	local fill = new("Frame", {
		BackgroundColor3 = Library.AccentColor,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 10, 0, 10),
		BackgroundTransparency = default and 0 or 1,
		Parent = box,
	})
	corner(fill, 2)

	new("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 24, 0, 0),
		Size = UDim2.new(1, -24, 1, 0),
		Font = Font,
		Text = text,
		TextColor3 = Theme.SubText,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = holder,
	})

	local button = new("TextButton", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Text = "",
		Parent = holder,
	})

	local state = default or false
	button.MouseButton1Click:Connect(function()
		state = not state
		tween(fill, {BackgroundTransparency = state and 0 or 1}, 0.12)
		if callback then callback(state) end
	end)

	return {
		Set = function(_, value)
			state = value
			fill.BackgroundTransparency = state and 0 or 1
		end,
		Get = function()
			return state
		end,
	}
end

--=========================================================
-- СЛАЙДЕР
--=========================================================

function Section:AddSlider(text, min, max, default, callback)
	min, max = min or 0, max or 100
	default = math.clamp(default or min, min, max)

	local holder = new("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 34),
		Parent = self.Body,
	})

	local label = new("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 16),
		Font = Font,
		Text = text,
		TextColor3 = Theme.SubText,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = holder,
	})

	local valueLabel = new("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 16),
		Font = Font,
		Text = tostring(default),
		TextColor3 = Theme.SubText,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = holder,
	})

	local track = new("Frame", {
		BackgroundColor3 = Theme.PanelLight,
		Position = UDim2.new(0, 0, 0, 20),
		Size = UDim2.new(1, 0, 0, 6),
		Parent = holder,
	})
	corner(track, 3)

	local fraction = (default - min) / (max - min)
	local fill = new("Frame", {
		BackgroundColor3 = Library.AccentColor,
		Size = UDim2.new(fraction, 0, 1, 0),
		Parent = track,
	})
	corner(fill, 3)

	local dragging = false
	local function setFromX(x)
		local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		local value = math.floor(min + (max - min) * rel + 0.5)
		fill.Size = UDim2.new(rel, 0, 1, 0)
		valueLabel.Text = tostring(value)
		if callback then callback(value) end
		return value
	end

	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			setFromX(input.Position.X)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			setFromX(input.Position.X)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	return {
		Set = function(_, value)
			local rel = math.clamp((value - min) / (max - min), 0, 1)
			fill.Size = UDim2.new(rel, 0, 1, 0)
			valueLabel.Text = tostring(value)
		end,
	}
end

--=========================================================
-- КНОПКА (стиль как "Load config" на референсе)
--=========================================================

function Section:AddButton(text, callback)
	local button = new("TextButton", {
		BackgroundColor3 = Theme.ButtonIdle,
		Size = UDim2.new(1, 0, 0, 28),
		AutoButtonColor = false,
		Font = FontSemibold,
		Text = text,
		TextColor3 = Theme.Text,
		TextSize = 13,
		Parent = self.Body,
	})
	corner(button, 4)
	stroke(button, Theme.Border, 1)

	button.MouseEnter:Connect(function()
		tween(button, {BackgroundColor3 = Theme.ButtonHover}, 0.12)
	end)
	button.MouseLeave:Connect(function()
		tween(button, {BackgroundColor3 = Theme.ButtonIdle}, 0.12)
	end)
	button.MouseButton1Down:Connect(function()
		tween(button, {BackgroundColor3 = Theme.ButtonPressed}, 0.08)
	end)
	button.MouseButton1Up:Connect(function()
		tween(button, {BackgroundColor3 = Theme.ButtonHover}, 0.08)
	end)
	button.MouseButton1Click:Connect(function()
		if callback then callback() end
	end)

	return button
end

--=========================================================
-- ДРОПДАУН
--=========================================================

function Section:AddDropdown(text, options, default, callback)
	options = options or {}

	local holder = new("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 34),
		ClipsDescendants = false,
		ZIndex = 2,
		Parent = self.Body,
	})

	new("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 14),
		Font = Font,
		Text = text,
		TextColor3 = Theme.SubText,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = holder,
	})

	local box = new("TextButton", {
		BackgroundColor3 = Theme.PanelLight,
		Position = UDim2.new(0, 0, 0, 16),
		Size = UDim2.new(1, 0, 0, 22),
		AutoButtonColor = false,
		Font = Font,
		Text = "  " .. tostring(default or options[1] or ""),
		TextColor3 = Theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 2,
		Parent = holder,
	})
	corner(box, 4)
	stroke(box, Theme.Border, 1)

	new("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.new(0, 12, 0, 12),
		Font = Font,
		Text = "▼",
		TextColor3 = Theme.SubText,
		TextSize = 10,
		ZIndex = 2,
		Parent = box,
	})

	local list = new("Frame", {
		BackgroundColor3 = Theme.PanelLight,
		Position = UDim2.new(0, 0, 1, 4),
		Size = UDim2.new(1, 0, 0, #options * 22),
		Visible = false,
		ZIndex = 5,
		Parent = box,
	})
	corner(list, 4)
	stroke(list, Theme.Border, 1)
	new("UIListLayout", {
		Parent = list,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	for _, optionText in ipairs(options) do
		local optionButton = new("TextButton", {
			BackgroundColor3 = Theme.PanelLight,
			Size = UDim2.new(1, 0, 0, 22),
			AutoButtonColor = false,
			Font = Font,
			Text = "  " .. optionText,
			TextColor3 = Theme.SubText,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 5,
			Parent = list,
		})
		optionButton.MouseEnter:Connect(function()
			tween(optionButton, {BackgroundColor3 = Theme.ButtonHover}, 0.1)
		end)
		optionButton.MouseLeave:Connect(function()
			tween(optionButton, {BackgroundColor3 = Theme.PanelLight}, 0.1)
		end)
		optionButton.MouseButton1Click:Connect(function()
			box.Text = "  " .. optionText
			list.Visible = false
			if callback then callback(optionText) end
		end)
	end

	box.MouseButton1Click:Connect(function()
		list.Visible = not list.Visible
	end)

	return {
		Set = function(_, value)
			box.Text = "  " .. tostring(value)
		end,
	}
end

--=========================================================
-- ЦВЕТ-ПИКЕР (упрощённая плашка, открывающая RGB-слайдеры)
--=========================================================

function Section:AddColorPicker(text, default, callback)
	default = default or Color3.fromRGB(255, 255, 255)

	local holder = new("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		Parent = self.Body,
	})

	new("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -30, 1, 0),
		Font = Font,
		Text = text,
		TextColor3 = Theme.SubText,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = holder,
	})

	local swatch = new("TextButton", {
		BackgroundColor3 = default,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 20, 0, 14),
		AutoButtonColor = false,
		Text = "",
		Parent = holder,
	})
	corner(swatch, 3)
	stroke(swatch, Theme.Border, 1)

	local panel = new("Frame", {
		BackgroundColor3 = Theme.PanelLight,
		Position = UDim2.new(1, -180, 1, 6),
		Size = UDim2.new(0, 180, 0, 96),
		Visible = false,
		ZIndex = 6,
		Parent = holder,
	})
	corner(panel, 4)
	stroke(panel, Theme.Border, 1)
	new("UIPadding", {
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
		PaddingTop = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 10),
		Parent = panel,
	})
	local panelLayout = new("UIListLayout", {
		Parent = panel,
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local r, g, b = default.R * 255, default.G * 255, default.B * 255

	local function updateColor()
		local color = Color3.fromRGB(r, g, b)
		swatch.BackgroundColor3 = color
		if callback then callback(color) end
	end

	local function makeChannel(label, value)
		local row = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), Parent = panel })
		new("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 16, 1, 0),
			Font = Font, Text = label, TextColor3 = Theme.SubText, TextSize = 12,
			Parent = row,
		})
		local track = new("Frame", {
			BackgroundColor3 = Theme.Panel,
			Position = UDim2.new(0, 20, 0, 7),
			Size = UDim2.new(1, -20, 0, 6),
			Parent = row,
		})
		corner(track, 3)
		local fill = new("Frame", {
			BackgroundColor3 = Library.AccentColor,
			Size = UDim2.new(value / 255, 0, 1, 0),
			Parent = track,
		})
		corner(fill, 3)

		local dragging = false
		local function setFromX(x)
			local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
			fill.Size = UDim2.new(rel, 0, 1, 0)
			return math.floor(rel * 255)
		end
		track.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				local v = setFromX(input.Position.X)
				if label == "R" then r = v elseif label == "G" then g = v else b = v end
				updateColor()
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local v = setFromX(input.Position.X)
				if label == "R" then r = v elseif label == "G" then g = v else b = v end
				updateColor()
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
	end

	makeChannel("R", r)
	makeChannel("G", g)
	makeChannel("B", b)

	swatch.MouseButton1Click:Connect(function()
		panel.Visible = not panel.Visible
	end)

	return {
		Set = function(_, color)
			r, g, b = color.R * 255, color.G * 255, color.B * 255
			updateColor()
		end,
	}
end

--=========================================================
-- СПИСОК С ЧЕКБОКСАМИ (как "Player ESP" на референсе)
--=========================================================

function Section:AddList(items)
	-- items: массив строк { "Name", "Health bar", ... }
	local results = {}
	for _, itemText in ipairs(items) do
		results[itemText] = self:AddCheckbox(itemText, false, function(state)
			results[itemText] = state
		end)
	end
	return results
end

return Library

--[[
	=========================================================
	ПРИМЕР ИСПОЛЬЗОВАНИЯ (просто для справки, не выполняется)
	=========================================================

	local LuauSense = require(path.to.LuauSense)
	local Library = LuauSense.new("Моё меню")
	Library:SetAccentColor(Color3.fromRGB(0, 170, 255))

	local Tab1 = Library:AddTab("Главная")
	local col1 = Tab1:AddColumn()
	local col2 = Tab1:AddColumn()

	local sectionA = Tab1:AddSection("Секция A", col1)
	sectionA:AddCheckbox("Опция 1", false, function(v) end)
	sectionA:AddSlider("Значение", 0, 100, 50, function(v) end)
	sectionA:AddButton("Нажми меня", function() end)

	local sectionB = Tab1:AddSection("Секция B", col2)
	sectionB:AddDropdown("Режим", {"Первый", "Второй", "Третий"}, "Первый", function(v) end)
	sectionB:AddColorPicker("Цвет", Color3.fromRGB(255, 0, 0), function(c) end)

	Library:Notify("Готово", "Настройки применены", 4)
]]
