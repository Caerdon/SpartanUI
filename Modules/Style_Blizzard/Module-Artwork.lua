local _G, SUI = _G, SUI
local Artwork_Core = SUI:GetModule('Artwork_Core')
local module = SUI:GetModule('Style_Blizzard')
----------------------------------------------------------------------------------------------------
module.Trays = {}
local CurScale
local petbattle = CreateFrame('Frame')

-- Misc Framework stuff
function module:updateScale()
	if (not SUI.DB.scale) then -- make sure the variable exists, and auto-configured based on screen size
		local width, height = string.match(GetCVar('gxResolution'), '(%d+).-(%d+)')
		if (tonumber(width) / tonumber(height) > 4 / 3) then
			SUI.DB.scale = 0.92
		else
			SUI.DB.scale = 0.78
		end
	end
	if SUI.DB.scale ~= CurScale then
		if (SUI.DB.scale ~= Artwork_Core:round(Blizzard_SpartanUI:GetScale())) then
			Blizzard_SpartanUI:SetScale(SUI.DB.scale)
		end
		CurScale = SUI.DB.scale
	end
end

function module:updateAlpha()
	if SUI.DB.alpha then
		Blizzard_SpartanUI.Left:SetAlpha(SUI.DB.alpha)
		Blizzard_SpartanUI.Right:SetAlpha(SUI.DB.alpha)
	end
	-- Update Action bar backgrounds
	for i = 1, 4 do
		if SUI.DB.Styles.Blizzard.Artwork['bar' .. i].enable then
			_G['Blizzard_Bar' .. i]:Show()
			_G['Blizzard_Bar' .. i]:SetAlpha(SUI.DB.Styles.Blizzard.Artwork['bar' .. i].alpha)
		else
			_G['Blizzard_Bar' .. i]:Hide()
		end
		if SUI.DB.Styles.Blizzard.Artwork.Stance.enable then
			_G['Blizzard_StanceBar']:Show()
			_G['Blizzard_StanceBar']:SetAlpha(SUI.DB.Styles.Blizzard.Artwork.Stance.alpha)
		else
			_G['Blizzard_StanceBar']:Hide()
		end
		if SUI.DB.Styles.Blizzard.Artwork.MenuBar.enable then
			_G['Blizzard_MenuBar']:Show()
			_G['Blizzard_MenuBar']:SetAlpha(SUI.DB.Styles.Blizzard.Artwork.MenuBar.alpha)
		else
			_G['Blizzard_MenuBar']:Hide()
		end
	end
end

function module:updateOffset()
	local fubar, ChocolateBar, titan = 0, 0, 0

	if not SUI.DB.yoffsetAuto then
		offset = max(SUI.DB.yoffset, 0)
	else
		for i = 1, 4 do -- FuBar Offset
			if (_G['FuBarFrame' .. i] and _G['FuBarFrame' .. i]:IsVisible()) then
				local bar = _G['FuBarFrame' .. i]
				local point = bar:GetPoint(1)
				if point == 'BOTTOMLEFT' then
					fubar = fubar + bar:GetHeight()
				end
			end
		end

		for i = 1, 100 do -- Chocolate Bar Offset
			if (_G['ChocolateBar' .. i] and _G['ChocolateBar' .. i]:IsVisible()) then
				local bar = _G['ChocolateBar' .. i]
				local point = bar:GetPoint(1)
				if point == 'RIGHT' then
					ChocolateBar = ChocolateBar + bar:GetHeight()
				end
			end
		end

		TitanBarOrder = {[1] = 'AuxBar2', [2] = 'AuxBar'} -- Bottom 2 Bar names

		for i = 1, 2 do
			if (_G['Titan_Bar__Display_' .. TitanBarOrder[i]] and TitanPanelGetVar(TitanBarOrder[i] .. '_Show')) then
				local PanelScale = TitanPanelGetVar('Scale') or 1
				titan = titan + (PanelScale * _G['Titan_Bar__Display_' .. TitanBarOrder[i]]:GetHeight())
			end
		end

		offset = max(fubar + titan + ChocolateBar, 1)
		SUI.DB.yoffset = offset
	end

	Blizzard_ActionBarPlate:ClearAllPoints()
	Blizzard_ActionBarPlate:SetPoint('BOTTOM', UIParent, 'BOTTOM', 0, offset)
