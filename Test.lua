local AppleGUI = {}
AppleGUI.__index = AppleGUI

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")

-- Theme Configuration
local Themes = {
    dark = {
        windowBackground = Color3.fromRGB(28, 28, 30),
        cardBackground = Color3.fromRGB(44, 44, 46),
        elementBackground = Color3.fromRGB(58, 58, 60),
        primaryText = Color3.fromRGB(255, 255, 255),
        secondaryText = Color3.fromRGB(152, 152, 157),
        tertiaryText = Color3.fromRGB(99, 99, 102),
        accent = Color3.fromRGB(0, 122, 255),
        accentHover = Color3.fromRGB(10, 132, 255),
        success = Color3.fromRGB(52, 199, 89),
        warning = Color3.fromRGB(255, 159, 10),
        error = Color3.fromRGB(255, 69, 58),
        border = Color3.fromRGB(72, 72, 74),
        divider = Color3.fromRGB(56, 56, 58),
        overlay = Color3.fromRGB(0, 0, 0),
        overlayTransparency = 0.6,
        glassTransparency = 0.1,
    },
    light = {
        windowBackground = Color3.fromRGB(255, 255, 255),
        cardBackground = Color3.fromRGB(245, 245, 247),
        elementBackground = Color3.fromRGB(229, 229, 231),
        primaryText = Color3.fromRGB(0, 0, 0),
        secondaryText = Color3.fromRGB(134, 134, 139),
        tertiaryText = Color3.fromRGB(174, 174, 178),
        accent = Color3.fromRGB(0, 122, 255),
        accentHover = Color3.fromRGB(10, 132, 255),
        success = Color3.fromRGB(52, 199, 89),
        warning = Color3.fromRGB(255, 149, 0),
        error = Color3.fromRGB(255, 59, 48),
        border = Color3.fromRGB(209, 209, 214),
        divider = Color3.fromRGB(229, 229, 234),
        overlay = Color3.fromRGB(0, 0, 0),
        overlayTransparency = 0.4,
        glassTransparency = 0.05,
    }
}

-- Utility Functions
local Utils = {}
function Utils.Tween(object, properties, duration, easingStyle, easingDirection, callback)
    duration = duration or 0.3
    easingStyle = easingStyle or Enum.EasingStyle.Quad
    easingDirection = easingDirection or Enum.EasingDirection.Out
    local tween = TweenService:Create(object, TweenInfo.new(duration, easingStyle, easingDirection), properties)
    if callback then tween.Completed:Connect(callback) end
    tween:Play()
    return tween
end
function Utils.CreateRoundedFrame(parent, radius)
    radius = radius or 8
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    frame.BorderSizePixel = 0
    frame.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = frame
    return frame
end
function Utils.CreateShadow(parent, depth)
    depth = depth or 1
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.85
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Size = UDim2.new(1, depth * 8, 1, depth * 8)
    shadow.Position = UDim2.new(0, -depth * 4, 0, depth * 2)
    shadow.ZIndex = (parent.ZIndex or 1) - 1
    shadow.Parent = parent
    return shadow
end
function Utils.MakeDraggable(frame, dragArea)
    local dragging, dragInput, mousePos, framePos = false, nil, nil, nil
    dragArea = dragArea or frame
    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    dragArea.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            Utils.Tween(frame, {Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)}, 0.1, Enum.EasingStyle.Linear)
        end
    end)
end
function Utils.RippleEffect(button, color)
    local ripple = Instance.new("Frame")
    ripple.Name = "Ripple"
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.BackgroundColor3 = color or Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.5
    ripple.BorderSizePixel = 0
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.ZIndex = button.ZIndex + 1
    ripple.Parent = button
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ripple
    local mousePos = UserInputService:GetMouseLocation()
    local buttonPos = button.AbsolutePosition
    local relativePos = mousePos - buttonPos
    ripple.Position = UDim2.new(0, relativePos.X, 0, relativePos.Y)
    local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
    Utils.Tween(ripple, {Size = UDim2.new(0, size, 0, size), BackgroundTransparency = 1}, 0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, function() ripple:Destroy() end)
end

-- Window Class
local Window = {}
Window.__index = Window
function Window.new(config)
    local self = setmetatable({}, Window)
    self.Title = config.Title or "Window"
    self.Size = config.Size or UDim2.new(0, 500, 0, 600)
    self.Theme = config.Theme or "dark"
    self.CurrentTheme = Themes[self.Theme]
    self.Tabs = {}
    self.CurrentTab = nil
    self:CreateScreenGui()
    self:CreateMainWindow()
    self:CreateTitleBar()
    self:CreateTabContainer()
    self:CreateContentArea()
    return self
