--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║                    AppleGUI v2.0                          ║
    ║           Premium UI Library for Roblox                   ║
    ║                  Created by: c4rl                         ║
    ║                                                           ║
    ║  Features:                                                ║
    ║  • 15+ Modern Components                                  ║
    ║  • Smooth Spring Animations                              ║
    ║  • Light & Dark Themes                                    ║
    ║  • Advanced Notifications                                 ║
    ║  • Search Functionality                                   ║
    ║  • Fully Customizable                                     ║
    ╚═══════════════════════════════════════════════════════════╝
]]

local AppleGUI = {}
AppleGUI.__index = AppleGUI
AppleGUI.Version = "2.0.0"

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- Theme Configuration with Extended Palette
local Themes = {
    dark = {
        windowBackground = Color3.fromRGB(28, 28, 30),
        sidebarBackground = Color3.fromRGB(22, 22, 24),
        cardBackground = Color3.fromRGB(44, 44, 46),
        elementBackground = Color3.fromRGB(58, 58, 60),
        hoverBackground = Color3.fromRGB(68, 68, 70),
        primaryText = Color3.fromRGB(255, 255, 255),
        secondaryText = Color3.fromRGB(152, 152, 157),
        tertiaryText = Color3.fromRGB(99, 99, 102),
        accent = Color3.fromRGB(0, 122, 255),
        accentHover = Color3.fromRGB(10, 132, 255),
        accentPressed = Color3.fromRGB(0, 112, 245),
        success = Color3.fromRGB(52, 199, 89),
        warning = Color3.fromRGB(255, 159, 10),
        error = Color3.fromRGB(255, 69, 58),
        info = Color3.fromRGB(90, 200, 245),
        purple = Color3.fromRGB(191, 90, 242),
        pink = Color3.fromRGB(255, 55, 95),
        border = Color3.fromRGB(72, 72, 74),
        divider = Color3.fromRGB(56, 56, 58),
        overlay = Color3.fromRGB(0, 0, 0),
        overlayTransparency = 0.6,
        glassTransparency = 0.02,
        shadowTransparency = 0.7,
    },
    light = {
        windowBackground = Color3.fromRGB(255, 255, 255),
        sidebarBackground = Color3.fromRGB(246, 246, 248),
        cardBackground = Color3.fromRGB(245, 245, 247),
        elementBackground = Color3.fromRGB(229, 229, 231),
        hoverBackground = Color3.fromRGB(219, 219, 221),
        primaryText = Color3.fromRGB(0, 0, 0),
        secondaryText = Color3.fromRGB(134, 134, 139),
        tertiaryText = Color3.fromRGB(174, 174, 178),
        accent = Color3.fromRGB(0, 122, 255),
        accentHover = Color3.fromRGB(10, 132, 255),
        accentPressed = Color3.fromRGB(0, 112, 245),
        success = Color3.fromRGB(52, 199, 89),
        warning = Color3.fromRGB(255, 149, 0),
        error = Color3.fromRGB(255, 59, 48),
        info = Color3.fromRGB(90, 200, 245),
        purple = Color3.fromRGB(175, 82, 222),
        pink = Color3.fromRGB(255, 45, 85),
        border = Color3.fromRGB(209, 209, 214),
        divider = Color3.fromRGB(229, 229, 234),
        overlay = Color3.fromRGB(0, 0, 0),
        overlayTransparency = 0.4,
        glassTransparency = 0.01,
        shadowTransparency = 0.85,
    }
}

-- Utility Functions
local Utils = {}

function Utils.Tween(object, properties, duration, easingStyle, easingDirection, callback)
    duration = duration or 0.3
    easingStyle = easingStyle or Enum.EasingStyle.Quint
    easingDirection = easingDirection or Enum.EasingDirection.Out
    local tween = TweenService:Create(object, TweenInfo.new(duration, easingStyle, easingDirection), properties)
    if callback then 
        tween.Completed:Connect(callback) 
    end
    tween:Play()
    return tween
end

function Utils.Spring(object, properties, callback)
    local info = TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
    local tween = TweenService:Create(object, info, properties)
    if callback then 
        tween.Completed:Connect(callback) 
    end
    tween:Play()
    return tween
end

function Utils.CreateRoundedFrame(parent, radius)
    radius = radius or 8
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
    frame.BorderSizePixel = 0
    frame.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = frame
    return frame
end

function Utils.CreateShadow(parent, depth, transparency)
    depth = depth or 1
    transparency = transparency or 0.7
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = transparency
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Size = UDim2.new(1, depth * 16, 1, depth * 16)
    shadow.Position = UDim2.new(0, -depth * 8, 0, depth * 4)
    shadow.ZIndex = (parent.ZIndex or 1) - 1
    shadow.Parent = parent
    return shadow
end

function Utils.CreateGradient(parent, color1, color2, rotation)
    rotation = rotation or 90
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(color1, color2)
    gradient.Rotation = rotation
    gradient.Parent = parent
    return gradient
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
                if input.UserInputState == Enum.UserInputState.End then 
                    dragging = false 
                end
            end)
        end
    end)
    
    dragArea.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then 
            dragInput = input 
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            Utils.Spring(frame, {
                Position = UDim2.new(
                    framePos.X.Scale, 
                    framePos.X.Offset + delta.X, 
                    framePos.Y.Scale, 
                    framePos.Y.Offset + delta.Y
                )
            })
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
    
    local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2.5
    Utils.Tween(ripple, {
        Size = UDim2.new(0, size, 0, size), 
        BackgroundTransparency = 1
    }, 0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, function() 
        ripple:Destroy() 
    end)
end

