--[[
    VoidLib Custom UI Library - FULL COMPLETED VERSION
    - last small updates
]]

local module = {}

local ts = cloneref(game:GetService("TweenService"))
local cg = cloneref(game:GetService("CoreGui"))
local ui = cloneref(game:GetService("UserInputService"))
local hs = cloneref(game:GetService("HttpService"))

module.Theme = {
	Font = Enum.Font.GothamMedium,
	FontBold = Enum.Font.GothamBold,

	CornerRadius = UDim.new(0, 8),
	ElementRadius = UDim.new(0, 8),

	Background = Color3.fromRGB(11, 11, 14),
	Topbar = Color3.fromRGB(26, 26, 46),
	TabBar = Color3.fromRGB(26, 26, 46),
	ElementBg = Color3.fromRGB(26, 26, 46),
	ElementHoverBg = Color3.fromRGB(42, 33, 64),

	Text = Color3.fromRGB(255, 255, 255),
	SubText = Color3.fromRGB(143, 143, 143),

	Accent = Color3.fromRGB(160, 32, 240),
	ToggleOn = Color3.fromRGB(160, 32, 240),
	ToggleOff = Color3.fromRGB(50, 50, 64),

	PanelTransparency = 0.30,
	ElementTransparency = 0.35,
	ElementHoverTransparency = 0.08,
	StrokeTransparency = 1,
	StrokeHoverTransparency = 0.35,
	WindowStrokeTransparency = 0.45,

	WindowSize = UDim2.new(0, 550, 0, 350),
	WindowPosition = UDim2.new(0.5, -275, 0.5, -175),

	TopbarHeight = 40,
	TabBarWidth = 130,
	ElementHeight = 36,
}

local function create(class, props)
	local inst = Instance.new(class)
	for k, v in pairs(props or {}) do
		inst[k] = v
	end
	return inst
end

local function reg(instance, property, themeKey)
	if instance and module.Theme[themeKey] then
		instance[property] = module.Theme[themeKey]
	end
end

local function checkText(val)
	if type(val) == "table" then
		return tostring(val.Name or val.Text or val[1] or "Unknown")
	end
	return tostring(val or "")
end

-------------------------------------------------------------------
-- RAYFIELD LUCIDE ICON SYSTEM INTEGRATION
-------------------------------------------------------------------
local Icons = nil
task.spawn(function()
	pcall(function()
		local content = game:HttpGet("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/refs/heads/main/icons.lua")
		if content then
			local func, err = loadstring(content)
			if func then
				Icons = func()
			end
		end
	end)
end)

local function getIcon(name : string)
	if not Icons then return nil end
	name = string.match(string.lower(name), "^%s*(.*)%s*$")
	local sizedicons = Icons['48px']
	if not sizedicons then return nil end
	local r = sizedicons[name]
	if not r then return nil end

	return {
		id = r[1],
		imageRectSize = Vector2.new(r[2][1], r[2][2]),
		imageRectOffset = Vector2.new(r[3][1], r[3][2]),
	}
end

local function isCustomAsset(value)
	return type(value) == "string" and (string.find(value, "rbxasset://") == 1 or string.find(value, "rbxthumb://") == 1)
end

local function resolveIcon(icon)
	if not icon or icon == 0 or icon == "" then
		return "", nil, nil
	end
	if isCustomAsset(icon) then
		return icon, nil, nil
	end
	if typeof(icon) == "string" and Icons then
		local asset = getIcon(icon)
		if asset then
			return "rbxassetid://" .. asset.id, asset.imageRectOffset, asset.imageRectSize
		end
	end
	if typeof(icon) == "number" then
		return "rbxassetid://" .. icon, nil, nil
	end
	if typeof(icon) == "string" and icon:match("^rbxassetid://") then
		return icon, nil, nil
	end
	return "", nil, nil
end

local function applyIconToLabel(label, iconSource)
	local img, offset, size = resolveIcon(iconSource)
	if img and img ~= "" then
		label.Image = img
		if offset and size then
			label.ImageRectOffset = offset
			label.ImageRectSize = size
		else
			label.ImageRectOffset = Vector2.new(0, 0)
			label.ImageRectSize = Vector2.new(0, 0)
		end
		return true
	end
	return false
end

-- Universelle Drag-Funktion (Smooth für Mobile & PC)
local function makeDraggable(dragFrame, clickFrame)
	local dragging, dragInput, mousePos, framePos
	clickFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true; mousePos = input.Position; framePos = dragFrame.Position
			input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
		end
	end)
	clickFrame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
	end)
	ui.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - mousePos
			dragFrame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
		end
	end)
end

-------------------------------------------------------------------
-- GLOBAL NOTIFICATION SYSTEM
-------------------------------------------------------------------
local notifyGui = nil
local notifyHolder = nil
local notifyCount = 0

local function ensureNotifyGui()
	if notifyGui and notifyGui.Parent then return end
	local hui = gethui or get_hidden_gui or nil
	notifyGui = create("ScreenGui", {
		Name = "CustomUI_Notifications",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 999,
	})
	notifyGui.Parent = hui and hui() or cg

	notifyHolder = create("Frame", { Name = "holder", Parent = notifyGui, AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -16, 1, -16), Size = UDim2.new(0, 280, 1, -32), BackgroundTransparency = 1 })
	create("UIListLayout", { Parent = notifyHolder, VerticalAlignment = Enum.VerticalAlignment.Bottom, HorizontalAlignment = Enum.HorizontalAlignment.Right, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder })
end