end

--	Module Calls
function module:TooltipLoc(_, parent)
	if (parent == 'UIParent') then
		tooltip:ClearAllPoints()
		tooltip:SetPoint('BOTTOMRIGHT', 'Blizzard_SpartanUI', 'TOPRIGHT', 0, 10)
	end
end

function module:BuffLoc(_, parent)
	BuffFrame:ClearAllPoints()
	BuffFrame:SetPoint('TOPRIGHT', -13, -13 - (SUI.DB.BuffSettings.offset))
end

function module:SetupVehicleUI()
	if SUI.DBMod.Artwork.VehicleUI then
		petbattle:HookScript(
			'OnHide',
			function()
				Blizzard_SpartanUI:Hide()
				Minimap:Hide()
			end
		)
		petbattle:HookScript(
			'OnShow',
			function()
				Blizzard_SpartanUI:Show()
				Minimap:Show()
			end
		)
		RegisterStateDriver(petbattle, 'visibility', '[petbattle] hide; show')
		RegisterStateDriver(Blizzard_SpartanUI, 'visibility', '[overridebar][vehicleui] hide; show')
	end
end

function module:RemoveVehicleUI()
	if SUI.DBMod.Artwork.VehicleUI then
		UnRegisterStateDriver(petbattle, 'visibility')
		UnRegisterStateDriver(Blizzard_SpartanUI, 'visibility')
	end
end

function module:InitArtwork()
	Artwork_Core:ActionBarPlates(
		'Blizzard_ActionBarPlate',
		{
			'BarBagBar',
			'BarStanceBar',
			'BarPetBar',
			'BarMicroMenu'
		}
	)

	plate = CreateFrame('Frame', 'Blizzard_ActionBarPlate', UIParent, 'Blizzard_ActionBarsTemplate')
	plate:SetFrameStrata('BACKGROUND')
	plate:SetFrameLevel(1)
	plate:SetPoint('BOTTOM')

	FramerateText:ClearAllPoints()
	FramerateText:SetPoint('TOPLEFT', UIParent, 'TOPLEFT', 10, -10)
end

function module:EnableArtwork()
-- local bar1 = CreateFrame("Frame", "MyMainMenuBar", UIParent, "SecureHandlerStateTemplate")
-- bar1:SetWidth(323)
-- bar1:SetHeight(26)

-- MainMenuBar:SetParent(bar1)
-- MainMenuBar:ClearAllPoints()
-- MainMenuBar:SetPoint("CENTER", 40,40)
-- MainMenuBarArtFrame:EnableMouse(false)


