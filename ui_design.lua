-- UI Design for Ecynx Cheat
-- Modern UI with round edges, bubbles, and black to red gradient
-- Created by saneishere

local Library = {}

-- Color palette for black to red gradient
Library.Colors = {
    Background = Color3.fromRGB(15, 15, 15),
    BackgroundDark = Color3.fromRGB(10, 10, 10),
    BackgroundLight = Color3.fromRGB(25, 25, 25),
    Primary = Color3.fromRGB(225, 25, 25),
    PrimaryDark = Color3.fromRGB(175, 15, 15),
    PrimaryLight = Color3.fromRGB(255, 50, 50),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(175, 175, 175),
    Border = Color3.fromRGB(30, 30, 30),
    BorderLight = Color3.fromRGB(50, 50, 50),
    Accent = Color3.fromRGB(255, 75, 75)
}

-- UI Settings
Library.Settings = {
    CornerRadius = UDim.new(0, 8),
    LargeCornerRadius = UDim.new(0, 12),
    SmallCornerRadius = UDim.new(0, 4),
    Padding = UDim.new(0, 10),
    SmallPadding = UDim.new(0, 5),
    LargePadding = UDim.new(0, 15),
    TitleSize = UDim2.new(1, 0, 0, 30),
    TabSize = UDim2.new(1, 0, 0, 35),
    ElementHeight = 35,
    ToggleSize = UDim2.new(0, 20, 0, 20),
    SliderHeight = 10,
    WindowSize = UDim2.new(0, 500, 0, 350),
    MinWindowSize = UDim2.new(0, 400, 0, 300),
    MaxWindowSize = UDim2.new(0, 800, 0, 600),
    Font = Enum.Font.GothamSemibold,
    TextSize = 14,
    SmallTextSize = 12,
    LargeTextSize = 18
}

-- Create gradient effect
function Library:CreateGradient(parent, rotation, colorSequence)
    local gradient = Instance.new("UIGradient")
    gradient.Rotation = rotation or 90
    gradient.Color = colorSequence or ColorSequence.new({
        ColorSequenceKeypoint.new(0, self.Colors.PrimaryDark),
        ColorSequenceKeypoint.new(1, self.Colors.Primary)
    })
    gradient.Parent = parent
    return gradient
end

