--[[
	VoidLib Theme: glass

	A glassmorphism theme: everything is semi-transparent with visible strokes,
	creating a "frosted glass" effect that lets the game world bleed through.
	Best used when the game background has interesting colors or scenery.

	Key techniques demonstrated here:
	- High BackgroundTransparency on every surface (0.4 – 0.75)
	- Visible strokes with low transparency to define edges clearly
	- Subtle white/light tint on backgrounds (so glass reads as glass, not void)
	- Soft shadow with very high transparency (near-invisible, just a hint of depth)
]]

return {
	-- Fonts
	Font = Enum.Font.GothamMedium,
	FontBold = Enum.Font.GothamBold,

	-- Corner rounding (slightly larger for the glass look)
	CornerRadius = UDim.new(0, 12),
	ElementRadius = UDim.new(0, 10),

	-- Text
	TextColor = Color3.fromRGB(255, 255, 255),
	SubTextColor = Color3.fromRGB(200, 200, 215),
	PlaceholderColor = Color3.fromRGB(170, 170, 190),

	-- Window — semi-transparent white tint
	Background = Color3.fromRGB(200, 200, 220),
	BackgroundTransparency = 0.65,
	Shadow = Color3.fromRGB(0, 0, 0),
	ShadowTransparency = 0.85,

	-- Topbar — slightly less transparent than the body so it reads as a header
	Topbar = Color3.fromRGB(180, 180, 210),
	TopbarTransparency = 0.55,

	-- Notifications — same glass treatment
	NotificationBackground = Color3.fromRGB(200, 200, 220),
	NotificationBackgroundTransparency = 0.55,
	NotificationActionsBackground = Color3.fromRGB(240, 240, 255),

	-- Tabs
	TabBackground = Color3.fromRGB(200, 200, 220),
	TabBackgroundTransparency = 0.70,
	TabBackgroundSelected = Color3.fromRGB(160, 130, 255),
	TabBackgroundSelectedTransparency = 0.45,
	TabStroke = Color3.fromRGB(255, 255, 255),
	TabStrokeTransparency = 0.60,
	TabTextColor = Color3.fromRGB(200, 200, 215),
	SelectedTabTextColor = Color3.fromRGB(255, 255, 255),

	-- General elements
	ElementBackground = Color3.fromRGB(210, 210, 230),
	ElementBackgroundTransparency = 0.72,
	ElementBackgroundHover = Color3.fromRGB(200, 185, 255),
	ElementBackgroundHoverTransparency = 0.60,
	SecondaryElementBackground = Color3.fromRGB(210, 210, 230),
	SecondaryElementBackgroundTransparency = 0.75,
	ElementStroke = Color3.fromRGB(255, 255, 255),
	ElementStrokeTransparency = 0.55,
	SecondaryElementStroke = Color3.fromRGB(255, 255, 255),
	SecondaryElementStrokeTransparency = 0.70,

	-- Accent
	Accent = Color3.fromRGB(170, 130, 255),

	-- Slider
	SliderBackground = Color3.fromRGB(200, 185, 255),
	SliderProgress = Color3.fromRGB(170, 130, 255),
	SliderStroke = Color3.fromRGB(255, 255, 255),

	-- Toggle
	ToggleBackground = Color3.fromRGB(210, 210, 230),
	ToggleEnabled = Color3.fromRGB(170, 130, 255),
	ToggleDisabled = Color3.fromRGB(150, 145, 170),
	ToggleEnabledStroke = Color3.fromRGB(200, 170, 255),
	ToggleDisabledStroke = Color3.fromRGB(180, 175, 195),
	ToggleEnabledOuterStroke = Color3.fromRGB(255, 255, 255),
	ToggleDisabledOuterStroke = Color3.fromRGB(200, 200, 215),

	-- Dropdown
	DropdownSelected = Color3.fromRGB(180, 155, 255),
	DropdownUnselected = Color3.fromRGB(210, 210, 230),

	-- Input
	InputBackground = Color3.fromRGB(215, 210, 235),
	InputBackgroundTransparency = 0.65,
	InputStroke = Color3.fromRGB(255, 255, 255),

	-- General stroke transparencies
	StrokeTransparency = 0.55,
	StrokeHoverTransparency = 0.20,
	WindowStrokeTransparency = 0.40,

	-- Fallback window size/position
	WindowSize = UDim2.new(0, 550, 0, 350),
	WindowPosition = UDim2.new(0.5, -275, 0.5, -175),

	-- Layout metrics
	TopbarHeight = 40,
	TabBarWidth = 130,
	ElementHeight = 36,
}