-- Advanced Loading Screen
function AppleGUI:CreateLoadingScreen(callback)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AppleGUILoader"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false
    
    local success = pcall(function() 
        screenGui.Parent = CoreGui 
    end)
    if not success then 
        screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") 
    end
    
    local overlay = Instance.new("Frame")
    overlay.Name = "Overlay"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 1000
    overlay.Parent = screenGui
    
    local loadBox = Utils.CreateRoundedFrame(overlay, 20)
    loadBox.Name = "LoadBox"
    loadBox.Size = UDim2.new(0, 0, 0, 0)
    loadBox.Position = UDim2.new(0.5, 0, 0.5, 0)
    loadBox.AnchorPoint = Vector2.new(0.5, 0.5)
    loadBox.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
    loadBox.ZIndex = 1001
    
    Utils.CreateShadow(loadBox, 5, 0.6)
    
    local gradient = Utils.CreateGradient(loadBox, 
        Color3.fromRGB(28, 28, 30), 
        Color3.fromRGB(38, 38, 42), 
        45
    )
    
    local logoText = Instance.new("TextLabel")
    logoText.Name = "Logo"
    logoText.Size = UDim2.new(1, 0, 0.5, 0)
    logoText.Position = UDim2.new(0, 0, 0.25, 0)
    logoText.BackgroundTransparency = 1
    logoText.Text = "c4rl"
    logoText.TextColor3 = Color3.fromRGB(255, 255, 255)
    logoText.TextSize = 0
    logoText.Font = Enum.Font.GothamBold
    logoText.TextTransparency = 1
    logoText.ZIndex = 1002
    logoText.Parent = loadBox
    
    local loadingBar = Utils.CreateRoundedFrame(loadBox, 4)
    loadingBar.Name = "LoadingBar"
    loadingBar.Size = UDim2.new(0.6, 0, 0, 4)
    loadingBar.Position = UDim2.new(0.2, 0, 0.7, 0)
    loadingBar.BackgroundColor3 = Color3.fromRGB(58, 58, 60)
    loadingBar.ZIndex = 1002
    loadingBar.BackgroundTransparency = 1
    
    local loadingFill = Utils.CreateRoundedFrame(loadingBar, 4)
    loadingFill.Name = "Fill"
    loadingFill.Size = UDim2.new(0, 0, 1, 0)
    loadingFill.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
    loadingFill.ZIndex = 1003
    
    Utils.CreateGradient(loadingFill, 
        Color3.fromRGB(0, 122, 255), 
        Color3.fromRGB(10, 132, 255), 
        0
    )
    
    Utils.Tween(loadBox, {Size = UDim2.new(0, 240, 0, 240)}, 0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out, function()
        Utils.Tween(logoText, {TextSize = 52, TextTransparency = 0}, 0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, function()
            Utils.Tween(loadingBar, {BackgroundTransparency = 0}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
            Utils.Tween(loadingFill, {Size = UDim2.new(1, 0, 1, 0)}, 1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, function()
                task.wait(0.3)
                Utils.Tween(logoText, {TextTransparency = 1}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                Utils.Tween(loadingBar, {BackgroundTransparency = 1}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                Utils.Tween(loadingFill, {BackgroundTransparency = 1}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                Utils.Tween(loadBox, {Size = UDim2.new(0, 0, 0, 0)}, 0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In, function()
                    Utils.Tween(overlay, {BackgroundTransparency = 1}, 0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, function()
                        screenGui:Destroy()
                        if callback then callback() end
                    end)
                end)
            end)
        end)
    end)
end

-- Window Class
local Window = {}
Window.__index = Window

function Window.new(config)
    local self = setmetatable({}, Window)
    self.Title = config.Title or "AppleGUI Window"
    self.Size = config.Size or UDim2.new(0, 750, 0, 550)
    self.Theme = config.Theme or "dark"
    self.CurrentTheme = Themes[self.Theme]
    self.Acrylic = config.Acrylic ~= false
    self.Tabs = {}
    self.CurrentTab = nil
    self.Minimized = false
    self.Maximized = false
    self.OriginalSize = self.Size
    self.OriginalPosition = UDim2.new(0.5, -self.Size.X.Offset/2, 0.5, -self.Size.Y.Offset/2)
    self.Notifications = {}
    
    self:CreateScreenGui()
    self:CreateMainWindow()
    self:CreateTitleBar()
    self:CreateSidebar()
    self:CreateContentArea()
    self:CreateSearchBar()
    
    return self
end

function Window:CreateScreenGui()
    local success, result = pcall(function() 
        return CoreGui:FindFirstChild("AppleGUI") 
    end)
    if success and result then 
        result:Destroy() 
    end
    
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "AppleGUI"
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.ResetOnSpawn = false
    
    success = pcall(function() 
        self.ScreenGui.Parent = CoreGui 
    end)
    if not success then 
        self.ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") 
    end
end

function Window:CreateMainWindow()
    self.MainFrame = Utils.CreateRoundedFrame(self.ScreenGui, 16)
    self.MainFrame.Name = "MainWindow"
    self.MainFrame.Size = self.Size
    self.MainFrame.Position = self.OriginalPosition
    self.MainFrame.BackgroundColor3 = self.CurrentTheme.windowBackground
    self.MainFrame.BackgroundTransparency = self.Acrylic and self.CurrentTheme.glassTransparency or 0
    self.MainFrame.ZIndex = 1
    self.MainFrame.ClipsDescendants = true
    
    local border = Instance.new("UIStroke")
    border.Color = Color3.fromRGB(255, 255, 255)
    border.Transparency = 0.85
    border.Thickness = 1
    border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    border.Parent = self.MainFrame
    
    Utils.CreateShadow(self.MainFrame, 4, self.CurrentTheme.shadowTransparency)
    
    if self.Acrylic then
        local noise = Instance.new("Frame")
        noise.Name = "Noise"
        noise.Size = UDim2.new(1, 0, 1, 0)
        noise.BackgroundTransparency = 0.98
        noise.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        noise.BorderSizePixel = 0
        noise.ZIndex = 2
        noise.Parent = self.MainFrame
    end
end

function Window:CreateTitleBar()
    self.TitleBar = Utils.CreateRoundedFrame(self.MainFrame, 0)
    self.TitleBar.Name = "TitleBar"
    self.TitleBar.Size = UDim2.new(1, 0, 0, 52)
    self.TitleBar.BackgroundTransparency = 1
    self.TitleBar.ZIndex = 3
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -120, 1, 0)
    titleLabel.Position = UDim2.new(0, 90, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = self.Title
    titleLabel.TextColor3 = self.CurrentTheme.primaryText
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamMedium
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 4
    titleLabel.Parent = self.TitleBar
    
    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.Name = "Subtitle"
    subtitleLabel.Size = UDim2.new(1, -120, 0, 14)
    subtitleLabel.Position = UDim2.new(0, 90, 0, 30)
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.Text = "v" .. AppleGUI.Version
    subtitleLabel.TextColor3 = self.CurrentTheme.secondaryText
    subtitleLabel.TextSize = 11
    subtitleLabel.Font = Enum.Font.Gotham
    subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    subtitleLabel.ZIndex = 4
    subtitleLabel.Parent = self.TitleBar
    
    local buttonData = {
        {Color3.fromRGB(255, 95, 86), "Close", "×", 18},
        {Color3.fromRGB(255, 189, 46), "Minimize", "-", 16},
        {Color3.fromRGB(40, 201, 64), "Maximize", "+", 14}
    }
    
    for i, data in ipairs(buttonData) do
        local button = Instance.new("TextButton")
        button.Name = data[2]
        button.Size = UDim2.new(0, 14, 0, 14)
        button.Position = UDim2.new(0, 18 + (i-1) * 24, 0.5, -7)
        button.BackgroundColor3 = data[1]
        button.BorderSizePixel = 0
        button.Text = ""
        button.ZIndex = 4
        button.AutoButtonColor = false
        button.Parent = self.TitleBar
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = button
        
        local icon = Instance.new("TextLabel")
        icon.Size = UDim2.new(1, 0, 1, 0)
        icon.BackgroundTransparency = 1
        icon.TextColor3 = Color3.fromRGB(0, 0, 0)
        icon.TextSize = data[4]
        icon.Font = Enum.Font.GothamBold
        icon.TextTransparency = 1
        icon.Text = data[3]
        icon.ZIndex = 5
        icon.Parent = button
        
        button.MouseEnter:Connect(function()
            Utils.Tween(icon, {TextTransparency = 0}, 0.15)
            Utils.Tween(button, {Size = UDim2.new(0, 16, 0, 16)}, 0.15, Enum.EasingStyle.Quint)
        end)
        
        button.MouseLeave:Connect(function()
            Utils.Tween(icon, {TextTransparency = 1}, 0.15)
            Utils.Tween(button, {Size = UDim2.new(0, 14, 0, 14)}, 0.15, Enum.EasingStyle.Quint)
        end)
        
        if data[2] == "Close" then
            button.MouseButton1Click:Connect(function()
                Utils.Tween(icon, {Rotation = 90}, 0.2)
                self:Close()
            end)
        elseif data[2] == "Minimize" then
            button.MouseButton1Click:Connect(function()
                self:Minimize()
            end)
        else
            button.MouseButton1Click:Connect(function()
                self:Maximize()
            end)
        end
    end
    
    local themeToggle = Instance.new("TextButton")
    themeToggle.Name = "ThemeToggle"
    themeToggle.Size = UDim2.new(0, 32, 0, 32)
    themeToggle.Position = UDim2.new(1, -44, 0.5, -16)
    themeToggle.BackgroundColor3 = self.CurrentTheme.elementBackground
    themeToggle.BackgroundTransparency = 0.5
    themeToggle.BorderSizePixel = 0
    themeToggle.Text = self.Theme == "dark" and "☀" or "🌙"
    themeToggle.TextColor3 = self.CurrentTheme.primaryText
    themeToggle.TextSize = 16
    themeToggle.Font = Enum.Font.GothamBold
    themeToggle.ZIndex = 4
    themeToggle.AutoButtonColor = false
    themeToggle.Parent = self.TitleBar
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 8)
    toggleCorner.Parent = themeToggle
    
    themeToggle.MouseButton1Click:Connect(function()
        self:ToggleTheme()
        themeToggle.Text = self.Theme == "dark" and "☀" or "🌙"
        Utils.Tween(themeToggle, {Rotation = 360}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out, function()
            themeToggle.Rotation = 0
        end)
    end)
    
    themeToggle.MouseEnter:Connect(function()
        Utils.Tween(themeToggle, {BackgroundTransparency = 0}, 0.2)
    end)
    
    themeToggle.MouseLeave:Connect(function()
        Utils.Tween(themeToggle, {BackgroundTransparency = 0.5}, 0.2)
    end)
    
    Utils.MakeDraggable(self.MainFrame, self.TitleBar)
end

function Window:CreateSidebar()
    self.Sidebar = Utils.CreateRoundedFrame(self.MainFrame, 0)
    self.Sidebar.Name = "Sidebar"
    self.Sidebar.Size = UDim2.new(0, 200, 1, -52)
    self.Sidebar.Position = UDim2.new(0, 0, 0, 52)
    self.Sidebar.BackgroundColor3 = self.CurrentTheme.sidebarBackground
    self.Sidebar.BackgroundTransparency = 0
    self.Sidebar.ZIndex = 3
    
    local sidebarDivider = Instance.new("Frame")
    sidebarDivider.Name = "Divider"
    sidebarDivider.Size = UDim2.new(0, 1, 1, 0)
    sidebarDivider.Position = UDim2.new(1, 0, 0, 0)
    sidebarDivider.BackgroundColor3 = self.CurrentTheme.divider
    sidebarDivider.BorderSizePixel = 0
    sidebarDivider.ZIndex = 4
    sidebarDivider.Parent = self.Sidebar
    
    self.TabList = Instance.new("ScrollingFrame")
    self.TabList.Name = "TabList"
    self.TabList.Size = UDim2.new(1, -16, 1, -56)
    self.TabList.Position = UDim2.new(0, 8, 0, 48)
    self.TabList.BackgroundTransparency = 1
    self.TabList.BorderSizePixel = 0
    self.TabList.ScrollBarThickness = 4
    self.TabList.ScrollBarImageColor3 = self.CurrentTheme.secondaryText
    self.TabList.ScrollBarImageTransparency = 0.5
    self.TabList.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.TabList.ZIndex = 4
    self.TabList.Parent = self.Sidebar
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.FillDirection = Enum.FillDirection.Vertical
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    listLayout.Padding = UDim.new(0, 4)
    listLayout.Parent = self.TabList
    
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.TabList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 8)
    end)
end

function Window:CreateSearchBar()
    local searchContainer = Utils.CreateRoundedFrame(self.Sidebar, 8)
    searchContainer.Name = "SearchContainer"
    searchContainer.Size = UDim2.new(1, -16, 0, 36)
    searchContainer.Position = UDim2.new(0, 8, 0, 6)
    searchContainer.BackgroundColor3 = self.CurrentTheme.elementBackground
    searchContainer.BackgroundTransparency = 0.3
    searchContainer.ZIndex = 4
    
    local searchIcon = Instance.new("TextLabel")
    searchIcon.Size = UDim2.new(0, 20, 1, 0)
    searchIcon.Position = UDim2.new(0, 10, 0, 0)
    searchIcon.BackgroundTransparency = 1
    searchIcon.Text = "🔍"
    searchIcon.TextColor3 = self.CurrentTheme.secondaryText
    searchIcon.TextSize = 14
    searchIcon.Font = Enum.Font.Gotham
    searchIcon.ZIndex = 5
    searchIcon.Parent = searchContainer
    
    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(1, -40, 1, 0)
    searchBox.Position = UDim2.new(0, 36, 0, 0)
    searchBox.BackgroundTransparency = 1
    searchBox.Text = ""
    searchBox.PlaceholderText = "Search tabs..."
    searchBox.PlaceholderColor3 = self.CurrentTheme.tertiaryText
    searchBox.TextColor3 = self.CurrentTheme.primaryText
    searchBox.TextSize = 13
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    searchBox.ClearTextOnFocus = false
    searchBox.ZIndex = 5
    searchBox.Parent = searchContainer
    
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local searchText = searchBox.Text:lower()
        for _, tab in ipairs(self.Tabs) do
            if searchText == "" or tab.Name:lower():find(searchText) then
                tab.Button.Visible = true
            else
                tab.Button.Visible = false
            end
        end
    end)
    
    searchBox.Focused:Connect(function()
        Utils.Tween(searchContainer, {BackgroundTransparency = 0}, 0.2)
    end)
    
    searchBox.FocusLost:Connect(function()
        Utils.Tween(searchContainer, {BackgroundTransparency = 0.3}, 0.2)
    end)
