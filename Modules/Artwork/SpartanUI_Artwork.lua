local SUI = SUI
local L = SUI.L
local Artwork_Core = SUI:NewModule('Artwork_Core')

local BarModule
local function GetBarSettings()
	-- local barStyle = SUI.DB.Styles['War']
	local barStyle = SUI.DB.Styles[SUI.DBMod.BarManager.Style] 

	return {
		profile = barStyle.BartenderProfile,
		type = barStyle.BarManager.type
	}
end

local function GetBarModule()
	local BarTypes = {
		Blizzard = 'Artwork_BlizzardBars',
		Bartender = 'Artwork_BartenderBars'
	}

	local BarSettings = GetBarSettings()
	barType = BarSettings.type

	-- Does it make sense to just go to Blizzard vs. Bartender
	-- based solely on if the addon is enabled?
	-- The problem is that I don't know if you can tell
	-- Bartender to just leave everything alone.
	-- Putting that in place for now to try it out...
	if (not select(4, GetAddOnInfo('Bartender4'))) then
		barType = 'Blizzard'
	else
		barType = 'Bartender'
	end
	local barModuleName = BarTypes[barType]

	local isSetup = false

	local barModule = nil

	if SUI:GetModule(barModuleName, true) then
		barModule = SUI:GetModule(barModuleName)
	else
		SUI:Err('Artwork_Core', 'Missing bar module: ' .. barModuleName)
	end

	return barModule
end

function Artwork_Core:updateScale()
	--Set default scale based on if the user is using a widescreen.
	if (not SUI.DB.scale) then
		local width, height = string.match(GetCVar('gxResolution'), '(%d+).-(%d+)')
		if (tonumber(width) / tonumber(height) > 4 / 3) then
			SUI.DB.scale = 0.92
		else
			SUI.DB.scale = 0.78
		end
	end

	-- Call module scale update if defined.
	local style = SUI:GetModule('Style_' .. SUI.DBMod.Artwork.Style)
	if style.updateScale then
		style:updateScale()
	end
end

function Artwork_Core:updateOffset()
	if InCombatLockdown() then
		return
	end

	local Top = 0
	local fubar, ChocolateBar, titan = 0, 0, 0

	if not SUI.DB.yoffsetAuto then
		offset = max(SUI.DB.yoffset, 0)
	else
		for i = 1, 4 do -- FuBar Offset
			if (_G['FuBarFrame' .. i] and _G['FuBarFrame' .. i]:IsVisible()) then
				local bar = _G['FuBarFrame' .. i]
				local point = bar:GetPoint(1)
				if point:find('TOP.*') then
					Top = Top + bar:GetHeight()
				end
				if point == 'BOTTOMLEFT' then
					fubar = fubar + bar:GetHeight()
				end
			end
		end

		for i = 1, 100 do -- Chocolate Bar Offset
			if (_G['ChocolateBar' .. i] and _G['ChocolateBar' .. i]:IsVisible()) then
				local bar = _G['ChocolateBar' .. i]
				local point = bar:GetPoint(1)
				if point:find('TOP.*') then
					Top = Top + bar:GetHeight()
				end
				if point == 'RIGHT' then
					ChocolateBar = ChocolateBar + bar:GetHeight()
				end
			end
		end

		local TitanTopBar = {[1] = 'Bar2', [2] = 'Bar'} -- Top 2 Bar names
		for i = 1, 2 do
			if (_G['Titan_Bar__Display_' .. TitanTopBar[i]] and TitanPanelGetVar(TitanTopBar[i] .. '_Show')) then
				local PanelScale = TitanPanelGetVar('Scale') or 1
				Top = Top + (PanelScale * _G['Titan_Bar__Display_' .. TitanTopBar[i]]:GetHeight())
			end
		end

		local TitanBarOrder = {[1] = 'AuxBar2', [2] = 'AuxBar'} -- Bottom 2 Bar names

		for i = 1, 2 do
			if (_G['Titan_Bar__Display_' .. TitanBarOrder[i]] and TitanPanelGetVar(TitanBarOrder[i] .. '_Show')) then
				local PanelScale = TitanPanelGetVar('Scale') or 1
				titan = titan + (PanelScale * _G['Titan_Bar__Display_' .. TitanBarOrder[i]]:GetHeight())
			end
		end

		if OrderHallCommandBar and OrderHallCommandBar:IsVisible() then
			Top = Top + OrderHallCommandBar:GetHeight()
		end

		offset = max(fubar + titan + ChocolateBar, 0)
		SUI.DB.yoffset = offset
	end

	-- Call module scale update if defined.
	local style = SUI:GetModule('Style_' .. SUI.DBMod.Artwork.Style)
	if style.updateOffset then
		style:updateOffset(Top, offset)
	end
