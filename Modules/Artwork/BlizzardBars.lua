local SUI = SUI
local L = SUI.L
local module = SUI:NewModule('Artwork_BlizzardBars')
module.bars = {}
module.DB = SUI.DBMod.BlizzardBars
local StyleSettings


function module:Initialize(Settings)
	StyleSettings = Settings

	--Create Bars
	module:factory()
	module:BuildOptions()
end

function module:SetupProfile(Settings)
end

function module:GetBagBar()
	return self.bars.bagframe
end

function module:GetStanceBar()
	return StanceBarFrame
end

function module:GetPetBar()
	return PetActionBarFrame
end

function module:GetMicroMenuBar()
	return self.bars.microframe
end

function module:RefreshPositions()
	local barSettings = SUI.DB.Styles[SUI.DBMod.Artwork.Style].BartenderSettings
  	local microInfo = barSettings.MicroMenu

	local width = CharacterMicroButton:GetWidth() * #MICRO_BUTTONS
	MoveMicroButtons("TOPLEFT", self.bars.microframe, "TOPLEFT", 0, 0, false);
end

function module:ResetMovedBars()
end

function module:SetupMovedBars()
end

function module:ResetDB()
end

function module:UseBlizzardVehicleUI(shouldUse)
end

function module:factory()
	local style = SUI.DBMod.Artwork.Style
	if style == 'Classic' then
		style = 'SUI'
	end

	local barSettings = SUI.DB.Styles[SUI.DBMod.Artwork.Style].BartenderSettings

  	local microInfo = barSettings.MicroMenu
  	local microWidth = (CharacterMicroButton:GetWidth() * (#MICRO_BUTTONS - 1)) -- 1 less because only store or help will be shown
 	self.bars.microframe = CreateFrame('Frame', nil, UIParent)
 	self.bars.microframe:SetSize(microWidth, CharacterMicroButton:GetHeight())
 	UpdateMicroButtonsParent(self.bars.microframe)

 	self.bars.microframe:SetScale(microInfo.position.scale)
 	self.bars.microframe:ClearAllPoints()
	if(SUI.DBMod.Artwork.Style == 'Classic') then
	 	self.bars.microframe:SetPoint(microInfo.position.point, microInfo.position.parent, microInfo.position.point, microInfo.position.x / microInfo.position.scale - 45, microInfo.position.y)
	else
	 	self.bars.microframe:SetPoint(microInfo.position.point, microInfo.position.parent, microInfo.position.point, microInfo.position.x / microInfo.position.scale + self.bars.microframe:GetWidth() / 2 + microInfo.padding, microInfo.position.y)
	end
 	self.bars.microframe:SetFrameStrata('LOW')

  	local bagInfo = barSettings.BagBar
	self.bars.bagframe = CreateFrame('Frame', nil, UIParent)
 	MainMenuBarBackpackButton:SetParent(self.bars.bagframe)

 	self.bars.bagframe:SetSize(CharacterBag0Slot:GetWidth() * NUM_BAG_FRAMES + 1, CharacterMicroButton:GetHeight())
 	self.bars.bagframe:SetScale(bagInfo.position.scale)
 	self.bars.bagframe:ClearAllPoints()
	if(SUI.DBMod.Artwork.Style == 'Classic' or SUI.DBMod.Artwork.Style == 'Minimal') then
		-- TODO: I'm missing where this difference comes from...
		-- flagging it for now until I track it down.
	 	self.bars.bagframe:SetPoint(bagInfo.position.point, bagInfo.position.parent, bagInfo.position.point, bagInfo.position.x / bagInfo.position.scale + self.bars.bagframe:GetWidth() / 2 - 128, bagInfo.position.y)
	else
	 	self.bars.bagframe:SetPoint(bagInfo.position.point, bagInfo.position.parent, bagInfo.position.point, bagInfo.position.x / bagInfo.position.scale - self.bars.bagframe:GetWidth() / bagInfo.position.scale, bagInfo.position.y)
	end
	MainMenuBarBackpackButton:ClearAllPoints()
 	MainMenuBarBackpackButton:SetPoint("TOPLEFT", self.bars.bagframe, "TOPLEFT", 0, 0)
 	local previousBag = MainMenuBarBackpackButton
 	for i = 0, NUM_BAG_FRAMES - 1 do
 		local bag = _G['CharacterBag'..i..'Slot']
 		bag:SetScale(1)
 		bag:SetParent(self.bars.bagframe)
 		bag:ClearAllPoints()
 		bag:SetPoint("TOPLEFT", previousBag, "TOPRIGHT", 0, 0)
 		previousBag = bag
 	end

 	self.bars.bagframe:SetFrameStrata('LOW')

	MicroButtonAndBagsBar:Hide()

	MainMenuBar:SetFrameStrata('LOW')
	MainMenuBarArtFrame.LeftEndCap:Hide()
	MainMenuBarArtFrame.RightEndCap:Hide()
	MainMenuBarArtFrameBackground:Hide()
	StatusTrackingBarManager:Hide()
    MainMenuBarArtFrameBackground:ClearAllPoints()
    MainMenuBarArtFrameBackground:SetPoint("LEFT", _G[style .. '_Bar2'], "LEFT", -3, 2)
    MainMenuBarArtFrame:SetScale(0.725)
    MainMenuBar:EnableMouse(false)
    MultiBarBottomLeftButton1:ClearAllPoints()
    MultiBarBottomLeftButton1:SetPoint("LEFT", _G[style .. '_Bar1'], "LEFT", 5, 0)
    MultiBarBottomRightButton1:ClearAllPoints()
    MultiBarBottomRightButton1:SetPoint("LEFT", _G[style .. '_Bar4'], "LEFT", 5, 0)
    MultiBarBottomRightButton7:ClearAllPoints()
    MultiBarBottomRightButton7:SetPoint("LEFT", MultiBarBottomRightButton6, "RIGHT", 5, 0)
    MultiActionBar_UpdateGridVisibility()
    for i = 1, 12 do
    	local bottomRightButton = _G['MultiBarBottomRightButton' .. i]
    	local mainButton = _G['ActionButton' .. i]
    	-- Make sure grid shows when it should.
    	bottomRightButton.noGrid = nil
    end

    hooksecurefunc('InterfaceOptions_UpdateMultiActionBars', function()
    	-- TODO: This code actually works on reload in combat, but it fails
    	-- if we try to go into Interface Options and change it while in combat.
    	-- A bit of an edge case, so I'm tempted to just leave it, as it's nice
    	-- to be able to immediately update even in a disconnect scenario.

    	-- if not InCombatLockdown() then
	    for i = 1, 12 do
	    	local mainButton = _G['ActionButton' .. i]
	    	-- Make sure grid shows when it should.  Main Bar seems to have a bug
	    	-- in the default Blizzard code.
	    	if MultibarGrid_IsVisible() then
		    	mainButton:SetAttribute("showgrid", mainButton:GetAttribute('showgrid') + 1)
		    	ActionButton_ShowGrid(mainButton)
			else
		    	mainButton:SetAttribute("showgrid", mainButton:GetAttribute('showgrid') - 1)
				ActionButton_HideGrid(mainButton)
		    end
	    end
	    -- end
    end)

    hooksecurefunc('MainMenuMicroButton_PositionAlert', function(alert)
    	-- Make sure alert is visible even if placed at the top.
    	local alertPoint = "BOTTOM"
    	local parentPoint = "TOP"
    	local parentInvert = 1

    	if ( alert.MicroButton:GetTop() > UIParent:GetTop() ) then
    		alertPoint = "TOP"
    		parentPoint = "BOTTOM"
    		parentInvert = -1
    	end

    	if ( alert.MicroButton:GetRight() + (alert:GetWidth() / 2) > UIParent:GetRight() ) then
			alert:ClearAllPoints();
			alert:SetPoint(alertPoint .. "RIGHT", alert.MicroButton, parentPoint .. "RIGHT", 16, 20 * parentInvert);
			alert.Arrow:ClearAllPoints();
			alert.Arrow:SetPoint("TOPRIGHT", alert, "BOTTOMRIGHT", -4, 4 * parentInvert);
		elseif ( alert.MicroButton:GetLeft() + (alert:GetWidth() / 2) < UIParent:GetLeft() ) then
			alert:ClearAllPoints();
			alert:SetPoint(alertPoint .. "LEFT", alert.MicroButton, parentPoint .. "LEFT", -16, 20 * parentInvert);
			alert.Arrow:ClearAllPoints();
			alert.Arrow:SetPoint(parentPoint.."LEFT", alert, alertPoint.."LEFT", 4, 1 * parentInvert);
		else
			alert:ClearAllPoints();
			alert:SetPoint(alertPoint, alert.MicroButton, parentPoint, 0, 20 * parentInvert);
			alert.Arrow:ClearAllPoints();
			alert.Arrow:SetPoint(parentPoint, alert, alertPoint, 0, 4 * parentInvert);
		end

		local buttonName = alert.MicroButton:GetName()
		_G[buttonName .. "AlertArrow"]:SetRotation(math.pi / 2 - (math.pi * parentInvert) / 2)
		_G[buttonName .. "AlertGlow"]:SetRotation(math.pi / 2 - (math.pi * parentInvert) / 2)
		_G[buttonName .. "AlertGlow"]:ClearAllPoints()
		_G[buttonName .. "AlertGlow"]:SetPoint("TOP", _G[buttonName .. "AlertArrow"], "TOP", 0, 4 + -4 * parentInvert)
    end)

end

function module:CreateProfile(ProfileOverride)
end

function module:BuildOptions()
	-- Build Holder
	-- SUI.opt.args['Artwork'].args['ActionBars'] = {
	-- 	name = L['Action Bars'],
	-- 	type = 'group',
	-- 	args = {}
	-- }

end