end

-- Window: ScreenGui Creation
function Window:CreateScreenGui()
    local success, result = pcall(function() return CoreGui:FindFirstChild("AppleGUI") end)
    if success and result then result:Destroy() end
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "AppleGUI"
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.ResetOnSpawn = false
    success = pcall(function() self.ScreenGui.Parent = CoreGui end)
    if not success then self.ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end
end

-- Window: Main Frame
function Window:CreateMainWindow()
    self.MainFrame = Utils.CreateRoundedFrame(self.ScreenGui, 12)
    self.MainFrame.Name = "MainWindow"
    self.MainFrame.Size = self.Size
    self.MainFrame.Position = UDim2.new(0.5, -self.Size.X.Offset/2, 0.5, -self.Size.Y.Offset/2)
    self.MainFrame.BackgroundColor3 = self.CurrentTheme.windowBackground
    self.MainFrame.BackgroundTransparency = self.CurrentTheme.glassTransparency
    self.MainFrame.ZIndex = 1
    local border = Instance.new("UIStroke")
    border.Color = Color3.fromRGB(255, 255, 255)
    border.Transparency = 0.8
    border.Thickness = 1
    border.Parent = self.MainFrame
    Utils.CreateShadow(self.MainFrame, 2)
end

-- Window: Title Bar
function Window:CreateTitleBar()
    self.TitleBar = Utils.CreateRoundedFrame(self.MainFrame, 0)
    self.TitleBar.Name = "TitleBar"
    self.TitleBar.Size = UDim2.new(1, 0, 0, 44)
    self.TitleBar.BackgroundTransparency = 1
    self.TitleBar.ZIndex = 3
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -100, 1, 0)
    titleLabel.Position = UDim2.new(0, 50, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = self.Title
    titleLabel.TextColor3 = self.CurrentTheme.primaryText
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamMedium
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center
    titleLabel.ZIndex = 4
    titleLabel.Parent = self.TitleBar
    local buttonColors = {{Color3.fromRGB(255, 95, 86), "Close"}, {Color3.fromRGB(255, 189, 46), "Minimize"}, {Color3.fromRGB(40, 201, 64), "Maximize"}}
    for i, data in ipairs(buttonColors) do
        local button = Instance.new("TextButton")
        button.Name = data[2]
        button.Size = UDim2.new(0, 12, 0, 12)
        button.Position = UDim2.new(0, 12 + (i-1) * 20, 0.5, -6)
        button.BackgroundColor3 = data[1]
        button.BorderSizePixel = 0
        button.Text = ""
        button.ZIndex = 4
        button.AutoButtonColor = false
        button.Parent = self.TitleBar
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = button
        button.MouseEnter:Connect(function()
            Utils.Tween(button, {BackgroundColor3 = Color3.fromRGB(math.min(255, data[1].R * 255 + 20), math.min(255, data[1].G * 255 + 20), math.min(255, data[1].B * 255 + 20))}, 0.15)
        end)
        button.MouseLeave:Connect(function() Utils.Tween(button, {BackgroundColor3 = data[1]}, 0.15) end)
        if data[2] == "Close" then button.MouseButton1Click:Connect(function() self:Close() end)
        elseif data[2] == "Minimize" then button.MouseButton1Click:Connect(function() self:Minimize() end) end
    end
    Utils.MakeDraggable(self.MainFrame, self.TitleBar)
end

-- Window: Tab Container
function Window:CreateTabContainer()
    self.TabContainer = Utils.CreateRoundedFrame(self.MainFrame, 0)
    self.TabContainer.Name = "TabContainer"
    self.TabContainer.Size = UDim2.new(1, 0, 0, 48)
    self.TabContainer.Position = UDim2.new(0, 0, 0, 44)
    self.TabContainer.BackgroundColor3 = self.CurrentTheme.cardBackground
    self.TabContainer.BackgroundTransparency = 0.3
    self.TabContainer.ZIndex = 3
    local divider = Instance.new("Frame")
    divider.Name = "Divider"
    divider.Size = UDim2.new(1, 0, 0, 1)
    divider.Position = UDim2.new(0, 0, 1, -1)
    divider.BackgroundColor3 = self.CurrentTheme.divider
    divider.BorderSizePixel = 0
    divider.ZIndex = 4
    divider.Parent = self.TabContainer
    self.TabList = Instance.new("Frame")
    self.TabList.Name = "TabList"
    self.TabList.Size = UDim2.new(1, -24, 1, -12)
    self.TabList.Position = UDim2.new(0, 12, 0, 6)
    self.TabList.BackgroundTransparency = 1
    self.TabList.ZIndex = 4
    self.TabList.Parent = self.TabContainer
    local listLayout = Instance.new("UIListLayout")
    listLayout.FillDirection = Enum.FillDirection.Horizontal
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    listLayout.Padding = UDim.new(0, 8)
    listLayout.Parent = self.TabList
end

-- Window: Content Area
function Window:CreateContentArea()
    self.ContentArea = Utils.CreateRoundedFrame(self.MainFrame, 0)
    self.ContentArea.Name = "ContentArea"
    self.ContentArea.Size = UDim2.new(1, -24, 1, -116)
    self.ContentArea.Position = UDim2.new(0, 12, 0, 104)
    self.ContentArea.BackgroundTransparency = 1
    self.ContentArea.ZIndex = 3
    self.ContentArea.ClipsDescendants = true
    self.ScrollFrame = Instance.new("ScrollingFrame")
    self.ScrollFrame.Name = "ScrollFrame"
    self.ScrollFrame.Size = UDim2.new(1, 0, 1, 0)
    self.ScrollFrame.BackgroundTransparency = 1
    self.ScrollFrame.BorderSizePixel = 0
    self.ScrollFrame.ScrollBarThickness = 4
    self.ScrollFrame.ScrollBarImageColor3 = self.CurrentTheme.secondaryText
    self.ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.ScrollFrame.ZIndex = 4
    self.ScrollFrame.Parent = self.ContentArea
    local listLayout = Instance.new("UIListLayout")
    listLayout.FillDirection = Enum.FillDirection.Vertical
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    listLayout.Padding = UDim.new(0, 12)
    listLayout.Parent = self.ScrollFrame
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 12)
    end)
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 6)
    padding.PaddingBottom = UDim.new(0, 6)
    padding.Parent = self.ScrollFrame