-- MainMenuBar.slideOut.IsPlaying = function() return true end
	Blizzard_SpartanUI:SetFrameStrata('BACKGROUND')
	Blizzard_SpartanUI:SetFrameLevel(1)

	Blizzard_SpartanUI.Left = Blizzard_SpartanUI:CreateTexture('Blizzard_SpartanUI_Left', 'BORDER')
	Blizzard_SpartanUI.Left:SetPoint('BOTTOMRIGHT', UIParent, 'BOTTOM', 0, 0)

	Blizzard_SpartanUI.Right = Blizzard_SpartanUI:CreateTexture('Blizzard_SpartanUI_Right', 'BORDER')
	Blizzard_SpartanUI.Right:SetPoint('LEFT', Blizzard_SpartanUI.Left, 'RIGHT', 0, 0)
	local barBG

	Blizzard_SpartanUI.Left:SetTexture('Interface\\AddOns\\SpartanUI_Style_Blizzard\\Images\\Base_Bar_Left.tga')
	Blizzard_SpartanUI.Right:SetTexture('Interface\\AddOns\\SpartanUI_Style_Blizzard\\Images\\Base_Bar_Right.tga')
	barBG = 'Interface\\AddOns\\SpartanUI_Style_Blizzard\\Images\\Barbg-' .. UnitFactionGroup('Player')

	Blizzard_SpartanUI.Left:SetScale(.75)
	Blizzard_SpartanUI.Right:SetScale(.75)

	for i = 1, 4 do
		_G['Blizzard_Bar' .. i .. 'BG']:SetAlpha(.25)
	end
	module:SlidingTrays()

	if barBG then
		for i = 1, 4 do
			_G['Blizzard_Bar' .. i .. 'BG']:SetTexture(barBG)
		end

		Blizzard_MenuBarBG:SetTexture(barBG)
		Blizzard_StanceBarBG:SetTexture(barBG)
	end

	module:updateOffset()

 	-- if (not InCombatLockdown()) then
 	-- UIPARENT_MANAGED_FRAME_POSITIONS["MultiBarBottomLeft"] = {baseY = 20, xOffset = 5, watchBar = 1, maxLevel = 1, anchorTo = "Blizzard_Bar1", point = "BOTTOMLEFT", rpoint = "BOTTOMLEFT"};
 	-- UIPARENT_MANAGED_FRAME_POSITIONS["MultiBarBottomLeft"].anchorTo = "Blizzard_Bar1"
	MainMenuBarArtFrame.LeftEndCap:Hide()
	MainMenuBarArtFrame.RightEndCap:Hide()
	MainMenuBarArtFrameBackground:Hide()
	StatusTrackingBarManager:Hide()
    MainMenuBarArtFrameBackground:ClearAllPoints()
    MainMenuBarArtFrameBackground:SetPoint("LEFT", Blizzard_Bar2, "LEFT", -3, 2)
    MainMenuBarArtFrame:SetScale(0.725)
    MainMenuBar:EnableMouse(false)
    MultiBarBottomLeftButton1:ClearAllPoints()
    MultiBarBottomLeftButton1:SetPoint("LEFT", Blizzard_Bar1, "LEFT", 5, 0)
    MultiBarBottomRightButton1:ClearAllPoints()
    MultiBarBottomRightButton1:SetPoint("LEFT", Blizzard_Bar4, "LEFT", 5, 0)
    MultiBarBottomRightButton7:ClearAllPoints()
    MultiBarBottomRightButton7:SetPoint("LEFT", MultiBarBottomRightButton6, "RIGHT", 5, 0)
   -- MultiBarBottomLeft:SetScale(0.725)
    -- MainMenuBarArtFrameBackground:SetScale(0.725)
    -- for i = 1, 12 do
    -- 	_G['ActionButton' .. i]:SetScale(0.725)
    -- end
    -- ActionBarUpButton:SetScale(0.725)
    -- ActionBarDownButton:SetScale(0.725)
-- end
	-- hooksecurefunc(
		-- 'UpdateContainerFrameAnchors',
		-- function()
	-- UIPARENT_MANAGED_FRAME_POSITIONS["MultiBarBottomLeft"] = {baseY = 2, xOffset = 5, watchBar = 1, maxLevel = 1, anchorTo = "Blizzard_Bar1", point = "BOTTOMLEFT", rpoint = "BOTTOMLEFT"};
	-- MultiBarBottomLeft:ClearAllPoints()
    -- MultiBarBottomLeft:SetPoint("LEFT", Blizzard_Bar1, "LEFT", 5, 20)
		-- end
	-- )

	hooksecurefunc(
		'UIParent_ManageFramePositions',
		function()

			TutorialFrameAlertButton:SetParent(Minimap)
			TutorialFrameAlertButton:ClearAllPoints()
			TutorialFrameAlertButton:SetPoint('CENTER', Minimap, 'TOP', -2, 30)
			CastingBarFrame:ClearAllPoints()
			CastingBarFrame:SetPoint('BOTTOM', Blizzard_SpartanUI, 'TOP', 0, 90)
		end
	)

	MainMenuBarVehicleLeaveButton:HookScript(
		'OnShow',
		function()
			MainMenuBarVehicleLeaveButton:ClearAllPoints()
			MainMenuBarVehicleLeaveButton:SetPoint('LEFT', SUI_playerFrame, 'RIGHT', 15, 0)
		end
	)

	Artwork_Core:MoveTalkingHeadUI()
	module:SetupVehicleUI()

	if (SUI.DB.MiniMap.AutoDetectAllowUse) or (SUI.DB.MiniMap.ManualAllowUse) then
		module:MiniMap()
	end

	module:updateScale()
	module:updateAlpha()
	module:StatusBars()