end

function Window:CreateContentArea()
    self.ContentArea = Utils.CreateRoundedFrame(self.MainFrame, 0)
    self.ContentArea.Name = "ContentArea"
    self.ContentArea.Size = UDim2.new(1, -220, 1, -72)
    self.ContentArea.Position = UDim2.new(0, 210, 0, 62)
    self.ContentArea.BackgroundColor3 = self.CurrentTheme.windowBackground
    self.ContentArea.BackgroundTransparency = 0
    self.ContentArea.ZIndex = 3
    self.ContentArea.ClipsDescendants = true
    
    self.ScrollFrame = Instance.new("ScrollingFrame")
    self.ScrollFrame.Name = "ScrollFrame"
    self.ScrollFrame.Size = UDim2.new(1, 0, 1, 0)
    self.ScrollFrame.BackgroundTransparency = 1
    self.ScrollFrame.BorderSizePixel = 0
    self.ScrollFrame.ScrollBarThickness = 6
    self.ScrollFrame.ScrollBarImageColor3 = self.CurrentTheme.secondaryText
    self.ScrollFrame.ScrollBarImageTransparency = 0.5
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
        self.ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
    end)
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.Parent = self.ScrollFrame
end

function Window:AddTab(name, icon)
    local tab = {
        Name = name, 
        Icon = icon or "📄", 
        Elements = {}, 
        Content = nil,
        Visible = true
    }
    
    local tabButton = Utils.CreateRoundedFrame(self.TabList, 8)
    tabButton.Name = name
    tabButton.Size = UDim2.new(1, 0, 0, 42)
    tabButton.BackgroundColor3 = self.CurrentTheme.sidebarBackground
    tabButton.BackgroundTransparency = 1
    tabButton.ZIndex = 5
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 20, 1, 0)
    iconLabel.Position = UDim2.new(0, 12, 0, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon or "📄"
    iconLabel.TextColor3 = self.CurrentTheme.secondaryText
    iconLabel.TextSize = 16
    iconLabel.Font = Enum.Font.Gotham
    iconLabel.ZIndex = 6
    iconLabel.Parent = tabButton
    
    local tabLabel = Instance.new("TextLabel")
    tabLabel.Size = UDim2.new(1, -44, 1, 0)
    tabLabel.Position = UDim2.new(0, 38, 0, 0)
    tabLabel.BackgroundTransparency = 1
    tabLabel.Text = name
    tabLabel.TextColor3 = self.CurrentTheme.secondaryText
    tabLabel.TextSize = 14
    tabLabel.Font = Enum.Font.Gotham
    tabLabel.TextXAlignment = Enum.TextXAlignment.Left
    tabLabel.TextTruncate = Enum.TextTruncate.AtEnd
    tabLabel.ZIndex = 6
    tabLabel.Parent = tabButton
    
    local indicator = Instance.new("Frame")
    indicator.Name = "Indicator"
    indicator.Size = UDim2.new(0, 3, 0, 0)
    indicator.Position = UDim2.new(0, 0, 0.5, 0)
    indicator.AnchorPoint = Vector2.new(0, 0.5)
    indicator.BackgroundColor3 = self.CurrentTheme.accent
    indicator.BorderSizePixel = 0
    indicator.ZIndex = 7
    indicator.Parent = tabButton
    
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(1, 0)
    indicatorCorner.Parent = indicator
    
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = name .. "_Content"
    contentContainer.Size = UDim2.new(1, 0, 1, 0)
    contentContainer.BackgroundTransparency = 1
    contentContainer.Visible = false
    contentContainer.ZIndex = 5
    contentContainer.Parent = self.ScrollFrame
    
    tab.Content = contentContainer
    tab.Button = tabButton
    tab.Label = tabLabel
    tab.Icon = iconLabel
    tab.Indicator = indicator
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.ZIndex = 6
    button.Parent = tabButton
    
    button.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)
    
    button.MouseEnter:Connect(function()
        if self.CurrentTab ~= tab then
            Utils.Tween(tabButton, {BackgroundTransparency = 0.95}, 0.2)
            Utils.Tween(iconLabel, {TextColor3 = self.CurrentTheme.primaryText}, 0.2)
        end
    end)
    
    button.MouseLeave:Connect(function()
        if self.CurrentTab ~= tab then
            Utils.Tween(tabButton, {BackgroundTransparency = 1}, 0.2)
            Utils.Tween(iconLabel, {TextColor3 = self.CurrentTheme.secondaryText}, 0.2)
        end
    end)
    
    table.insert(self.Tabs, tab)
    if #self.Tabs == 1 then 
        self:SelectTab(tab) 
    end
    
    return setmetatable({_window = self, _tab = tab}, {
        __index = function(_, key) 
            return Window[key] 
        end
    })
