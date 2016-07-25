local addon = LibStub("AceAddon-3.0"):NewAddon("SpartanUI","AceEvent-3.0", "AceConsole-3.0");
local AceConfig = LibStub("AceConfig-3.0");
local AceConfigDialog = LibStub("AceConfigDialog-3.0");
local L = LibStub("AceLocale-3.0"):GetLocale("SpartanUI", true)
addon.SpartanVer = GetAddOnMetadata("SpartanUI", "Version")
addon.CurseVersion = GetAddOnMetadata("SpartanUI", "X-Curse-Packaged-Version")
----------------------------------------------------------------------------------------------------
addon.opt = {
	name = "SpartanUI ".. addon.SpartanVer, type = "group", childGroups = "tab", args = {
		General = {name = L["General"], type = "group",order = 0, args = {}};
		Artwork = {name = L["Artwork"], type = "group", args = {}};
		PlayerFrames = {name = L["PlayerFrames"], type = "group", args = {}};
		PartyFrames = {name = L["PartyFrames"], type = "group", args = {}};
		RaidFrames = {name = L["RaidFrames"], type = "group", args = {}};
	}
}

local FontItems = {Primary={},Core={},Party={},Player={},Raid={}}
local FontItemsSize = {Primary={},Core={},Party={},Player={},Raid={}}
local fontdefault = {Size = 0, Face = "SpartanUI", Type = "outline"}
local MovedDefault = {moved=false;point = "",relativeTo = nil,relativePoint = "",xOffset = 0,yOffset = 0}
local frameDefault1 = {movement=MovedDefault,AuraDisplay=true,display=true,Debuffs="all",buffs="all",style="large",Auras={NumBuffs=5,NumDebuffs = 10,size = 20,spacing = 1,showType=true,onlyShowPlayer=false},moved=false,Anchors={}}
local frameDefault2 = {AuraDisplay=true,display=true,Debuffs="all",buffs="all",style="medium",Auras={NumBuffs=0,NumDebuffs = 10,size = 15,spacing = 1,showType=true,onlyShowPlayer=false},moved=false,Anchors={}}

