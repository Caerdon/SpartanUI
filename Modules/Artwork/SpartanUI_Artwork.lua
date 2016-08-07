local _, SUI
spartan = _G["SUI"]
local L = spartan.L;
local Artwork_Core = spartan:NewModule("Artwork_Core");
local Bartender4Version, BartenderMin = "","4.7.1"
if select(4, GetAddOnInfo("Bartender4")) then Bartender4Version = GetAddOnMetadata("Bartender4", "Version") end

function Artwork_Core:isPartialMatch(frameName, tab)
	local result = false

	for k,v in ipairs(tab) do
		local startpos, endpos = strfind(strlower(frameName), strlower(v))
		if (startpos == 1) then
			result = true;
		end
	end

	return result;
end

function Artwork_Core:isInTable(tab, frameName)
	for k,v in ipairs(tab) do
		if (strlower(v) == strlower(frameName)) then
			return true;
		end
	end
	return false;
end

function Artwork_Core:round(num) -- rounds a number to 2 decimal places
	if num then return floor( (num*10^2)+0.5) / (10^2); end
end;

function Artwork_Core:MoveTalkingHeadUI()
	local THUDB = DB.Styles[DBMod.Artwork.Style].TalkingHeadUI
	local MoveTalkingHead = CreateFrame("Frame")
	MoveTalkingHead:RegisterEvent("ADDON_LOADED")
	MoveTalkingHead:SetScript("OnEvent", function(self, event, ...)
		local addonName = ...;
		if addonName and addonName == "Blizzard_TalkingHeadUI" then
			TalkingHeadFrame:SetMovable(true)
			TalkingHeadFrame:SetClampedToScreen(true)
			TalkingHeadFrame.ignoreFramePositionManager = true
			TalkingHeadFrame:ClearAllPoints()
			TalkingHeadFrame:SetPoint(THUDB.point, UIParent, THUDB.relPoint, THUDB.x, THUDB.y)
			if THUDB.scale then -- set scale
				TalkingHeadFrame:SetScale(THUDB.scale)
			end
		end
	end)
end

function Artwork_Core:ActionBarPlates(plate)
	local lib = LibStub("LibWindow-1.1",true);
	if not lib then return; end
	function lib.RegisterConfig(frame, storage, names)
		if not lib.windowData[frame] then
			lib.windowData[frame] = {}
		end
		lib.windowData[frame].names = names
		lib.windowData[frame].storage = storage
		
		-- If no name return, helps avoid other addons that use the library
		if (frame:GetName() == nil) then return end
		
		-- Catch if Movedbars is not initalized
		if DB.Styles[DBMod.Artwork.Style].MovedBars == nil then DB.Styles[DBMod.Artwork.Style].MovedBars = {} end
		
		-- If the name contains Bartender and we have not moved it set the parent to what is in sorage
		if (frame:GetName():match("BT4Bar")) and storage.parent and not DB.Styles[DBMod.Artwork.Style].MovedBars[frame:GetName()] then
			if (storage.parent) and _G[storage.parent] then
				frame:SetParent(storage.parent);
				frame:SetParent(plate);
				if storage.parent == plate then
					frame:SetFrameStrata("LOW");
				end
			-- elseif (parent and parent:GetName() == plate) then
				-- frame:SetParent(UIParent);
			end
		else
			storage.parent = UIParent
		end
	end
	
end

function Artwork_Core:OnInitialize()
	StaticPopupDialogs["BartenderVerWarning"] = {
		text = '|cff33ff99SpartanUI v'..spartan.SpartanVer..'|n|r|n|n'..L["Warning"]..': '..L["BartenderOldMSG"]..' '..Bartender4Version..'|n|nSpartanUI requires '..BartenderMin..' or higher.',
		button1 = "Ok",
		OnAccept = function()
			DBGlobal.BartenderVerWarning = spartan.SpartanVer;
		end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = false
	}
	StaticPopupDialogs["BartenderInstallWarning"] = {
		text = '|cff33ff99SpartanUI v'..spartan.SpartanVer..'|n|r|n|n'..L["Warning"]..': '..L["BartenderNotFoundMSG1"]..'|n'..L["BartenderNotFoundMSG2"],
		button1 = "Ok",
		OnAccept = function()
			DBGlobal.BartenderInstallWarning = spartan.SpartanVer
		end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = false
	}
	
	if not DBMod.Artwork.SetupDone then Artwork_Core:FirstTime() end
	if DB.Styles[DBMod.Artwork.Style].MovedBars == nil then DB.Styles[DBMod.Artwork.Style].MovedBars = {} end
	Artwork_Core:CheckMiniMap();