end

function Artwork_Core:isPartialMatch(frameName, tab)
	local result = false

	for _, v in ipairs(tab) do
		local startpos = strfind(strlower(frameName), strlower(v))
		if (startpos == 1) then
			result = true
		end
	end

	return result
end

function Artwork_Core:isInTable(tab, frameName)
	for _, v in ipairs(tab) do
		if (strlower(v) == strlower(frameName)) then
			return true
		end
	end
	return false
end

function Artwork_Core:round(num) -- rounds a number to 2 decimal places
	if num then
		return floor((num * 10 ^ 2) + 0.5) / (10 ^ 2)
	end
end

function Artwork_Core:MoveTalkingHeadUI()
	local THUDB = SUI.DB.Styles[SUI.DBMod.Artwork.Style].TalkingHeadUI
	local MoveTalkingHead = CreateFrame('Frame')
	MoveTalkingHead:RegisterEvent('ADDON_LOADED')
	MoveTalkingHead:SetScript(
		'OnEvent',
		function(self, event, ...)
			local addonName = ...
			if addonName and addonName == 'Blizzard_TalkingHeadUI' then
				TalkingHeadFrame:SetMovable(true)
				TalkingHeadFrame:SetClampedToScreen(true)
				TalkingHeadFrame.ignoreFramePositionManager = true
				TalkingHeadFrame:ClearAllPoints()
				TalkingHeadFrame:SetPoint(THUDB.point, UIParent, THUDB.relPoint, THUDB.x, THUDB.y)
				if THUDB.scale then -- set scale
					TalkingHeadFrame:SetScale(THUDB.scale)
				end
			end
		end
	)
end

function Artwork_Core:ActionBarPlates(plate, excludelist)
	local lib = LibStub('LibWindow-1.1', true)
	if not lib then
		return
	end
	function lib.RegisterConfig(frame, storage, names)
		if not lib.windowData[frame] then
			lib.windowData[frame] = {}
		end
		lib.windowData[frame].names = names
		lib.windowData[frame].storage = storage

		-- If no name return, helps avoid other addons that use the library
		if (frame:GetName() == nil) then
			return
		end

		-- Catch if Movedbars is not initalized
		if SUI.DB.Styles[SUI.DBMod.Artwork.Style].MovedBars == nil then
			SUI.DB.Styles[SUI.DBMod.Artwork.Style].MovedBars = {}
		end
		local excluded = false
		if excludelist then
			for _, key in ipairs(excludelist) do
				if frame:GetName():match(key) then
					excluded = true
				end
			end
		end

		-- TODO: It seems like the bottom else condition below (storage.parent = UIParent)
		-- could apply to anything.  Can this whole thing be moved to BartenderBars (ApplyMovedPanels), 
		-- or do we need to split it out?

		-- If the name contains Bartender and we have not moved it set the parent to what is in storage
		-- if (frame:GetName():match("BT4Bar")) and storage.parent and not SUI.DB.Styles[SUI.DBMod.Artwork.Style].MovedBars[frame:GetName()] then
		if
			(frame:GetName():match('BT4Bar') and not excluded) and
				not SUI.DB.Styles[SUI.DBMod.Artwork.Style].MovedBars[frame:GetName()]
		 then
			-- end
			-- end
			-- if (storage.parent) and _G[storage.parent] then
			-- frame:SetParent(storage.parent);
			frame:SetParent(plate)
			-- if storage.parent == plate then
			frame:SetFrameStrata('LOW')
		else
			-- print("---")
			-- print(frame:GetName())
			-- print(SUI.DB.Styles[SUI.DBMod.Artwork.Style].MovedBars[frame:GetName()])
			-- print(storage.parent)
			-- print(plate)
			-- print("---")
			storage.parent = UIParent
		end
	end
end

function Artwork_Core:OnInitialize()
	if not SUI.DBMod.Artwork.SetupDone then
		Artwork_Core:FirstTime()
	end
	if SUI.DB.Styles[SUI.DBMod.Artwork.Style].MovedBars == nil then
		SUI.DB.Styles[SUI.DBMod.Artwork.Style].MovedBars = {}
	end
	Artwork_Core:CheckMiniMap()
end