end

function module:StatusBars()
	local Settings = {
		bars = {
			'Blizzard_StatusBar_Left',
			'Blizzard_StatusBar_Right'
		},
		Blizzard_StatusBar_Left = {
			bgImg = 'Interface\\AddOns\\SpartanUI_Style_Blizzard\\Images\\StatusBar-' .. UnitFactionGroup('Player'),
			size = {370, 20},
			TooltipSize = {250, 65},
			TooltipTextSize = {225, 40},
			texCords = {0.0546875, 0.9140625, 0.5555555555555556, 0},
			GlowPoint = {x = -16},
			MaxWidth = 48
		},
		Blizzard_StatusBar_Right = {
			bgImg = 'Interface\\AddOns\\SpartanUI_Style_Blizzard\\Images\\StatusBar-' .. UnitFactionGroup('Player'),
			Grow = 'RIGHT',
			size = {370, 20},
			TooltipSize = {250, 65},
			TooltipTextSize = {225, 40},
			texCords = {0.0546875, 0.9140625, 0.5555555555555556, 0},
			GlowPoint = {x = 16},
			MaxWidth = 48
		}
	}

	local StatusBars = SUI:GetModule('Artwork_StatusBars')
	StatusBars:Initalize(Settings)

	StatusBars.bars.Blizzard_StatusBar_Left:SetAlpha(.9)
	StatusBars.bars.Blizzard_StatusBar_Right:SetAlpha(.9)

	-- Position the StatusBars
	StatusBars.bars.Blizzard_StatusBar_Left:SetPoint('BOTTOMRIGHT', Blizzard_SpartanUI, 'BOTTOM', -100, 0)
	StatusBars.bars.Blizzard_StatusBar_Right:SetPoint('BOTTOMLEFT', Blizzard_SpartanUI, 'BOTTOM', 100, 0)
end

local SetBarVisibility = function(side, state)
	if side == 'left' and state == 'hide' then
		-- BT4BarStanceBar
		-- TODO: Stance Bar?
		-- if not SUI.DB.Styles.Blizzard.MovedBars.BT4BarStanceBar then
		-- 	_G['BT4BarStanceBar']:Hide()
		-- end
		-- if not SUI.DB.Styles.Blizzard.MovedBars.BT4BarPetBar then
		-- 	_G['BT4BarPetBar']:Hide()
		-- end
	elseif side == 'right' and state == 'hide' then
		-- TODO: Handle hide of MicroBarAndBags
		-- if not SUI.DB.Styles.Blizzard.MovedBars.BT4BarBagBar then
		-- 	_G['BT4BarBagBar']:Hide()
		-- end
		-- if not SUI.DB.Styles.Blizzard.MovedBars.BT4BarMicroMenu then
		-- 	_G['BT4BarMicroMenu']:Hide()
		-- end
	end

	if side == 'left' and state == 'show' then
		-- TODO: Stance?
		-- BT4BarStanceBar
		-- if not SUI.DB.Styles.Blizzard.MovedBars.BT4BarStanceBar then
		-- 	_G['BT4BarStanceBar']:Show()
		-- end
		-- if not SUI.DB.Styles.Blizzard.MovedBars.BT4BarPetBar then
		-- 	_G['BT4BarPetBar']:Show()
		-- end
	elseif side == 'right' and state == 'show' then
		-- TODO: Handle show of MicroBagAndBar
		-- if not SUI.DB.Styles.Blizzard.MovedBars.BT4BarBagBar then
		-- 	_G['BT4BarBagBar']:Show()
		-- end
		-- if not SUI.DB.Styles.Blizzard.MovedBars.BT4BarMicroMenu then
		-- 	_G['BT4BarMicroMenu']:Show()
		-- end
	end