end

function Artwork_Core:FirstTime()
	DBMod.Artwork.SetupDone = false
	local PageData = {
		SubTitle = "Art Style",
		Desc1 = "Please pick an art style from the options below.",
		Display = function()
			--Container
			SUI_Win.Artwork = CreateFrame("Frame", nil)
			SUI_Win.Artwork:SetParent(SUI_Win.content)
			SUI_Win.Artwork:SetAllPoints(SUI_Win.content)
			
			local RadioButtons = function(self)
				SUI_Win.Artwork.Classic.radio:SetValue(false)
				SUI_Win.Artwork.Transparent.radio:SetValue(false)
				SUI_Win.Artwork.Minimal.radio:SetValue(false)
				SUI_Win.Artwork.Fel.radio:SetValue(false)
				self.radio:SetValue(true)
			end
			
			local gui = LibStub("AceGUI-3.0")
			
			--Classic
			local control = gui:Create("Icon")
			control:SetImage("interface\\addons\\SpartanUI_Artwork\\Themes\\Classic\\Images\\base-center")
			control:SetImageSize(120, 60)
			control:SetPoint("TOPRIGHT", SUI_Win.Artwork, "TOP", -30, -30)
			control:SetCallback("OnClick", RadioButtons)
			control.frame:SetParent(SUI_Win.Artwork)
			control.frame:Show()
			
			local radio = gui:Create("CheckBox")
			radio:SetLabel("Classic")
			radio:SetUserData("value", "Classic")
			radio:SetUserData("text", "Classic")
			radio:SetType("radio")
			radio:SetDisabled(true)
			radio:SetWidth(control.frame:GetWidth()/1.4)
			radio:SetHeight(16)
			radio.frame:SetPoint("TOP", control.frame, "BOTTOM", 0, 0)
			radio:SetCallback("OnClick", RadioButton)
			radio.frame:SetParent(control.frame)
			radio.frame:Show()
			control.radio = radio
			
			SUI_Win.Artwork.Classic = control
			
			--Fel
			local control = gui:Create("Icon")
			control:SetImage("interface\\addons\\SpartanUI\\media\\Style_Fel")
			control:SetImageSize(120, 60)
			control:SetPoint("TOPLEFT", SUI_Win.Artwork, "TOP", 30, -30)
			control:SetCallback("OnClick", RadioButtons)
			control.frame:SetParent(SUI_Win.Artwork)
			control.frame:Show()
			
			local radio = gui:Create("CheckBox")
			radio:SetLabel("Fel")
			radio:SetUserData("value", "Fel")
			radio:SetUserData("text", "Fel")
			radio:SetType("radio")
			radio:SetDisabled(true)
			radio:SetWidth(control.frame:GetWidth()/1.15)
			radio:SetHeight(16)
			radio.frame:SetPoint("TOP", control.frame, "BOTTOM", 0, 0)
			radio.frame:SetParent(control.frame)
			radio.frame:Show()
			control.radio = radio
			
			SUI_Win.Artwork.Fel = control
			
			--Transparent
			local control = gui:Create("Icon")
			control:SetImage("interface\\addons\\SpartanUI\\media\\Style_Transparent")
			control:SetImageSize(120, 60)
			control:SetPoint("TOP", SUI_Win.Artwork.Classic.frame, "BOTTOM", 0, -60)
			control:SetCallback("OnClick", RadioButtons)
			control.frame:SetParent(SUI_Win.Artwork)
			control.frame:Show()
			
			local radio = gui:Create("CheckBox")
			radio:SetLabel("Transparent")
			radio:SetUserData("value", "Transparent")
			radio:SetUserData("text", "Transparent")
			radio:SetType("radio")
			radio:SetDisabled(true)
			radio:SetWidth(control.frame:GetWidth()/1.15)
			radio:SetHeight(16)
			radio.frame:SetPoint("TOP", control.frame, "BOTTOM", 0, 0)
			radio.frame:SetParent(control.frame)
			radio.frame:Show()
			control.radio = radio
			
			SUI_Win.Artwork.Transparent = control
			
			--Minimal
			local control = gui:Create("Icon")
			control:SetImage("interface\\addons\\SpartanUI\\media\\Style_Minimal")
			control:SetImageSize(120, 60)
			control:SetPoint("TOP", SUI_Win.Artwork.Fel.frame, "BOTTOM", 0, -60)
			control:SetCallback("OnClick", RadioButtons)
			control.frame:SetParent(SUI_Win.Artwork)
			control.frame:Show()
			
			local radio = gui:Create("CheckBox")
			radio:SetLabel("Minimal")
			radio:SetUserData("value", "Minimal")
			radio:SetUserData("text", "Minimal")
			radio:SetType("radio")
			radio:SetDisabled(true)
			radio:SetWidth(control.frame:GetWidth()/1.15)
			radio:SetHeight(16)
			radio.frame:SetPoint("TOP", control.frame, "BOTTOM", 0, 0)
			radio.frame:SetParent(control.frame)
			radio.frame:Show()
			control.radio = radio
			
			SUI_Win.Artwork.Minimal = control
			
			SUI_Win.Artwork[DBMod.Artwork.Style].radio:SetValue(true)
		end,
		Next = function()
			DBMod.Artwork.SetupDone = true
			
			if (SUI_Win.Artwork.Classic.radio:GetValue()) then DBMod.Artwork.Style = "Classic"; end
			if (SUI_Win.Artwork.Transparent.radio:GetValue()) then DBMod.Artwork.Style = "Transparent"; end
			if (SUI_Win.Artwork.Minimal.radio:GetValue()) then DBMod.Artwork.Style = "Minimal"; end
			
			DBMod.PlayerFrames.Style = DBMod.Artwork.Style;
			DBMod.PartyFrames.Style = DBMod.Artwork.Style;
			DBMod.RaidFrames.Style = DBMod.Artwork.Style;
			DBMod.Artwork.FirstLoad = true;
			
			--Reset Moved bars
			if DB.Styles[DBMod.Artwork.Style].MovedBars == nil then DB.Styles[DBMod.Artwork.Style].MovedBars = {} end
			local FrameList = {BT4Bar1, BT4Bar2, BT4Bar3, BT4Bar4, BT4Bar5, BT4Bar6, BT4BarBagBar, BT4BarExtraActionBar, BT4BarStanceBar, BT4BarPetBar, BT4BarMicroMenu}
			for k,v in ipairs(FrameList) do
				if DB.Styles[DBMod.Artwork.Style].MovedBars[v:GetName()] then
					DB.Styles[DBMod.Artwork.Style].MovedBars[v:GetName()] = false
				end
			end;
			
			spartan:GetModule("Style_"..DBMod.Artwork.Style):SetupProfile();
			
			SUI_Win.Artwork:Hide()
			SUI_Win.Artwork = nil
		end,
		RequireReload = true,
		Priority = 1,
		Skipable = true,
		NoReloadOnSkip = true,
		Skip = function()
			DBMod.Artwork.SetupDone = true
		end
	}
	local SetupWindow = spartan:GetModule("SetupWindow")
	SetupWindow:AddPage(PageData)
	SetupWindow:DisplayPage()
