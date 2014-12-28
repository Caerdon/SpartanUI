local spartan = LibStub("AceAddon-3.0"):GetAddon("SpartanUI");
local L = LibStub("AceLocale-3.0"):GetLocale("SpartanUI", true);
local AceConfig = LibStub("AceConfig-3.0");
local AceConfigDialog = LibStub("AceConfigDialog-3.0");
local module = spartan:NewModule("Options");
---------------------------------------------------------------------------

function module:OnInitialize()
	spartan.opt.args["General"].args["SuiVersion"] = {name = "SpartanUI "..L["Version"]..": "..spartan.SpartanVer,order=1,type = "header"};
	if (spartan.SpartanVer ~= spartan.CurseVersion) then
		spartan.opt.args["General"].args["CurseVersion"] = {name = "Build "..spartan.CurseVersion,order=1.1,type = "header"};
	end
	-- spartan.opt.args["General"].args["reset"] = {name = ,type = "execute",order=999,
		-- desc = ,
		-- func = function()
			-- if (InCombatLockdown()) then 
				-- spartan:Print(ERR_NOT_IN_COMBAT);
			-- else
				-- spartan.db:ResetDB();
				-- ReloadUI();
			-- end
		-- end
	-- };
	spartan.opt.args["General"].args["font"] = {name = L["FontSizeStyle"], type = "group",order = 200,
		args = {
			a = {name=L["GFontSet"],type="header"},
			b = {name = L["FontType"], type="select",
				values = {["SpartanUI"]="SpartanUI",["FrizQuadrata"]="Friz Quadrata",["ArialNarrow"]="Arial Narrow",["Skurri"]="Skurri",["Morpheus"]="Morpheus"},
				get = function(info) return DB.font.Primary.Face; end,
				set = function(info,val) DB.font.Primary.Face = val; end
			},
			c = {name = L["FontStyle"], type="select",
				values = {["normal"]=L["normal"], ["monochrome"]=L["monochrome"], ["outline"]=L["outline"], ["thickoutline"]=L["thickoutline"]},
				get = function(info) return DB.font.Primary.Type; end,
				set = function(info,val) DB.font.Primary.Type = val; end
			},
			d = {name = L["AdjFontSize"], type="range",width="double",
				min=-3,max=3,step=1,
				get = function(info) return DB.font.Primary.Size; end,
				set = function(info,val) DB.font.Primary.Size = val; end
			},
			z = {name = L["AplyGlobal"].." "..L["AllSet"], type="execute",width="double",
				func = function()
					DB.font.Core.Face = DB.font.Primary.Face;
					DB.font.Core.Type = DB.font.Primary.Type;
					DB.font.Core.Size = DB.font.Primary.Size;
					DB.font.Player.Face = DB.font.Primary.Face;
					DB.font.Player.Type = DB.font.Primary.Type;
					DB.font.Player.Size = DB.font.Primary.Size;
					DB.font.Party.Face = DB.font.Primary.Face;
					DB.font.Party.Type = DB.font.Primary.Type;
					DB.font.Party.Size = DB.font.Primary.Size;
					DB.font.Raid.Face = DB.font.Primary.Face;
					DB.font.Raid.Type = DB.font.Primary.Type;
					DB.font.Raid.Size = DB.font.Primary.Size;
					spartan:FontRefresh("Core");
					spartan:FontRefresh("Player");
					spartan:FontRefresh("Party");
					spartan:FontRefresh("Raid");
				end
			},
		
			Core = {name = L["CoreSet"],type = "group",
				args = {
					CFace = {name = L["FontType"], type="select", order = 1,
						values = {["SpartanUI"]="SpartanUI",["FrizQuadrata"]="Friz Quadrata",["ArialNarrow"]="Arial Narrow",["Skurri"]="Skurri",["Morpheus"]="Morpheus"},
						get = function(info) return DB.font.Core.Face; end,
						set = function(info,val) DB.font.Core.Face = val; spartan:FontRefresh("Core") end
					},
					COutline = {name = L["FontStyle"], type="select", order = 2,
						values = {["normal"]=L["normal"], ["monochrome"]=L["monochrome"], ["outline"]=L["outline"], ["thickoutline"]=L["thickoutline"]},
						get = function(info) return DB.font.Core.Type; end,
						set = function(info,val) DB.font.Core.Type = val; spartan:FontRefresh("Core") end
					},
					CSize = {name = L["AdjFontSize"], type="range", order = 3,width="full",
						min=-3,max=3,step=1,
						get = function(info) return DB.font.Core.Size; end,
						set = function(info,val) DB.font.Core.Size = val; spartan:FontRefresh("Core") end
					}
				}
			},
			Player = {name = L["PlayerSet"],type = "group",
				disabled = function(info) if not spartan:GetModule("PlayerFrames", true) then return true end end,
				args = {
					PlFace = {name = L["FontType"], type="select", order = 1,
						values = {["SpartanUI"]="SpartanUI",["FrizQuadrata"]="Friz Quadrata",["ArialNarrow"]="Arial Narrow",["Skurri"]="Skurri",["Morpheus"]="Morpheus"},
						get = function(info) return DB.font.Player.Face; end,
						set = function(info,val) DB.font.Player.Face = val; spartan:FontRefresh("Player") end
					},
					PlOutline = {name = L["FontStyle"], type="select", order = 2,
						values = {["normal"]=L["normal"], ["monochrome"]=L["monochrome"], ["outline"]=L["outline"], ["thickoutline"]=L["thickoutline"]},
						get = function(info) return DB.font.Player.Type; end,
						set = function(info,val) DB.font.Player.Type = val; spartan:FontRefresh("Player") end
					},
					PlSize = {name = L["AdjFontSize"], type="range", order = 3,width="full",
						min=-3,max=3,step=1,
						get = function(info) return DB.font.Player.Size; end,
						set = function(info,val) DB.font.Player.Size = val; spartan:FontRefresh("Player") end
					}
				}
			},
			Party = {name = L["PartySet"],type = "group",
				disabled = function(info) if not spartan:GetModule("PartyFrames", true) then return true end end,
				args = {
					PaFace = {name = L["FontType"], type="select", order = 1,
						values = {["SpartanUI"]="SpartanUI",["FrizQuadrata"]="Friz Quadrata",["ArialNarrow"]="Arial Narrow",["Skurri"]="Skurri",["Morpheus"]="Morpheus"},
						get = function(info) return DB.font.Party.Face; end,
						set = function(info,val) DB.font.Party.Face = val; spartan:FontRefresh("Party") end
					},
					PaOutline = {name = L["FontStyle"], type="select", order = 2,
						values = {["normal"]=L["normal"], ["monochrome"]=L["monochrome"], ["outline"]=L["outline"], ["thickoutline"]=L["thickoutline"]},
						get = function(info) return DB.font.Party.Type; end,
						set = function(info,val) DB.font.Party.Type = val; spartan:FontRefresh("Party") end
					},
					PaSize = {name = L["AdjFontSize"], type="range", order = 3,width="full",
						min=-3,max=3,step=1,
						get = function(info) return DB.font.Party.Size; end,
						set = function(info,val) DB.font.Party.Size = val; spartan:FontRefresh("Party") end
					}
				}
			},
			raid = {name = L["RaidSet"],type = "group",
				disabled = function(info) if not spartan:GetModule("RaidFrames", true) then return true end end,
				args = {
					RFace = {name = L["FontType"], type="select", order = 1,
						values = {["SpartanUI"]="SpartanUI",["FrizQuadrata"]="Friz Quadrata",["ArialNarrow"]="Arial Narrow",["Skurri"]="Skurri",["Morpheus"]="Morpheus"},
						get = function(info) return DB.font.Raid.Face; end,
						set = function(info,val) DB.font.Raid.Face = val; spartan:FontRefresh("Raid") end
					},
					ROutline = {name = L["FontStyle"], type="select", order = 2,
						values = {["normal"]=L["normal"], ["monochrome"]=L["monochrome"], ["outline"]=L["outline"], ["thickoutline"]=L["thickoutline"]},
						get = function(info) return DB.font.Raid.Type; end,
						set = function(info,val) DB.font.Raid.Type = val; spartan:FontRefresh("Raid") end
					},
					RSize = {name = L["AdjFontSize"], type="range", order = 3,width="full",
						min=-3,max=3,step=1,
						get = function(info) return DB.font.Raid.Size; end,
						set = function(info,val) DB.font.Raid.Size = val; spartan:FontRefresh("Raid") end
					}
				}
			},
		}
	};
	spartan.opt.args["General"].args["Help"] = {name = "Help", type = "group", order = 900,
		args = {
			ResetDB			= {name = L["ResetDatabase"], type = "execute", width= "double",order=1, func = function() spartan.db:ResetDB(); ReloadUI(); end},
			ResetArtwork	= {name = "Reset ActionBars", type = "execute", width= "double",order=2, func = function() DBMod.Artwork.FirstLoad = true; spartan:GetModule("Artwork_"..DBMod.Artwork.Style):SetupProfile(); ReloadUI(); end},
			
			navigationissues = {name="Have a Question?",type="description",order = 100,fontSize="large"},
			navigationissues2 = {name="    -|cff6666FF http://faq.spartanui.net/",type="description",order = 101,fontSize="medium"},
			
			bugsandfeatures = {name="Bugs & Feature Requests:",type="description",order = 200,fontSize="large"},
			bugsandfeatures2 = {name="     -|cff6666FF http://bugs.spartanui.net/",type="description",order = 201,fontSize="medium"},
			bugsandfeatures3 = {name="     -|cff6666FF http://wow.curseforge.com/addons/spartan-ui/tickets/",type="description",order = 202,fontSize="medium"},
			
			
			line = {name="",type="header",order = 900},
			description = {name="Providing the below string can assist in helping you when you are having issues",type="description",order = 901,fontSize="large"},
			dataDump = {name="Export",type="input",multiline=10,width="full",order=990,get = function(info) return module:enc(module:ExportData()) end},
			description = {name="This string contains your Spec, Region, SpartanUI Settings, and a list of running addons.",type="description",order = 999,fontSize="small"},
			}
		}
	-- };
	
end

function module:ExportData()

    CharData = {
		Region = GetCurrentRegion(),
		PlayerName = UnitName("player"),
		PlayerLevel = UnitLevel("player"),
		ActiveSpec = GetSpecializationInfo(GetSpecialization())
	}
	
	return "$SUI." .. spartan.SpartanVer .. "-" .. spartan.CurseVersion
		.. "$C." .. module:FlatenTable(CharData)
		.. "$DB." .. module:FlatenTable(DB)
		.. "$DBMod." .. module:FlatenTable(DBMod)
end

function module:FlatenTable(input)
	returnval = ""
	for key,value in pairs(input) do
		if (type(value) == "table") then
			returnval = returnval .. key .. "= {" .. module:FlatenTable(value) .. "},"
		elseif (type(value) ~= "string") then
			returnval = returnval .. key .. "=" .. tostring(value) .. ","
		else
			returnval = returnval .. key .. "=" .. value .. ","
		end
	end
	return returnval
end

local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
-- encoding
function module:enc(data)
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end
 
-- decoding
function module:dec(data)

    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(7-i) or 0) end
        return string.char(c)
    end))
end
