--[[
	VoidLib Theme: glass

	True glassmorphism: the game world is blurred behind the window (Blur = 24),
	all surfaces are highly transparent with a subtle light tint, and thin white
	strokes define every edge. The result looks like a frosted glass panel
	floating in front of the game.

	Blur uses Roblox's BlurEffect in Lighting - it blurs the entire game world,
	not just behind the window, which is exactly how glassmorphism works in
	every other context (you can't blur behind a single element in Roblox).
]]

return {
	-- Fonts
	Font = Enum.Font.GothamMedium,
	FontBold = Enum.Font.GothamBold,

	-- Rounded corners (slightly larger radius for a softer glass look)
	CornerRadius = UDim.new(0, 14),
	ElementRadius = UDim.new(0, 10),

	-- Text (white reads cleanest against a frosted glass surface)
	TextColor = Color3.fromRGB(255, 255, 255),
	SubTextColor = Color3.fromRGB(210, 210, 225),
	PlaceholderColor = Color3.fromRGB(180, 180, 200),

	-- Window — very transparent, slight cool white tint
	Background = Color3.fromRGB(220, 225, 240),
	BackgroundTransparency = 0.35,
	Shadow = Color3.fromRGB(0, 0, 0),
	ShadowTransparency = 0.15,

	-- Blur: the game world behind the entire screen is blurred by this amount.
	-- 0 = no blur, 8 = subtle, 24 = strong frosted glass, 56 = max (Roblox cap).
	Blur = 24,

	-- Topbar — slightly more opaque so it reads as a header
	Topbar = Color3.fromRGB(200, 208, 230),
	TopbarTransparency = 0.35,

	-- Notifications
	NotificationBackground = Color3.fromRGB(220, 225, 240),
	NotificationBackgroundTransparency = 0.65,
	NotificationActionsBackground = Color3.fromRGB(255, 255, 255),

	-- Tabs
	TabBackground = Color3.fromRGB(220, 225, 240),
	TabBackgroundTransparency = 0.40,
	TabBackgroundSelected = Color3.fromRGB(180, 160, 255),
	TabBackgroundSelectedTransparency = 0.50,
	TabStroke = Color3.fromRGB(255, 255, 255),
	TabStrokeTransparency = 0.45,
	TabTextColor = Color3.fromRGB(200, 200, 220),
	SelectedTabTextColor = Color3.fromRGB(255, 255, 255),

	-- General elements
	ElementBackground = Color3.fromRGB(220, 225, 240),
	ElementBackgroundTransparency = 0.35,
	ElementBackgroundHover = Color3.fromRGB(200, 185, 255),
	ElementBackgroundHoverTransparency = 0.45,
	SecondaryElementBackground = Color3.fromRGB(220, 225, 240),
	SecondaryElementBackgroundTransparency = 0.80,
	ElementStroke = Color3.fromRGB(255, 255, 255),
	ElementStrokeTransparency = 0.45,
	SecondaryElementStroke = Color3.fromRGB(255, 255, 255),
	SecondaryElementStrokeTransparency = 0.35,

	-- Accent (soft violet works well with the frosted look)
	Accent = Color3.fromRGB(180, 140, 255),

	-- Slider
	SliderBackground = Color3.fromRGB(200, 185, 255),
	SliderProgress = Color3.fromRGB(180, 140, 255),
	SliderStroke = Color3.fromRGB(255, 255, 255),

	-- Toggle
	ToggleBackground = Color3.fromRGB(220, 225, 240),
	ToggleEnabled = Color3.fromRGB(180, 140, 255),
	ToggleDisabled = Color3.fromRGB(160, 160, 180),
	ToggleEnabledStroke = Color3.fromRGB(210, 180, 255),
	ToggleDisabledStroke = Color3.fromRGB(190, 190, 210),
	ToggleEnabledOuterStroke = Color3.fromRGB(255, 255, 255),
	ToggleDisabledOuterStroke = Color3.fromRGB(220, 220, 235),

	-- Dropdown
	DropdownSelected = Color3.fromRGB(190, 170, 255),
	DropdownUnselected = Color3.fromRGB(220, 225, 240),

	-- Input
	InputBackground = Color3.fromRGB(210, 215, 235),
	InputBackgroundTransparency = 0.35,
	InputStroke = Color3.fromRGB(255, 255, 255),

	-- Strokes
	StrokeTransparency = 0.45,
	StrokeHoverTransparency = 0.15,
	WindowStrokeTransparency = 0.35,

	-- Fallback window size/position
	WindowSize = UDim2.new(0, 550, 0, 350),
	WindowPosition = UDim2.new(0.5, -275, 0.5, -175),

	-- Layout metrics
	TopbarHeight = 40,
	TabBarWidth = 130,
	ElementHeight = 36,
}
