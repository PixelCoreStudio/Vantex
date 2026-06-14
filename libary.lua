--[[
    FINAL CYBER UI STYLIZED LIBRARY (FOR EXECUTOR LOADER)
    This script contains the complete module logic AND the necessary startup wrappers 
    to maximize compatibility with external loading environments.
]]

local CyberUI = {} -- Use a clean table to hold the module reference

local ts = nil
local cg = nil
local ui_service = nil

-- Initialize Services (Attempting robust service fetching)
if game then
    ts = game:GetService("TweenService")
    cg = game:GetService("CoreGui")
    ui_service = game:GetService("UserInputService")
end

-- Style Constants Definition (Ensures the style is always loaded first)
local C = {
    ObsidianBlack = Color3.fromRGB(11, 11, 14),
    VelvetGray = Color3.fromRGB(26, 26, 46),
    AccentNeon = Color3.fromRGB(160, 32, 240),
    WhitePrimary = Color3.new(1, 1, 1),
    GraySecondary = Color3.fromRGB(143, 143, 143)
}

local CORNER_RADIUS = UDim2.new(0, 8) 
local TRANSITION_TIME = 0.3 
local HOVER_DURATION = 0.25

-- Helper function (Copied and applied everywhere for consistency)
local function applyCyberStyle(instance, bgColor)
    if instance:IsA("Frame") or instance:IsA("TextLabel") then
        local corner = Instance.new("UICorner")
        corner.CornerRadius = CORNER_RADIUS
        corner.Parent = instance

        instance.BackgroundColor3 = bgColor
        -- Use a slightly higher transparency for the dark glass look
        instance.BackgroundTransparency = 0.15 
    end
end