local DBdefault = {
	SUIProper = {
		Version = addon.SpartanVer,
		HVer = "",
		yoffset = 0,
		xOffset = 0,
		yoffsetAuto = true,
		scale = .92,
		alpha = 1,
		viewport = true,
		EnabledComponents = {},
		Styles = {
			['**'] = {
				Artwork = false,
				PlayerFrames = false,
				PartyFrames = false,
				RaidFrames = false,
				Movable = {
					Minimap = true,
					PlayerFrames = true,
					PartyFrames = true,
					RaidFrames = true,
				},
				Minimap = {
					shape = "circle",
					size = {width = 140, height = 140}
				},
				TooltipLoc = false
			},
			Classic = {
				Artwork = true,
				PlayerFrames = true,
				PartyFrames = true,
				RaidFrames = true,
				BartenderProfile = "SpartanUI - Classic",
				Movable = {
					Minimap = false,
					PlayerFrames = true,
					PartyFrames = true,
					RaidFrames = true,
				},
				Minimap = {
					shape = "circle",
					size = {width = 140, height = 140}
				},
				TooltipLoc = true
			}
		},
		ChatSettings = {
			enabled = true
		},
		BuffSettings = {
			disableblizz = true,
			enabled = true,
			Manualoffset = false,
			offset = 0
		},
		PopUP = {
			popup1enable = true,
			popup2enable = true,
			popup1alpha = 100,
			popup2alpha = 100,
			popup1anim = true,
			popup2anim = true
		},
		XPBar = {
			enabled = true,
			text = true,
			ToolTip = "click",
			GainedColor	= "Blue",
			GainedRed	= 0,
			GainedBlue	= 1,
			GainedGreen	= .5,
			GainedBrightness= .7,
			RestedColor	= "Light_Blue",
			RestedRed	= 0,
			RestedBlue	= 1,
			RestedGreen	= .5,
			RestedBrightness= .7,
			RestedMatchColor= false
		},
		RepBar = {
			enabled = true,
			text = false,
			ToolTip = "click",
			GainedColor	= "AUTO",
			GainedRed	= 0,
			GainedBlue	= 0,
			GainedGreen	= 1,
			GainedBrightness= .6,
			AutoDefined	= true
		},
		MiniMap = {
			northTag = false,
			ManualAllowUse = false,
			ManualAllowPrompt = "",
			AutoDetectAllowUse = true,
			MapButtons = true,
			MouseIsOver = false,
			MapZoomButtons = true,
			Shape = "square",
			BlizzStyle = "mouseover",
			OtherStyle = "mouseover",
			Moved = false,
			Position = nil,
			-- frames = {},
			-- IgnoredFrames = {},
			SUIMapChangesActive = false
		},
		ActionBars = {
			Allalpha = 100,
			Allenable = true,
			popup1 = {anim = true, alpha = 100, enable = true},
			popup2 = {anim = true, alpha = 100, enable = true},
			bar1 = {alpha = 100, enable = true},
			bar2 = {alpha = 100, enable = true},
			bar3 = {alpha = 100, enable = true},
			bar4 = {alpha = 100, enable = true},
			bar5 = {alpha = 100, enable = true},
			bar6 = {alpha = 100, enable = true},
		},
		font = {
			Path = "",
			Primary = fontdefault,
			Core = fontdefault,
			Player = fontdefault,
			Party = fontdefault,
			Raid = fontdefault,
		},
		Components = {
		}
	},
	Modules = {
		Artwork = {
			Style = "Classic",
			FirstLoad = true,
			VehicleUI = true,
			Viewport = 
			{
				enabled = true,
				offset = 
				{
					top = 0,bottom = 2.3,left = 0,right = 0
				}
			}
		},
		SpinCam = {
			enable = true,
			speed = 8
		},
		FilmEffects = {
			enable = false,
			animationInterval = 0,
			anim = "",
			vignette = nil
		},
		PartyFrames  = {
			Style = "Classic",
			Portrait3D = true,
			threat = true,
			preset = "dps",
			FrameStyle = "large",
			showAuras = true,
			partyLock = true,
			showClass = true,
			partyMoved = false,
			castbar = true,
			castbartext = true,
			showPartyInRaid = false,
			showParty = true,
			showPlayer = true,
			showSolo = false,
			Portrait = true,
			scale=1,
			Auras = {
				NumBuffs = 0,
				NumDebuffs = 10,
				size = 16,
				spacing = 1,
				showType = true
			},
			Anchors = {
				point = "TOPLEFT",
				relativeTo = "UIParent",
				relativePoint = "TOPLEFT",
				xOfs = 10,
				yOfs = -20
			},
			bars = {health={textstyle="dynamic", textmode=1},mana={textstyle="dynamic", textmode=1}},
			display = {pet = true,target=true,mana=true},
		},
		PlayerFrames = {
			Style = "Classic",
			Portrait3D = true,
			showClass = true,
			focusMoved = false,
			PetPortrait = true,
			global = frameDefault1,
			player = frameDefault1,
			target = frameDefault1,
			targettarget = frameDefault2,
			pet = frameDefault2,
			focus = frameDefault2,
			focustarget = frameDefault2,
			boss = frameDefault2,
			bars = {
				health = {textstyle = "dynamic",textmode=1},
				mana = {textstyle = "longfor",textmode=1},
				player = {color="dynamic"},
				target = {color="reaction"},
				targettarget = {color="dynamic",style="large"},
				pet = {color="happiness"},
				focus = {color="dynamic"},
				focustarget = {color="dynamic"},
			},
			Castbar = {player=1,target=1,targettarget=1,pet=1,focus=1,text={player=1,target=1,targettarget=1,pet=1,focus=1}},
			BossFrame = {movement=MovedDefault,display=true,scale=1},
			ArenaFrame = {movement=MovedDefault,display=false,scale=1},
			ClassBar = {scale = 1,movement=MovedDefault},
			TotemFrame = {movement=MovedDefault},
			AltManaBar = {movement=MovedDefault},
		},
		RaidFrames  = {
			Style = "Classic",
			HideBlizzFrames = true,
			threat = true,
			mode = "ASSIGNEDROLE",
			preset = "dps",
			FrameStyle = "small",
			showAuras = true,
			showClass = true,
			moved = false,
			showRaid = true,
			maxColumns = 4,
			unitsPerColumn = 10,
			columnSpacing = 5,
			scale=1,
			Anchors = {
				point = "TOPLEFT",
				relativeTo = "UIParent",
				relativePoint = "TOPLEFT",
				xOfs = 10,
				yOfs = -20
			},
			bars = {
				health = {textstyle="dynamic", textmode=1},
				mana = {textstyle="dynamic", textmode=1}
			},
			debuffs = {display=true},
			Auras={size=10,spacing=1,showType=true}
		}
	}
}
local DBdefaults = {char = DBdefault,profile = DBdefault}
-- local DBGlobals = {Version = addon.SpartanVer}

function addon:ResetConfig()
	addon.db:ResetProfile(false,true);
	ReloadUI();
end