end

-- Tab Management
function Window:AddTab(name)
    local tab = {Name = name, Elements = {}, Content = nil}
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name
    tabButton.Size = UDim2.new(0, 0, 1, 0)
    tabButton.BackgroundColor3 = self.CurrentTheme.elementBackground
    tabButton.BackgroundTransparency = 1
    tabButton.BorderSizePixel = 0
    tabButton.Text = name
    tabButton.TextColor3 = self.CurrentTheme.secondaryText
    tabButton.TextSize = 14
    tabButton.Font = Enum.Font.GothamMedium
    tabButton.AutoButtonColor = false
    tabButton.ZIndex = 5
    tabButton.Parent = self.TabList
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = tabButton
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 16)
    padding.PaddingRight = UDim.new(0, 16)
    padding.Parent = tabButton
    local textSize = TextService:GetTextSize(name, 14, Enum.Font.GothamMedium, Vector2.new(1000, 36))
    tabButton.Size = UDim2.new(0, textSize.X + 32, 1, 0)
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = name .. "_Content"
    contentContainer.Size = UDim2.new(1, 0, 1, 0)
    contentContainer.BackgroundTransparency = 1
    contentContainer.Visible = false
    contentContainer.ZIndex = 5
    contentContainer.Parent = self.ScrollFrame
    tab.Content = contentContainer
    tab.Button = tabButton
    tabButton.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
        Utils.RippleEffect(tabButton, self.CurrentTheme.accent)
    end)
    tabButton.MouseEnter:Connect(function()
        if self.CurrentTab ~= tab then Utils.Tween(tabButton, {BackgroundTransparency = 0.7}, 0.2) end
    end)
    tabButton.MouseLeave:Connect(function()
        if self.CurrentTab ~= tab then Utils.Tween(tabButton, {BackgroundTransparency = 1}, 0.2) end
    end)
    table.insert(self.Tabs, tab)
    if #self.Tabs == 1 then self:SelectTab(tab) end
    return setmetatable({_window = self, _tab = tab}, {__index = function(_, key) return Window[key] end})
end
function Window:SelectTab(tab)
    if self.CurrentTab then
        self.CurrentTab.Content.Visible = false
        Utils.Tween(self.CurrentTab.Button, {BackgroundTransparency = 1, TextColor3 = self.CurrentTheme.secondaryText}, 0.2)
    end
    self.CurrentTab = tab
    tab.Content.Visible = true
    Utils.Tween(tab.Button, {BackgroundTransparency = 0, TextColor3 = self.CurrentTheme.primaryText}, 0.2)
end