end

function Window:SelectTab(tab)
    if self.CurrentTab then
        self.CurrentTab.Content.Visible = false
        Utils.Tween(self.CurrentTab.Button, {BackgroundTransparency = 1}, 0.3, Enum.EasingStyle.Quint)
        Utils.Tween(self.CurrentTab.Label, {TextColor3 = self.CurrentTheme.secondaryText}, 0.3, Enum.EasingStyle.Quint)
        Utils.Tween(self.CurrentTab.Icon, {TextColor3 = self.CurrentTheme.secondaryText}, 0.3, Enum.EasingStyle.Quint)
        Utils.Tween(self.CurrentTab.Indicator, {Size = UDim2.new(0, 3, 0, 0)}, 0.3, Enum.EasingStyle.Quint)
    end
    
    self.CurrentTab = tab
    tab.Content.Visible = true
    
    Utils.Tween(tab.Button, {BackgroundTransparency = 0.92}, 0.3, Enum.EasingStyle.Quint)
    Utils.Tween(tab.Label, {TextColor3 = self.CurrentTheme.primaryText}, 0.3, Enum.EasingStyle.Quint)
    Utils.Tween(tab.Icon, {TextColor3 = self.CurrentTheme.accent}, 0.3, Enum.EasingStyle.Quint)
    Utils.Tween(tab.Indicator, {Size = UDim2.new(0, 3, 0, 26)}, 0.3, Enum.EasingStyle.Quint)
end

-- Continue in next part due to size...

-- Enhanced Button Component
function Window:AddButton(config)
    local tab = self._tab or self.CurrentTab
    if not tab then return end
    
    local buttonType = config.Type or "primary"
    local text = config.Text or "Button"
    local icon = config.Icon
    local callback = config.Callback or function() end
    local disabled = config.Disabled or false
    
    function Window:AddButton(config)
    local tab = self._tab or self.CurrentTab
    if not tab then return end
    local theme = self._window and self._window.CurrentTheme or self.CurrentTheme
    local buttonFrame = Utils.CreateRoundedFrame(tab.Content, 10)
    buttonFrame.Name = "Button_" .. text
    buttonFrame.Size = UDim2.new(1, 0, 0, 46)
    buttonFrame.ZIndex = 6
    buttonFrame.ClipsDescendants = true
    
    if buttonType == "primary" then
        buttonFrame.BackgroundColor3 = theme.accent
        Utils.CreateGradient(buttonFrame, self.CurrentTheme.accent, self.CurrentTheme.accentHover, 45)
    elseif buttonType == "secondary" then
        buttonFrame.BackgroundColor3 = theme.accent
        local stroke = Instance.new("UIStroke")
        stroke.Color = self.CurrentTheme.accent
        stroke.Thickness = 1.5
        stroke.Transparency = 0.3
        stroke.Parent = buttonFrame
    elseif buttonType == "success" then
        buttonFrame.BackgroundColor3 = theme.accent
    elseif buttonType == "danger" then
        buttonFrame.BackgroundColor3 = theme.accent
    else
        buttonFrame.BackgroundTransparency = 1
    end
    
    if disabled then
        buttonFrame.BackgroundTransparency = 0.5
    end
    
    local button = Instance.new("TextButton")
    button.Name = "Button"
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = icon and "" or text
    button.TextSize = 15
    button.Font = Enum.Font.GothamMedium
    button.AutoButtonColor = false
    button.ZIndex = 7
    button.Parent = buttonFrame
    
    if buttonType == "primary" or buttonType == "success" or buttonType == "danger" then
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        button.TextColor3 = self.CurrentTheme.accent
    end
    
    if icon then
        local iconLabel = Instance.new("TextLabel")
        iconLabel.Size = UDim2.new(0, 20, 1, 0)
        iconLabel.Position = UDim2.new(0, 16, 0, 0)
        iconLabel.BackgroundTransparency = 1
        iconLabel.Text = icon
        iconLabel.TextColor3 = button.TextColor3
        iconLabel.TextSize = 18
        iconLabel.Font = Enum.Font.Gotham
        iconLabel.ZIndex = 8
        iconLabel.Parent = buttonFrame
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, -52, 1, 0)
        textLabel.Position = UDim2.new(0, 42, 0, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = text
        textLabel.TextColor3 = button.TextColor3
        textLabel.TextSize = 15
        textLabel.Font = Enum.Font.GothamMedium
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        textLabel.ZIndex = 8
        textLabel.Parent = buttonFrame
    end
    
    if not disabled then
        button.MouseButton1Click:Connect(function()
            Utils.RippleEffect(buttonFrame, Color3.fromRGB(255, 255, 255))
            Utils.Spring(buttonFrame, {Size = UDim2.new(1, 0, 0, 44)})
            task.wait(0.1)
            Utils.Spring(buttonFrame, {Size = UDim2.new(1, 0, 0, 46)})
            callback()
        end)
        
        button.MouseEnter:Connect(function()
            if buttonType == "primary" then
                Utils.Tween(buttonFrame, {BackgroundColor3 = self.CurrentTheme.accentHover}, 0.25, Enum.EasingStyle.Quint)
            elseif buttonType == "tertiary" then
                Utils.Tween(buttonFrame, {BackgroundTransparency = 0.9}, 0.25, Enum.EasingStyle.Quint)
                buttonFrame.BackgroundColor3 = self.CurrentTheme.elementBackground
            end
        end)
        
        button.MouseLeave:Connect(function()
            if buttonType == "primary" then
                Utils.Tween(buttonFrame, {BackgroundColor3 = self.CurrentTheme.accent}, 0.25, Enum.EasingStyle.Quint)
            elseif buttonType == "tertiary" then
                Utils.Tween(buttonFrame, {BackgroundTransparency = 1}, 0.25, Enum.EasingStyle.Quint)
            end
        end)
    end
    
    table.insert(tab.Elements, buttonFrame)
    return buttonFrame
end

-- Enhanced Toggle Component
function Window:AddToggle(config)
    local tab = self._tab or self.CurrentTab
    if not tab then return end
    
    local text = config.Text or "Toggle"
    local description = config.Description
    local default = config.Default or false
    local callback = config.Callback or function() end
    local toggleState = default
    
    local containerHeight = description and 72 or 58
    local container = Utils.CreateRoundedFrame(tab.Content, 10)
    container.Name = "Toggle_" .. text
    container.Size = UDim2.new(1, 0, 0, containerHeight)
    container.BackgroundColor3 = self.CurrentTheme.cardBackground
    container.BackgroundTransparency = 0.3
    container.ZIndex = 6
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -90, 0, 20)
    label.Position = UDim2.new(0, 20, 0, description and 12 or 19)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = self.CurrentTheme.primaryText
    label.TextSize = 15
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 7
    label.Parent = container
    
    if description then
        local descLabel = Instance.new("TextLabel")
        descLabel.Name = "Description"
        descLabel.Size = UDim2.new(1, -90, 0, 16)
        descLabel.Position = UDim2.new(0, 20, 0, 36)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = description
        descLabel.TextColor3 = self.CurrentTheme.secondaryText
        descLabel.TextSize = 12
        descLabel.Font = Enum.Font.Gotham
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.TextWrapped = true
        descLabel.ZIndex = 7
        descLabel.Parent = container
    end
    
    local toggleBg = Utils.CreateRoundedFrame(container, 18)
    toggleBg.Name = "ToggleBackground"
    toggleBg.Size = UDim2.new(0, 54, 0, 32)
    toggleBg.Position = UDim2.new(1, -70, 0.5, -16)
    toggleBg.BackgroundColor3 = self.CurrentTheme.elementBackground
    toggleBg.ZIndex = 7
    
    local toggleKnob = Instance.new("Frame")
    toggleKnob.Name = "Knob"
    toggleKnob.Size = UDim2.new(0, 28, 0, 28)
    toggleKnob.Position = UDim2.new(0, 2, 0, 2)
    toggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleKnob.BorderSizePixel = 0
    toggleKnob.ZIndex = 8
    toggleKnob.Parent = toggleBg
    
    Utils.CreateShadow(toggleKnob, 1, 0.5)
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = toggleKnob
    
    if default then
        toggleBg.BackgroundColor3 = self.CurrentTheme.success
        toggleKnob.Position = UDim2.new(0, 24, 0, 2)
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
            Utils.Spring(toggleBg, {BackgroundColor3 = self.CurrentTheme.success})
            Utils.Spring(toggleKnob, {Position = UDim2.new(0, 24, 0, 2)})
        else
            Utils.Spring(toggleBg, {BackgroundColor3 = self.CurrentTheme.elementBackground})
            Utils.Spring(toggleKnob, {Position = UDim2.new(0, 2, 0, 2)})
        end
        
        callback(toggleState)
    end)
    
    table.insert(tab.Elements, container)
    return container