--- CORE UI FUNCTIONS (Module:win) ---
function CyberUI:win(title)
    local window = game:GetObjects("rbxassetid://96576283085736")[1]
    local elements = game:GetObjects("rbxassetid://83539751566719")[1]

    -- Safety check for core services before proceeding
    if not window or not elements or not ts or not cg or not ui_service then
        warn("[CyberUI ERROR] Failed to find necessary assets or core services. Cannot initialize.")
        return 
    end

    applyCyberStyle(window, C.ObsidianBlack)
    
    local hui = gethui or get_hidden_gui or nil
    if hui then
        window.Parent = hui()
        applyCyberStyle(window, C.ObsidianBlack)
    else
        window.Parent = cg
        applyCyberStyle(window, C.ObsidianBlack)
    end

    local topbar = window.Frame.topbar
    topbar.title.Text = title
    if topbar.title and topbar.title:IsA("TextLabel") then
        topbar.title.TextColor3 = C.WhitePrimary
    end

    local closeBtn = topbar.btns.Close
    local miniBtn = topbar.btns.Minimize

    applyCyberStyle(closeBtn, C.ObsidianBlack) 
    applyCyberStyle(miniBtn, C.ObsidianBlack)


    local toggleCon = nil

    local function fadebtn(btn, isIn)
        ts:Create(
            btn,
            TweenInfo.new(HOVER_DURATION),
            {
                BackgroundTransparency = isIn and 0.2 or 1
            }
        ):Play()
    end

    local function togglewin(isIn)
        ts:Create(
            window.Frame,
            TweenInfo.new(TRANSITION_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {
                GroupTransparency = isIn and 0 or 1
            }
        ):Play()
        ts:Create(
            window.Frame,
            TweenInfo.new(TRANSITION_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {
                Size = isIn and UDim2.new(0.37, 0, 0.407, 0) or UDim2.new(0.37, 0, 0.376, 0)
            }
        ):Play()

        window.Frame.Interactable = isIn and true or false
    end

    local function fadetopbar(isIn)
        ts:Create(
            topbar,
            TweenInfo.new(HOVER_DURATION),
            {
                BackgroundTransparency = isIn and 0.2 or 0.8
            }
        ):Play()
    end

    closeBtn.MouseEnter:Connect(function() fadebtn(closeBtn, true) end)
    miniBtn.MouseEnter:Connect(function() fadebtn(miniBtn, true) end)
    closeBtn.MouseLeave:Connect(function() fadebtn(closeBtn, false) end)
    miniBtn.MouseLeave:Connect(function() fadebtn(miniBtn, false) end)

    topbar.MouseEnter:Connect(function() fadetopbar(true) end)
    topbar.MouseLeave:Connect(function() fadetopbar(false) end)

    closeBtn.MouseButton1Click:Connect(function()
        window:Destroy()
        elements:Destroy()
        toggleCon:Disconnect()
    end)

    miniBtn.MouseButton1Click:Connect(function()
        togglewin(false)
    end)

    toggleCon = ui_service.InputBegan:Connect(function(keyc, gamep)
        if not gamep and keyc.KeyCode == Enum.KeyCode.K then
            togglewin(not window.Frame.Interactable)
        end
    end)

    -- [ DRAGGING LOGIC UNCHANGED ] 
    local sections = {}
    local curSelected = nil
    local dragging = false
    local dragInput, mousePos, framePos

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = window.Frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    ui_service.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            window.Frame.Position = UDim2.new(
                framePos.X.Scale,
                framePos.X.Offset + delta.X,
                framePos.Y.Scale,
                framePos.Y.Offset + delta.Y
            )
        end
    end)

    -- [ TABS AND SECTIONS LOGIC (Styled) ] 
    local function toggletab(tab, isIn)
        ts:Create(
            tab,
            TweenInfo.new(TRANSITION_TIME),
            {
                GroupTransparency = isIn and 0 or 1
            }
        ):Play()
        ts:Create(
            tab,
            TweenInfo.new(TRANSITION_TIME),
            {
                Position = isIn and UDim2.new(0.5, 0, 1, 0) or UDim2.new(0.5, 0, 1.1, 0)
            }
        ):Play()
        tab.Interactable = isIn and true or false
    end

    local function fadeelement(which, isIn)
        ts:Create(
            which,
            TweenInfo.new(HOVER_DURATION),
            {
                BackgroundTransparency = isIn and 0.2 or 0.3 -- The glow effect
            }
        ):Play()
    end

    function sections:tab(title, ico)
        local newBtn = elements.tabelement:Clone()
        applyCyberStyle(newBtn, C.ObsidianBlack) -- Styled background
        newBtn.Name = title

        newBtn.Image = ico
        newBtn.title.Text = title

        newBtn.Parent = window.Frame.tabscontainer

        local newSect = elements.sectioncanvas:Clone()
        applyCyberStyle(newSect, C.ObsidianBlack) -- Styled background
        newSect.Parent = window.Frame.sectionsholder
        newSect.GroupTransparency = 1
        newSect.Position = UDim2.new(0.5, 0, 1.1, 0)
        newSect.Interactable = false

        local function fadetab(isIn)
            ts:Create(
                newBtn,
                TweenInfo.new(HOVER_DURATION),
                {ImageTransparency = isIn and 0.25 or 0.5}
            ):Play()
            ts:Create(
                newBtn.title,
                TweenInfo.new(HOVER_DURATION),
                {TextColor3 = isIn and C.AccentNeon or C.WhitePrimary} -- Color change on hover
            ):Play()
        end

        newBtn.MouseEnter:Connect(function() fadetab(true) end)
        newBtn.MouseLeave:Connect(function() fadetab(false) end)

        newBtn.MouseButton1Click:Connect(function()
            if curSelected == newSect then return end
            if curSelected ~= nil then
                toggletab(curSelected, false)
            end

            toggletab(newSect, true)
            curSelected = newSect
        end)

        local contents = {}

        function contents:label(title)
            local newLabel = elements.LabelElement:Clone()
            applyCyberStyle(newLabel, C.ObsidianBlack) 
            if newLabel:FindFirstChild("lbl") then
                 local lblObj = newLabel.lbl
                 lblObj.TextColor3 = C.WhitePrimary -- Force white text color
             end
            newLabel.lbl.Text = title
            newLabel.Parent = newSect.sectioncontainer
        end

        function contents:button(title, cb)
            local newButton = elements.ButtonElement:Clone()
            applyCyberStyle(newButton, C.ObsidianBlack) 

            local btnObj = newButton.btn 
            applyCyberStyle(btnObj, C.VelvetGray) -- Contrast background
            
            if btnObj:FindFirstChild("lbl") then
                local lblObj = btnObj.lbl
                 lblObj.TextColor3 = C.WhitePrimary
            end

            newButton.btn.lbl.Text = title
            newButton.Parent = newSect.sectioncontainer

            btnObj.MouseEnter:Connect(function() fadeelement(btnObj, true) end)
            btnObj.MouseLeave:Connect(function() fadeelement(btnObj, false) end)
            newButton.btn.MouseButton1Click:Connect(cb)
        end

        function contents:toggle(title, default, cb)
            local toggled = default

            local newToggle = elements.ToggleElement:Clone()
            applyCyberStyle(newToggle, C.ObsidianBlack) 

            local btnObj = newToggle.btn 
            applyCyberStyle(btnObj, C.VelvetGray) 

            if btnObj:FindFirstChild("lbl") then
                local lblObj = btnObj.lbl
                 lblObj.TextColor3 = C.WhitePrimary
            end

            newToggle.btn.lbl.Text = title
            newToggle.Parent = newSect.sectioncontainer

            local togglebg = newToggle.btn.togglebg
            local sidetog = togglebg.Frame
            applyCyberStyle(sidetog, C.AccentNeon) -- Neon Accent

            if toggled then
                togglebg.BackgroundColor3 = C.AccentNeon
                sidetog.AnchorPoint = Vector2.new(1, 0.5)
                sidetog.Position = UDim2.new(1, 0, 0.5, 0)
                task.defer(cb, toggled)
            end

            newToggle.btn.MouseButton1Click:Connect(function()
                toggled = not toggled

                local targetAnchorPoint = Vector2.new(1, 0.5)
                local initialTargetAnchorPoint = Vector2.new(0, 0.5)
                local targetPosition = UDim2.new(1, 0, 0.5, 0)
                local initialPosition = UDim2.new(0, 0, 0.5, 0)

                if toggled then
                    togglebg.BackgroundColor3 = C.AccentNeon
                    sidetog.AnchorPoint = targetAnchorPoint
                    sidetog.Position = targetPosition
                else
                    togglebg.BackgroundColor3 = Color3.fromRGB(74, 255, 89):Lerp(C.ObsidianBlack, 0.5)
                    sidetog.AnchorPoint = initialTargetAnchorPoint
                    sidetog.Position = initialPosition
                end

                ts:Create(
                    sidetog,
                    TweenInfo.new(HOVER_DURATION),
                    {
                        AnchorPoint = toggled and targetAnchorPoint or initialTargetAnchorPoint
                    }
                ):Play()

                ts:Create(
                    sidetog,
                    TweenInfo.new(HOVER_DURATION),
                    {
                        Position = toggled and targetPosition or initialPosition
                    }
                ):Play()
                
                cb(toggled)
            end)
        end

        function contents:textbox(title, default, cb)
            local newtb = elements.TextboxElement:Clone()
            applyCyberStyle(newtb, C.ObsidianBlack) 
            
            if newtb:FindFirstChild("frame") then
                -- Apply style to the input area wrapper (secondary background)
                applyCyberStyle(newtb.frame, C.VelvetGray) 

                if newtb.frame:FindFirstChild("lbl") then 
                    local lblObj = newtb.frame.lbl
                    lblObj.TextColor3 = C.WhitePrimary
                end

                local inp = newtb.frame.inp.lbl
                applyCyberStyle(newtb.frame.inp, C.ObsidianBlack) 
                inp.TextColor3 = C.WhitePrimary

                -- Functionality remains identical
                if default ~= "" then
                    task.defer(cb, default)
                end

                inp.FocusLost:Connect(function(ep)
                    if ep then
                        cb(inp.Text)
                    end
                end)
            end
        end

        function contents:slider(title, min, max, default, cb)
            local newsl = elements.SliderElement:Clone()
            applyCyberStyle(newsl, C.ObsidianBlack) 
            
            if newsl:FindFirstChild("lbl") then 
                local lblObj = newsl.lbl
                 lblObj.TextColor3 = C.WhitePrimary
            end

            local slbtn = newsl.btn
            applyCyberStyle(slbtn, C.VelvetGray) 
            
            -- Neon Accent on the progress bar (CRITICAL STYLE POINT)
            local prog = slbtn.prog
            applyCyberStyle(prog, C.AccentNeon) 

            local lastval = 0
            local dragging = false

            local function setFromAlpha(alpha)
                alpha = math.clamp(alpha, 0, 1)
                local value = math.floor(min + (max - min) * alpha + 0.5)
                prog.Size = UDim2.new(alpha, 0, 1, 0)
                lastval = value
            end

            local function updateFromInput(x)
                local rel = (x - slbtn.AbsolutePosition.X) / slbtn.AbsoluteSize.X
                setFromAlpha(rel)
            end

            setFromAlpha((default - min) / (max - min))

            slbtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    updateFromInput(input.Position.X)
                end
            end)

            ui_service.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                    or input.UserInputType == Enum.UserInputType.Touch) then
                    updateFromInput(input.Position.X)
                end
            end)

            ui_service.InputEnded:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch) then

                    dragging = false
                    if cb then
                        newsl.lbl.Text = title .. " : " .. tostring(lastval)
                        pcall(cb, lastval)
                    end
                end
            end)
        end

    return sections
end

return module