-- Component: Button
function Window:AddButton(config)
    local tab = self._tab or self.CurrentTab
    if not tab then return end
    local buttonType = config.Type or "primary"
    local text = config.Text or "Button"
    local callback = config.Callback or function() end
    local buttonFrame = Utils.CreateRoundedFrame(tab.Content, 8)
    buttonFrame.Name = "Button_" .. text
    buttonFrame.Size = UDim2.new(1, 0, 0, 36)
    buttonFrame.ZIndex = 6
    buttonFrame.ClipsDescendants = true
    if buttonType == "primary" then
        buttonFrame.BackgroundColor3 = self.CurrentTheme.accent
    elseif buttonType == "secondary" then
        buttonFrame.BackgroundColor3 = self.CurrentTheme.cardBackground
        local stroke = Instance.new("UIStroke")
        stroke.Color = self.CurrentTheme.accent
        stroke.Thickness = 1
        stroke.Parent = buttonFrame
    else
        buttonFrame.BackgroundTransparency = 1
    end
    local button = Instance.new("TextButton")
    button.Name = "Button"
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = text
    button.TextSize = 14
    button.Font = Enum.Font.GothamMedium
    button.AutoButtonColor = false
    button.ZIndex = 7
    button.Parent = buttonFrame
    if buttonType == "primary" then
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        button.TextColor3 = self.CurrentTheme.accent
    end
    button.MouseButton1Click:Connect(function()
        Utils.RippleEffect(buttonFrame, Color3.fromRGB(255, 255, 255))
        Utils.Tween(buttonFrame, {Size = UDim2.new(1, 0, 0, 34)}, 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, function()
            Utils.Tween(buttonFrame, {Size = UDim2.new(1, 0, 0, 36)}, 0.1)
        end)
        callback()
    end)
    button.MouseEnter:Connect(function()
        if buttonType == "primary" then
            Utils.Tween(buttonFrame, {BackgroundColor3 = self.CurrentTheme.accentHover}, 0.2)
        elseif buttonType == "tertiary" then
            Utils.Tween(buttonFrame, {BackgroundTransparency = 0.9}, 0.2)
            buttonFrame.BackgroundColor3 = self.CurrentTheme.elementBackground
        end
    end)
    button.MouseLeave:Connect(function()
        if buttonType == "primary" then
            Utils.Tween(buttonFrame, {BackgroundColor3 = self.CurrentTheme.accent}, 0.2)
        elseif buttonType == "tertiary" then
            Utils.Tween(buttonFrame, {BackgroundTransparency = 1}, 0.2)
        end
    end)
    table.insert(tab.Elements, buttonFrame)
    return buttonFrame
end