-- Create rounded corners
function Library:CreateCorners(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or self.Settings.CornerRadius
    corner.Parent = parent
    return corner
end

-- Create a bubble effect
function Library:CreateBubble(parent, position, size, color)
    local bubble = Instance.new("Frame")
    bubble.BackgroundColor3 = color or self.Colors.Primary
    bubble.BackgroundTransparency = 0.7
    bubble.Position = position
    bubble.Size = size
    bubble.BorderSizePixel = 0
    
    self:CreateCorners(bubble, UDim.new(1, 0))
    
    local gradient = self:CreateGradient(bubble, 90, ColorSequence.new({
        ColorSequenceKeypoint.new(0, self.Colors.PrimaryLight),
        ColorSequenceKeypoint.new(1, self.Colors.Primary)
    }))
    
    bubble.Parent = parent
    return bubble
end

-- Create main window
function Library:CreateWindow(title)
    -- Create ScreenGui
    local ecynxGui = Instance.new("ScreenGui")
    ecynxGui.Name = "EcynxCheat"
    ecynxGui.ResetOnSpawn = false
    ecynxGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Create main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.BackgroundColor3 = self.Colors.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.Position = UDim2.new(0.5, -self.Settings.WindowSize.X.Offset / 2, 0.5, -self.Settings.WindowSize.Y.Offset / 2)
    mainFrame.Size = self.Settings.WindowSize
    mainFrame.Active = true
    mainFrame.Draggable = true
    
    -- Add rounded corners
    self:CreateCorners(mainFrame, self.Settings.LargeCornerRadius)
    
    -- Create title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.BackgroundColor3 = self.Colors.BackgroundDark
    titleBar.BorderSizePixel = 0
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.Parent = mainFrame
    
    -- Add rounded corners to title bar (top only)
    local titleCorner = self:CreateCorners(titleBar, self.Settings.LargeCornerRadius)
    
    -- Create title text
    local titleText = Instance.new("TextLabel")
    titleText.Name = "Title"
    titleText.BackgroundTransparency = 1
    titleText.Position = UDim2.new(0, 15, 0, 0)
    titleText.Size = UDim2.new(1, -30, 1, 0)
    titleText.Font = self.Settings.Font
    titleText.Text = title or "Ecynx | Beta"
    titleText.TextColor3 = self.Colors.Text
    titleText.TextSize = self.Settings.LargeTextSize
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    -- Create decorative bubbles
    self:CreateBubble(mainFrame, UDim2.new(0.9, 0, 0.1, 0), UDim2.new(0, 30, 0, 30), self.Colors.Primary)
    self:CreateBubble(mainFrame, UDim2.new(0.1, 0, 0.85, 0), UDim2.new(0, 20, 0, 20), self.Colors.PrimaryDark)
    self:CreateBubble(mainFrame, UDim2.new(0.8, 0, 0.7, 0), UDim2.new(0, 15, 0, 15), self.Colors.PrimaryLight)
    
    -- Create content frame
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.BackgroundTransparency = 1
    contentFrame.Position = UDim2.new(0, 0, 0, 40)
    contentFrame.Size = UDim2.new(1, 0, 1, -40)
    contentFrame.Parent = mainFrame
    
    -- Create tabs frame
    local tabsFrame = Instance.new("Frame")
    tabsFrame.Name = "TabsFrame"
    tabsFrame.BackgroundColor3 = self.Colors.BackgroundLight
    tabsFrame.BorderSizePixel = 0
    tabsFrame.Position = UDim2.new(0, 10, 0, 10)
    tabsFrame.Size = UDim2.new(0, 120, 1, -20)
    tabsFrame.Parent = contentFrame
    
    -- Add rounded corners to tabs frame
    self:CreateCorners(tabsFrame, self.Settings.CornerRadius)
    
    -- Create tab content frame
    local tabContentFrame = Instance.new("Frame")
    tabContentFrame.Name = "TabContentFrame"
    tabContentFrame.BackgroundColor3 = self.Colors.BackgroundLight
    tabContentFrame.BorderSizePixel = 0
    tabContentFrame.Position = UDim2.new(0, 140, 0, 10)
    tabContentFrame.Size = UDim2.new(1, -150, 1, -20)
    tabContentFrame.Parent = contentFrame
    
    -- Add rounded corners to tab content frame
    self:CreateCorners(tabContentFrame, self.Settings.CornerRadius)
    
    -- Create gradient effect on main frame
    local mainGradient = self:CreateGradient(mainFrame, 135, ColorSequence.new({
        ColorSequenceKeypoint.new(0, self.Colors.Background),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 10, 10))
    }))
    
    -- Create window object
    local window = {
        Gui = ecynxGui,
        MainFrame = mainFrame,
        TabsFrame = tabsFrame,
        TabContentFrame = tabContentFrame,
        Tabs = {},
        ActiveTab = nil
    }
    
    -- Create tabs list
    local tabsList = Instance.new("ScrollingFrame")
    tabsList.Name = "TabsList"
    tabsList.BackgroundTransparency = 1
    tabsList.BorderSizePixel = 0
    tabsList.Position = UDim2.new(0, 0, 0, 10)
    tabsList.Size = UDim2.new(1, 0, 1, -10)
    tabsList.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabsList.ScrollBarThickness = 2
    tabsList.ScrollBarImageColor3 = self.Colors.Primary
    tabsList.Parent = tabsFrame
    
    -- Create UIListLayout for tabs
    local tabsListLayout = Instance.new("UIListLayout")
    tabsListLayout.Padding = UDim.new(0, 5)
    tabsListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabsListLayout.Parent = tabsList
    
    -- Function to create a new tab
    function window:AddTab(name, icon)
        -- Create tab button
        local tabButton = Instance.new("TextButton")
        tabButton.Name = name .. "Tab"
        tabButton.BackgroundColor3 = Library.Colors.BackgroundDark
        tabButton.BorderSizePixel = 0
        tabButton.Size = UDim2.new(1, -10, 0, 35)
        tabButton.Font = Library.Settings.Font
        tabButton.Text = name
        tabButton.TextColor3 = Library.Colors.TextDark
        tabButton.TextSize = Library.Settings.TextSize
        tabButton.Parent = tabsList
        
        -- Add rounded corners to tab button
        Library:CreateCorners(tabButton, Library.Settings.SmallCornerRadius)
        
        -- Create tab content
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Name = name .. "Content"
        tabContent.BackgroundTransparency = 1
        tabContent.BorderSizePixel = 0
        tabContent.Position = UDim2.new(0, 10, 0, 10)
        tabContent.Size = UDim2.new(1, -20, 1, -20)
        tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabContent.ScrollBarThickness = 3
        tabContent.ScrollBarImageColor3 = Library.Colors.Primary
        tabContent.Visible = false
        tabContent.Parent = self.TabContentFrame
        
        -- Create UIListLayout for tab content
        local contentLayout = Instance.new("UIListLayout")
        contentLayout.Padding = UDim.new(0, 8)
        contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        contentLayout.Parent = tabContent
        
        -- Create UIPadding for tab content
        local contentPadding = Instance.new("UIPadding")
        contentPadding.PaddingTop = UDim.new(0, 5)
        contentPadding.PaddingBottom = UDim.new(0, 5)
        contentPadding.Parent = tabContent
        
        -- Create tab object
        local tab = {
            Button = tabButton,
            Content = tabContent,
            Elements = {}
        }
        
        -- Tab button click event
        tabButton.MouseButton1Click:Connect(function()
            -- Deactivate all tabs
            for _, t in pairs(self.Tabs) do
                t.Button.BackgroundColor3 = Library.Colors.BackgroundDark
                t.Button.TextColor3 = Library.Colors.TextDark
                t.Content.Visible = false
            end
            
            -- Activate this tab
            tabButton.BackgroundColor3 = Library.Colors.Primary
            tabButton.TextColor3 = Library.Colors.Text
            tabContent.Visible = true
            self.ActiveTab = tab
        end)
        
        -- Add tab to tabs table
        table.insert(self.Tabs, tab)
        
        -- Update canvas size
        tabsList.CanvasSize = UDim2.new(0, 0, 0, tabsListLayout.AbsoluteContentSize.Y + 10)
        
        -- If this is the first tab, activate it
        if #self.Tabs == 1 then
            tabButton.BackgroundColor3 = Library.Colors.Primary
            tabButton.TextColor3 = Library.Colors.Text
            tabContent.Visible = true
            self.ActiveTab = tab
        end
        
        -- Function to add a toggle
        function tab:AddToggle(name, default, callback)
            -- Create toggle frame
            local toggleFrame = Instance.new("Frame")
            toggleFrame.Name = name .. "Toggle"
            toggleFrame.BackgroundColor3 = Library.Colors.BackgroundDark
            toggleFrame.BorderSizePixel = 0
            toggleFrame.Size = UDim2.new(1, -10, 0, 40)
            toggleFrame.Parent = tabContent
            
            -- Add rounded corners to toggle frame
            Library:CreateCorners(toggleFrame, Library.Settings.SmallCornerRadius)
            
            -- Create toggle text
            local toggleText = Instance.new("TextLabel")
            toggleText.Name = "Text"
            toggleText.BackgroundTransparency = 1
            toggleText.Position = UDim2.new(0, 10, 0, 0)
            toggleText.Size = UDim2.new(1, -60, 1, 0)
            toggleText.Font = Library.Settings.Font
            toggleText.Text = name
            toggleText.TextColor3 = Library.Colors.Text
            toggleText.TextSize = Library.Settings.TextSize
            toggleText.TextXAlignment = Enum.TextXAlignment.Left
            toggleText.Parent = toggleFrame
            
            -- Create toggle button
            local toggleButton = Instance.new("Frame")
            toggleButton.Name = "Button"
            toggleButton.BackgroundColor3 = default and Library.Colors.Primary or Library.Colors.BackgroundLight
            toggleButton.BorderSizePixel = 0
            toggleButton.Position = UDim2.new(1, -50, 0.5, -10)
            toggleButton.Size = UDim2.new(0, 40, 0, 20)
            toggleButton.Parent = toggleFrame
            
            -- Add rounded corners to toggle button
            Library:CreateCorners(toggleButton, UDim.new(0, 10))
            
            -- Create toggle indicator
            local toggleIndicator = Instance.new("Frame")
            toggleIndicator.Name = "Indicator"
            toggleIndicator.BackgroundColor3 = Library.Colors.Text
            toggleIndicator.BorderSizePixel = 0
            toggleIndicator.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            toggleIndicator.Size = UDim2.new(0, 16, 0, 16)
            toggleIndicator.Parent = toggleButton
            
            -- Add rounded corners to toggle indicator
            Library:CreateCorners(toggleIndicator, UDim.new(1, 0))
            
            -- Create toggle object
            local toggle = {
                Frame = toggleFrame,
                Button = toggleButton,
                Indicator = toggleIndicator,
                Value = default or false
            }
            
            -- Make toggle clickable
            toggleFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    toggle.Value = not toggle.Value
                    toggleButton.BackgroundColor3 = toggle.Value and Library.Colors.Primary or Library.Colors.BackgroundLight
                    toggleIndicator:TweenPosition(
                        toggle.Value and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                        Enum.EasingDirection.InOut,
                        Enum.EasingStyle.Quad,
                        0.15,
                        true
                    )
                    if callback then
                        callback(toggle.Value)
                    end
                end
            end)
            
            -- Add toggle to elements table
            table.insert(self.Elements, toggle)
            
            -- Update canvas size
            tabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 10)
            
            return toggle
        end
        
        -- Function to add a slider
        function tab:AddSlider(name, min, max, default, callback)
            -- Create slider frame
            local sliderFrame = Instance.new("Frame")
            sliderFrame.Name = name .. "Slider"
            sliderFrame.BackgroundColor3 = Library.Colors.BackgroundDark
            sliderFrame.BorderSizePixel = 0
            sliderFrame.Size = UDim2.new(1, -10, 0, 60)
            sliderFrame.Parent = tabContent
            
            -- Add rounded corners to slider frame
            Library:CreateCorners(sliderFrame, Library.Settings.SmallCornerRadius)
            
            -- Create slider text
            local sliderText = Instance.new("TextLabel")
            sliderText.Name = "Text"
            sliderText.BackgroundTransparency = 1
            sliderText.Position = UDim2.new(0, 10, 0, 5)
            sliderText.Size = UDim2.new(1, -20, 0, 20)
            sliderText.Font = Library.Settings.Font
            sliderText.Text = name
            sliderText.TextColor3 = Library.Colors.Text
            sliderText.TextSize = Library.Settings.TextSize
            sliderText.TextXAlignment = Enum.TextXAlignment.Left
            sliderText.Parent = sliderFrame
            
            -- Create value text
            local valueText = Instance.new("TextLabel")
            valueText.Name = "Value"
            valueText.BackgroundTransparency = 1
            valueText.Position = UDim2.new(1, -50, 0, 5)
            valueText.Size = UDim2.new(0, 40, 0, 20)
            valueText.Font = Library.Settings.Font
            valueText.Text = tostring(default)
            valueText.TextColor3 = Library.Colors.Text
            valueText.TextSize = Library.Settings.TextSize
            valueText.TextXAlignment = Enum.TextXAlignment.Right
            valueText.Parent = sliderFrame
            
            -- Create slider background
 <response clipped><NOTE>To save on context only part of this file has been shown to you. You should retry this tool after you have searched inside the file with `grep -n` in order to find the line numbers of what you are looking for.</NOTE>
