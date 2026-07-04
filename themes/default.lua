--[[
	VoidLib Theme: default

	This is the base theme VoidLib ships with. Use it as a template for your own
	themes: copy this file, rename it (e.g. "dark.lua", "ocean.lua"), and change
	whatever values you want. You don't have to include every field in a custom
	theme - anything you leave out just keeps its default value.

	HOW THEMES ARE LOADED:
	1. Put this file (and any others you make) in a "themes" folder in your GitHub repo.
	2. In VoidLib:win({...}), set:
	     Theme = "default"                       -- matches this file's name (no ".lua")
	     ThemesFolder = "https://raw.githubusercontent.com/YOUR-USER/YOUR-REPO/refs/heads/main/themes/"
	3. To skip this system entirely and set colors yourself, either leave `Theme`
	   unset or set `Theme = "Custom"`, and use `ThemeOverrides = { ... }` instead
	   (see the VoidLib documentation, chapter 9).

	Note: ThemeOverrides in VoidLib:win({...}) is always applied on top of whatever
	theme you load here, so you can load a named theme AND still tweak a couple of
	individual colors on top of it if you want.
]]

return {
	-- Fonts
	Font = Enum.Font.GothamMedium,
	FontBold = Enum.Font.GothamBold,

	-- Corner rounding
	CornerRadius = UDim.new(0, 8),
	ElementRadius = UDim.new(0, 8),

	-- Core colors
	Background = Color3.fromRGB(11, 11, 14),
	Topbar = Color3.fromRGB(26, 26, 46),
	TabBar = Color3.fromRGB(26, 26, 46),
	ElementBg = Color3.fromRGB(26, 26, 46),
	ElementHoverBg = Color3.fromRGB(42, 33, 64),

	-- Text colors
	Text = Color3.fromRGB(255, 255, 255),
	SubText = Color3.fromRGB(143, 143, 143),

	-- Accent / toggle colors
	Accent = Color3.fromRGB(160, 32, 240),
	ToggleOn = Color3.fromRGB(160, 32, 240),
	ToggleOff = Color3.fromRGB(50, 50, 64),

	-- Transparencies (0 = fully opaque, 1 = fully invisible)
	PanelTransparency = 0.30,
	ElementTransparency = 0.35,
	ElementHoverTransparency = 0.08,
	StrokeTransparency = 1,
	StrokeHoverTransparency = 0.35,
	WindowStrokeTransparency = 0.45,

	-- Fallback window size/position (only used if you don't set WindowSize
	-- in VoidLib:win({...}), or if you explicitly set WindowPosition here
	-- and want it respected instead of automatic centering)
	WindowSize = UDim2.new(0, 550, 0, 350),
	WindowPosition = UDim2.new(0.5, -275, 0.5, -175),

	-- Layout metrics
	TopbarHeight = 40,
	TabBarWidth = 130,
	ElementHeight = 36,
}