-- Component: Toggle
function Window:AddToggle(config)
    local tab = self._tab or self.CurrentTab
    if not tab then return end
    local text = config.Text or "Toggle"
    local default = config.Default or false
    local callback = config.Callback or function() end
    local toggleState = default
    local container = Utils.CreateRoundedFrame(tab.Content, 8)
    container.Name = "Toggle_" .. text
    container.Size = UDim2.new(1, 0, 0, 48)
    container.BackgroundColor3 = self.CurrentTheme.cardBackground
    container.BackgroundTransparency = 0.5
    container.ZIndex = 6
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -75, 1, 0)
    label.Position = UDim2.new(0, 16, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = self.CurrentTheme.primaryText
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 7
    label.Parent = container
    local toggleBg = Utils.CreateRoundedFrame(container, 16)
    toggleBg.Name = "ToggleBackground"
    toggleBg.Size = UDim2.new(0, 51, 0, 31)
    toggleBg.Position = UDim2.new(1, -63, 0.5, -15.5)
    toggleBg.BackgroundColor3 = self.CurrentTheme.elementBackground
    toggleBg.ZIndex = 7
    local toggleKnob = Instance.new("Frame")
    toggleKnob.Name = "Knob"
    toggleKnob.Size = UDim2.new(0, 27, 0, 27)
    toggleKnob.Position = UDim2.new(0, 2, 0, 2)
    toggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleKnob.BorderSizePixel = 0
    toggleKnob.ZIndex = 8
    toggleKnob.Parent = toggleBg
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = toggleKnob
    if default then
        toggleBg.BackgroundColor3 = self.CurrentTheme.success
        toggleKnob.Position = UDim2.new(0, 22, 0, 2)
    end
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.ZIndex = 9
    button.Parent = toggleBg
    button.MouseButton1Click:Connect(function()
        toggleState = not toggleState
        if toggleState then
            Utils.Tween(toggleBg, {BackgroundColor3 = self.CurrentTheme.success}, 0.25, Enum.EasingStyle.Cubic)
            Utils.Tween(toggleKnob, {Position = UDim2.new(0, 22, 0, 2)}, 0.25, Enum.EasingStyle.Cubic)
        else
            Utils.Tween(toggleBg, {BackgroundColor3 = self.CurrentTheme.elementBackground}, 0.25, Enum.EasingStyle.Cubic)
            Utils.Tween(toggleKnob, {Position = UDim2.new(0, 2, 0, 2)}, 0.25, Enum.EasingStyle.Cubic)
        end
        callback(toggleState)
    end)
    table.insert(tab.Elements, container)
    return container
end

-- Component: Slider
function Window:AddSlider(config)
    local tab = self._tab or self.CurrentTab
    if not tab then return end
    local text = config.Text or "Slider"
    local min = config.Min or 0
    local max = config.Max or 100
    local default = config.Default or min
    local step = config.Step or 1
    local callback = config.Callback or function() end
    local sliderValue = default
    local container = Utils.CreateRoundedFrame(tab.Content, 8)
    container.Name = "Slider_" .. text
    container.Size = UDim2.new(1, 0, 0, 64)
    container.BackgroundColor3 = self.CurrentTheme.cardBackground
    container.BackgroundTransparency = 0.5
    container.ZIndex = 6
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -80, 0, 20)
    label.Position = UDim2.new(0, 16, 0, 12)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = self.CurrentTheme.primaryText
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 7
    label.Parent = container
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "Value"
    valueLabel.Size = UDim2.new(0, 60, 0, 20)
    valueLabel.Position = UDim2.new(1, -76, 0, 12)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = self.CurrentTheme.accent
    valueLabel.TextSize = 14
    valueLabel.Font = Enum.Font.GothamMedium
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.ZIndex = 7
    valueLabel.Parent = container
    local sliderTrack = Utils.CreateRoundedFrame(container, 3)
    sliderTrack.Name = "Track"
    sliderTrack.Size = UDim2.new(1, -32, 0, 6)
    sliderTrack.Position = UDim2.new(0, 16, 1, -24)
    sliderTrack.BackgroundColor3 = self.CurrentTheme.elementBackground
    sliderTrack.ZIndex = 7
    local sliderFill = Utils.CreateRoundedFrame(sliderTrack, 3)
    sliderFill.Name = "Fill"
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.Position = UDim2.new(0, 0, 0, 0)
    sliderFill.BackgroundColor3 = self.CurrentTheme.accent
    sliderFill.ZIndex = 8
    local sliderThumb = Instance.new("Frame")
    sliderThumb.Name = "Thumb"
    sliderThumb.Size = UDim2.new(0, 18, 0, 18)
    sliderThumb.Position = UDim2.new((default - min) / (max - min), -9, 0.5, -9)
    sliderThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderThumb.BorderSizePixel = 0
    sliderThumb.ZIndex = 9
    sliderThumb.Parent = sliderTrack
    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(1, 0)
    thumbCorner.Parent = sliderThumb
    local dragging = false
    local function updateSlider(input)
        local pos = (input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X
        pos = math.clamp(pos, 0, 1)
        sliderValue = math.floor((min + (max - min) * pos) / step + 0.5) * step
        sliderValue = math.clamp(sliderValue, min, max)
        local normalizedValue = (sliderValue - min) / (max - min)
        Utils.Tween(sliderFill, {Size = UDim2.new(normalizedValue, 0, 1, 0)}, 0.1)
        Utils.Tween(sliderThumb, {Position = UDim2.new(normalizedValue, -9, 0.5, -9)}, 0.1)
        valueLabel.Text = tostring(sliderValue)
        callback(sliderValue)
    end
    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input)
            Utils.Tween(sliderThumb, {Size = UDim2.new(0, 22, 0, 22)}, 0.1)
        end
    end)
    sliderTrack.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            Utils.Tween(sliderThumb, {Size = UDim2.new(0, 18, 0, 18)}, 0.1)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    table.insert(tab.Elements, container)
    return container
end

