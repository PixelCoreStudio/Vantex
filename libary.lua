--[[
    Customizable UI Library (Cyberpunk Edition) - Fixed version.
]]

local module = {}

local ts = cloneref(game:GetService("TweenService"))
local cg = cloneref(game:GetService("CoreGui"))
local ui = cloneref(game:GetService("UserInputService"))

-- =========================================================================
-- THEME  -- Single source of truth for the whole design.
-- =========================================================================
module.Theme = {
    -- --- FONT & RADIUS ---
    Font            = Enum.Font.GothamMedium,
    FontBold        = Enum.Font.GothamBold,

    CornerRadius    = UDim.new(0, 8),   -- Soft corners (8px) for all elements
    ElementRadius   = UDim.new(0, 8),   -- Consistency: Use the main radius here

    -- --- COLORS (Cyberpunk Schema) ---
    Background      = Color3.fromRGB(11, 11, 14), -- Obsidian Black (#0B0B0E) - Main panels
    Topbar          = Color3.fromRGB(20, 20, 35), -- Deep Dark Blue/Black for depth
    TabBar          = Color3.fromRGB(26, 26, 46), -- Dark Velvet Blue/Grey (#1A1A2E) - Tab Bar background
    ElementBg       = Color3.fromRGB(26, 26, 46), -- Secondary Background (#1A1A2E) - Buttons / Inputs
    ElementHoverBg  = Color3.fromRGB(35, 35, 60), -- Slightly brighter secondary shade for hover
    
    Text            = Color3.fromRGB(255, 255, 255), -- Pure White (#FFFFFF) - Primary text
    SubText         = Color3.fromRGB(143, 143, 143), -- Ash Grey (#8F8F8F) - Descriptions/Inactive text

    Accent          = Color3.fromRGB(160, 32, 240), -- Neon Purple/Amethyst (#A020F0) - Highlights
    ToggleOn        = Color3.fromRGB(0, 255, 255),  -- Vibrant Cyan for "ON" state (Cyberpunk glow)
    ToggleOff       = Color3.fromRGB(255, 64, 64), -- Soft Red/Pink for "OFF" state

    -- --- LAYOUT CONSTANTS ---
    WindowSize      = UDim2.new(0.37, 0, 0.42, 0),
    WindowPosition  = UDim2.new(0.315, 0, 0.29, 0),

    TopbarHeight    = 40,
    TabBarWidth     = 130,
    ElementHeight   = 36,
}

-- =========================================================================
-- HELPERS (Unchanged)
-- =========================================================================
local function create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    return inst
end

-- =========================================================================
-- WINDOW (Functionality unchanged, visuals updated by theme values)
-- =========================================================================
function module:win(title, themeOverrides)

    local theme = {}
    for k, v in pairs(module.Theme) do theme[k] = v end
    for k, v in pairs(themeOverrides or {}) do theme[k] = v end

    local registry = {}
    local function reg(inst, prop, key)
        inst[prop] = theme[key]
        table.insert(registry, {inst, prop, key})
        return inst
    end

    -- screen gui ------------------------------------------------------------
    local screenGui = create("ScreenGui", {
        Name = "CustomUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    screenGui.Parent = gethui or get_hidden_gui or nil

    -- main frame ----------------------------------------------------------
    local main = create("CanvasGroup", {
        Name = "Frame",
        Parent = screenGui,
        Size = theme.WindowSize,
        Position = theme.WindowPosition,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    })
    reg(main, "BackgroundColor3", "Background")
    create("UICorner", {Parent = main, CornerRadius = theme.CornerRadius})

    -- topbar ------------------------------------------------------------------
    local topbar = create("Frame", {
        Name = "topbar",
        Parent = main,
        Size = UDim2.new(1, 0, 0, theme.TopbarHeight),
        BackgroundTransparency = 0.8,
        BorderSizePixel = 0,
    })
    reg(topbar, "BackgroundColor3", "Topbar")
    create("UICorner", {Parent = topbar, CornerRadius = theme.CornerRadius})

    local titleLbl = create("TextLabel", {
        Name = "title",
        Parent = topbar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -90, 1, 0),
        Text = title,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    reg(titleLbl, "TextColor3", "Text")
    reg(titleLbl, "Font", "FontBold")

    -- topbar buttons (close / minimize)
    local btns = create("Frame", {
        Name = "btns",
        Parent = topbar,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.new(0, 60, 0, 24),
    })
    create("UIListLayout", {
        Parent = btns,
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 6),
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
    })

    local function makeTopbarBtn(symbol)
        local btn = create("TextButton", {
            Parent = btns,
            Size = UDim2.new(0, 24, 0, 24),
            BackgroundTransparency = 1,
            Text = symbol,
            TextSize = 14,
            AutoButtonColor = false,
        })
        reg(btn, "TextColor3", "SubText")
        reg(btn, "Font", "Font")
        reg(btn, "BackgroundColor3", "Topbar")
        create("UICorner", {Parent = btn, CornerRadius = UDim.new(0, 4)})

        btn.MouseEnter:Connect(function()
            ts:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.8}):Play()
        end)
        btn.MouseLeave:Connect(function()
            ts:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
        end)
        return btn
    end

    local minimizeBtn = makeTopbarBtn("–")
    local closeBtn = makeTopbarBtn("✕")

    -- open / minimize -------------------------------------------------------
    local function setOpen(isOpen)
        ts:Create(main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            GroupTransparency = isOpen and 0 or 1,
            Size = isOpen and theme.WindowSize
                or UDim2.new(theme.WindowSize.X.Scale, theme.WindowSize.X.Offset, 0, theme.TopbarHeight),
        }):Play()
        main.Interactable = isOpen
    end

    minimizeBtn.MouseButton1Click:Connect(function()
        setOpen(false)
    end)

    local toggleKeyConn = ui.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.K then
            setOpen(not main.Interactable)
        end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        toggleKeyConn:Disconnect()
        screenGui:Destroy()
    end)

    -- dragging via topbar -----------------------------------------------------
    local dragConnection = nil -- Variable to hold the connection for clean disconnection

    do
        local isDragging = false
        local inputStartMousePos = Vector2.new(0, 0)
        local frameInitialPosition = main.Position

        -- Handle InputBegan on Topbar (Start Dragging)
        local function onInputBegan(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = true
                inputStartMousePos = input.Position
            end
        end

        -- Handle InputChanged (Continuous Movement/Drag)
        local function onInputChanged(input)
             if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - inputStartMousePos
                main.Position = UDim2.new(
                    frameInitialPosition.X.Scale, frameInitialPosition.X.Offset + delta.X,
                    frameInitialPosition.Y.Scale, frameInitialPosition.Y.Offset + delta.Y
                )
            end
        end

        -- Handle InputEnded (Stop Dragging)
        local function onInputEnded(input)
             if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                 isDragging = false
            end
        end

        topbar.InputBegan:Connect(onInputBegan)
        topbar.InputChanged:Connect(function(input)
            if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                onInputChanged(input)
            end
        end)
        -- Listen to the global Input service for ending drag, which is more reliable than only listening to the topbar
        dragConnection = ui.InputEnded:Connect(function(input)
             if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = false
            end
        end)

    end -- End of do block

    -- body: tab bar (left) + section container (right) ----------------------
    local body = create("Frame", {
        Name = "body",
        Parent = main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, theme.TopbarHeight),
        Size = UDim2.new(1, 0, 1, -theme.TopbarHeight),
    })

    local tabBar = create("ScrollingFrame", {
        Name = "tabbar",
        Parent = body,
        BorderSizePixel = 0,
        Size = UDim2.new(0, theme.TabBarWidth, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3,
    })
    reg(tabBar, "BackgroundColor3", "TabBar")
    reg(tabBar, "ScrollBarImageColor3", "Accent")
    create("UIListLayout", {Parent = tabBar, Padding = UDim.new(0, 4)})
    create("UIPadding", {
        Parent = tabBar,
        PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
    })

    local sectionsHolder = create("Frame", {
        Name = "sectionsholder",
        Parent = body,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, theme.TabBarWidth, 0, 0),
        Size = UDim2.new(1, -theme.TabBarWidth, 1, 0),
        ClipsDescendants = true,
    })

    -- =====================================================================
    -- TABS / SECTIONS
    -- =====================================================================
    local sections = {}
    local curBtn, curSection = nil, nil

    local function setSelectedTab(btn, section)
        if curBtn == btn then return end
        if curBtn then
            ts:Create(curBtn, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
            ts:Create(curBtn.indicator, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
            curSection.Visible = false
        end
        ts:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.85}):Play()
        ts:Create(btn.indicator, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
        section.Visible = true
        curBtn, curSection = btn, section
    end

    function sections:tab(title, icon)
        local btn = create("TextButton", {
            Parent = tabBar,
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundTransparency = 1,
            AutoButtonColor = false,
            Text = "",
        })
        reg(btn, "BackgroundColor3", "ElementBg")
        create("UICorner", {Parent = btn, CornerRadius = theme.ElementRadius})

        local indicator = create("Frame", {
            Name = "indicator",
            Parent = btn,
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.new(0, 3, 0.6, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
        })
        reg(indicator, "BackgroundColor3", "Accent")
        create("UICorner", {Parent = indicator, CornerRadius = UDim.new(1, 0)})

        local label = create("TextLabel", {
            Parent = btn,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, (icon and icon ~= "") and 36 or 12, 0, 0),
            Size = UDim2.new(1, (icon and icon ~= "") and -44 or -20, 1, 0),
            Text = title,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        reg(label, "TextColor3", "Text")
        reg(label, "Font", "Font")

        if icon and icon ~= "" then
            local iconLbl = create("ImageLabel", {
                Parent = btn,
                BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 8, 0.5, 0),
                Size = UDim2.new(0, 18, 0, 18),
                Image = icon,
            })
            reg(iconLbl, "ImageColor3", "SubText")
        end

        btn.MouseEnter:Connect(function()
            if curBtn ~= btn then
                ts:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.92}):Play()
            end
        end)
        btn.MouseLeave:Connect(function()
            if curBtn ~= btn then
                ts:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            end
        end)

        -- section content -----------------------------------------------------
        local section = create("ScrollingFrame", {
            Name = title,
            Parent = sectionsHolder,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 3,
            Visible = false,
        })
        reg(section, "ScrollBarImageColor3", "Accent")
        create("UIListLayout", {Parent = section, Padding = UDim.new(0, 6)})
        create("UIPadding", {
            Parent = section,
            PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
        })

        btn.MouseButton1Click:Connect(function()
            setSelectedTab(btn, section)
        end)

        if not curBtn then
            setSelectedTab(btn, section)
        end

        -- =================================================================
        -- ELEMENTS (No functional changes, only theme updates applied)
        -- =================================================================

        local contents = {}

        function contents:label(text)
            local lbl = create("TextLabel", {
                Parent = section,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 20),
                Text = text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
            })
            reg(lbl, "TextColor3", "SubText")
            reg(lbl, "Font", "Font")
            return lbl
        end

        function contents:button(text, cb)
            local btnEl = create("TextButton", {
                Parent = section,
                Size = UDim2.new(1, 0, 0, theme.ElementHeight),
                BackgroundTransparency = 0.9,
                AutoButtonColor = false,
                Text = text,
                TextSize = 13,
            })
            reg(btnEl, "BackgroundColor3", "ElementBg")
            reg(btnEl, "TextColor3", "Text")
            reg(btnEl, "Font", "Font")
            create("UICorner", {Parent = btnEl, CornerRadius = theme.ElementRadius})

            btnEl.MouseEnter:Connect(function()
                ts:Create(btnEl, TweenInfo.new(0.2), {BackgroundTransparency = 0.7}):Play()
            end)
            btnEl.MouseLeave:Connect(function()
                ts:Create(btnEl, TweenInfo.new(0.2), {BackgroundTransparency = 0.9}):Play()
            end)
            btnEl.MouseButton1Click:Connect(cb)
            return btnEl
        end

        function contents:toggle(text, default, cb)
            local toggled = default and true or false

            local holder = create("TextButton", {
                Parent = section,
                Size = UDim2.new(1, 0, 0, theme.ElementHeight),
                BackgroundTransparency = 0.9,
                AutoButtonColor = false,
                Text = "",
            })
            reg(holder, "BackgroundColor3", "ElementBg")
            create("UICorner", {Parent = holder, CornerRadius = theme.ElementRadius})

            local lbl = create("TextLabel", {
                Parent = holder,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 0),
                Size = UDim2.new(1, -60, 1, 0),
                Text = text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            reg(lbl, "TextColor3", "Text")
            reg(lbl, "Font", "Font")

            local track = create("Frame", {
                Parent = holder,
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -12, 0.5, 0),
                Size = UDim2.new(0, 38, 0, 20),
                BorderSizePixel = 0,
            })
            create("UICorner", {Parent = track, CornerRadius = UDim.new(1, 0)})

            local knob = create("Frame", {
                Parent = track,
                AnchorPoint = toggled and Vector2.new(1, 0.5) or Vector2.new(0, 0.5),
                Position = toggled and UDim2.new(1, -2, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
                Size = UDim2.new(0, 16, 0, 16),
                BackgroundColor3 = Color3.new(1, 1, 1),
                BorderSizePixel = 0,
            })
            create("UICorner", {Parent = knob, CornerRadius = UDim.new(1, 0)})

            local function applyVisual(animated)
                local goalColor = toggled and theme.ToggleOn or theme.ToggleOff
                local goalPos = toggled and UDim2.new(1, -2, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
                local goalAnchor = toggled and Vector2.new(1, 0.5) or Vector2.new(0, 0.5)
                if animated then
                    ts:Create(track, TweenInfo.new(0.2), {BackgroundColor3 = goalColor}):Play()
                    ts:Create(knob, TweenInfo.new(0.2), {Position = goalPos}):Play()
                else
                    track.BackgroundColor3 = goalColor
                    knob.Position = goalPos
                end
                knob.AnchorPoint = goalAnchor
            end
            applyVisual(false)

            holder.MouseEnter:Connect(function()
                ts:Create(holder, TweenInfo.new(0.2), {BackgroundTransparency = 0.7}):Play()
            end)
            holder.MouseLeave:Connect(function()
                ts:Create(holder, TweenInfo.new(0.2), {BackgroundTransparency = 0.9}):Play()
            end)

            holder.MouseButton1Click:Connect(function()
                toggled = not toggled
                applyVisual(true)
                cb(toggled)
            end)

            if toggled then
                task.defer(cb, toggled)
            end

            return holder
        end

        function contents:textbox(text, default, cb)
            local holder = create("Frame", {
                Parent = section,
                Size = UDim2.new(1, 0, 0, theme.ElementHeight),
                BackgroundTransparency = 0.9,
            })
            reg(holder, "BackgroundColor3", "ElementBg")
            create("UICorner", {Parent = holder, CornerRadius = theme.ElementRadius})

            local lbl = create("TextLabel", {
                Parent = holder,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 0),
                Size = UDim2.new(0.5, -12, 1, 0),
                Text = text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            reg(lbl, "TextColor3", "Text")
            reg(lbl, "Font", "Font")

            local inputBg = create("Frame", {
                Parent = holder,
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -8, 0.5, 0),
                Size = UDim2.new(0.45, 0, 0, 24),
            })
            reg(inputBg, "BackgroundColor3", "ElementHoverBg")
            create("UICorner", {Parent = inputBg, CornerRadius = UDim.new(0, 4)})

            local input = create("TextBox", {
                Parent = inputBg,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -10, 1, 0),
                Position = UDim2.new(0, 5, 0, 0),
                Text = default or "",
                PlaceholderText = "...",
                TextSize = 13,
                ClearTextOnFocus = false,
            })
            reg(input, "TextColor3", "Text")
            reg(input, "Font", "Font")

            if default and default ~= "" then
                task.defer(cb, default)
            end

            input.FocusLost:Connect(function(enterPressed)
                if enterPressed then
                    cb(input.Text)
                end
            end)

            return holder
        end

        function contents:slider(text, min, max, default, cb)
            local holder = create("Frame", {
                Parent = section,
                Size = UDim2.new(1, 0, 0, theme.ElementHeight + 14),
                BackgroundTransparency = 0.9,
            })
            reg(holder, "BackgroundColor3", "ElementBg")
            create("UICorner", {Parent = holder, CornerRadius = theme.ElementRadius})

            local lbl = create("TextLabel", {
                Parent = holder,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 4),
                Size = UDim2.new(1, -24, 0, 18),
                Text = text .. " : " .. tostring(default),
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            reg(lbl, "TextColor3", "Text")
            reg(lbl, "Font", "Font")

            local track = create("Frame", {
                Parent = holder,
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.new(0.5, 0, 0, 28),
                Size = UDim2.new(1, -24, 0, 6),
                BorderSizePixel = 0,
            })
            reg(track, "BackgroundColor3", "ElementHoverBg")
            create("UICorner", {Parent = track, CornerRadius = UDim.new(1, 0)})

            local fill = create("Frame", {
                Parent = track,
                Size = UDim2.new(0, 0, 1, 0),
                BorderSizePixel = 0,
            })
            reg(fill, "BackgroundColor3", "Accent")
            create("UICorner", {Parent = fill, CornerRadius = UDim.new(1, 0)})

            local dragging = false
            local lastVal = default

            local function setFromAlpha(alpha)
                alpha = math.clamp(alpha, 0, 1)
                local value = math.floor(min + (max - min) * alpha + 0.5)
                fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                lastVal = value
                lbl.Text = text .. " : " .. tostring(value)
            end

            local function updateFromInput(x)
                local rel = (x - track.AbsolutePosition.X) / track.AbsoluteSize.X
                setFromAlpha(rel)
            end

            setFromAlpha((default - min) / (max - min))

            track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    updateFromInput(input.Position.X)
                end
            end)

            ui.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateFromInput(input.Position.X)
                end
            end)

            ui.InputEnded:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                    dragging = false
                    if cb then
                        pcall(cb, lastVal)
                    end
                end
            end)

            return holder
        end

        return contents
    end

    -- live re-theming: change colors/fonts/sizes after the UI was built ----
    function sections:SetTheme(overrides)
        for k, v in pairs(overrides) do
            theme[k] = v
        end
        for _, entry in ipairs(registry) do
            local inst, prop, key = entry[1], entry[2], entry[3]
            if inst and inst.Parent then
                inst[prop] = theme[key]
            end
        end
    end

    function sections:GetTheme()
        return theme
    end

    return sections
end

return module