function Artwork_Core:FirstTime()
	SUI.DBMod.Artwork.SetupDone = false
	local PageData = {
		ID = 'ArtworkCore',
		Name = 'SpartanUI style',
		SubTitle = 'Art Style',
		Desc1 = 'Please pick an art style from the options below.',
		RequireReload = true,
		Priority = true,
		Skipable = true,
		NoReloadOnSkip = true,
		RequireDisplay = SUI.DBMod.Artwork.SetupDone,
		Display = function()
			local window = SUI:GetModule('SetupWizard').window
			local SUI_Win = window.content
			local StdUi = window.StdUi
			
			--Container
			SUI_Win.Artwork = CreateFrame('Frame', nil)
			SUI_Win.Artwork:SetParent(SUI_Win)
			SUI_Win.Artwork:SetAllPoints(SUI_Win)

			local RadioButtons = function(self)
				self.radio:Click()
			end

			local control

			--Classic
			control = StdUi:HighlightButton(SUI_Win.Artwork, 120, 60, '')
			control:SetScript('OnClick', RadioButtons)
			control:SetNormalTexture('interface\\addons\\SpartanUI_Artwork\\Themes\\Classic\\Images\\base-center')

			control.radio = StdUi:Radio(SUI_Win.Artwork, 'Classic', 'SUIArtwork', 120, 20)
			control.radio:SetValue('Classic')
			StdUi:GlueBelow(control.radio, control)

			SUI_Win.Artwork.Classic = control

			--Fel
			control = StdUi:HighlightButton(SUI_Win.Artwork, 120, 60, '')
			control:SetScript('OnClick', RadioButtons)
			control:SetNormalTexture('interface\\addons\\SpartanUI\\media\\Style_Fel')

			control.radio = StdUi:Radio(SUI_Win.Artwork, 'Fel', 'SUIArtwork', 120, 20)
			control.radio:SetValue('Fel')
			StdUi:GlueBelow(control.radio, control)

			SUI_Win.Artwork.Fel = control

			--War
			control = StdUi:HighlightButton(SUI_Win.Artwork, 120, 60, '')
			control:SetScript('OnClick', RadioButtons)
			control:SetNormalTexture('interface\\addons\\SpartanUI\\media\\Style_War')

			control.radio = StdUi:Radio(SUI_Win.Artwork, 'War', 'SUIArtwork', 120, 20)
			control.radio:SetValue('War')
			StdUi:GlueBelow(control.radio, control)

			SUI_Win.Artwork.War = control

			--Digital
			control = StdUi:HighlightButton(SUI_Win.Artwork, 120, 60, '')
			control:SetScript('OnClick', RadioButtons)
			control:SetNormalTexture('interface\\addons\\SpartanUI\\media\\Style_Digital')

			control.radio = StdUi:Radio(SUI_Win.Artwork, 'Digital', 'SUIArtwork', 120, 20)
			control.radio:SetValue('Digital')
			StdUi:GlueBelow(control.radio, control)

			SUI_Win.Artwork.Digital = control

			--Transparent
			control = StdUi:HighlightButton(SUI_Win.Artwork, 120, 60, '')
			control:SetScript('OnClick', RadioButtons)
			control:SetNormalTexture('interface\\addons\\SpartanUI\\media\\Style_Transparent')

			control.radio = StdUi:Radio(SUI_Win.Artwork, 'Transparent', 'SUIArtwork', 120, 20)
			control.radio:SetValue('Transparent')
			StdUi:GlueBelow(control.radio, control)

			SUI_Win.Artwork.Transparent = control

			--Minimal
			control = StdUi:HighlightButton(SUI_Win.Artwork, 120, 60, '')
			control:SetScript('OnClick', RadioButtons)
			control:SetNormalTexture('interface\\addons\\SpartanUI\\media\\Style_Minimal')

			control.radio = StdUi:Radio(SUI_Win.Artwork, 'Minimal', 'SUIArtwork', 120, 20)
			control.radio:SetValue('Minimal')
			StdUi:GlueBelow(control.radio, control)

			SUI_Win.Artwork.Minimal = control

			-- Position the Top row
			StdUi:GlueTop(SUI_Win.Artwork.Fel, SUI_Win, 0, -80)
			StdUi:GlueLeft(SUI_Win.Artwork.Classic, SUI_Win.Artwork.Fel, -20, 0)
			StdUi:GlueRight(SUI_Win.Artwork.War, SUI_Win.Artwork.Fel, 20, 0)

			-- Position the Bottom row
			StdUi:GlueTop(SUI_Win.Artwork.Digital, SUI_Win.Artwork.Fel.radio, 0, -30)
			StdUi:GlueLeft(SUI_Win.Artwork.Transparent, SUI_Win.Artwork.Digital, -20, 0)
			StdUi:GlueRight(SUI_Win.Artwork.Minimal, SUI_Win.Artwork.Digital, 20, 0)

			-- Check Classic as default
			SUI_Win.Artwork.Classic.radio:SetChecked(true)
		end,
		Next = function()
			local window = SUI:GetModule('SetupWizard').window
			local SUI_Win = window.content
			local StdUi = window.StdUi
			SUI.DBMod.Artwork.SetupDone = true

			SUI.DBMod.Artwork.Style = StdUi:GetRadioGroupValue('SUIArtwork')

			SUI.DBMod.PlayerFrames.Style = SUI.DBMod.Artwork.Style
			SUI.DBMod.PartyFrames.Style = SUI.DBMod.Artwork.Style
			SUI.DBMod.RaidFrames.Style = SUI.DBMod.Artwork.Style
			SUI.DBMod.BarManager.Style = SUI.DBMod.Artwork.Style
			SUI.DBMod.Artwork.FirstLoad = true
			SUI.DBG.BartenderChangesActive = true
			Artwork_Core:SetupProfile()

			SUI:GetModule('Artwork_Core'):ResetMovedBars()

			SUI_Win.Artwork:Hide()
			SUI_Win.Artwork = nil
		end,
		Skip = function()
			local SUI_Win = SUI:GetModule('SetupWizard').window
			SUI.DBMod.Artwork.SetupDone = true
			SUI_Win.Artwork:Hide()
			SUI_Win.Artwork = nil
		end
	}
	local SetupWindow = SUI:GetModule('SetupWizard')
	SetupWindow:AddPage(PageData)