end

function Artwork_Core:OnEnable()
	-- No Bartender/out of date Notification
	if (not select(4, GetAddOnInfo("Bartender4")) and (DBGlobal.BartenderInstallWarning ~= spartan.SpartanVer)) then
		if spartan.SpartanVer ~= DBGlobal.Version then StaticPopup_Show ("BartenderInstallWarning") end
	elseif Bartender4Version < BartenderMin then
			if spartan.SpartanVer ~= DBGlobal.Version then StaticPopup_Show ("BartenderVerWarning") end
	end
	
	Artwork_Core:SetupOptions();
	
	local FrameList = {BT4Bar1, BT4Bar2, BT4Bar3, BT4Bar4, BT4Bar5, BT4Bar6, BT4Bar7, BT4Bar8, BT4Bar9, BT4Bar10, BT4BarBagBar, BT4BarExtraActionBar, BT4BarStanceBar, BT4BarPetBar, BT4BarMicroMenu}
	
	for k,v in ipairs(FrameList) do	
		if v then
			v.SavePosition = function()
				if not DB.Styles[DBMod.Artwork.Style].MovedBars[v:GetName()] or v:GetParent():GetName() ~= "UIParent" then
					DB.Styles[DBMod.Artwork.Style].MovedBars[v:GetName()] = true
					LibStub("LibWindow-1.1").windowData[v].storage.parent = UIParent
					v:SetParent(UIParent)
				end
				
				LibStub("LibWindow-1.1").SavePosition(v)
			end
		end
	end