function addon:OnInitialize()
	addon.db = LibStub("AceDB-3.0"):New("SpartanUIDB", DBdefaults);
	-- addon.db.profile.playerName = UnitName("player")
	DBGlobal = addon.db.global
	DB = addon.db.profile.SUIProper
	DBMod = addon.db.profile.Modules
	addon.opt.args["Profiles"] = LibStub("AceDBOptions-3.0"):GetOptionsTable(addon.db);
	
	-- Add dual-spec support
	local LibDualSpec = LibStub('LibDualSpec-1.0')
	LibDualSpec:EnhanceDatabase(self.db, "SpartanUI")
	LibDualSpec:EnhanceOptions(addon.opt.args["Profiles"], self.db)
	addon.opt.args["Profiles"].order=999
	
	-- Spec Setup
	addon.db.RegisterCallback(addon, "OnNewProfile", "InitializeProfile")
	addon.db.RegisterCallback(addon, "OnProfileChanged", "UpdateModuleConfigs")
	addon.db.RegisterCallback(addon, "OnProfileCopied", "UpdateModuleConfigs")
	addon.db.RegisterCallback(addon, "OnProfileReset", "UpdateModuleConfigs")
	
	--Bartender4 Hooks
	if Bartender4 then
		--Update to the current profile
		DB.BT4Profile = Bartender4.db:GetCurrentProfile()
		Bartender4.db.RegisterCallback(addon, "OnProfileChanged", "BT4RefreshConfig")
		Bartender4.db.RegisterCallback(addon, "OnProfileCopied", "BT4RefreshConfig")
		Bartender4.db.RegisterCallback(addon, "OnProfileReset", "BT4RefreshConfig")
	end

	addon:FontSetup()
end

function addon:InitializeProfile()
	addon.db:RegisterDefaults(DBdefaults)
end

function addon:BT4RefreshConfig()
	DB.BT4Profile = Bartender4.db:GetCurrentProfile()
end

function addon:UpdateModuleConfigs()
	addon.db:RegisterDefaults(DBdefaults)
	
	DB = addon.db.profile.SUIProper
	DBMod = addon.db.profile.Modules
	
	addon:DBUpdates() -- Make sure the profile we loaded is up to date
	
	Bartender4.db:SetProfile(DB.BT4Profile);
	addon:reloadui()
end

function addon:reloadui()
	DB.OpenOptions = true;
	ReloadUI();
end

function addon:OnEnable()
    AceConfig:RegisterOptionsTable("SpartanUIBliz", { name = "SpartanUI", type = "group",args={
		n1={type="description", fontSize="medium", order=1, width="full", name="Options have moved into their own window as this menu was getting a bit crowded."},
		n3={type="description", fontSize="medium", order=3, width="full", name="Options can be accessed by the button below or by typing /sui or /spartanui"},
		Close={name = "Launch Options",width="full",type = "execute",order = 50,
			func = function()
				InterfaceOptionsFrame:Hide();
				AceConfigDialog:SetDefaultSize("SpartanUI", 850, 600);
				AceConfigDialog:Open("SpartanUI");
			end	}
		}
	})
	AceConfigDialog:AddToBlizOptions("SpartanUIBliz", "SpartanUI")
	
    AceConfig:RegisterOptionsTable("SpartanUI", addon.opt)
	if not addon:GetModule("Artwork_Core", true) then addon.opt.args["Artwork"].disabled = true end
    if not addon:GetModule("PartyFrames", true) then  addon.opt.args["PartyFrames"].disabled = true end
    if not addon:GetModule("PlayerFrames", true) then addon.opt.args["PlayerFrames"].disabled = true end
    if not addon:GetModule("RaidFrames", true) then addon.opt.args["RaidFrames"].disabled = true end
    
    self:RegisterChatCommand("sui", "ChatCommand")
    self:RegisterChatCommand("suihelp", "suihelp")
    self:RegisterChatCommand("spartanui", "ChatCommand")
	
	local LaunchOpt = CreateFrame("Frame");
	LaunchOpt:SetScript("OnEvent",function(self,...)
		if DB.OpenOptions then
			addon:ChatCommand()
			DB.OpenOptions = false;
		end
	end);
	LaunchOpt:RegisterEvent("PLAYER_ENTERING_WORLD");
end

function addon:suihelp(input)
	AceConfigDialog:SetDefaultSize("SpartanUI", 850, 600)
	AceConfigDialog:Open("SpartanUI", "General", "Help")
	-- AceConfigDialog:SelectGroup("SpartanUI", spartan.opt.args["General"].args["Help"])
end

function addon:ChatCommand(input)
	if input == "version" then
		addon:Print("SpartanUI "..L["Version"].." "..GetAddOnMetadata("SpartanUI", "Version"))
		addon:Print("SpartanUI Curse "..L["Version"].." "..GetAddOnMetadata("SpartanUI", "X-Curse-Packaged-Version"))
	elseif input == "map" then
		Minimap.mover:Show();
	else
		AceConfigDialog:SetDefaultSize("SpartanUI", 850, 600)
		AceConfigDialog:Open("SpartanUI")
    end
end

function addon:Err(mod, err)
	addon:Print("|cffff0000Error detected")
	addon:Print("An error has been captured in the Component '" .. mod .. "'")
	addon:Print("Details: " .. err)
	addon:Print("Please submit a bug at |cff3370FFhttp://spartanui.net/bugs")