end

function Artwork_Core:OnEnable()
	Artwork_Core:SetupOptions()

	local BarModule = GetBarModule()
	if BarModule then
		BarModule:SetupMovedBars()
	end
end

function Artwork_Core:CheckMiniMap()
	-- Check for Carbonite dinking with the minimap.
	if (NXTITLELOW) then
		SUI:Print(NXTITLELOW .. ' is loaded ...Checking settings ...')
		if (Nx.db.profile.MiniMap.Own == true) then
			SUI:Print(NXTITLELOW .. ' is controlling the Minimap')
			SUI:Print('SpartanUI Will not modify or move the minimap unless Carbonite is a separate minimap')
			SUI.DB.MiniMap.AutoDetectAllowUse = false
		end
	end

	if select(4, GetAddOnInfo('SexyMap')) then
		SUI:Print(L['SexyMapLoaded'])
		SUI.DB.MiniMap.AutoDetectAllowUse = false
	end

	local _, relativeTo = MinimapCluster:GetPoint()
	if (relativeTo ~= UIParent) then
		SUI:Print('A unknown addon is controlling the Minimap')
		SUI:Print('SpartanUI Will not modify or move the minimap until the addon modifying the minimap is no longer enabled.')
		SUI.DB.MiniMap.AutoDetectAllowUse = false
	end
end

function Artwork_Core:SetupBars()
	local isSetup = false
	local BarModule = GetBarModule()
	if BarModule then
		local BarSettings = GetBarSettings()
		isSetup = BarModule:Initialize(BarSettings)
	end

	return isSetup
end

function Artwork_Core:SetupProfile()
	local BarModule = GetBarModule()
	if BarModule then
		local BarSettings = GetBarSettings()
		BarModule:CreateProfile(BarSettings.profile)
	end
end

function Artwork_Core:ResetMovedBars()
	local BarModule = GetBarModule()
	if BarModule then
		BarModule:ResetMovedBars()
	end
end

function Artwork_Core:ResetDB()
	local BarModule = GetBarModule()
	if BarModule then
		BarModule:ResetDB()
	end
end

function Artwork_Core:UseBlizzardVehicleUI(shouldUse)
	local BarModule = GetBarModule()
	if BarModule then
		BarModule:UseBlizzardVehicleUI(shouldUse)
	end
end

function Artwork_Core:GetBagBar()
	local BarModule = GetBarModule()
	if BarModule then
		return BarModule:GetBagBar()
	end
end

function Artwork_Core:GetStanceBar()
	local BarModule = GetBarModule()
	if BarModule then
		return BarModule:GetStanceBar()
	end
end

function Artwork_Core:GetPetBar()
	local BarModule = GetBarModule()
	if BarModule then
		return BarModule:GetPetBar()
	end
end

function Artwork_Core:GetMicroMenuBar()
	local BarModule = GetBarModule()
	if BarModule then
		return BarModule:GetMicroMenuBar()
	end
end

function Artwork_Core:RefreshPositions()
	local BarModule = GetBarModule()
	if BarModule then
		return BarModule:RefreshPositions(self)
	end
end
