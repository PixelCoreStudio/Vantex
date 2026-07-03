--[[
    Customizable UI Library - Rayfield-Style Update
    Fixed: ToggleUIKeybind dynamic key registration
    Fixed: Independent Loading Screen Overlay (No CanvasGroup bug)
    Added: VoidCore Logo integration on Loading Screen (Asset: 140071513873333)
    Added: Configuration Saving, Discord Invite Prompt & Key System
	Added: Discord fix 1
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

local function checkText(val)
	if type(val) == "table" then
		return tostring(val.Name or val.Text or val[1] or "Unknown")
	end
	return tostring(val or "")
end

function module:win(config)
	config = type(config) == "table" and config or {}
	
	local title = checkText(config.Name or "Custom Interface Suite")
	local loadingTitle = checkText(config.LoadingTitle or title)
	local loadingSubtitle = checkText(config.LoadingSubtitle or "Loading assets...")
	
	-- Theme setup
	local theme = {}
	for k, v in pairs(module.Theme) do theme[k] = v end
	if config.ThemeOverrides then
		for k, v in pairs(config.ThemeOverrides) do theme[k] = v end
	end

	local registry = {}
	local function reg(inst, prop, key)
		inst[prop] = theme[key]
		table.insert(registry, { inst, prop, key })
		return inst
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
	local savedData = {}
	local folderName = cfgSettings.FolderName or "CustomUILogs"
	local fileName = (cfgSettings.FileName or "Big Hub") .. ".json"

	if cfgSettings.Enabled and writefile and readfile and isfolder and makefolder then
		if not isfolder(folderName) then
			makefolder(folderName)
		end
		if isfile(folderName .. "/" .. fileName) then
			pcall(function()
				savedData = hs:JSONDecode(readfile(folderName .. "/" .. fileName))
			end)
		end
	end

	local function saveConfig()
		if cfgSettings.Enabled and writefile then
			pcall(function()
				writefile(folderName .. "/" .. fileName, hs:JSONEncode(savedData))
			end)
		end
	end

	-------------------------------------------------------------------
	-- DISCORD INVITE SYSTEM (Handles Full Links & Raw Codes)
	-------------------------------------------------------------------
	local discordSettings = config.Discord or { Enabled = false }
	if discordSettings.Enabled and discordSettings.Invite and discordSettings.Invite ~= "noinvitelink" then
		local shouldPrompt = true
		if discordSettings.RememberJoins and isfile and readfile then
			if isfile(folderName .. "/discord_joined.txt") then
				shouldPrompt = false
			end
		end

		if shouldPrompt then
			task.spawn(function()
				local rawInput = discordSettings.Invite
				
				-- 1. Reinen Code extrahieren (für die Discord Desktop-App)
				local inviteCode = rawInput:gsub("https://discord.gg/", "")
				inviteCode = inviteCode:gsub("http://discord.gg/", "")
				inviteCode = inviteCode:gsub("discord.gg/", "")
				inviteCode = inviteCode:gsub("https://discord.com/invite/", "")
				inviteCode = inviteCode:gsub("http://discord.com/invite/", "")
				inviteCode = inviteCode:trim() -- Falls Leerzeichen drin sind

				-- 2. Voller Link generieren (für den Browser-Fallback)
				local fullUrl = "https://discord.gg/" .. inviteCode

				local http_request = request or (syn and syn.request) or (http and http.request)
				if http_request then
					-- Methode 1: Direkt über die Discord Desktop-App (RPC)
					local success, _ = pcall(function()
						return http_request({
							Url = "http://127.0.0.1:6463/rpc?v=1",
							Method = "POST",
							Headers = {
								["Content-Type"] = "application/json",
								["Origin"] = "https://discord.com"
							},
							Body = hs:JSONEncode({
								cmd = "INVITE_BROWSER",
								args = { code = inviteCode },
								nonce = hs:GenerateGUID(false)
							})
						})
					end)

					-- Methode 2: Fallback über den Browser, falls RPC fehlschlägt
					if not success then
						pcall(function()
							http_request({
								Url = fullUrl,
								Method = "GET"
							})
						end)
					end

					-- Speichern, um erneuten Prompt zu verhindern
					if discordSettings.RememberJoins and writefile then
						writefile(folderName .. "/discord_joined.txt", "true")
					end
				end
			end)
		end
	end

	-------------------------------------------------------------------
	-- KEY SYSTEM (Wird vor allem anderen ausgeführt)
	-------------------------------------------------------------------
	if config.KeySystem then
		local keySettings = config.KeySettings or {}
		local keyTitle = keySettings.Title or "Untitled"
		local keySubtitle = keySettings.Subtitle or "Key System"
		local keyNote = keySettings.Note or "No method of obtaining the key is provided"
		local keyFileName = (keySettings.FileName or "Key") .. ".txt"
		local validKeys = keySettings.Key or {"Hello"}

		if keySettings.GrabKeyFromSite and keySettings.Key and type(keySettings.Key) == "string" then
			pcall(function()
				local success, res = pcall(game.HttpGet, game, keySettings.Key)
				if success then
					validKeys = {}
					for line in res:gmatch("[^\r\n]+") do
						table.insert(validKeys, line)
					end
				end
			end)
		end

		local keyPassed = false
		if keySettings.SaveKey and isfile and readfile and isfile(folderName .. "/" .. keyFileName) then
			local savedKey = readfile(folderName .. "/" .. keyFileName)
			for _, k in ipairs(validKeys) do
				if savedKey == k then
					keyPassed = true
					break
				end
			end
		end

		if not keyPassed then
			local keyFrame = create("Frame", {
				Name = "KeySystemOverlay",
				Parent = screenGui,
				Size = UDim2.new(0, 350, 0, 240),
				Position = UDim2.new(0.5, -175, 0.5, -120),
				BorderSizePixel = 0,
				ZIndex = 20,
			})
			reg(keyFrame, "BackgroundColor3", "Background")
			create("UICorner", { Parent = keyFrame, CornerRadius = theme.CornerRadius })
			local kStroke = create("UIStroke", { Parent = keyFrame, Thickness = 1, Transparency = theme.WindowStrokeTransparency, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
			reg(kStroke, "Color", "Accent")

			create("TextLabel", { Parent = keyFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 15), Size = UDim2.new(1, 0, 0, 25), Text = keyTitle, TextSize = 18, TextColor3 = theme.Text, Font = theme.FontBold })
			create("TextLabel", { Parent = keyFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 40), Size = UDim2.new(1, 0, 0, 20), Text = keySubtitle, TextSize = 13, TextColor3 = theme.SubText, Font = theme.Font })
			
			local noteLbl = create("TextLabel", { Parent = keyFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 20, 0, 65), Size = UDim2.new(1, -40, 0, 40), Text = keyNote, TextSize = 11, TextColor3 = theme.SubText, Font = theme.Font, TextWrapped = true })
			
			local inputBg = create("Frame", { Parent = keyFrame, Position = UDim2.new(0, 20, 0, 115), Size = UDim2.new(1, -40, 0, 36) })
			reg(inputBg, "BackgroundColor3", "ElementBg")
			create("UICorner", { Parent = inputBg, CornerRadius = theme.ElementRadius })
			
			local keyInput = create("TextBox", { Parent = inputBg, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 10, 0, 0), Text = "", PlaceholderText = "Enter Key...", TextSize = 14, TextColor3 = theme.Text, Font = theme.Font, ClearTextOnFocus = false })
			
			local checkBtn = create("TextButton", { Parent = keyFrame, Position = UDim2.new(0, 20, 0, 170), Size = UDim2.new(1, -40, 0, 36), Text = "Check Key", TextSize = 14, AutoButtonColor = false })
			reg(checkBtn, "BackgroundColor3", "Accent")
			reg(checkBtn, "TextColor3", "Text")
			reg(checkBtn, "Font", "FontBold")
			create("UICorner", { Parent = checkBtn, CornerRadius = theme.ElementRadius })

			checkBtn.MouseButton1Click:Connect(function()
				local text = keyInput.Text
				local match = false
				for _, k in ipairs(validKeys) do
					if text == k then match = true; break end
				end
				if match then
					if keySettings.SaveKey and writefile then
						writefile(folderName .. "/" .. keyFileName, text)
					end
					keyPassed = true
					ts:Create(keyFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1, Size = UDim2.new(0, 370, 0, 260), Position = UDim2.new(0.5, -185, 0.5, -130) }):Play()
					for _, child in ipairs(keyFrame:GetChildren()) do
						if child:IsA("TextLabel") or child:IsA("Frame") or child:IsA("TextButton") then
							ts:Create(child, TweenInfo.new(0.2), { Transparency = 1 }):Play()
						end
					end
					task.wait(0.3)
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
	end

	-------------------------------------------------------------------
	-- MAIN UI WINDOW (Startet unsichtbar hinter dem Ladebildschirm)
	-------------------------------------------------------------------
	local main = create("Frame", {
		Name = "Frame",
		Parent = screenGui,
		Size = theme.WindowSize,
		Position = theme.WindowPosition,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Visible = false,
	})
	reg(main, "BackgroundColor3", "Background")
	create("UICorner", { Parent = main, CornerRadius = theme.CornerRadius })

	local mainStroke = create("UIStroke", {
		Parent = main,
		Thickness = 1,
		Transparency = theme.WindowStrokeTransparency,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
	reg(mainStroke, "Color", "Accent")

	local topbar = create("Frame", {
		Name = "topbar",
		Parent = main,
		Size = UDim2.new(1, 0, 0, theme.TopbarHeight),
		BackgroundTransparency = theme.PanelTransparency,
		BorderSizePixel = 0,
	})
	reg(topbar, "BackgroundColor3", "Topbar")
	create("UICorner", { Parent = topbar, CornerRadius = theme.CornerRadius })

	local topbarLine = create("Frame", {
		Name = "accentline",
		Parent = topbar,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 1),
		BorderSizePixel = 0,
		BackgroundTransparency = 0.55,
	})
	reg(topbarLine, "BackgroundColor3", "Accent")

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

	-- Dynamic Toggle Key registration[cite: 1]
	local toggleKey = Enum.KeyCode.K
	if config.ToggleUIKeybind then
		if typeof(config.ToggleUIKeybind) == "EnumItem" then
			toggleKey = config.ToggleUIKeybind
		elseif type(config.ToggleUIKeybind) == "string" and #config.ToggleUIKeybind == 1 then
			pcall(function()
				toggleKey = Enum.KeyCode[config.ToggleUIKeybind:upper()]
			end)
		end
	end

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
		reg(btn, "BackgroundColor3", "ElementBg")
		create("UICorner", { Parent = btn, CornerRadius = UDim.new(0, 6) })

		btn.MouseEnter:Connect(function()
			ts:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = theme.ElementHoverTransparency }):Play()
			ts:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { TextColor3 = theme.Accent }):Play()
		end)
		btn.MouseLeave:Connect(function()
			ts:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()
			ts:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { TextColor3 = theme.SubText }):Play()
		end)
		return btn
	end

	local minimizeBtn = makeTopbarBtn("-")
	local closeBtn = makeTopbarBtn("X")

	local uiVisible = true
	local function setOpen(isOpen)
		uiVisible = isOpen
		main.Visible = uiVisible
	end

	minimizeBtn.MouseButton1Click:Connect(function()
		setOpen(false)
	end)

	local toggleKeyConn = ui.InputBegan:Connect(function(input, processed)
		if not processed and input.KeyCode == toggleKey then
			setOpen(not main.Visible)
		end
	end)

	closeBtn.MouseButton1Click:Connect(function()
		toggleKeyConn:Disconnect()
		screenGui:Destroy()
	end)

	do
		local dragging, dragInput, mousePos, framePos
		topbar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				mousePos = input.Position
				framePos = main.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then dragging = false end
				end)
			end
		end)
		topbar.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end)
		ui.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				local delta = input.Position - mousePos
				main.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
			end
		end)
	end

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
		BackgroundTransparency = theme.PanelTransparency,
		Size = UDim2.new(0, theme.TabBarWidth, 1, 0),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3,
	})
	reg(tabBar, "BackgroundColor3", "TabBar")
	reg(tabBar, "ScrollBarImageColor3", "Accent")
	create("UIListLayout", { Parent = tabBar, Padding = UDim.new(0, 4) })
	create("UIPadding", { Parent = tabBar, PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) })

	local sectionsHolder = create("Frame", {
		Name = "sectionsholder",
		Parent = body,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, theme.TabBarWidth, 0, 0),
		Size = UDim2.new(1, -theme.TabBarWidth, 1, 0),
		ClipsDescendants = true,
	})

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
		
		local btn = create("TextButton", {
			Parent = tabBar,
			Size = UDim2.new(1, 0, 0, 32),
			BackgroundTransparency = 1,
			AutoButtonColor = false,
			Text = "",
		})
		reg(btn, "BackgroundColor3", "ElementBg")
		create("UICorner", { Parent = btn, CornerRadius = theme.ElementRadius })

		local glow = create("UIStroke", {
			Name = "glow",
			Parent = btn,
			Thickness = 1,
			Transparency = theme.StrokeTransparency,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		})
		reg(glow, "Color", "Accent")

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
		create("UICorner", { Parent = indicator, CornerRadius = UDim.new(1, 0) })

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
				ts:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = theme.ElementTransparency }):Play()
				ts:Create(glow, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Transparency = theme.StrokeHoverTransparency }):Play()
			end
		end)
		btn.MouseLeave:Connect(function()
			if curBtn ~= btn then
				ts:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()
				ts:Create(glow, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Transparency = theme.StrokeTransparency }):Play()
			end
		end)

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
		create("UIListLayout", { Parent = section, Padding = UDim.new(0, 6) })
		create("UIPadding", { Parent = section, PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) })

		btn.MouseButton1Click:Connect(function() setSelectedTab(btn, section) end)
		if not curBtn then setSelectedTab(btn, section) end

		local contents = {}

		function contents:label(text)
			text = checkText(text)
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
			text = checkText(text)
			local btnEl = create("TextButton", {
				Parent = section,
				Size = UDim2.new(1, 0, 0, theme.ElementHeight),
				BackgroundTransparency = theme.ElementTransparency,
				AutoButtonColor = false,
				Text = text,
				TextSize = 13,
			})
			reg(btnEl, "BackgroundColor3", "ElementBg")
			reg(btnEl, "TextColor3", "Text")
			reg(btnEl, "Font", "Font")
			create("UICorner", { Parent = btnEl, CornerRadius = theme.ElementRadius })

			local glow = create("UIStroke", {
				Parent = btnEl,
				Thickness = 1,
				Transparency = theme.StrokeTransparency,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			})
			reg(glow, "Color", "Accent")

			btnEl.MouseEnter:Connect(function()
				ts:Create(btnEl, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = theme.ElementHoverTransparency }):Play()
				ts:Create(glow, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Transparency = theme.StrokeHoverTransparency }):Play()
			end)
			btnEl.MouseLeave:Connect(function()
				ts:Create(btnEl, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = theme.ElementTransparency }):Play()
				ts:Create(glow, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Transparency = theme.StrokeTransparency }):Play()
			end)
			btnEl.MouseButton1Click:Connect(cb)
			return btnEl
		end

		function contents:toggle(text, id, default, cb)
			text = checkText(text)
			id = tostring(id or text)
			if type(default) == "function" then cb = default; default = false end
			
			local toggled = default and true or false
			if savedData[id] ~= nil then toggled = savedData[id] end

			local holder = create("TextButton", {
				Parent = section,
				Size = UDim2.new(1, 0, 0, theme.ElementHeight),
				BackgroundTransparency = theme.ElementTransparency,
				AutoButtonColor = false,
				Text = "",
			})
			reg(holder, "BackgroundColor3", "ElementBg")
			create("UICorner", { Parent = holder, CornerRadius = theme.ElementRadius })

			local hoverGlow = create("UIStroke", {
				Parent = holder,
				Thickness = 1,
				Transparency = theme.StrokeTransparency,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			})
			reg(hoverGlow, "Color", "Accent")

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
			create("UICorner", { Parent = track, CornerRadius = UDim.new(1, 0) })

			local trackGlow = create("UIStroke", { Parent = track, Thickness = 1, Transparency = 0.6, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
			reg(trackGlow, "Color", "Accent")

			local knob = create("Frame", {
				Parent = track,
				AnchorPoint = toggled and Vector2.new(1, 0.5) or Vector2.new(0, 0.5),
				Position = toggled and UDim2.new(1, -2, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
				Size = UDim2.new(0, 16, 0, 16),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BorderSizePixel = 0,
			})
			create("UICorner", { Parent = knob, CornerRadius = UDim.new(1, 0) })

			local function applyVisual(animated)
				local goalColor = toggled and theme.ToggleOn or theme.ToggleOff
				local goalGlow = toggled and 0.15 or 0.85
				local goalPos = toggled and UDim2.new(1, -2, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
				local goalAnchor = toggled and Vector2.new(1, 0.5) or Vector2.new(0, 0.5)
				if animated then
					ts:Create(track, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundColor3 = goalColor }):Play()
					ts:Create(trackGlow, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Transparency = goalGlow }):Play()
					ts:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = goalPos }):Play()
				else
					track.BackgroundColor3 = goalColor
					trackGlow.Transparency = goalGlow
					knob.Position = goalPos
				end
				knob.AnchorPoint = goalAnchor
			end
			applyVisual(false)

			holder.MouseEnter:Connect(function()
				ts:Create(holder, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = theme.ElementHoverTransparency }):Play()
				ts:Create(hoverGlow, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Transparency = theme.StrokeHoverTransparency }):Play()
			end)
			holder.MouseLeave:Connect(function()
				ts:Create(holder, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = theme.ElementTransparency }):Play()
				ts:Create(hoverGlow, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Transparency = theme.StrokeTransparency }):Play()
			end)

			holder.MouseButton1Click:Connect(function()
				toggled = not toggled
				savedData[id] = toggled
				saveConfig()
				applyVisual(true)
				if cb then cb(toggled) end
			end)

			if cb then task.defer(cb, toggled) end
			return holder
		end

		function contents:textbox(text, id, default, cb)
			text = checkText(text)
			id = tostring(id or text)
			if type(default) == "function" then cb = default; default = "" end
			
			local currentText = checkText(default)
			if savedData[id] ~= nil then currentText = tostring(savedData[id]) end

			local holder = create("Frame", {
				Parent = section,
				Size = UDim2.new(1, 0, 0, theme.ElementHeight),
				BackgroundTransparency = theme.ElementTransparency,
			})
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

			local input = create("TextBox", { Parent = inputBg, BackgroundTransparency = 1, Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 5, 0, 0), Text = currentText, PlaceholderText = "...", TextSize = 13, ClearTextOnFocus = false })
			reg(input, "TextColor3", "Text")
			reg(input, "Font", "Font")

			input.Focused:Connect(function()
				ts:Create(focusGlow, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Transparency = theme.StrokeHoverTransparency }):Play()
			end)

			if cb then task.defer(cb, currentText) end

			input.FocusLost:Connect(function(enterPressed)
				ts:Create(focusGlow, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Transparency = theme.StrokeTransparency }):Play()
				savedData[id] = input.Text
				saveConfig()
				if cb then cb(input.Text) end
			end)

			return holder
		end

        function contents:slider(text, id, min, max, default, cb)
            text = checkText(text)
            id = tostring(id or text)
            
            -- Typsicherungen, falls Parameter vertauscht wurden
            min = tonumber(min) or 0
            max = tonumber(max) or 100
            if type(default) == "function" then 
                cb = default 
                default = min 
            end
            default = tonumber(default) or min
        
            local valStart = default
            if savedData[id] ~= nil then valStart = tonumber(savedData[id]) or default end
        
            local holder = create("Frame", { Parent = section, Size = UDim2.new(1, 0, 0, theme.ElementHeight + 14), BackgroundTransparency = theme.ElementTransparency })
            reg(holder, "BackgroundColor3", "ElementBg")
            create("UICorner", { Parent = holder, CornerRadius = theme.ElementRadius })
        
            local lbl = create("TextLabel", { Parent = holder, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 4), Size = UDim2.new(1, -24, 0, 18), Text = text .. " : " .. tostring(valStart), TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left })
            reg(lbl, "TextColor3", "Text")
            reg(lbl, "Font", "Font")
        
            local track = create("Frame", { Parent = holder, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 28), Size = UDim2.new(1, -24, 0, 6), BorderSizePixel = 0 })
            reg(track, "BackgroundColor3", "ElementHoverBg")
            create("UICorner", { Parent = track, CornerRadius = UDim.new(1, 0) })
        
            local fill = create("Frame", { Parent = track, Size = UDim2.new(0, 0, 1, 0), BorderSizePixel = 0 })
            reg(fill, "BackgroundColor3", "Accent")
            create("UICorner", { Parent = fill, CornerRadius = UDim.new(1, 0) })
        
            local dragging = false
            local lastVal = valStart
        
            local function setFromAlpha(alpha)
                alpha = math.clamp(alpha, 0, 1)
                local value = math.floor(min + (max - min) * alpha + 0.5)
                
                -- Verhindert Division durch Null, falls min == max
                local denom = (max - min)
                local scaleX = denom > 0 and ((value - min) / denom) or 0
                
                fill.Size = UDim2.new(scaleX, 0, 1, 0)
                lastVal = value
                lbl.Text = text .. " : " .. tostring(value)
            end
        
            local function updateFromInput(x)
                if track.AbsoluteSize.X > 0 then
                    local rel = (x - track.AbsolutePosition.X) / track.AbsoluteSize.X
                    setFromAlpha(rel)
                end
            end
        
            local denom = (max - min)
            setFromAlpha(denom > 0 and ((valStart - min) / denom) or 0)
        
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
                    savedData[id] = lastVal
                    saveConfig()
                    if cb then pcall(cb, lastVal) end
                end
            end)
        
            if cb then task.defer(cb, lastVal) end
            return holder
        end

		function contents:dropdown(text, id, list, default, cb)
			text = checkText(text)
			id = tostring(id or text)
			list = type(list) == "table" and list or {}
			if type(default) == "function" then cb = default; default = nil end

			local open = false
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
					local opt = create("TextButton", { Parent = container, Size = UDim2.new(1, 0, 0, theme.ElementHeight - 6), BackgroundTransparency = theme.ElementTransparency, BackgroundColor3 = theme.ElementHoverBg, Text = optionStr, TextSize = 12, AutoButtonColor = false })
					reg(opt, "TextColor3", "Text")
					reg(opt, "Font", "Font")
					create("UICorner", { Parent = opt, CornerRadius = UDim.new(0, 4) })

					opt.MouseButton1Click:Connect(function()
						currentSelected = val
						selectedLbl.Text = optionStr
						open = false
						savedData[id] = val
						saveConfig()
						ts:Create(holder, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, theme.ElementHeight) }):Play()
						ts:Create(container, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = UDim2.new(1, -12, 0, 0) }):Play()
						indicator.Text = "V"
						if cb then cb(val) end
					end)
				end
			end

			function contents:keybind(text, id, default, cb)
			    text = checkText(text)
			    id = tostring(id or text)
                
			    local currentKey = default
			    if typeof(currentKey) == "EnumItem" then
			    	currentKey = currentKey.Name
			    elseif type(currentKey) ~= "string" then
			    	currentKey = "None"
			    end

			    if savedData[id] ~= nil then currentKey = tostring(savedData[id]) end

			    local holder = create("Frame", {
			    	Parent = section,
			    	Size = UDim2.new(1, 0, 0, theme.ElementHeight),
			    	BackgroundTransparency = theme.ElementTransparency,
			    })
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

			    local inputConn
			    inputConn = ui.InputBegan:Connect(function(input, processed)
			    	if not screenGui or not screenGui.Parent then
			    		inputConn:Disconnect()
			    		return
			    	end
                
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
			    			if cb then pcall(cb) end
			    		end
			    	end
			    end)

			    -- Initialer Trigger beim Starten, falls geladen
			    if cb and currentKey ~= "None" then
			    	-- Falls du beim Laden direkt triggern willst, hier aktivieren
			    end

			    return holder
		    end
			
			updateOptions()

			trigger.MouseButton1Click:Connect(function()
				open = not open
				local maxItems = math.min(#list, 4)
				local targetContainerHeight = maxItems * (theme.ElementHeight - 2)
				ts:Create(holder, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = open and UDim2.new(1, 0, 0, theme.ElementHeight + targetContainerHeight + 6) or UDim2.new(1, 0, 0, theme.ElementHeight) }):Play()
				ts:Create(container, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = open and UDim2.new(1, -12, 0, targetContainerHeight) or UDim2.new(1, -12, 0, 0) }):Play()
				indicator.Text = open and "^" or "V"
			end)

			if cb then task.defer(cb, currentSelected) end
			return { Refresh = function(_, nl, nd) list = nl or {}; if nd then currentSelected = nd; selectedLbl.Text = tostring(nd) end; updateOptions() end }
		end

		return contents
	end

	-------------------------------------------------------------------
	-- SEPARATER SEITENÜBERGREIFENDER LOADING SCREEN OVERLAY (With Logo)
	-------------------------------------------------------------------
	local loadingFrame = create("Frame", {
		Name = "LoadingOverlay",
		Parent = screenGui,
		Size = theme.WindowSize,
		Position = theme.WindowPosition,
		BorderSizePixel = 0,
		ZIndex = 10,
	})
	reg(loadingFrame, "BackgroundColor3", "Background")
	create("UICorner", { Parent = loadingFrame, CornerRadius = theme.CornerRadius })
	
	local loadStroke = create("UIStroke", { Parent = loadingFrame, Thickness = 1, Transparency = theme.WindowStrokeTransparency, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
	reg(loadStroke, "Color", "Accent")

	-- BRANDING LOGO (Neue Asset-ID)
	local loadLogo = create("ImageLabel", {
		Name = "VoidCoreLogo",
		Parent = loadingFrame,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 35),
		Size = UDim2.new(0, 110, 0, 110),
		Image = "rbxassetid://140071513873333",
	})

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

	-- Logo Pulsieren-Effekt
	task.spawn(function()
		while loadingFrame and loadingFrame.Parent do
			local pulseOut = ts:Create(loadLogo, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Size = UDim2.new(0, 116, 0, 116), Position = UDim2.new(0.5, 0, 0, 32) })
			local pulseIn = ts:Create(loadLogo, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Size = UDim2.new(0, 110, 0, 110), Position = UDim2.new(0.5, 0, 0, 35) })
			pulseOut:Play()
			pulseOut.Completed:Wait()
			if not loadingFrame or not loadingFrame.Parent then break end
			pulseIn:Play()
			pulseIn.Completed:Wait()
		end
	end)

	-- Loading Animation
	task.spawn(function()
		local fillTween = ts:Create(barFill, TweenInfo.new(2.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 1, 0) })
		fillTween:Play()
		fillTween.Completed:Wait()
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