end

-- Enhanced Slider Component
function Window:AddSlider(config)
    local tab = self._tab or self.CurrentTab
    if not tab then return end
    
    local text = config.Text or "Slider"
    local min = config.Min or 0
    local max = config.Max or 100
    local default = config.Default or min
    local step = config.Step or 1
    local unit = config.Unit or ""
    local callback = config.Callback or function() end
    local sliderValue = default
    
    local container = Utils.CreateRoundedFrame(tab.Content, 10)
    container.Name = "Slider_" .. text
    container.Size = UDim2.new(1, 0, 0, 76)
    container.BackgroundColor3 = self.CurrentTheme.cardBackground
    container.BackgroundTransparency = 0.3
    container.ZIndex = 6
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -100, 0, 24)
    label.Position = UDim2.new(0, 20, 0, 14)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = self.CurrentTheme.primaryText
    label.TextSize = 15
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 7
    label.Parent = container
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "Value"
    valueLabel.Size = UDim2.new(0, 80, 0, 24)
    valueLabel.Position = UDim2.new(1, -96, 0, 14)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default) .. unit
    valueLabel.TextColor3 = self.CurrentTheme.accent
    valueLabel.TextSize = 15
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.ZIndex = 7
    valueLabel.Parent = container
    
    local sliderTrack = Utils.CreateRoundedFrame(container, 4)
    sliderTrack.Name = "Track"
    sliderTrack.Size = UDim2.new(1, -40, 0, 8)
    sliderTrack.Position = UDim2.new(0, 20, 1, -28)
    sliderTrack.BackgroundColor3 = self.CurrentTheme.elementBackground
    sliderTrack.ZIndex = 7
    
    local sliderFill = Utils.CreateRoundedFrame(sliderTrack, 4)
    sliderFill.Name = "Fill"
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.Position = UDim2.new(0, 0, 0, 0)
    sliderFill.BackgroundColor3 = self.CurrentTheme.accent
    sliderFill.ZIndex = 8
    
    Utils.CreateGradient(sliderFill, self.CurrentTheme.accent, self.CurrentTheme.accentHover, 45)
    
    local sliderThumb = Instance.new("Frame")
    sliderThumb.Name = "Thumb"
    sliderThumb.Size = UDim2.new(0, 22, 0, 22)
    sliderThumb.Position = UDim2.new((default - min) / (max - min), -11, 0.5, -11)
    sliderThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderThumb.BorderSizePixel = 0
    sliderThumb.ZIndex = 9
    sliderThumb.Parent = sliderTrack
    
    Utils.CreateShadow(sliderThumb, 1, 0.4)
    
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
        
        Utils.Spring(sliderFill, {Size = UDim2.new(normalizedValue, 0, 1, 0)})
        Utils.Spring(sliderThumb, {Position = UDim2.new(normalizedValue, -11, 0.5, -11)})
        
        valueLabel.Text = tostring(sliderValue) .. unit
        callback(sliderValue)
    end
    
    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input)
            Utils.Spring(sliderThumb, {Size = UDim2.new(0, 26, 0, 26)})
        end
    end)
    
    sliderTrack.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            Utils.Spring(sliderThumb, {Size = UDim2.new(0, 22, 0, 22)})
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    local function setValue(newValue)
        sliderValue = math.clamp(newValue, min, max)
        local normalizedValue = (sliderValue - min) / (max - min)
        Utils.Spring(sliderFill, {Size = UDim2.new(normalizedValue, 0, 1, 0)})
        Utils.Spring(sliderThumb, {Position = UDim2.new(normalizedValue, -11, 0.5, -11)})
        valueLabel.Text = tostring(sliderValue) .. unit
    end
    
    table.insert(tab.Elements, container)
    return container, setValue
end

-- Continue in next message...

