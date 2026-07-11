--[[
	VoidLib Theme: light

	A light/white-mode theme, meant to contrast with the dark "default" theme.
	Same structure as themes/default.lua - only the colors changed. Drop this
	file in your "themes" folder as "light.lua" and load it with:

		VoidLib:win({ Theme = "light" })
]]

return {
	-- Fonts
	Font = Enum.Font.GothamMedium,
	FontBold = Enum.Font.GothamBold,

	-- Corner rounding
	CornerRadius = UDim.new(0, 8),
	ElementRadius = UDim.new(0, 8),

	-- Core colors
	Background = Color3.fromRGB(245, 245, 248),
	Topbar = Color3.fromRGB(255, 255, 255),
	TabBar = Color3.fromRGB(255, 255, 255),
	ElementBg = Color3.fromRGB(255, 255, 255),
	ElementHoverBg = Color3.fromRGB(233, 230, 240),

	-- Text colors
	Text = Color3.fromRGB(20, 20, 25),
	SubText = Color3.fromRGB(100, 100, 110),

	-- Accent / toggle colors
	Accent = Color3.fromRGB(124, 58, 237), -- violet, keeps the same "personality" as default but works on light bg
	ToggleOn = Color3.fromRGB(124, 58, 237),
	ToggleOff = Color3.fromRGB(210, 210, 218),

	-- Transparencies (0 = fully opaque, 1 = fully invisible)
	PanelTransparency = 0.05,
	ElementTransparency = 0.0,
	ElementHoverTransparency = 0.0,
	StrokeTransparency = 0.85,
	StrokeHoverTransparency = 0.35,
	WindowStrokeTransparency = 0.75,

	-- Blur (0 = disabled)
	Blur = 0,

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