end

---------------		Math and Comparison FUNCTIONS		-------------------------------

function addon:isPartialMatch(frameName, tab)
	local result = false

	for k,v in ipairs(tab) do
		startpos, endpos = strfind(strlower(frameName), strlower(v))
		if (startpos == 1) then
			result = true;
		end
	end

	return result;
end

function addon:isInTable(tab, frameName)
	-- local Count = 0
	-- for Index, Value in pairs( tab ) do
	  -- Count = Count + 1
	-- end
	-- print (Count)
	if tab == nil or frameName == nil then return false end
	for k,v in ipairs(tab) do
		if v ~= nil and frameName ~= nil then
			if (strlower(v) == strlower(frameName)) then
				return true;
			end
		end
	end
	return false;
end

function addon:round(num) -- rounds a number to 2 decimal places
	if num then return floor( (num*10^2)+0.5) / (10^2); end
end;

function addon:comma_value(n)
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1' .. _G.LARGE_NUMBER_SEPERATOR):reverse())..right
end

---------------		FONT FUNCTIONS		---------------------------------------------

function addon:FontSetup()
	local OutlineSizes = {22, 18, 13, 12,11,10,9,8}
	local Sizes = {10}
	for i,v in ipairs(OutlineSizes) do
		local filename, fontHeight, flags = _G["SUI_FontOutline" .. v]:GetFont()
		if filename ~= addon:GetFontFace("Primary") then
			_G["SUI_FontOutline" .. v] = _G["SUI_FontOutline" .. v]:SetFont(addon:GetFontFace("Primary"), v)
		end
	end	
	
	for i,v in ipairs(Sizes) do
		local filename, fontHeight, flags = _G["SUI_Font" .. v]:GetFont()
		if filename ~= addon:GetFontFace("Primary") then
			_G["SUI_Font" .. v] = _G["SUI_Font" .. v]:SetFont(addon:GetFontFace("Primary"), v)
		end
	end
end

function addon:GetFontFace(Module)
	if Module then
		if DB.font[Module].Face == "SpartanUI" then
			return "Interface\\AddOns\\SpartanUI\\media\\font-cognosis.ttf"
		elseif DB.font[Module].Face == "SUI4" then
			return "Interface\\AddOns\\SpartanUI\\media\\NotoSans-Bold.ttf"
		elseif DB.font[Module].Face == "FrizQuadrata" then
			return "Fonts\\FRIZQT__.TTF"
		elseif DB.font[Module].Face == "ArialNarrow" then
			return "Fonts\\ARIALN.TTF"
		elseif DB.font[Module].Face == "Skurri" then
			return "Fonts\\skurri.TTF"
		elseif DB.font[Module].Face == "Morpheus" then
			return "Fonts\\MORPHEUS.TTF"
		elseif DB.font[Module].Face == "Custom" and DB.font.Path ~= "" then
			return DB.font.Path
		end
	end
	
	return "Interface\\AddOns\\SpartanUI\\media\\NotoSans-Bold.ttf"
end

function addon:FormatFont(element, size, Module)
	--Adaptive Modules
	if DB.font[Module] == nil then
		DB.font[Module] = spartan.fontdefault;
	end
	--Set Font Outline
	local flags, sizeFinal = ""
	if DB.font[Module].Type == "monochrome" then flags = flags.."monochrome " end
	
	-- Outline was deemed to thick, it is not a slight drop shadow done below
	--if DB.font[Module].Type == "outline" then flags = flags.."outline " end
	
	if DB.font[Module].Type == "thickoutline" then flags = flags.."thickoutline " end
	--Set Size
	sizeFinal = size + DB.font[Module].Size;
	--Create Font
	element:SetFont(addon:GetFontFace(Module), sizeFinal, flags)
	
	if DB.font[Module].Type == "outline" then
		element:SetShadowColor(0,0,0,.9)
		element:SetShadowOffset(1,-1)
	end
	--Add Item to the Array
	local count = 0
	for _ in pairs(FontItems[Module]) do count = count + 1 end
	FontItems[Module][count+1]=element
	FontItemsSize[Module][count+1]=size
end

function addon:FontRefresh(Module)
	for a,b in pairs(FontItems[Module]) do
		--Set Font Outline
		local flags, size
		if DB.font[Module].Type == "monochrome" then flags = flags.."monochrome " end
		if DB.font[Module].Type == "outline" then flags = flags.."outline " end
		if DB.font[Module].Type == "thickoutline" then flags = flags.."thickoutline " end
		--Set Size
		size = FontItemsSize[Module][a] + DB.font[Module].Size;
		--Update Font
		b:SetFont(addon:GetFontFace(Module), size, flags)
	end
end