-- Component: Dropdown
function Window:AddDropdown(config)
    local tab = self._tab or self.CurrentTab
    if not tab then return end
    local text = config.Text or "Dropdown"
    local options = config.Options or {"Option 1", "Option 2", "Option 3"}
    local default = config.Default or options[1]
    local callback = config.Callback or function() end
    local selectedValue = default
    local dropdownOpen = false
    local container = Utils.CreateRoundedFrame(tab.Content, 8)
    container.Name = "Dropdown_" .. text
    container.Size = UDim2.new(1, 0, 0, 70)
    container.BackgroundColor3 = self.CurrentTheme.cardBackground
    container.BackgroundTransparency = 0.5
    container.ZIndex = 6
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -16, 0, 16)
    label.Position = UDim2.new(0, 16, 0, 8)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = self.CurrentTheme.secondaryText
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 7
    label.Parent = container
    local dropdownButton = Utils.CreateRoundedFrame(container, 6)
    dropdownButton.Name = "DropdownButton"
    dropdownButton.Size = UDim2.new(1, -32, 0, 36)
    dropdownButton.Position = UDim2.new(0, 16, 0, 28)
    dropdownButton.BackgroundColor3 = self.CurrentTheme.elementBackground
    dropdownButton.ZIndex = 7
    local selectedLabel = Instance.new("TextLabel")
    selectedLabel.Size = UDim2.new(1, -40, 1, 0)
    selectedLabel.Position = UDim2.new(0, 12, 0, 0)
    selectedLabel.BackgroundTransparency = 1
    selectedLabel.Text = selectedValue
    selectedLabel.TextColor3 = self.CurrentTheme.primaryText
    selectedLabel.TextSize = 14
    selectedLabel.Font = Enum.Font.Gotham
    selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
    selectedLabel.TextTruncate = Enum.TextTruncate.AtEnd
    selectedLabel.ZIndex = 8
    selectedLabel.Parent = dropdownButton
    local chevron = Instance.new("TextLabel")
    chevron.Size = UDim2.new(0, 20, 1, 0)
    chevron.Position = UDim2.new(1, -28, 0, 0)
    chevron.BackgroundTransparency = 1
    chevron.Text = "▼"
    chevron.TextColor3 = self.CurrentTheme.secondaryText
    chevron.TextSize = 10
    chevron.Font = Enum.Font.GothamBold
    chevron.ZIndex = 8
    chevron.Parent = dropdownButton
    local dropdownMenu = Utils.CreateRoundedFrame(self.ScreenGui, 8)
    dropdownMenu.Name = "DropdownMenu"
    dropdownMenu.Size = UDim2.new(0, dropdownButton.AbsoluteSize.X, 0, 0)
    dropdownMenu.BackgroundColor3 = self.CurrentTheme.cardBackground
    dropdownMenu.Visible = false
    dropdownMenu.ZIndex = 100
    dropdownMenu.ClipsDescendants = true
    local menuBorder = Instance.new("UIStroke")
    menuBorder.Color = self.CurrentTheme.border
    menuBorder.Thickness = 1
    menuBorder.Parent = dropdownMenu
    local menuList = Instance.new("ScrollingFrame")
    menuList.Size = UDim2.new(1, 0, 1, 0)
    menuList.BackgroundTransparency = 1
    menuList.BorderSizePixel = 0
    menuList.ScrollBarThickness = 4
    menuList.ScrollBarImageColor3 = self.CurrentTheme.secondaryText
    menuList.CanvasSize = UDim2.new(0, 0, 0, 0)
    menuList.ZIndex = 101
    menuList.Parent = dropdownMenu
    local listLayout = Instance.new("UIListLayout")
    listLayout.FillDirection = Enum.FillDirection.Vertical
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    listLayout.Padding = UDim.new(0, 0)
    listLayout.Parent = menuList
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        menuList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
    end)
    for _, option in ipairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Size = UDim2.new(1, 0, 0, 36)
        optionButton.BackgroundColor3 = self.CurrentTheme.cardBackground
        optionButton.BorderSizePixel = 0
        optionButton.Text = option
        optionButton.TextColor3 = self.CurrentTheme.primaryText
        optionButton.TextSize = 14
        optionButton.Font = Enum.Font.Gotham
        optionButton.TextXAlignment = Enum.TextXAlignment.Left
        optionButton.AutoButtonColor = false
        optionButton.ZIndex = 102
        optionButton.Parent = menuList
        local optionPadding = Instance.new("UIPadding")
        optionPadding.PaddingLeft = UDim.new(0, 12)
        optionPadding.PaddingRight = UDim.new(0, 12)
        optionPadding.Parent = optionButton
        optionButton.MouseEnter:Connect(function()
            Utils.Tween(optionButton, {BackgroundColor3 = self.CurrentTheme.elementBackground}, 0.15)
        end)
        optionButton.MouseLeave:Connect(function()
            Utils.Tween(optionButton, {BackgroundColor3 = self.CurrentTheme.cardBackground}, 0.15)
        end)
        optionButton.MouseButton1Click:Connect(function()
            selectedValue = option
            selectedLabel.Text = option
            callback(option)
            dropdownOpen = false
            Utils.Tween(dropdownMenu, {Size = UDim2.new(0, dropdownButton.AbsoluteSize.X, 0, 0)}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, function()
                dropdownMenu.Visible = false
            end)
            Utils.Tween(chevron, {Rotation = 0}, 0.2)
        end)
    end
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.ZIndex = 8
    button.Parent = dropdownButton
    button.MouseButton1Click:Connect(function()
        dropdownOpen = not dropdownOpen
        if dropdownOpen then
            local pos = dropdownButton.AbsolutePosition
            dropdownMenu.Position = UDim2.new(0, pos.X, 0, pos.Y + dropdownButton.AbsoluteSize.Y + 4)
            dropdownMenu.Size = UDim2.new(0, dropdownButton.AbsoluteSize.X, 0, 0)
            dropdownMenu.Visible = true
            local maxHeight = math.min(#options * 36, 180)
            Utils.Tween(dropdownMenu, {Size = UDim2.new(0, dropdownButton.AbsoluteSize.X, 0, maxHeight)}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            Utils.Tween(chevron, {Rotation = 180}, 0.2)
        else
            Utils.Tween(dropdownMenu, {Size = UDim2.new(0, dropdownButton.AbsoluteSize.X, 0, 0)}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, function()
                dropdownMenu.Visible = false
            end)
            Utils.Tween(chevron, {Rotation = 0}, 0.2)
        end
    end)
    table.insert(tab.Elements, container)
    return container
end

-- Component: Textbox
function Window:AddTextbox(config)
    local tab = self._tab or self.CurrentTab
    if not tab then return end
    local text = config.Text or "Textbox"
    local placeholder = config.Placeholder or "Enter text..."
    local default = config.Default or ""
    local multiline = config.Multiline or false
    local callback = config.Callback or function() end
    local container = Utils.CreateRoundedFrame(tab.Content, 8)
    container.Name = "Textbox_" .. text
    container.Size = UDim2.new(1, 0, 0, multiline and 96 or 70)
    container.BackgroundColor3 = self.CurrentTheme.cardBackground
    container.BackgroundTransparency = 0.5
    container.ZIndex = 6
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -16, 0, 16)
    label.Position = UDim2.new(0, 16, 0, 8)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = self.CurrentTheme.secondaryText
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 7
    label.Parent = container
    local inputFrame = Utils.CreateRoundedFrame(container, 6)
    inputFrame.Name = "InputFrame"
    inputFrame.Size = UDim2.new(1, -32, 0, multiline and 60 or 36)
    inputFrame.Position = UDim2.new(0, 16, 0, 28)
    inputFrame.BackgroundColor3 = self.CurrentTheme.elementBackground
    inputFrame.ZIndex = 7
    local inputBorder = Instance.new("UIStroke")
    inputBorder.Color = self.CurrentTheme.border
    inputBorder.Thickness = 1
    inputBorder.Transparency = 0.5
    inputBorder.Parent = inputFrame
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, -24, 1, 0)
    textBox.Position = UDim2.new(0, 12, 0, 0)
    textBox.BackgroundTransparency = 1
    textBox.Text = default
    textBox.PlaceholderText = placeholder
    textBox.PlaceholderColor3 = self.CurrentTheme.tertiaryText
    textBox.TextColor3 = self.CurrentTheme.primaryText
    textBox.TextSize = 14
    textBox.Font = Enum.Font.Gotham
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.TextYAlignment = multiline and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center
    textBox.ClearTextOnFocus = false
    textBox.MultiLine = multiline
    textBox.TextWrapped = multiline
    textBox.ZIndex = 8
    textBox.Parent = inputFrame
    textBox.Focused:Connect(function()
        Utils.Tween(inputBorder, {Color = self.CurrentTheme.accent, Transparency = 0, Thickness = 2}, 0.2)
    end)
    textBox.FocusLost:Connect(function()
        Utils.Tween(inputBorder, {Color = self.CurrentTheme.border, Transparency = 0.5, Thickness = 1}, 0.2)
        callback(textBox.Text)
    end)
    table.insert(tab.Elements, container)
    return container
