--[[
	VoidLib Theme: light

	A light/white-mode theme, meant to contrast with the dark "default" theme.
	Same field structure as themes/default.lua - only the colors changed.
]]

return {
	-- Fonts
	Font = Enum.Font.GothamMedium,
	FontBold = Enum.Font.GothamBold,

	-- Corner rounding
	CornerRadius = UDim.new(0, 8),
	ElementRadius = UDim.new(0, 8),

	-- Text
	TextColor = Color3.fromRGB(20, 20, 25),
	SubTextColor = Color3.fromRGB(100, 100, 110),
	PlaceholderColor = Color3.fromRGB(150, 150, 158),

	-- Window
	Background = Color3.fromRGB(245, 245, 248),
	BackgroundTransparency = 0,
	Shadow = Color3.fromRGB(0, 0, 0),
	ShadowTransparency = 0.85,

	-- Topbar
	Topbar = Color3.fromRGB(255, 255, 255),
	TopbarTransparency = 0,

	-- Notifications
	NotificationBackground = Color3.fromRGB(255, 255, 255),
	NotificationBackgroundTransparency = 0.05,
	NotificationActionsBackground = Color3.fromRGB(230, 230, 230),

	-- Tabs
	TabBackground = Color3.fromRGB(255, 255, 255),
	TabBackgroundTransparency = 0,
	TabBackgroundSelected = Color3.fromRGB(233, 230, 240),
	TabBackgroundSelectedTransparency = 0,
	TabStroke = Color3.fromRGB(124, 58, 237),
	TabStrokeTransparency = 0.85,
	TabTextColor = Color3.fromRGB(100, 100, 110),
	SelectedTabTextColor = Color3.fromRGB(20, 20, 25),

	-- General elements
	ElementBackground = Color3.fromRGB(255, 255, 255),
	ElementBackgroundTransparency = 0.0,
	ElementBackgroundHover = Color3.fromRGB(233, 230, 240),
	ElementBackgroundHoverTransparency = 0.0,
	SecondaryElementBackground = Color3.fromRGB(255, 255, 255),
	SecondaryElementBackgroundTransparency = 0.0,
	ElementStroke = Color3.fromRGB(124, 58, 237),
	ElementStrokeTransparency = 0.85,
	SecondaryElementStroke = Color3.fromRGB(124, 58, 237),
	SecondaryElementStrokeTransparency = 0.75,

	-- Accent
	Accent = Color3.fromRGB(124, 58, 237),

	-- Slider
	SliderBackground = Color3.fromRGB(225, 222, 232),
	SliderProgress = Color3.fromRGB(124, 58, 237),
	SliderStroke = Color3.fromRGB(124, 58, 237),

	-- Toggle
	ToggleBackground = Color3.fromRGB(255, 255, 255),
	ToggleEnabled = Color3.fromRGB(124, 58, 237),
	ToggleDisabled = Color3.fromRGB(210, 210, 218),
	ToggleEnabledStroke = Color3.fromRGB(124, 58, 237),
	ToggleDisabledStroke = Color3.fromRGB(190, 190, 198),
	ToggleEnabledOuterStroke = Color3.fromRGB(124, 58, 237),
	ToggleDisabledOuterStroke = Color3.fromRGB(210, 210, 218),

	-- Dropdown
	DropdownSelected = Color3.fromRGB(233, 230, 240),
	DropdownUnselected = Color3.fromRGB(255, 255, 255),

	-- Input
	InputBackground = Color3.fromRGB(255, 255, 255),
	InputBackgroundTransparency = 0,
	InputStroke = Color3.fromRGB(124, 58, 237),

	-- General stroke transparencies
	StrokeTransparency = 0.85,
	StrokeHoverTransparency = 0.35,
	WindowStrokeTransparency = 0.75,

	-- Fallback window size/position
	WindowSize = UDim2.new(0, 550, 0, 350),
	WindowPosition = UDim2.new(0.5, -275, 0.5, -175),

	-- Layout metrics
	TopbarHeight = 40,
	TabBarWidth = 130,
	ElementHeight = 36,
}