function module:Notify(config)
	config = type(config) == "table" and config or {}
	local theme = module.Theme
	local notifTitle = checkText(config.Title or "Notification")
	local notifContent = checkText(config.Content or "")
	local duration = tonumber(config.Duration) or 4
	local image = config.Image

	ensureNotifyGui()

	local hasIcon = image ~= nil and image ~= 0 and image ~= ""

	notifyCount = notifyCount + 1
	local card = create("Frame", { Parent = notifyHolder, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, ClipsDescendants = true, LayoutOrder = notifyCount })
	reg(card, "BackgroundColor3", "Background")

	local cardStroke = create("UIStroke", { Parent = card, Thickness = 1, Transparency = theme.WindowStrokeTransparency, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
	reg(cardStroke, "Color", "Accent")
	create("UICorner", { Parent = card, CornerRadius = theme.CornerRadius })
	create("UIPadding", { Parent = card, PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10) })

	local textOffset = 0
	if hasIcon then
		local iconImg = create("ImageLabel", { Parent = card, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(0, 22, 0, 22) })
		reg(iconImg, "ImageColor3", "Accent")
		task.spawn(function()
			while not Icons do task.wait(0.1) end
			applyIconToLabel(iconImg, image)
		end)
		textOffset = 30
	end

	local titleLbl = create("TextLabel", { Parent = card, BackgroundTransparency = 1, Position = UDim2.new(0, textOffset, 0, 0), Size = UDim2.new(1, -textOffset, 0, 16), Text = notifTitle, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y })
	reg(titleLbl, "TextColor3", "Text")
	reg(titleLbl, "Font", "FontBold")

	local contentLbl = create("TextLabel", { Parent = card, BackgroundTransparency = 1, Position = UDim2.new(0, textOffset, 0, 20), Size = UDim2.new(1, -textOffset, 0, 16), Text = notifContent, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y })
	reg(contentLbl, "TextColor3", "SubText")
	reg(contentLbl, "Font", "Font")

	card.BackgroundTransparency = 1
	cardStroke.Transparency = 1
	titleLbl.TextTransparency = 1
	contentLbl.TextTransparency = 1

	ts:Create(card, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = theme.PanelTransparency }):Play()
	ts:Create(cardStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Transparency = theme.WindowStrokeTransparency }):Play()
	ts:Create(titleLbl, TweenInfo.new(0.25), { TextTransparency = 0 }):Play()
	ts:Create(contentLbl, TweenInfo.new(0.25), { TextTransparency = 0 }):Play()

	task.delay(duration, function()
		if not card or not card.Parent then return end
		local fadeOut = ts:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { BackgroundTransparency = 1 })
		ts:Create(cardStroke, TweenInfo.new(0.3), { Transparency = 1 }):Play()
		ts:Create(titleLbl, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
		ts:Create(contentLbl, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
		fadeOut:Play()
		fadeOut.Completed:Wait()
		card:Destroy()
	end)

	return card
end

function module:win(config)
	config = type(config) == "table" and config or {}
	
	local title = checkText(config.Name or "Custom Interface Suite")
	local loadingTitle = checkText(config.LoadingTitle or title)
	local loadingSubtitle = checkText(config.LoadingSubtitle or "Loading assets...")
	local topbarIcon = config.Icon or 0
	local showTextString = checkText(config.ShowText or "VoidLib")
	
	local theme = {}
	for k, v in pairs(module.Theme) do theme[k] = v end
	if config.ThemeOverrides then
		for k, v in pairs(config.ThemeOverrides) do theme[k] = v end
	end

	local screenGui = create("ScreenGui", {
		Name = "CustomUI",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})

	local hui = gethui or get_hidden_gui or nil
	screenGui.Parent = hui and hui() or cg

	-------------------------------------------------------------------
	-- CONFIGURATION SAVING SYSTEM
	-------------------------------------------------------------------
	local cfgSettings = config.ConfigurationSaving or { Enabled = false }
	local isSavingEnabled = (cfgSettings.Enabled == true or cfgSettings.Enable == true)
	
	local savedData = {}
	local folderName = cfgSettings.FolderName or "CustomUILocks"
	local fileName = (cfgSettings.FileName or "Big Hub") .. ".json"

	if isSavingEnabled and writefile and readfile and isfolder and makefolder then
		if not isfolder(folderName) then makefolder(folderName) end
		if isfile(folderName .. "/" .. fileName) then
			pcall(function() savedData = hs:JSONDecode(readfile(folderName .. "/" .. fileName)) end)
		end
	end

	local function saveConfig()
		if isSavingEnabled and writefile then
			pcall(function() writefile(folderName .. "/" .. fileName, hs:JSONEncode(savedData)) end)
		end
	end

	-------------------------------------------------------------------
	-- DISCORD SYSTEM
	-------------------------------------------------------------------
	local discordSettings = config.Discord or { Enable = false }
	local isDiscordEnabled = (discordSettings.Enable == true or discordSettings.Enabled == true)

	if isDiscordEnabled and discordSettings.Invite then
		task.spawn(function()
			local inviteCode = tostring(discordSettings.Invite)
				:gsub("https://discord.gg/", "")
				:gsub("http://discord.gg/", "")
				:gsub("discord.gg/", "")
				:gsub("https://discord.com/invite/", "")
				:gsub("/", "")

			local inviteFolderName = folderName .. "/Discord Invites"
			if makefolder and isfolder and not isfolder(inviteFolderName) then makefolder(inviteFolderName) end

			local fileCheckPath = inviteFolderName .. "/" .. inviteCode .. ".txt"
			local launchInvite = true
			if isfile and isfile(fileCheckPath) then launchInvite = false end

			if launchInvite then
				local requestFunc = request or syn.request or http.request or (http and http.request)
				if requestFunc then
					pcall(function()
						requestFunc({
							Url = "http://127.0.0.1:6463/rpc?v=1",
							Method = "POST",
							Headers = { ["Content-Type"] = "application/json", ["Origin"] = "https://discord.com" },
							Body = hs:JSONEncode({ cmd = "INVITE_BROWSER", nonce = hs:GenerateGUID(false), args = { code = inviteCode } })
						})
					end)
				end
				if discordSettings.RememberJoins and writefile then
					writefile(fileCheckPath, "VoidLib RememberJoins is true...")
				end
			end
		end)
	end

	-------------------------------------------------------------------
	-- KEY SYSTEM
	-------------------------------------------------------------------
	local keyPassed = false
	if config.KeySystem then
		local keySettings = config.KeySettings or {}
		local keyTitle = keySettings.Title or "Untitled"
		local keySubtitle = keySettings.Subtitle or "Key System"
		local keyNote = keySettings.Note or "No method of obtaining the key is provided"
		local keyFileName = (keySettings.FileName or "Key") .. ".txt"
		local validKeys = keySettings.Key or {"Hello"}

		if type(validKeys) == "string" then validKeys = {validKeys} end

		if keySettings.GrabKeyFromSite and keySettings.Key and type(keySettings.Key) == "string" then
			pcall(function()
				local success, res = pcall(game.HttpGet, game, keySettings.Key)
				if success then
					validKeys = {}
					for line in res:gmatch("[^\r\n]+") do table.insert(validKeys, line) end
				end
			end)
		end

		if makefolder and isfolder and not isfolder(folderName) then makefolder(folderName) end
		if keySettings.SaveKey and isfile and readfile and isfile(folderName .. "/" .. keyFileName) then
			local savedKey = readfile(folderName .. "/" .. keyFileName)
			for _, k in ipairs(validKeys) do
				if savedKey == k then keyPassed = true; break end
			end
		end

		if not keyPassed then
			local keyFrame = create("Frame", { Name = "KeySystemOverlay", Parent = screenGui, Size = UDim2.new(0, 350, 0, 240), Position = UDim2.new(0.5, -175, 0.5, -120), BorderSizePixel = 0, ZIndex = 20 })
			reg(keyFrame, "BackgroundColor3", "Background")
			create("UICorner", { Parent = keyFrame, CornerRadius = theme.CornerRadius })
			local kStroke = create("UIStroke", { Parent = keyFrame, Thickness = 1, Transparency = theme.WindowStrokeTransparency, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
			reg(kStroke, "Color", "Accent")

			create("TextLabel", { Parent = keyFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 15), Size = UDim2.new(1, 0, 0, 25), Text = keyTitle, TextSize = 18, TextColor3 = theme.Text, Font = theme.FontBold })
			create("TextLabel", { Parent = keyFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 40), Size = UDim2.new(1, 0, 0, 20), Text = keySubtitle, TextSize = 13, TextColor3 = theme.SubText, Font = theme.Font })
			local noteLbl = create("TextLabel", { Parent = keyFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 20, 0, 65), Size = UDim2.new(1, -44, 0, 40), Text = keyNote, TextSize = 11, TextColor3 = theme.SubText, Font = theme.Font, TextWrapped = true })
			
			local inputBg = create("Frame", { Parent = keyFrame, Position = UDim2.new(0, 20, 0, 115), Size = UDim2.new(1, -44, 0, 36) })
			reg(inputBg, "BackgroundColor3", "ElementBg")
			create("UICorner", { Parent = inputBg, CornerRadius = theme.ElementRadius })
			
			local keyInput = create("TextBox", { Parent = inputBg, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 10, 0, 0), Text = "", PlaceholderText = "Enter Key...", TextSize = 14, TextColor3 = theme.Text, Font = theme.Font, ClearTextOnFocus = false })
			local checkBtn = create("TextButton", { Parent = keyFrame, Position = UDim2.new(0, 20, 0, 170), Size = UDim2.new(1, -44, 0, 36), Text = "Check Key", TextSize = 14, AutoButtonColor = false })
			reg(checkBtn, "BackgroundColor3", "Accent")
			reg(checkBtn, "TextColor3", "Text")
			reg(checkBtn, "Font", "FontBold")
			create("UICorner", { Parent = checkBtn, CornerRadius = theme.ElementRadius })

			checkBtn.MouseButton1Click:Connect(function()
				local text = keyInput.Text
				local match = false
				for _, k in ipairs(validKeys) do if text == k then match = true; break end end
				if match then
					if keySettings.SaveKey and writefile then writefile(folderName .. "/" .. keyFileName, text) end
					keyPassed = true
					ts:Create(keyFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1, Size = UDim2.new(0, 370, 0, 260), Position = UDim2.new(0.5, -185, 0.5, -130) }):Play()
					for _, child in ipairs(keyFrame:GetChildren()) do
						if child:IsA("TextLabel") or child:IsA("Frame") or child:IsA("TextButton") then ts:Create(child, TweenInfo.new(0.2), { Transparency = 1 }):Play() end
					end
					task.wait(0.35)
					keyFrame:Destroy()
				else
					keyInput.Text = ""
					keyInput.PlaceholderText = "Invalid Key! Try Again."
					noteLbl.TextColor3 = Color3.fromRGB(255, 50, 50)
					task.delay(2, function() noteLbl.TextColor3 = theme.SubText end)
				end
			end)
			while not keyPassed do task.wait(0.1) end
		end
	else
		keyPassed = true
	end

	-------------------------------------------------------------------
	-- MAIN UI WINDOW
	-------------------------------------------------------------------
	local main = create("Frame", { Name = "Frame", Parent = screenGui, Size = theme.WindowSize, Position = theme.WindowPosition, BorderSizePixel = 0, ClipsDescendants = true, Visible = false })
	reg(main, "BackgroundColor3", "Background")
	create("UICorner", { Parent = main, CornerRadius = theme.CornerRadius })

	local mainStroke = create("UIStroke", { Parent = main, Thickness = 1, Transparency = theme.WindowStrokeTransparency, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
	reg(mainStroke, "Color", "Accent")

	local topbar = create("Frame", { Name = "topbar", Parent = main, Size = UDim2.new(1, 0, 0, theme.TopbarHeight), BackgroundTransparency = theme.PanelTransparency, BorderSizePixel = 0 })
	reg(topbar, "BackgroundColor3", "Topbar")
	create("UICorner", { Parent = topbar, CornerRadius = theme.CornerRadius })

	local topbarLine = create("Frame", { Name = "accentline", Parent = topbar, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 0, 1), BorderSizePixel = 0, BackgroundTransparency = 0.55 })
	reg(topbarLine, "BackgroundColor3", "Accent")

	-------------------------------------------------------------------
	-- TOPBAR ICON
	-------------------------------------------------------------------
	local iconLabel = create("ImageLabel", { Name = "TopbarIcon", Parent = topbar, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 12, 0.5, 0), Size = UDim2.new(0, 20, 0, 20), Image = "" })
	reg(iconLabel, "ImageColor3", "Text")
	
	task.spawn(function()
		while not Icons do task.wait(0.1) end
		if not applyIconToLabel(iconLabel, topbarIcon) then
			iconLabel.Visible = false
		end
	end)

	local titleLbl = create("TextLabel", { Name = "title", Parent = topbar, BackgroundTransparency = 1, Position = UDim2.new(0, 38, 0, 0), Size = UDim2.new(1, -118, 1, 0), Text = title, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left })
	reg(titleLbl, "TextColor3", "Text")
	reg(titleLbl, "Font", "FontBold")

	local toggleKey = Enum.KeyCode.K
	if config.ToggleUIKeybind then
		if typeof(config.ToggleUIKeybind) == "EnumItem" then
			toggleKey = config.ToggleUIKeybind
		elseif type(config.ToggleUIKeybind) == "string" then
			local ok, enumKey = pcall(function() return Enum.KeyCode[config.ToggleUIKeybind] end)
			if ok and enumKey then toggleKey = enumKey end
		end
	end

	-------------------------------------------------------------------
	-- MOBILE RE-OPEN BUTTON
	-------------------------------------------------------------------
	local mobileBtn = create("TextButton", { Name = "MobileOpenButton", Parent = screenGui, Size = UDim2.new(0, 100, 0, 32), Position = UDim2.new(1, -115, 1, -45), AutoButtonColor = false, Text = "", Visible = false })
	reg(mobileBtn, "BackgroundColor3", "Topbar")
	create("UICorner", { Parent = mobileBtn, CornerRadius = UDim.new(0, 6) })
	local mobileStroke = create("UIStroke", { Parent = mobileBtn, Thickness = 1, Transparency = 0.5 })
	reg(mobileStroke, "Color", "Accent")

	makeDraggable(mobileBtn, mobileBtn)

	task.spawn(function()
		while not Icons do task.wait(0.1) end
		local isLucide = (showTextString ~= "Rayfield" and showTextString ~= "VoidLib") and getIcon(showTextString)
		if isLucide then
			mobileBtn.Size = UDim2.new(0, 36, 0, 36)
			local mobileIconImg = create("ImageLabel", { Parent = mobileBtn, Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0.5, -10, 0.5, -10), BackgroundTransparency = 1 })
			reg(mobileIconImg, "ImageColor3", "Text")
			applyIconToLabel(mobileIconImg, showTextString)
		else
			mobileBtn.Text = showTextString
			reg(mobileBtn, "TextColor3", "Text")
			reg(mobileBtn, "Font", "FontBold")
			mobileBtn.TextSize = 13
		end
	end)

	local function setUIVisibility(visible)
		main.Visible = visible
		mobileBtn.Visible = not visible
	end

	mobileBtn.MouseButton1Click:Connect(function() setUIVisibility(true) end)

	local btns = create("Frame", { Name = "btns", Parent = topbar, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.new(0, 60, 0, 24) })
	create("UIListLayout", { Parent = btns, FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), VerticalAlignment = Enum.VerticalAlignment.Center, HorizontalAlignment = Enum.HorizontalAlignment.Right })

	local function makeTopbarBtn(symbol)
		local btn = create("TextButton", { Parent = btns, Size = UDim2.new(0, 24, 0, 24), BackgroundTransparency = 1, Text = symbol, TextSize = 14, AutoButtonColor = false })
		reg(btn, "TextColor3", "SubText")
		reg(btn, "Font", "Font")
		reg(btn, "BackgroundColor3", "ElementBg")
		create("UICorner", { Parent = btn, CornerRadius = UDim.new(0, 6) })

		btn.MouseEnter:Connect(function()
			ts:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = theme.ElementHoverTransparency, TextColor3 = theme.Accent }):Play()
		end)
		btn.MouseLeave:Connect(function()
			ts:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = 1, TextColor3 = theme.SubText }):Play()
		end)
		return btn
	end

	local minimizeBtn = makeTopbarBtn("-")
	local closeBtn = makeTopbarBtn("X")

	minimizeBtn.MouseButton1Click:Connect(function() setUIVisibility(false) end)
	local toggleKeyConn = ui.InputBegan:Connect(function(input, processed)
		if not processed and input.KeyCode == toggleKey then setUIVisibility(not main.Visible) end
	end)
	closeBtn.MouseButton1Click:Connect(function() toggleKeyConn:Disconnect(); screenGui:Destroy() end)

	makeDraggable(main, topbar)

	local body = create("Frame", { Name = "body", Parent = main, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, theme.TopbarHeight), Size = UDim2.new(1, 0, 1, -theme.TopbarHeight) })
	local tabBar = create("ScrollingFrame", { Name = "tabbar", Parent = body, BorderSizePixel = 0, BackgroundTransparency = theme.PanelTransparency, Size = UDim2.new(0, theme.TabBarWidth, 1, 0), CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 3 })
	reg(tabBar, "BackgroundColor3", "TabBar")
	reg(tabBar, "ScrollBarImageColor3", "Accent")
	create("UIListLayout", { Parent = tabBar, Padding = UDim.new(0, 4) })
	create("UIPadding", { Parent = tabBar, PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) })

	local sectionsHolder = create("Frame", { Name = "sectionsholder", Parent = body, BackgroundTransparency = 1, Position = UDim2.new(0, theme.TabBarWidth, 0, 0), Size = UDim2.new(1, -theme.TabBarWidth, 1, 0), ClipsDescendants = true })
	local sections = {}
	local curBtn, curSection = nil, nil

	local function setSelectedTab(btn, section)
		if curBtn == btn then return end
		if curBtn then
			local curGlow = curBtn:FindFirstChild("glow")
			local curIndicator = curBtn:FindFirstChild("indicator")
			ts:Create(curBtn, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()
			if curIndicator then ts:Create(curIndicator, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play() end
			if curGlow then ts:Create(curGlow, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Transparency = theme.StrokeTransparency }):Play() end
			curSection.Visible = false
		end
		local glow = btn:FindFirstChild("glow")
		local indicator = btn:FindFirstChild("indicator")
		ts:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = theme.ElementHoverTransparency }):Play()
		if indicator then ts:Create(indicator, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = 0 }):Play() end
		if glow then ts:Create(glow, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Transparency = theme.StrokeHoverTransparency }):Play() end
		section.Visible = true
		curBtn, curSection = btn, section
	end

	function sections:tab(title, icon)
		title = checkText(title)
		local btn = create("TextButton", { Parent = tabBar, Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, AutoButtonColor = false, Text = "" })
		reg(btn, "BackgroundColor3", "ElementBg")
		create("UICorner", { Parent = btn, CornerRadius = theme.ElementRadius })

		local glow = create("UIStroke", { Name = "glow", Parent = btn, Thickness = 1, Transparency = theme.StrokeTransparency, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
		reg(glow, "Color", "Accent")

		local indicator = create("Frame", { Name = "indicator", Parent = btn, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.new(0, 3, 0.6, 0), BackgroundTransparency = 1, BorderSizePixel = 0 })
		reg(indicator, "BackgroundColor3", "Accent")
		create("UICorner", { Parent = indicator, CornerRadius = UDim.new(1, 0) })

		local label = create("TextLabel", { Parent = btn, BackgroundTransparency = 1, Position = UDim2.new(0, 36, 0, 0), Size = UDim2.new(1, -44, 1, 0), Text = title, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left })
		reg(label, "TextColor3", "Text")
		reg(label, "Font", "Font")

		local tabIconLbl = create("ImageLabel", { Parent = btn, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 8, 0.5, 0), Size = UDim2.new(0, 18, 0, 18) })
		reg(tabIconLbl, "ImageColor3", "SubText")

		task.spawn(function()
			while not Icons do task.wait(0.1) end
			if not applyIconToLabel(tabIconLbl, icon) then
				tabIconLbl.Visible = false
				label.Position = UDim2.new(0, 12, 0, 0)
			end
		end)

		btn.MouseEnter:Connect(function() if curBtn ~= btn then ts:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = theme.ElementTransparency }):Play(); ts:Create(glow, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Transparency = theme.StrokeHoverTransparency }):Play() end end)
		btn.MouseLeave:Connect(function() if curBtn ~= btn then ts:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play(); ts:Create(glow, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Transparency = theme.StrokeTransparency }):Play() end end)

		local section = create("ScrollingFrame", { Name = title, Parent = sectionsHolder, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, 0), CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 3, Visible = false })
		reg(section, "ScrollBarImageColor3", "Accent")
		create("UIListLayout", { Parent = section, Padding = UDim.new(0, 6) })
		create("UIPadding", { Parent = section, PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) })

		btn.MouseButton1Click:Connect(function() setSelectedTab(btn, section) end)
		if not curBtn then setSelectedTab(btn, section) end

		local contents = {}

		function contents:label(text, icon)
			text = checkText(text)
			local holder = create("Frame", { Parent = section, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20) })

			local iconLbl = create("ImageLabel", { Parent = holder, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0.5, -8), Size = UDim2.new(0, 16, 0, 16), Visible = false })
			reg(iconLbl, "ImageColor3", "SubText")

			local textLbl = create("TextLabel", { Parent = holder, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true })
			reg(textLbl, "TextColor3", "SubText")
			reg(textLbl, "Font", "Font")

			local function applyIcon(ic)
				if ic and applyIconToLabel(iconLbl, ic) then
					iconLbl.Visible = true
					textLbl.Position = UDim2.new(0, 22, 0, 0)
					textLbl.Size = UDim2.new(1, -22, 1, 0)
				else
					iconLbl.Visible = false
					textLbl.Position = UDim2.new(0, 0, 0, 0)
					textLbl.Size = UDim2.new(1, 0, 1, 0)
				end
			end

			if icon then
				task.spawn(function()
					while not Icons do task.wait(0.1) end
					applyIcon(icon)
				end)
			end

			local labelObj = { Instance = holder }
			function labelObj:Set(newTitle, newIcon, newColor, ignoreTheme)
				if newTitle ~= nil then textLbl.Text = checkText(newTitle) end
				if newIcon ~= nil then applyIcon(newIcon) end
				if newColor ~= nil then
					textLbl.TextColor3 = newColor
					iconLbl.ImageColor3 = newColor
				elseif not ignoreTheme then
					reg(textLbl, "TextColor3", "SubText")
					reg(iconLbl, "ImageColor3", "SubText")
				end
			end
			function labelObj:Get()
				return {
					Title = textLbl.Text,
					Color = textLbl.TextColor3,
					IconVisible = iconLbl.Visible,
				}
			end
			return labelObj
		end
		contents.CreateLabel = contents.label

		function contents:button(text, cb)
			text = checkText(text)
			local btnEl = create("TextButton", { Parent = section, Size = UDim2.new(1, 0, 0, theme.ElementHeight), BackgroundTransparency = theme.ElementTransparency, AutoButtonColor = false, Text = text, TextSize = 13 })
			reg(btnEl, "BackgroundColor3", "ElementBg")
			reg(btnEl, "TextColor3", "Text")
			reg(btnEl, "Font", "Font")
			create("UICorner", { Parent = btnEl, CornerRadius = theme.ElementRadius })

			local glowE = create("UIStroke", { Parent = btnEl, Thickness = 1, Transparency = theme.StrokeTransparency, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
			reg(glowE, "Color", "Accent")

			btnEl.MouseEnter:Connect(function() ts:Create(btnEl, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = theme.ElementHoverTransparency }):Play(); ts:Create(glowE, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Transparency = theme.StrokeHoverTransparency }):Play() end)
			btnEl.MouseLeave:Connect(function() ts:Create(btnEl, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = theme.ElementTransparency }):Play(); ts:Create(glowE, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Transparency = theme.StrokeTransparency }):Play() end)
			btnEl.MouseButton1Click:Connect(cb)

			local btnObj = { Instance = btnEl }
			function btnObj:Set(newText)
				btnEl.Text = checkText(newText)
			end
			function btnObj:Get()
				return btnEl.Text
			end
			return btnObj
		end

		function contents:toggle(text, id, default, cb)
			text = checkText(text)
			if type(id) == "boolean" or type(id) == "nil" then cb = default; default = id; id = text end
			id = tostring(id)

			local toggled = default and true or false
			if savedData[id] ~= nil then toggled = savedData[id] end

			local holder = create("TextButton", { Parent = section, Size = UDim2.new(1, 0, 0, theme.ElementHeight), BackgroundTransparency = theme.ElementTransparency, AutoButtonColor = false, Text = "" })
			reg(holder, "BackgroundColor3", "ElementBg")
			create("UICorner", { Parent = holder, CornerRadius = theme.ElementRadius })

			local hoverGlow = create("UIStroke", { Parent = holder, Thickness = 1, Transparency = theme.StrokeTransparency, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
			reg(hoverGlow, "Color", "Accent")

			local lbl = create("TextLabel", { Parent = holder, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -60, 1, 0), Text = text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left })
			reg(lbl, "TextColor3", "Text")
			reg(lbl, "Font", "Font")

			local track = create("Frame", { Parent = holder, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.new(0, 38, 0, 20), BorderSizePixel = 0 })
			create("UICorner", { Parent = track, CornerRadius = UDim.new(1, 0) })

			local trackGlow = create("UIStroke", { Parent = track, Thickness = 1, Transparency = 0.6, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
			reg(trackGlow, "Color", "Accent")

			local knob = create("Frame", { Parent = track, Size = UDim2.new(0, 16, 0, 16), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0 })
			create("UICorner", { Parent = knob, CornerRadius = UDim.new(1, 0) })

			local function applyVisual(animated)
				local goalColor = toggled and theme.ToggleOn or theme.ToggleOff
				local goalGlow = toggled and 0.15 or 0.85
				local goalPos = toggled and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
				if animated then
					ts:Create(track, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundColor3 = goalColor }):Play()
					ts:Create(trackGlow, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Transparency = goalGlow }):Play()
					ts:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = goalPos }):Play()
				else
					track.BackgroundColor3 = goalColor
					trackGlow.Transparency = goalGlow
					knob.Position = goalPos
				end
				knob.AnchorPoint = Vector2.new(0, 0.5)
			end
			applyVisual(false)

			holder.MouseEnter:Connect(function() ts:Create(holder, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = theme.ElementHoverTransparency }):Play(); ts:Create(hoverGlow, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Transparency = theme.StrokeHoverTransparency }):Play() end)
			holder.MouseLeave:Connect(function() ts:Create(holder, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = theme.ElementTransparency }):Play(); ts:Create(hoverGlow, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Transparency = theme.StrokeTransparency }):Play() end)

			holder.MouseButton1Click:Connect(function()
				toggled = not toggled
				savedData[id] = toggled
				saveConfig()
				applyVisual(true)
				if cb then cb(toggled) end
			end)

			local toggleObj = { Instance = holder }
			function toggleObj:Set(newVal, silent)
				toggled = newVal and true or false
				savedData[id] = toggled
				saveConfig()
				applyVisual(true)
				if cb and not silent then cb(toggled) end
			end
			function toggleObj:Get()
				return toggled
			end
			return toggleObj
		end

		function contents:textbox(text, id, default, cb, opts)
			text = checkText(text)
			if type(id) == "string" and type(default) == "string" and type(cb) == "nil" then id = text end
			if type(id) == "function" then cb = id; default = ""; id = text end
			if type(default) == "function" then cb = default; default = id; id = text end
			id = tostring(id)
			opts = type(opts) == "table" and opts or {}
			local placeholderText = opts.PlaceholderText or "..."
			local removeAfterFocusLost = opts.RemoveTextAfterFocusLost == true

			local currentText = checkText(default)
			if savedData[id] ~= nil then currentText = tostring(savedData[id]) end

			local holder = create("Frame", { Parent = section, Size = UDim2.new(1, 0, 0, theme.ElementHeight), BackgroundTransparency = theme.ElementTransparency })
			reg(holder, "BackgroundColor3", "ElementBg")
			create("UICorner", { Parent = holder, CornerRadius = theme.ElementRadius })

			local lbl = create("TextLabel", { Parent = holder, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(0.5, -12, 1, 0), Text = text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left })
			reg(lbl, "TextColor3", "Text")
			reg(lbl, "Font", "Font")

			local inputBg = create("Frame", { Parent = holder, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.new(0.45, 0, 0, 24) })
			reg(inputBg, "BackgroundColor3", "ElementHoverBg")
			create("UICorner", { Parent = inputBg, CornerRadius = UDim.new(0, 6) })

			local focusGlow = create("UIStroke", { Parent = inputBg, Thickness = 1, Transparency = theme.StrokeTransparency, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
			reg(focusGlow, "Color", "Accent")

			local input = create("TextBox", { Parent = inputBg, BackgroundTransparency = 1, Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 5, 0, 0), Text = currentText, PlaceholderText = placeholderText, TextSize = 13, ClearTextOnFocus = false })
			reg(input, "TextColor3", "Text")
			reg(input, "Font", "Font")

			input.Focused:Connect(function() ts:Create(focusGlow, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Transparency = theme.StrokeHoverTransparency }):Play() end)
			input.FocusLost:Connect(function()
				ts:Create(focusGlow, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Transparency = theme.StrokeTransparency }):Play()
				savedData[id] = input.Text
				saveConfig()
				if cb then cb(input.Text) end
				if removeAfterFocusLost then input.Text = "" end
			end)

			local textboxObj = { Instance = holder }
			function textboxObj:Set(newText, silent)
				newText = checkText(newText)
				input.Text = newText
				savedData[id] = newText
				saveConfig()
				if cb and not silent then cb(newText) end
			end
			function textboxObj:Get()
				return input.Text
			end
			return textboxObj
		end

		function contents:slider(text, id, min, max, default, cb)
			text = checkText(text)
			if type(id) == "number" then cb = default; default = max; max = min; min = id; id = text end
			id = tostring(id)
			min = tonumber(min) or 0
			max = tonumber(max) or 100
			default = tonumber(default) or min

			local valStart = default
			if savedData[id] ~= nil then valStart = tonumber(savedData[id]) or default end

			local holder = create("Frame", { Parent = section, Size = UDim2.new(1, 0, 0, theme.ElementHeight + 16), BackgroundTransparency = theme.ElementTransparency })
			reg(holder, "BackgroundColor3", "ElementBg")
			create("UICorner", { Parent = holder, CornerRadius = theme.ElementRadius })

			local lbl = create("TextLabel", { Parent = holder, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 6), Size = UDim2.new(1, -24, 0, 14), Text = text .. " : " .. tostring(valStart), TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left })
			reg(lbl, "TextColor3", "Text")
			reg(lbl, "Font", "Font")

			local track = create("Frame", { Parent = holder, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 28), Size = UDim2.new(1, -24, 0, 6), BorderSizePixel = 0 })
			reg(track, "BackgroundColor3", "ElementHoverBg")
			create("UICorner", { Parent = track, CornerRadius = UDim.new(1, 0) })

			local fill = create("Frame", { Parent = track, Size = UDim2.new(0, 0, 1, 0), BorderSizePixel = 0 })
			reg(fill, "BackgroundColor3", "Accent")
			create("UICorner", { Parent = fill, CornerRadius = UDim.new(1, 0) })

			local sliderDragging = false
			local lastVal = valStart

			local function setFromAlpha(alpha)
				alpha = math.clamp(alpha, 0, 1)
				local value = math.floor(min + (max - min) * alpha + 0.5)
				local denom = (max - min)
				local scaleX = denom > 0 and ((value - min) / denom) or 0
				fill.Size = UDim2.new(scaleX, 0, 1, 0)
				lastVal = value
				lbl.Text = text .. " : " .. tostring(value)
			end

			track.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					sliderDragging = true
					setFromAlpha((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X)
				end
			end)
			ui.InputChanged:Connect(function(input)
				if sliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					setFromAlpha((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X)
				end
			end)
			ui.InputEnded:Connect(function(input)
				if sliderDragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
					sliderDragging = false
					savedData[id] = lastVal
					saveConfig()
					if cb then pcall(cb, lastVal) end
				end
			end)

			task.defer(function()
				local denom = (max - min)
				setFromAlpha(denom > 0 and ((valStart - min) / denom) or 0)
			end)

			local sliderObj = { Instance = holder }
			function sliderObj:Set(newVal, silent)
				local denom = (max - min)
				local clampedVal = math.clamp(tonumber(newVal) or min, min, max)
				local alpha = denom > 0 and ((clampedVal - min) / denom) or 0
				setFromAlpha(alpha)
				savedData[id] = lastVal
				saveConfig()
				if cb and not silent then pcall(cb, lastVal) end
			end
			function sliderObj:Get()
				return lastVal
			end
			return sliderObj
		end

		function contents:dropdown(text, id, list, default, cb)
			text = checkText(text)
			if type(id) == "table" then cb = default; default = list; list = id; id = text end
			if type(default) == "function" then cb = default; default = nil end
			id = tostring(id)
			list = type(list) == "table" and list or {}

			local dropdownOpen = false
			local currentSelected = default or (list[1] or "...")
			if savedData[id] ~= nil then currentSelected = savedData[id] end

			local holder = create("Frame", { Parent = section, Size = UDim2.new(1, 0, 0, theme.ElementHeight), BackgroundTransparency = theme.ElementTransparency, ClipsDescendants = true })
			reg(holder, "BackgroundColor3", "ElementBg")
			create("UICorner", { Parent = holder, CornerRadius = theme.ElementRadius })

			local hoverGlow = create("UIStroke", { Parent = holder, Thickness = 1, Transparency = theme.StrokeTransparency, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
			reg(hoverGlow, "Color", "Accent")

			local trigger = create("TextButton", { Parent = holder, Size = UDim2.new(1, 0, 0, theme.ElementHeight), BackgroundTransparency = 1, AutoButtonColor = false, Text = "" })
			local lbl = create("TextLabel", { Parent = trigger, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(0.5, -12, 1, 0), Text = text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left })
			reg(lbl, "TextColor3", "Text")
			reg(lbl, "Font", "Font")

			local selectedLbl = create("TextLabel", { Parent = trigger, BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0, 0), Size = UDim2.new(0.5, -30, 1, 0), Text = tostring(currentSelected), TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right })
			reg(selectedLbl, "TextColor3", "SubText")
			reg(selectedLbl, "Font", "Font")

			local indicator = create("TextLabel", { Parent = trigger, BackgroundTransparency = 1, Position = UDim2.new(1, -24, 0, 0), Size = UDim2.new(0, 20, 1, 0), Text = "V", TextSize = 10, TextXAlignment = Enum.TextXAlignment.Center })
			reg(indicator, "TextColor3", "SubText")
			reg(indicator, "Font", "FontBold")

			local container = create("ScrollingFrame", { Parent = holder, Position = UDim2.new(0, 6, 0, theme.ElementHeight), Size = UDim2.new(1, -12, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y })
			reg(container, "ScrollBarImageColor3", "Accent")
			create("UIListLayout", { Parent = container, Padding = UDim.new(0, 4) })
			create("UIPadding", { Parent = container, PaddingBottom = UDim.new(0, 4) })

			local function updateOptions()
				for _, child in ipairs(container:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
				for _, val in ipairs(list) do
					local optionStr = tostring(val)
					local opt = create("TextButton", { Parent = container, Size = UDim2.new(1, 0, 0, theme.ElementHeight - 6), BackgroundTransparency = 0, BackgroundColor3 = theme.ElementHoverBg, Text = optionStr, TextSize = 12, AutoButtonColor = false })
					reg(opt, "TextColor3", "Text")
					reg(opt, "Font", "Font")
					create("UICorner", { Parent = opt, CornerRadius = UDim.new(0, 4) })

					opt.MouseButton1Click:Connect(function()
						currentSelected = val
						selectedLbl.Text = optionStr
						dropdownOpen = false
						savedData[id] = val
						saveConfig()
						ts:Create(holder, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, theme.ElementHeight) }):Play()
						ts:Create(container, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = UDim2.new(1, -12, 0, 0) }):Play()
						indicator.Text = "V"
						if cb then cb(val) end
					end)
				end
			end
			updateOptions()

			trigger.MouseButton1Click:Connect(function()
				dropdownOpen = not dropdownOpen
				local maxItems = math.min(#list, 4)
				local targetContainerHeight = maxItems * (theme.ElementHeight - 2)
				ts:Create(holder, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = dropdownOpen and UDim2.new(1, 0, 0, theme.ElementHeight + targetContainerHeight + 6) or UDim2.new(1, 0, 0, theme.ElementHeight) }):Play()
				ts:Create(container, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = dropdownOpen and UDim2.new(1, -12, 0, targetContainerHeight) or UDim2.new(1, -12, 0, 0) }):Play()
				indicator.Text = dropdownOpen and "^" or "V"
			end)

			return {
				Refresh = function(_, nl, nd) list = nl or {}; if nd then currentSelected = nd; selectedLbl.Text = tostring(nd) end; updateOptions() end,
				Get = function(_) return currentSelected end,
			}
		end

		function contents:keybind(text, id, default, cb, opts)
			text = checkText(text)
			if typeof(id) == "EnumItem" then
				-- old-style call: keybind(text, defaultKeyEnum, callback)
				cb = default; default = id; id = text
			elseif type(id) == "string" and type(default) == "function" and cb == nil then
				-- old-style call: keybind(text, "F", callback) -- no explicit id given
				cb = default; default = id; id = text
			end
			id = tostring(id)
			opts = type(opts) == "table" and opts or {}
			local holdToInteract = opts.HoldToInteract == true

			local currentKey = default
			if typeof(currentKey) == "EnumItem" then currentKey = currentKey.Name
			elseif type(currentKey) ~= "string" then currentKey = "None" end

			if savedData[id] ~= nil then currentKey = tostring(savedData[id]) end

			local holder = create("Frame", { Parent = section, Size = UDim2.new(1, 0, 0, theme.ElementHeight), BackgroundTransparency = theme.ElementTransparency })
			reg(holder, "BackgroundColor3", "ElementBg")
			create("UICorner", { Parent = holder, CornerRadius = theme.ElementRadius })

			local lbl = create("TextLabel", { Parent = holder, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(0.5, -12, 1, 0), Text = text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left })
			reg(lbl, "TextColor3", "Text")
			reg(lbl, "Font", "Font")

			local bindBtn = create("TextButton", { Parent = holder, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.new(0.35, 0, 0, 24), Text = currentKey, TextSize = 12, AutoButtonColor = false })
			reg(bindBtn, "BackgroundColor3", "ElementHoverBg")
			reg(bindBtn, "TextColor3", "SubText")
			reg(bindBtn, "Font", "Font")
			create("UICorner", { Parent = bindBtn, CornerRadius = UDim.new(0, 6) })

			local glow = create("UIStroke", { Parent = bindBtn, Thickness = 1, Transparency = theme.StrokeTransparency, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
			reg(glow, "Color", "Accent")

			local listening = false
			bindBtn.MouseButton1Click:Connect(function()
				if listening then return end
				listening = true
				bindBtn.Text = "..."
				reg(bindBtn, "TextColor3", "Accent")
				ts:Create(glow, TweenInfo.new(0.15), { Transparency = theme.StrokeHoverTransparency }):Play()
			end)

			local holding = false
			local inputConn
			inputConn = ui.InputBegan:Connect(function(input, processed)
				if not screenGui or not screenGui.Parent then inputConn:Disconnect(); return end
				if listening then
					if input.UserInputType == Enum.UserInputType.Keyboard then
						listening = false
						currentKey = input.KeyCode.Name
						bindBtn.Text = currentKey
						reg(bindBtn, "TextColor3", "SubText")
						ts:Create(glow, TweenInfo.new(0.15), { Transparency = theme.StrokeTransparency }):Play()
						savedData[id] = currentKey
						saveConfig()
					elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
						listening = false
						bindBtn.Text = currentKey
						reg(bindBtn, "TextColor3", "SubText")
						ts:Create(glow, TweenInfo.new(0.15), { Transparency = theme.StrokeTransparency }):Play()
					end
				else
					if not processed and currentKey ~= "None" and input.KeyCode.Name == currentKey then
						if holdToInteract then
							if not holding then
								holding = true
								if cb then pcall(cb, true) end
							end
						else
							if cb then pcall(cb, currentKey) end
						end
					end
				end
			end)

			if holdToInteract then
				ui.InputEnded:Connect(function(input)
					if holding and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == currentKey then
						holding = false
						if cb then pcall(cb, false) end
					end
				end)
			end

			local keybindObj = { Instance = holder }
			function keybindObj:Set(newKey, silent)
				if typeof(newKey) == "EnumItem" then newKey = newKey.Name
				elseif type(newKey) ~= "string" then newKey = "None" end
				currentKey = newKey
				bindBtn.Text = currentKey
				savedData[id] = currentKey
				saveConfig()
				if cb and not silent then
					if holdToInteract then
						pcall(cb, true)
					else
						pcall(cb, currentKey)
					end
				end
			end
			function keybindObj:Get()
				return currentKey, holding
			end
			return keybindObj
		end

		function contents:CreateParagraph(config)
			config = type(config) == "table" and config or {}
			local pTitle = checkText(config.Title or "")
			local pContent = checkText(config.Content or "")

			local holder = create("Frame", { Parent = section, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = theme.ElementTransparency })
			reg(holder, "BackgroundColor3", "ElementBg")
			create("UICorner", { Parent = holder, CornerRadius = theme.ElementRadius })
			create("UIPadding", { Parent = holder, PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10) })
			create("UIListLayout", { Parent = holder, Padding = UDim.new(0, 4) })

			local titleLbl = create("TextLabel", { Parent = holder, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), Text = pTitle, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 1 })
			reg(titleLbl, "TextColor3", "Text")
			reg(titleLbl, "Font", "FontBold")

			local contentLbl = create("TextLabel", { Parent = holder, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), Text = pContent, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2 })
			reg(contentLbl, "TextColor3", "SubText")
			reg(contentLbl, "Font", "Font")

			local paragraphObj = { Instance = holder }
			function paragraphObj:Set(newConfig)
				newConfig = type(newConfig) == "table" and newConfig or {}
				if newConfig.Title ~= nil then titleLbl.Text = checkText(newConfig.Title) end
				if newConfig.Content ~= nil then contentLbl.Text = checkText(newConfig.Content) end
			end
			function paragraphObj:Get()
				return { Title = titleLbl.Text, Content = contentLbl.Text }
			end
			return paragraphObj
		end

		function contents:CreateColorPicker(config)
			config = type(config) == "table" and config or {}
			local cName = checkText(config.Name or "Color")
			local id = tostring(config.Flag or cName)
			local cb = config.Callback

			local currentColor = typeof(config.Color) == "Color3" and config.Color or Color3.fromRGB(255, 255, 255)
			if savedData[id] ~= nil and type(savedData[id]) == "table" then
				local c = savedData[id]
				pcall(function() currentColor = Color3.fromRGB(c[1] or 255, c[2] or 255, c[3] or 255) end)
			end

			local holder = create("Frame", { Parent = section, Size = UDim2.new(1, 0, 0, theme.ElementHeight), BackgroundTransparency = theme.ElementTransparency, ClipsDescendants = true })
			reg(holder, "BackgroundColor3", "ElementBg")
			create("UICorner", { Parent = holder, CornerRadius = theme.ElementRadius })

			local lbl = create("TextLabel", { Parent = holder, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(0.6, -12, 0, theme.ElementHeight), Text = cName, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left })
			reg(lbl, "TextColor3", "Text")
			reg(lbl, "Font", "Font")

			local swatch = create("TextButton", { Parent = holder, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0, theme.ElementHeight / 2), Size = UDim2.new(0, 40, 0, 22), BackgroundColor3 = currentColor, AutoButtonColor = false, Text = "" })
			create("UICorner", { Parent = swatch, CornerRadius = UDim.new(0, 6) })
			local swatchStroke = create("UIStroke", { Parent = swatch, Thickness = 1, Transparency = 0.4 })
			reg(swatchStroke, "Color", "Accent")

			local panel = create("Frame", { Parent = holder, Position = UDim2.new(0, 8, 0, theme.ElementHeight + 4), Size = UDim2.new(1, -16, 0, 0), BackgroundTransparency = 1 })
			create("UIListLayout", { Parent = panel, Padding = UDim.new(0, 6) })

			local sliders = {}
			local channels = { { key = "R", label = "R" }, { key = "G", label = "G" }, { key = "B", label = "B" } }

			local function currentRGB()
				return math.floor(currentColor.R * 255 + 0.5), math.floor(currentColor.G * 255 + 0.5), math.floor(currentColor.B * 255 + 0.5)
			end

			local updatingInternally = false

			local function applyColor(newColor, fireCb)
				currentColor = newColor
				swatch.BackgroundColor3 = currentColor
				local r, g, b = currentRGB()
				savedData[id] = { r, g, b }
				saveConfig()
				if fireCb and cb then pcall(cb, currentColor) end
			end

			for _, chDef in ipairs(channels) do
				local row = create("Frame", { Parent = panel, Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1 })
				local chLbl = create("TextLabel", { Parent = row, BackgroundTransparency = 1, Size = UDim2.new(0, 16, 1, 0), Text = chDef.label, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left })
				reg(chLbl, "TextColor3", "SubText")
				reg(chLbl, "Font", "Font")

				local track = create("Frame", { Parent = row, Position = UDim2.new(0, 20, 0.5, -3), Size = UDim2.new(1, -20, 0, 6), BorderSizePixel = 0 })
				reg(track, "BackgroundColor3", "ElementHoverBg")
				create("UICorner", { Parent = track, CornerRadius = UDim.new(1, 0) })

				local fill = create("Frame", { Parent = track, Size = UDim2.new(0, 0, 1, 0), BorderSizePixel = 0 })
				reg(fill, "BackgroundColor3", "Accent")
				create("UICorner", { Parent = fill, CornerRadius = UDim.new(1, 0) })

				local dragging = false
				local function setAlpha(alpha)
					alpha = math.clamp(alpha, 0, 1)
					fill.Size = UDim2.new(alpha, 0, 1, 0)
					if updatingInternally then return end
					local r, g, b = currentRGB()
					local val = math.floor(alpha * 255 + 0.5)
					if chDef.key == "R" then r = val elseif chDef.key == "G" then g = val else b = val end
					applyColor(Color3.fromRGB(r, g, b), false)
				end

				track.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragging = true
						setAlpha((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X)
					end
				end)
				ui.InputChanged:Connect(function(input)
					if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
						setAlpha((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X)
					end
				end)
				ui.InputEnded:Connect(function(input)
					if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
						dragging = false
						savedData[id] = { currentRGB() }
						saveConfig()
						if cb then pcall(cb, currentColor) end
					end
				end)

				sliders[chDef.key] = setAlpha
			end

			local function refreshSliders()
				updatingInternally = true
				local r, g, b = currentRGB()
				sliders.R(r / 255)
				sliders.G(g / 255)
				sliders.B(b / 255)
				updatingInternally = false
			end
			task.defer(refreshSliders)

			local expanded = false
			swatch.MouseButton1Click:Connect(function()
				expanded = not expanded
				local panelHeight = expanded and (#channels * 30) or 0
				ts:Create(holder, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, theme.ElementHeight + (expanded and (panelHeight + 12) or 0)) }):Play()
				ts:Create(panel, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = UDim2.new(1, -16, 0, panelHeight) }):Play()
			end)

			local colorPickerObj = { Instance = holder }
			function colorPickerObj:Set(newColor, silent)
				if typeof(newColor) ~= "Color3" then return end
				applyColor(newColor, not silent)
				refreshSliders()
			end
			function colorPickerObj:Get()
				return currentColor
			end
			return colorPickerObj
		end
		function contents:CreateDivider()
			local holder = create("Frame", { Parent = section, Size = UDim2.new(1, 0, 0, 9), BackgroundTransparency = 1 })
			local line = create("Frame", { Parent = holder, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(1, 0, 0, 1), BorderSizePixel = 0, BackgroundTransparency = 0.85 })
			reg(line, "BackgroundColor3", "SubText")

			local dividerObj = { Instance = holder }
			function dividerObj:Set(visible)
				holder.Visible = (visible ~= false)
			end
			function dividerObj:Get()
				return holder.Visible
			end
			return dividerObj
		end
		contents.Divider = contents.CreateDivider

		contents.ColorPicker = contents.CreateColorPicker
		contents.Paragraph = contents.CreateParagraph

		return contents
	end

	-------------------------------------------------------------------
	-- LOADING SCREEN OVERLAY
	-------------------------------------------------------------------
	local loadingFrame = create("Frame", { Name = "LoadingOverlay", Parent = screenGui, Size = theme.WindowSize, Position = theme.WindowPosition, BorderSizePixel = 0, ZIndex = 10 })
	reg(loadingFrame, "BackgroundColor3", "Background")
	create("UICorner", { Parent = loadingFrame, CornerRadius = theme.CornerRadius })
	
	local loadStroke = create("UIStroke", { Parent = loadingFrame, Thickness = 1, Transparency = theme.WindowStrokeTransparency, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
	reg(loadStroke, "Color", "Accent")

	local loadLogo = create("ImageLabel", { Name = "VoidCoreLogo", Parent = loadingFrame, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 35), Size = UDim2.new(0, 110, 0, 110), Image = "rbxassetid://140071513873333" })
	local loadTitleLbl = create("TextLabel", { Parent = loadingFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 160), Size = UDim2.new(1, 0, 0, 30), Text = loadingTitle, TextSize = 22 })
	reg(loadTitleLbl, "TextColor3", "Text")
	reg(loadTitleLbl, "Font", "FontBold")

	local loadSubLbl = create("TextLabel", { Parent = loadingFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 195), Size = UDim2.new(1, 0, 0, 20), Text = loadingSubtitle, TextSize = 13 })
	reg(loadSubLbl, "TextColor3", "SubText")
	reg(loadSubLbl, "Font", "Font")

	local barBg = create("Frame", { Parent = loadingFrame, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0, 250), Size = UDim2.new(0.7, 0, 0, 4), BorderSizePixel = 0 })
	reg(barBg, "BackgroundColor3", "ElementBg")
	create("UICorner", { Parent = barBg, CornerRadius = UDim.new(1, 0) })

	local barFill = create("Frame", { Parent = barBg, Size = UDim2.new(0, 0, 1, 0), BorderSizePixel = 0 })
	reg(barFill, "BackgroundColor3", "Accent")
	create("UICorner", { Parent = barFill, CornerRadius = UDim.new(1, 0) })

	task.spawn(function()
		while loadingFrame and loadingFrame.Parent do
			local pulseOut = ts:Create(loadLogo, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Size = UDim2.new(0, 116, 0, 116), Position = UDim2.new(0.5, 0, 0, 32) })
			local pulseIn = ts:Create(loadLogo, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Size = UDim2.new(0, 110, 0, 110), Position = UDim2.new(0.5, 0, 0, 35) })
			pulseOut:Play(); pulseOut.Completed:Wait()
			if not loadingFrame or not loadingFrame.Parent then break end
			pulseIn:Play(); pulseIn.Completed:Wait()
		end
	end)

	task.spawn(function()
		local fillTween = ts:Create(barFill, TweenInfo.new(2.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 1, 0) })
		fillTween:Play(); fillTween.Completed:Wait()
		task.wait(0.2)

		main.Visible = true

		local fadeTween = ts:Create(loadingFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1, Size = theme.WindowSize + UDim2.new(0, 40, 0, 40), Position = theme.WindowPosition - UDim2.new(0, 20, 0, 20) })
		ts:Create(loadLogo, TweenInfo.new(0.25), { ImageTransparency = 1 }):Play()
		ts:Create(loadTitleLbl, TweenInfo.new(0.25), { TextTransparency = 1 }):Play()
		ts:Create(loadSubLbl, TweenInfo.new(0.25), { TextTransparency = 1 }):Play()
		ts:Create(barBg, TweenInfo.new(0.25), { BackgroundTransparency = 1 }):Play()
		ts:Create(barFill, TweenInfo.new(0.25), { BackgroundTransparency = 1 }):Play()
		ts:Create(loadStroke, TweenInfo.new(0.25), { Transparency = 1 }):Play()

		fadeTween:Play()
		fadeTween.Completed:Wait()
		loadingFrame:Destroy()
	end)

	return sections
end

return module