-- Enhanced Dropdown Component
function Window:AddDropdown(config)
    local tab = self._tab or self.CurrentTab
    if not tab then return end
    
    local text = config.Text or "Dropdown"
    local options = config.Options or {"Option 1", "Option 2", "Option 3"}
    local default = config.Default or options[1]
    local multi = config.Multi or false
    local callback = config.Callback or function() end
    
    local selectedValue = multi and {default} or default
    local dropdownOpen = false
    
    local container = Utils.CreateRoundedFrame(tab.Content, 10)
    container.Name = "Dropdown_" .. text
    container.Size = UDim2.new(1, 0, 0, 82)
    container.BackgroundColor3 = self.CurrentTheme.cardBackground
    container.BackgroundTransparency = 0.3
    container.ZIndex = 6
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -20, 0, 18)
    label.Position = UDim2.new(0, 20, 0, 12)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = self.CurrentTheme.secondaryText
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 7
    label.Parent = container
    
    local dropdownButton = Utils.CreateRoundedFrame(container, 8)
    dropdownButton.Name = "DropdownButton"
    dropdownButton.Size = UDim2.new(1, -40, 0, 42)
    dropdownButton.Position = UDim2.new(0, 20, 0, 34)
    dropdownButton.BackgroundColor3 = self.CurrentTheme.elementBackground
    dropdownButton.ZIndex = 7
    
    local selectedLabel = Instance.new("TextLabel")
    selectedLabel.Size = UDim2.new(1, -48, 1, 0)
    selectedLabel.Position = UDim2.new(0, 14, 0, 0)
    selectedLabel.BackgroundTransparency = 1
    selectedLabel.Text = multi and table.concat(selectedValue, ", ") or selectedValue
    selectedLabel.TextColor3 = self.CurrentTheme.primaryText
    selectedLabel.TextSize = 14
    selectedLabel.Font = Enum.Font.Gotham
    selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
    selectedLabel.TextTruncate = Enum.TextTruncate.AtEnd
    selectedLabel.ZIndex = 8
    selectedLabel.Parent = dropdownButton
    
    local chevron = Instance.new("TextLabel")
    chevron.Size = UDim2.new(0, 28, 1, 0)
    chevron.Position = UDim2.new(1, -34, 0, 0)
    chevron.BackgroundTransparency = 1
    chevron.Text = "▼"
    chevron.TextColor3 = self.CurrentTheme.secondaryText
    chevron.TextSize = 10
    chevron.Font = Enum.Font.GothamBold
    chevron.ZIndex = 8
    chevron.Parent = dropdownButton
    
    local dropdownMenu = Utils.CreateRoundedFrame(self.ScreenGui, 10)
    dropdownMenu.Name = "DropdownMenu"
    dropdownMenu.Size = UDim2.new(0, dropdownButton.AbsoluteSize.X, 0, 0)
    dropdownMenu.BackgroundColor3 = self.CurrentTheme.cardBackground
    dropdownMenu.Visible = false
    dropdownMenu.ZIndex = 100
    dropdownMenu.ClipsDescendants = true
    
    Utils.CreateShadow(dropdownMenu, 3, 0.5)
    
    local menuBorder = Instance.new("UIStroke")
    menuBorder.Color = self.CurrentTheme.border
    menuBorder.Thickness = 1
    menuBorder.Transparency = 0.5
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
        optionButton.Size = UDim2.new(1, 0, 0, 42)
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
        optionPadding.PaddingLeft = UDim.new(0, 14)
        optionPadding.PaddingRight = UDim.new(0, 14)
        optionPadding.Parent = optionButton
        
        if multi then
            local checkbox = Instance.new("Frame")
            checkbox.Size = UDim2.new(0, 18, 0, 18)
            checkbox.Position = UDim2.new(1, -22, 0.5, -9)
            checkbox.BackgroundColor3 = self.CurrentTheme.elementBackground
            checkbox.BorderSizePixel = 0
            checkbox.ZIndex = 103
            checkbox.Parent = optionButton
            
            local checkCorner = Instance.new("UICorner")
            checkCorner.CornerRadius = UDim.new(0, 4)
            checkCorner.Parent = checkbox
            
            local checkmark = Instance.new("TextLabel")
            checkmark.Size = UDim2.new(1, 0, 1, 0)
            checkmark.BackgroundTransparency = 1
            checkmark.Text = "✓"
            checkmark.TextColor3 = Color3.fromRGB(255, 255, 255)
            checkmark.TextSize = 12
            checkmark.Font = Enum.Font.GothamBold
            checkmark.TextTransparency = 1
            checkmark.ZIndex = 104
            checkmark.Parent = checkbox
            
            if table.find(selectedValue, option) then
                checkbox.BackgroundColor3 = self.CurrentTheme.accent
                checkmark.TextTransparency = 0
            end
        end
        
        optionButton.MouseEnter:Connect(function()
            Utils.Tween(optionButton, {BackgroundColor3 = self.CurrentTheme.hoverBackground}, 0.2, Enum.EasingStyle.Quint)
        end)
        
        optionButton.MouseLeave:Connect(function()
            Utils.Tween(optionButton, {BackgroundColor3 = self.CurrentTheme.cardBackground}, 0.2, Enum.EasingStyle.Quint)
        end)
        
        optionButton.MouseButton1Click:Connect(function()
            if multi then
                local index = table.find(selectedValue, option)
                if index then
                    table.remove(selectedValue, index)
                    local checkbox = optionButton:FindFirstChild("Frame")
                    if checkbox then
                        Utils.Tween(checkbox, {BackgroundColor3 = self.CurrentTheme.elementBackground}, 0.2)
                        Utils.Tween(checkbox:FindFirstChildOfClass("TextLabel"), {TextTransparency = 1}, 0.2)
                    end
                else
                    table.insert(selectedValue, option)
                    local checkbox = optionButton:FindFirstChild("Frame")
                    if checkbox then
                        Utils.Tween(checkbox, {BackgroundColor3 = self.CurrentTheme.accent}, 0.2)
                        Utils.Tween(checkbox:FindFirstChildOfClass("TextLabel"), {TextTransparency = 0}, 0.2)
                    end
                end
                selectedLabel.Text = table.concat(selectedValue, ", ")
                callback(selectedValue)
            else
                selectedValue = option
                selectedLabel.Text = option
                callback(option)
                
                dropdownOpen = false
                Utils.Spring(dropdownMenu, {Size = UDim2.new(0, dropdownButton.AbsoluteSize.X, 0, 0)})
                task.wait(0.3)
                dropdownMenu.Visible = false
                Utils.Spring(chevron, {Rotation = 0})
            end
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
            dropdownMenu.Position = UDim2.new(0, pos.X, 0, pos.Y + dropdownButton.AbsoluteSize.Y + 6)
            dropdownMenu.Size = UDim2.new(0, dropdownButton.AbsoluteSize.X, 0, 0)
            dropdownMenu.Visible = true
            
            local maxHeight = math.min(#options * 42, 220)
            Utils.Spring(dropdownMenu, {Size = UDim2.new(0, dropdownButton.AbsoluteSize.X, 0, maxHeight)})
            Utils.Spring(chevron, {Rotation = 180})
        else
            Utils.Spring(dropdownMenu, {Size = UDim2.new(0, dropdownButton.AbsoluteSize.X, 0, 0)})
            task.wait(0.3)
            dropdownMenu.Visible = false
            Utils.Spring(chevron, {Rotation = 0})
        end
    end)
    
    table.insert(tab.Elements, container)
    return container
end

-- Enhanced Textbox Component  
function Window:AddTextbox(config)
    local tab = self._tab or self.CurrentTab
    if not tab then return end
    
    local text = config.Text or "Textbox"
    local placeholder = config.Placeholder or "Enter text..."
    local default = config.Default or ""
    local multiline = config.Multiline or false
    local numeric = config.Numeric or false
    local callback = config.Callback or function() end
    
    local container = Utils.CreateRoundedFrame(tab.Content, 10)
    container.Name = "Textbox_" .. text
    container.Size = UDim2.new(1, 0, 0, multiline and 116 or 82)
    container.BackgroundColor3 = self.CurrentTheme.cardBackground
    container.BackgroundTransparency = 0.3
    container.ZIndex = 6
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -20, 0, 18)
    label.Position = UDim2.new(0, 20, 0, 12)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = self.CurrentTheme.secondaryText
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 7
    label.Parent = container
    
    local inputFrame = Utils.CreateRoundedFrame(container, 8)
    inputFrame.Name = "InputFrame"
    inputFrame.Size = UDim2.new(1, -40, 0, multiline and 74 or 42)
    inputFrame.Position = UDim2.new(0, 20, 0, 34)
    inputFrame.BackgroundColor3 = self.CurrentTheme.elementBackground
    inputFrame.ZIndex = 7
    
    local inputBorder = Instance.new("UIStroke")
    inputBorder.Color = self.CurrentTheme.border
    inputBorder.Thickness = 1
    inputBorder.Transparency = 0.5
    inputBorder.Parent = inputFrame
    
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, -28, 1, multiline and -14 or 0)
    textBox.Position = UDim2.new(0, 14, 0, multiline and 7 or 0)
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
    
    if numeric then
        textBox:GetPropertyChangedSignal("Text"):Connect(function()
            local text = textBox.Text
            local filtered = text:gsub("[^%d%.%-]", "")
            if filtered ~= text then
                textBox.Text = filtered
            end
        end)
    end
    
    textBox.Focused:Connect(function()
        Utils.Spring(inputBorder, {Color = self.CurrentTheme.accent, Transparency = 0, Thickness = 2})
        Utils.Spring(inputFrame, {
            BackgroundColor3 = Color3.fromRGB(
                self.CurrentTheme.elementBackground.R * 255 + 8,
                self.CurrentTheme.elementBackground.G * 255 + 8,
                self.CurrentTheme.elementBackground.B * 255 + 8
            )
        })
    end)
    
    textBox.FocusLost:Connect(function()
        Utils.Spring(inputBorder, {Color = self.CurrentTheme.border, Transparency = 0.5, Thickness = 1})
        Utils.Spring(inputFrame, {BackgroundColor3 = self.CurrentTheme.elementBackground})
        callback(textBox.Text)
    end)
    
    table.insert(tab.Elements, container)
    return container, textBox