end

local CollapseToggle = function(self)
	if SUI.DB.Styles.Blizzard.SlidingTrays[self.side].collapsed then
		SUI.DB.Styles.Blizzard.SlidingTrays[self.side].collapsed = false
		module.Trays[self.side].expanded:Show()
		module.Trays[self.side].collapsed:Hide()
		SetBarVisibility(self.side, 'show')
	else
		SUI.DB.Styles.Blizzard.SlidingTrays[self.side].collapsed = true
		module.Trays[self.side].expanded:Hide()
		module.Trays[self.side].collapsed:Show()
		SetBarVisibility(self.side, 'hide')
	end
end

-- Artwork Stuff
function module:SlidingTrays()
	local trayIDs = {'left', 'right'}
	Blizzard_MenuBarBG:SetAlpha(0)
	Blizzard_StanceBarBG:SetAlpha(0)

	for _, key in ipairs(trayIDs) do
		local tray = CreateFrame('Frame', nil, UIParent)
		tray:SetFrameStrata('BACKGROUND')
		tray:SetAlpha(.8)
		tray:SetSize(400, 45)

		local expanded = CreateFrame('Frame', nil, tray)
		expanded:SetAllPoints()
		local collapsed = CreateFrame('Frame', nil, tray)
		collapsed:SetAllPoints()

		local bg = expanded:CreateTexture(nil, 'BACKGROUND', expanded)
		bg:SetTexture('Interface\\AddOns\\SpartanUI_Style_Blizzard\\Images\\Trays-' .. UnitFactionGroup('Player'))
		bg:SetAllPoints()
		bg:SetTexCoord(0.076171875, 0.92578125, 0, 0.18359375)

		local bgCollapsed = collapsed:CreateTexture(nil, 'BACKGROUND', collapsed)
		bgCollapsed:SetTexture('Interface\\AddOns\\SpartanUI_Style_Blizzard\\Images\\Trays-' .. UnitFactionGroup('Player'))
		bgCollapsed:SetPoint('TOPLEFT', tray)
		bgCollapsed:SetPoint('TOPRIGHT', tray)
		bgCollapsed:SetHeight(18)
		bgCollapsed:SetTexCoord(0.076171875, 0.92578125, 1, 0.92578125)

		local btnUp = CreateFrame('BUTTON', nil, expanded)
		local UpTex = expanded:CreateTexture()
		UpTex:SetTexture('Interface\\AddOns\\SpartanUI_Style_Blizzard\\Images\\Trays-' .. UnitFactionGroup('Player'))
		UpTex:SetTexCoord(0.3671875, 0.640625, 0.20703125, 0.25390625)
		UpTex:Hide()
		btnUp:SetSize(130, 9)
		UpTex:SetAllPoints(btnUp)
		btnUp:SetNormalTexture('')
		btnUp:SetHighlightTexture(UpTex)
		btnUp:SetPushedTexture('')
		btnUp:SetDisabledTexture('')
		btnUp:SetPoint('BOTTOM', tray, 'BOTTOM', 1, 2)

		local btnDown = CreateFrame('BUTTON', nil, collapsed)
		local DownTex = collapsed:CreateTexture()
		DownTex:SetTexture('Interface\\AddOns\\SpartanUI_Style_Blizzard\\Images\\Trays-' .. UnitFactionGroup('Player'))
		DownTex:SetTexCoord(0.3671875, 0.640625, 0.25390625, 0.20703125)
		DownTex:Hide()
		btnDown:SetSize(130, 9)
		DownTex:SetAllPoints(btnDown)
		btnDown:SetNormalTexture('')
		btnDown:SetHighlightTexture(DownTex)
		btnDown:SetPushedTexture('')
		btnDown:SetDisabledTexture('')
		btnDown:SetPoint('TOP', tray, 'TOP', 2, -6)

		btnUp.side = key
		btnDown.side = key
		btnUp:SetScript('OnClick', CollapseToggle)
		btnDown:SetScript('OnClick', CollapseToggle)

		expanded.bg = bg
		expanded.btnUp = btnUp

		collapsed.bgCollapsed = bgCollapsed
		collapsed.btnDown = btnDown

		tray.expanded = expanded
		tray.collapsed = collapsed

		if SUI.DB.Styles.Blizzard.SlidingTrays[key].collapsed then
			tray.expanded:Hide()
			SetBarVisibility(key, 'hide')
		else
			tray.collapsed:Hide()
		end
		module.Trays[key] = tray
	end

	module.Trays.left:SetPoint('TOP', UIParent, 'TOP', -300, 0)
	module.Trays.right:SetPoint('TOP', UIParent, 'TOP', 300, 0)