end

function Artwork_Core:CheckMiniMap()
	-- Check for Carbonite dinking with the minimap.
	if (NXTITLELOW) then
		spartan:Print(NXTITLELOW..' is loaded ...Checking settings ...');
		if (Nx.db.profile.MiniMap.Own == true) then
			spartan:Print(NXTITLELOW..' is controlling the Minimap');
			spartan:Print("SpartanUI Will not modify or move the minimap unless Carbonite is a separate minimap");
			DB.MiniMap.AutoDetectAllowUse = false;
		end
	end
	
	if select(4, GetAddOnInfo("SexyMap")) then
		spartan:Print(L["SexyMapLoaded"])
		DB.MiniMap.AutoDetectAllowUse = false;
	end
	
	local point, relativeTo, relativePoint, x, y = MinimapCluster:GetPoint();
	if (relativeTo ~= UIParent) then
		spartan:Print('A unknown addon is controlling the Minimap');
		spartan:Print("SpartanUI Will not modify or move the minimap until the addon modifying the minimap is no longer enabled.");
		DB.MiniMap.AutoDetectAllowUse = false;
	end
end

-- Bartender4 Items
function Artwork_Core:SetupProfile()
	local ProfileName = DB.Styles[DBMod.Artwork.Style].BartenderProfile
	local BartenderSettings = DB.Styles[DBMod.Artwork.Style].BartenderSettings
	--If this is set then we have already setup the bars once, and the user changed them
	if DB.Styles[DBMod.Artwork.Style].BT4Profile and DB.Styles[DBMod.Artwork.Style].BT4Profile ~= ProfileName then return end
	
	--Exit if Bartender4 is not loaded
	if (not select(4, GetAddOnInfo("Bartender4"))) then return; end
	
	-- Set/Create our Profile
	Bartender4.db:SetProfile(ProfileName);
	
	--Load the Profile Data
	for k,v in LibStub("AceAddon-3.0"):IterateModulesOfAddon(Bartender4) do -- for each module (BagBar, ActionBars, etc..)
		if BartenderSettings[k] and v.db.profile then
			v.db.profile = Artwork_Core:MergeData(v.db.profile,BartenderSettings[k])
		end
	end
end;

function Artwork_Core:BartenderProfileCheck(Input,Report)
	local profiles, r = Bartender4.db:GetProfiles(), false
	for k,v in pairs(profiles) do
		if v == Input then r = true end
	end
	if (Report) and (r ~= true) then
		addon:Print(Input.." "..L["BartenderProfileCheckFail"])
	end
	return r
end

function Artwork_Core:MergeData(target,source)
	if type(target) ~= "table" then target = {} end
	for k,v in pairs(source) do
		if type(v) == "table" then
			target[k] = self:MergeData(target[k], v);
		else
			target[k] = v;
		end
	end
	return target;
end

function Artwork_Core:CreateProfile()
	local ProfileName = DB.Styles[DBMod.Artwork.Style].BartenderProfile
	local BartenderSettings = DB.Styles[DBMod.Artwork.Style].BartenderSettings
	--If this is set then we have already setup the bars once, and the user changed them
	if DB.Styles[DBMod.Artwork.Style].BT4Profile and DB.Styles[DBMod.Artwork.Style].BT4Profile ~= ProfileName then return end
	
	--Exit if Bartender4 is not loaded
	if (not select(4, GetAddOnInfo("Bartender4"))) then return; end
	
	-- Set/Create our Profile
	Bartender4.db:SetProfile(ProfileName);
	
	--Load the Profile Data
	for k,v in LibStub("AceAddon-3.0"):IterateModulesOfAddon(Bartender4) do -- for each module (BagBar, ActionBars, etc..)
		if BartenderSettings[k] and v.db.profile then
			v.db.profile = Artwork_Core:MergeData(v.db.profile,BartenderSettings[k])
		end
	end
	
	Bartender4:UpdateModuleConfigs();
end