end

-- Continue in next part...

-- Color Picker Component
function Window:AddColorPicker(config)
    local tab = self._tab or self.CurrentTab
    if not tab then return end
    
    local text = config.Text or "Color Picker"
    local default = config.Default or Color3.fromRGB(0, 122, 255)
    local callback = config.Callback or function() end
    
    local selectedColor = default
    
    local container = Utils.CreateRoundedFrame(tab.Content, 10)
    container.Name = "ColorPicker_" .. text
    container.Size = UDim2.new(1, 0, 0, 58)
    container.BackgroundColor3 = self.CurrentTheme.cardBackground
    container.BackgroundTransparency = 0.3
    container.ZIndex = 6
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -80, 1, 0)
    label.Position = UDim2.new(0, 20, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = self.CurrentTheme.primaryText
    label.TextSize = 15
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 7
    label.Parent = container
    
    local colorDisplay = Utils.CreateRoundedFrame(container, 8)
    colorDisplay.Name = "ColorDisplay"
    colorDisplay.Size = UDim2.new(0, 48, 0, 32)
    colorDisplay.Position = UDim2.new(1, -64, 0.5, -16)
    colorDisplay.BackgroundColor3 = selectedColor
    colorDisplay.ZIndex = 7
    
    local displayBorder = Instance.new("UIStroke")
    displayBorder.Color = self.CurrentTheme.border
    displayBorder.Thickness = 1
    displayBorder.Transparency = 0.5
    displayBorder.Parent = colorDisplay
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.ZIndex = 8
    button.Parent = colorDisplay
    
    button.MouseButton1Click:Connect(function()
        callback(selectedColor)
    end)
    
    button.MouseEnter:Connect(function()
        Utils.Tween(displayBorder, {Color = self.CurrentTheme.accent, Transparency = 0}, 0.2)
    end)
    
    button.MouseLeave:Connect(function()
        Utils.Tween(displayBorder, {Color = self.CurrentTheme.border, Transparency = 0.5}, 0.2)
    end)
    
    table.insert(tab.Elements, container)
    return container
end

-- Keybind Component
function Window:AddKeybind(config)
    local tab = self._tab or self.CurrentTab
    if not tab then return end
    
    local text = config.Text or "Keybind"
    local default = config.Default or Enum.KeyCode.E
    local callback = config.Callback or function() end
    
    local currentKey = default
    local listening = false
    
    local container = Utils.CreateRoundedFrame(tab.Content, 10)
    container.Name = "Keybind_" .. text
    container.Size = UDim2.new(1, 0, 0, 58)
    container.BackgroundColor3 = self.CurrentTheme.cardBackground
    container.BackgroundTransparency = 0.3
    container.ZIndex = 6
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -130, 1, 0)
    label.Position = UDim2.new(0, 20, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = self.CurrentTheme.primaryText
    label.TextSize = 15
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 7
    label.Parent = container
    
    local keybindButton = Utils.CreateRoundedFrame(container, 8)
    keybindButton.Name = "KeybindButton"
    keybindButton.Size = UDim2.new(0, 100, 0, 32)
    keybindButton.Position = UDim2.new(1, -116, 0.5, -16)
    keybindButton.BackgroundColor3 = self.CurrentTheme.elementBackground
    keybindButton.ZIndex = 7
    
    local keyLabel = Instance.new("TextLabel")
    keyLabel.Size = UDim2.new(1, 0, 1, 0)
    keyLabel.BackgroundTransparency = 1
    keyLabel.Text = currentKey.Name
    keyLabel.TextColor3 = self.CurrentTheme.primaryText
    keyLabel.TextSize = 13
    keyLabel.Font = Enum.Font.GothamMedium
    keyLabel.ZIndex = 8
    keyLabel.Parent = keybindButton
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.ZIndex = 8
    button.Parent = keybindButton
    
    button.MouseButton1Click:Connect(function()
        listening = true
        keyLabel.Text = "..."
        Utils.Tween(keybindButton, {BackgroundColor3 = self.CurrentTheme.accent}, 0.2)
    end)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
            currentKey = input.KeyCode
            keyLabel.Text = currentKey.Name
            listening = false
            Utils.Tween(keybindButton, {BackgroundColor3 = self.CurrentTheme.elementBackground}, 0.2)
        end
        
        if not gameProcessed and input.KeyCode == currentKey then
            callback()
        end
    end)
    
    table.insert(tab.Elements, container)
    return container
end

-- Label Component
function Window:AddLabel(config)
    local tab = self._tab or self.CurrentTab
    if not tab then return end
    
    local text = config.Text or "Label"
    local size = config.Size or 15
    local color = config.Color or self.CurrentTheme.primaryText
    
    local label = Instance.new("TextLabel")
    label.Name = "Label_" .. text
    label.Size = UDim2.new(1, 0, 0, 30)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextSize = size
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = true
    label.ZIndex = 7
    label.Parent = tab.Content
    
    table.insert(tab.Elements, label)
    return label
end

-- Section Component
function Window:AddSection(text)
    local tab = self._tab or self.CurrentTab
    if not tab then return end
    
    local section = Instance.new("Frame")
    section.Name = "Section_" .. text
    section.Size = UDim2.new(1, 0, 0, 40)
    section.BackgroundTransparency = 1
    section.ZIndex = 6
    section.Parent = tab.Content
    
    local sectionLabel = Instance.new("TextLabel")
    sectionLabel.Size = UDim2.new(1, -40, 1, 0)
    sectionLabel.Position = UDim2.new(0, 20, 0, 0)
    sectionLabel.BackgroundTransparency = 1
    sectionLabel.Text = text
    sectionLabel.TextColor3 = self.CurrentTheme.primaryText
    sectionLabel.TextSize = 17
    sectionLabel.Font = Enum.Font.GothamBold
    sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    sectionLabel.TextYAlignment = Enum.TextYAlignment.Bottom
    sectionLabel.ZIndex = 7
    sectionLabel.Parent = section
    
    local sectionLine = Instance.new("Frame")
    sectionLine.Size = UDim2.new(1, -40, 0, 2)
    sectionLine.Position = UDim2.new(0, 20, 1, -4)
    sectionLine.BackgroundColor3 = self.CurrentTheme.accent
    sectionLine.BorderSizePixel = 0
    sectionLine.ZIndex = 7
    sectionLine.Parent = section
    
    local lineCorner = Instance.new("UICorner")
    lineCorner.CornerRadius = UDim.new(1, 0)
    lineCorner.Parent = sectionLine
    
    table.insert(tab.Elements, section)
    return section
end

-- Divider Component
function Window:AddDivider()
    local tab = self._tab or self.CurrentTab
    if not tab then return end
    
    local divider = Instance.new("Frame")
    divider.Name = "Divider"
    divider.Size = UDim2.new(1, -40, 0, 1)
    divider.Position = UDim2.new(0, 20, 0, 0)
    divider.BackgroundColor3 = self.CurrentTheme.divider
    divider.BorderSizePixel = 0
    divider.ZIndex = 7
    divider.Parent = tab.Content
    
    table.insert(tab.Elements, divider)
    return divider
end

-- Paragraph Component
function Window:AddParagraph(config)
    local tab = self._tab or self.CurrentTab
    if not tab then return end
    
    local title = config.Title or "Paragraph"
    local content = config.Content or "Content text here..."
    
    local container = Utils.CreateRoundedFrame(tab.Content, 10)
    container.Name = "Paragraph_" .. title
    container.Size = UDim2.new(1, 0, 0, 80)
    container.BackgroundColor3 = self.CurrentTheme.cardBackground
    container.BackgroundTransparency = 0.3
    container.ZIndex = 6
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -40, 0, 22)
    titleLabel.Position = UDim2.new(0, 20, 0, 12)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = self.CurrentTheme.primaryText
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 7
    titleLabel.Parent = container
    
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Size = UDim2.new(1, -40, 1, -46)
    contentLabel.Position = UDim2.new(0, 20, 0, 38)
    contentLabel.BackgroundTransparency = 1
    contentLabel.Text = content
    contentLabel.TextColor3 = self.CurrentTheme.secondaryText
    contentLabel.TextSize = 13
    contentLabel.Font = Enum.Font.Gotham
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.TextYAlignment = Enum.TextYAlignment.Top
    contentLabel.TextWrapped = true
    contentLabel.ZIndex = 7
    contentLabel.Parent = container
    
    local textSize = TextService:GetTextSize(
        content, 
        13, 
        Enum.Font.Gotham, 
        Vector2.new(container.AbsoluteSize.X - 40, 1000)
    )
    
    container.Size = UDim2.new(1, 0, 0, textSize.Y + 58)
    
    table.insert(tab.Elements, container)
    return container