end

-- Component: Label
function Window:AddLabel(config)
    local tab = self._tab or self.CurrentTab
    if not tab then return end
    local text = config.Text or "Label"
    local label = Instance.new("TextLabel")
    label.Name = "Label_" .. text
    label.Size = UDim2.new(1, 0, 0, 24)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = self.CurrentTheme.primaryText
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = true
    label.ZIndex = 7
    label.Parent = tab.Content
    table.insert(tab.Elements, label)
    return label
end

-- Component: Divider
function Window:AddDivider()
    local tab = self._tab or self.CurrentTab
    if not tab then return end
    local divider = Instance.new("Frame")
    divider.Name = "Divider"
    divider.Size = UDim2.new(1, 0, 0, 1)
    divider.BackgroundColor3 = self.CurrentTheme.divider
    divider.BorderSizePixel = 0
    divider.ZIndex = 7
    divider.Parent = tab.Content
    table.insert(tab.Elements, divider)
    return divider
end

-- Window Actions
function Window:Close()
    Utils.Tween(self.MainFrame, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In, function()
        self.ScreenGui:Destroy()
    end)
end
function Window:Minimize()
    if self.Minimized then
        Utils.Tween(self.MainFrame, {Size = self.Size}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        self.Minimized = false
    else
        Utils.Tween(self.MainFrame, {Size = UDim2.new(self.Size.X.Scale, self.Size.X.Offset, 0, 44)}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        self.Minimized = true
    end
end
function Window:ToggleTheme()
    self.Theme = self.Theme == "dark" and "light" or "dark"
    self.CurrentTheme = Themes[self.Theme]
    Utils.Tween(self.MainFrame, {BackgroundColor3 = self.CurrentTheme.windowBackground}, 0.3)
end

-- Notifications
function Window:CreateNotification(config)
    local notifType = config.Type or "info"
    local title = config.Title or "Notification"
    local message = config.Message or ""
    local duration = config.Duration or 3
    local notifColors = {
        info = self.CurrentTheme.accent,
        success = self.CurrentTheme.success,
        warning = self.CurrentTheme.warning,
        error = self.CurrentTheme.error
    }
    local notification = Utils.CreateRoundedFrame(self.ScreenGui, 8)
    notification.Name = "Notification"
    notification.Size = UDim2.new(0, 300, 0, 0)
    notification.Position = UDim2.new(1, -320, 0, 20)
    notification.BackgroundColor3 = self.CurrentTheme.cardBackground
    notification.ZIndex = 200
    local notifBorder = Instance.new("UIStroke")
    notifBorder.Color = notifColors[notifType] or self.CurrentTheme.accent
    notifBorder.Thickness = 2
    notifBorder.Parent = notification
    Utils.CreateShadow(notification, 3)
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -48, 0, 20)
    titleLabel.Position = UDim2.new(0, 12, 0, 12)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = self.CurrentTheme.primaryText
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 201
    titleLabel.Parent = notification
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -24, 0, 0)
    messageLabel.Position = UDim2.new(0, 12, 0, 36)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = self.CurrentTheme.secondaryText
    messageLabel.TextSize = 12
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true
    messageLabel.ZIndex = 201
    messageLabel.Parent = notification
    local textSize = TextService:GetTextSize(message, 12, Enum.Font.Gotham, Vector2.new(264, 1000))
    messageLabel.Size = UDim2.new(1, -24, 0, textSize.Y)
    local totalHeight = 56 + textSize.Y
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 24, 0, 24)
    closeButton.Position = UDim2.new(1, -36, 0, 8)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "×"
    closeButton.TextColor3 = self.CurrentTheme.secondaryText
    closeButton.TextSize = 18
    closeButton.Font = Enum.Font.GothamBold
    closeButton.ZIndex = 201
    closeButton.Parent = notification
    local progressBar = Utils.CreateRoundedFrame(notification, 2)
    progressBar.Size = UDim2.new(1, 0, 0, 3)
    progressBar.Position = UDim2.new(0, 0, 1, -3)
    progressBar.BackgroundColor3 = notifColors[notifType] or self.CurrentTheme.accent
    progressBar.ZIndex = 201
    Utils.Tween(notification, {Size = UDim2.new(0, 300, 0, totalHeight), Position = UDim2.new(1, -320, 0, 20)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    Utils.Tween(progressBar, {Size = UDim2.new(0, 0, 0, 3)}, duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, function()
        Utils.Tween(notification, {Position = UDim2.new(1, 20, 0, 20), Size = UDim2.new(0, 0, 0, totalHeight)}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In, function()
            notification:Destroy()
        end)
    end)
    closeButton.MouseButton1Click:Connect(function()
        Utils.Tween(notification, {Position = UDim2.new(1, 20, 0, 20), Size = UDim2.new(0, 0, 0, totalHeight)}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In, function()
            notification:Destroy()
        end)
    end)
    return notification
end

-- Main Library
function AppleGUI:CreateWindow(config)
    return Window.new(config)
end

return AppleGUI
