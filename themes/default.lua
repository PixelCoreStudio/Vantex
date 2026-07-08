--[[
	VoidLib Theme: default

	This is the base theme VoidLib ships with. Use it as a template for your own
	themes: copy this file, rename it (e.g. "dark.lua", "ocean.lua"), and change
	whatever values you want. You don't have to include every field in a custom
	theme - anything you leave out just keeps its default value.

	Every surface has its own COLOR and, where it makes sense, its own
	TRANSPARENCY field, so you have full freedom - including things like
	glassmorphism (very transparent backgrounds + visible strokes).

	HOW THEMES ARE LOADED:
	1. Put this file (and any others you make) in the "themes" folder of the
	   repo your THEMES_FOLDER constant (near the top of VoidLib.lua) points to.
	2. In VoidLib:win({...}), set:
	     Theme = "default"   -- matches this file's name (no ".lua")
	3. To skip this system entirely and set colors yourself, either leave `Theme`
	   unset or set `Theme = "Custom"`, and use `ThemeOverrides = { ... }` instead.

	Note: ThemeOverrides in VoidLib:win({...}) is always applied on top of whatever
	theme you load here, so you can load a named theme AND still tweak a couple of
	individual fields on top of it if you want.
]]

return {
	-- Fonts
	Font = Enum.Font.GothamMedium,
	FontBold = Enum.Font.GothamBold,

	-- Corner rounding
	CornerRadius = UDim.new(0, 8),
	ElementRadius = UDim.new(0, 8),

	-- Text
	TextColor = Color3.fromRGB(255, 255, 255),
	SubTextColor = Color3.fromRGB(143, 143, 143),
	PlaceholderColor = Color3.fromRGB(143, 143, 143),

	-- Window
	Background = Color3.fromRGB(11, 11, 14),
	BackgroundTransparency = 0,
	Shadow = Color3.fromRGB(0, 0, 0),
	ShadowTransparency = 0.5,

	-- Topbar
	Topbar = Color3.fromRGB(26, 26, 46),
	TopbarTransparency = 0,

	-- Notifications
	NotificationBackground = Color3.fromRGB(11, 11, 14),
	NotificationBackgroundTransparency = 0.30,
	NotificationActionsBackground = Color3.fromRGB(230, 230, 230),

	-- Tabs
	TabBackground = Color3.fromRGB(26, 26, 46),
	TabBackgroundTransparency = 0,
	TabBackgroundSelected = Color3.fromRGB(42, 33, 64),
	TabBackgroundSelectedTransparency = 0,
	TabStroke = Color3.fromRGB(160, 32, 240),
	TabStrokeTransparency = 1,
	TabTextColor = Color3.fromRGB(143, 143, 143),
	SelectedTabTextColor = Color3.fromRGB(255, 255, 255),

	-- General elements (buttons, labels, paragraphs, color picker frame, etc.)
	ElementBackground = Color3.fromRGB(26, 26, 46),
	ElementBackgroundTransparency = 0.35,
	ElementBackgroundHover = Color3.fromRGB(42, 33, 64),
	ElementBackgroundHoverTransparency = 0.08,
	SecondaryElementBackground = Color3.fromRGB(26, 26, 46),
	SecondaryElementBackgroundTransparency = 0.35,
	ElementStroke = Color3.fromRGB(160, 32, 240),
	ElementStrokeTransparency = 1,
	SecondaryElementStroke = Color3.fromRGB(160, 32, 240),
	SecondaryElementStrokeTransparency = 0.35,

	-- Accent (highlights, active states, indicators, drag handles, etc.)
	Accent = Color3.fromRGB(160, 32, 240),

	-- Slider
	SliderBackground = Color3.fromRGB(42, 33, 64),
	SliderProgress = Color3.fromRGB(160, 32, 240),
	SliderStroke = Color3.fromRGB(160, 32, 240),

	-- Toggle
	ToggleBackground = Color3.fromRGB(50, 50, 64),
	ToggleEnabled = Color3.fromRGB(160, 32, 240),
	ToggleDisabled = Color3.fromRGB(100, 100, 100),
	ToggleEnabledStroke = Color3.fromRGB(160, 32, 240),
	ToggleDisabledStroke = Color3.fromRGB(125, 125, 125),
	ToggleEnabledOuterStroke = Color3.fromRGB(100, 100, 100),
	ToggleDisabledOuterStroke = Color3.fromRGB(65, 65, 65),

	-- Dropdown
	DropdownSelected = Color3.fromRGB(42, 33, 64),
	DropdownUnselected = Color3.fromRGB(26, 26, 46),

	-- Input (textbox, keybind capture button)
	InputBackground = Color3.fromRGB(42, 33, 64),
	InputBackgroundTransparency = 0,
	InputStroke = Color3.fromRGB(160, 32, 240),

	-- General stroke transparencies (used as fallback/behavioral transparencies, not surface colors)
	StrokeTransparency = 1,
	StrokeHoverTransparency = 0.35,
	WindowStrokeTransparency = 0.45,

	-- Fallback window size/position (only used if you don't set WindowSize in
	-- VoidLib:win({...}), or if you explicitly set WindowPosition here and want
	-- it respected instead of automatic centering)
	WindowSize = UDim2.new(0, 550, 0, 350),
	WindowPosition = UDim2.new(0.5, -275, 0.5, -175),

	-- Layout metrics
	TopbarHeight = 40,
	TabBarWidth = 130,
	ElementHeight = 36,
}