end

-- Window Actions
function Window:Close()
    Utils.Spring(self.MainFrame, {
        Size = UDim2.new(0, 0, 0, 0), 
        Position = UDim2.new(0.5, 0, 0.5, 0)
    })
    task.wait(0.6)
    self.ScreenGui:Destroy()
end

function Window:Minimize()
    if self.Minimized then
        Utils.Spring(self.MainFrame, {Size = self.OriginalSize})
        self.Minimized = false
    else
        Utils.Spring(self.MainFrame, {Size = UDim2.new(self.OriginalSize.X.Scale, self.OriginalSize.X.Offset, 0, 52)})
        self.Minimized = true
    end
end

function Window:Maximize()
    if self.Maximized then
        Utils.Spring(self.MainFrame, {Size = self.OriginalSize, Position = self.OriginalPosition})
        self.Maximized = false
    else
        local viewport = workspace.CurrentCamera.ViewportSize
        Utils.Spring(self.MainFrame, {
            Size = UDim2.new(0, viewport.X - 120, 0, viewport.Y - 120), 
            Position = UDim2.new(0.5, -(viewport.X - 120)/2, 0.5, -(viewport.Y - 120)/2)
        })
        self.Maximized = true
    end
end

function Window:ToggleTheme()
    self.Theme = self.Theme == "dark" and "light" or "dark"
    self.CurrentTheme = Themes[self.Theme]
    
    Utils.Spring(self.MainFrame, {BackgroundColor3 = self.CurrentTheme.windowBackground})
    Utils.Spring(self.Sidebar, {BackgroundColor3 = self.CurrentTheme.sidebarBackground})
    
    for _, tab in ipairs(self.Tabs) do
        Utils.Spring(tab.Label, {TextColor3 = self.CurrentTab == tab and self.CurrentTheme.primaryText or self.CurrentTheme.secondaryText})
        Utils.Spring(tab.Icon, {TextColor3 = self.CurrentTab == tab and self.CurrentTheme.accent or self.CurrentTheme.secondaryText})
    end
end

-- Enhanced Notifications
function Window:CreateNotification(config)
    local notifType = config.Type or "info"
    local title = config.Title or "Notification"
    local message = config.Message or ""
    local duration = config.Duration or 4
    local icon = config.Icon
    
    local notifColors = {
        info = self.CurrentTheme.info,
        success = self.CurrentTheme.success,
        warning = self.CurrentTheme.warning,
        error = self.CurrentTheme.error
    }
    
    local notifIcons = {
        info = "ℹ",
        success = "✓",
        warning = "⚠",
        error = "✕"
    }
    
    local notification = Utils.CreateRoundedFrame(self.ScreenGui, 12)
    notification.Name = "Notification"
    notification.Size = UDim2.new(0, 360, 0, 0)
    notification.Position = UDim2.new(1, -380, 0, 20 + (#self.Notifications * 110))
    notification.BackgroundColor3 = self.CurrentTheme.cardBackground
    notification.ZIndex = 200
    notification.ClipsDescendants = true
    
    local notifBorder = Instance.new("UIStroke")
    notifBorder.Color = notifColors[notifType] or self.CurrentTheme.accent
    notifBorder.Thickness = 2
    notifBorder.Transparency = 0.3
    notifBorder.Parent = notification
    
    Utils.CreateShadow(notification, 4, 0.5)
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 36, 0, 36)
    iconLabel.Position = UDim2.new(0, 16, 0, 16)
    iconLabel.BackgroundColor3 = notifColors[notifType] or self.CurrentTheme.accent
    iconLabel.BackgroundTransparency = 0.9
    iconLabel.BorderSizePixel = 0
    iconLabel.Text = icon or notifIcons[notifType] or "ℹ"
    iconLabel.TextColor3 = notifColors[notifType] or self.CurrentTheme.accent
    iconLabel.TextSize = 20
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.ZIndex = 201
    iconLabel.Parent = notification
    
    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(0, 8)
    iconCorner.Parent = iconLabel
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -108, 0, 22)
    titleLabel.Position = UDim2.new(0, 60, 0, 16)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = self.CurrentTheme.primaryText
    titleLabel.TextSize = 15
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
    titleLabel.ZIndex = 201
    titleLabel.Parent = notification
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -76, 0, 0)
    messageLabel.Position = UDim2.new(0, 60, 0, 42)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = self.CurrentTheme.secondaryText
    messageLabel.TextSize = 13
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true
    messageLabel.ZIndex = 201
    messageLabel.Parent = notification
    
    local textSize = TextService:GetTextSize(message, 13, Enum.Font.Gotham, Vector2.new(284, 1000))
    messageLabel.Size = UDim2.new(1, -76, 0, textSize.Y)
    
    local totalHeight = math.max(68, 58 + textSize.Y)
    
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 32, 0, 32)
    closeButton.Position = UDim2.new(1, -44, 0, 12)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "×"
    closeButton.TextColor3 = self.CurrentTheme.secondaryText
    closeButton.TextSize = 22
    closeButton.Font = Enum.Font.GothamBold
    closeButton.ZIndex = 201
    closeButton.AutoButtonColor = false
    closeButton.Parent = notification
    
    closeButton.MouseEnter:Connect(function()
        Utils.Tween(closeButton, {TextColor3 = self.CurrentTheme.primaryText}, 0.2)
    end)
    
    closeButton.MouseLeave:Connect(function()
        Utils.Tween(closeButton, {TextColor3 = self.CurrentTheme.secondaryText}, 0.2)
    end)
    
    local progressBar = Utils.CreateRoundedFrame(notification, 3)
    progressBar.Size = UDim2.new(1, 0, 0, 4)
    progressBar.Position = UDim2.new(0, 0, 1, -4)
    progressBar.BackgroundColor3 = notifColors[notifType] or self.CurrentTheme.accent
    progressBar.ZIndex = 201
    
    table.insert(self.Notifications, notification)
    
    Utils.Spring(notification, {Size = UDim2.new(0, 360, 0, totalHeight)})
    
    Utils.Tween(progressBar, {Size = UDim2.new(0, 0, 0, 4)}, duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, function()
        local index = table.find(self.Notifications, notification)
        if index then
            table.remove(self.Notifications, index)
        end
        
        Utils.Spring(notification, {Position = UDim2.new(1, 20, 0, notification.Position.Y.Offset)})
        task.wait(0.4)
        notification:Destroy()
        
        for i, notif in ipairs(self.Notifications) do
            Utils.Spring(notif, {Position = UDim2.new(1, -380, 0, 20 + ((i-1) * 110))})
        end
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        local index = table.find(self.Notifications, notification)
        if index then
            table.remove(self.Notifications, index)
        end
        
        Utils.Spring(notification, {Position = UDim2.new(1, 20, 0, notification.Position.Y.Offset)})
        task.wait(0.4)
        notification:Destroy()
        
        for i, notif in ipairs(self.Notifications) do
            Utils.Spring(notif, {Position = UDim2.new(1, -380, 0, 20 + ((i-1) * 110))})
        end
    end)
    
    return notification
end

-- Main Library Function
function AppleGUI:CreateWindow(config)
    local window
    self:CreateLoadingScreen(function()
        window = Window.new(config)
    end)
    repeat task.wait() until window
    return window
end

return AppleGUI