end

-- Bartender Stuff
function module:SetupProfile()
	Artwork_Core:SetupProfile()
end

function module:CreateProfile()
	Artwork_Core:CreateProfile()
end

-- Minimap
function module:MiniMapUpdate()
	if Minimap.BG then
		Minimap.BG:ClearAllPoints()
	end

	Minimap.BG:SetTexture('Interface\\AddOns\\SpartanUI_Style_Blizzard\\Images\\minimap1')
	Minimap.BG:SetPoint('CENTER', Minimap, 'CENTER', 0, 3)
	Minimap.BG:SetAlpha(.75)
	-- Minimap.BG:SetTexture('Interface\\AddOns\\SpartanUI_Style_Blizzard\\Images\\minimap2')
	-- Minimap.BG:SetPoint('CENTER', Minimap, 'CENTER', -7, 5)
	Minimap.BG:SetSize(256, 256)
	Minimap.BG:SetBlendMode('ADD')
end

module.Settings.MiniMap = {
	size = {
		156,
		156
	},
	TextLocation = 'BOTTOM',
	coordsLocation = 'BOTTOM',
	coords = {
		TextColor = {1, .82, 0, 1}
	}
}

function module:MiniMap()
	Minimap:SetParent(Blizzard_SpartanUI)

	if Minimap.ZoneText ~= nil then
		Minimap.ZoneText:ClearAllPoints()
		Minimap.ZoneText:SetPoint('TOPLEFT', Minimap, 'BOTTOMLEFT', 0, -5)
		Minimap.ZoneText:SetPoint('TOPRIGHT', Minimap, 'BOTTOMRIGHT', 0, -5)
		Minimap.ZoneText:Hide()
		MinimapZoneText:Show()
	end

	QueueStatusFrame:ClearAllPoints()
	QueueStatusFrame:SetPoint('BOTTOM', Blizzard_SpartanUI, 'TOP', 0, 100)

	Minimap.BG = Minimap:CreateTexture(nil, 'BACKGROUND')

	module.Settings.MiniMap.TextLocation = 'TOP'
	module.Settings.MiniMap.Anchor = {
		'CENTER',
		Blizzard_SpartanUI.Left,
		'RIGHT',
		0,
		5
	}
	SUI:GetModule('Component_Minimap'):ShapeChange('circle')

	module:MiniMapUpdate()

	Minimap.coords:SetTextColor(1, .82, 0, 1)
	Minimap.coords:SetShadowColor(0, 0, 0, 1)
	Minimap.coords:SetScale(1.2)

	Blizzard_SpartanUI:HookScript(
		'OnHide',
		function(this, event)
			Minimap:ClearAllPoints()
			Minimap:SetParent(UIParent)
			Minimap:SetPoint('TOP', UIParent, 'TOP', 0, -20)
			-- SUI:GetModule('Component_Minimap'):ShapeChange('square')
		end
	)

	Blizzard_SpartanUI:HookScript(
		'OnShow',
		function(this, event)
			Minimap:ClearAllPoints()
			Minimap:SetPoint('CENTER', Blizzard_SpartanUI.Left, 'RIGHT', 0, 5)
			Minimap:SetParent(Blizzard_SpartanUI)
			-- SUI:GetModule('Component_Minimap'):ShapeChange('circle')
		end
	)
end
