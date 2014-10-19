local spartan = LibStub("AceAddon-3.0"):GetAddon("SpartanUI");
local L = LibStub("AceLocale-3.0"):GetLocale("SpartanUI", true);
local Artwork_Core = spartan:GetModule("Artwork_Core");

function Artwork_Core:SetupOptions()
	Profiles = {}
	for name, module in spartan:IterateModules() do
		if (string.match(name, "Artwork_") and name ~= "Artwork_Core") then
			Profiles[string.sub(name, 9)] = string.sub(name, 9)
		end
	end
	spartan.opt.Artwork.args["Profile"] = {name="Profile",type="select",order=0,style="dropdown",
		values=Profiles,
		get = function(info) return DBMod.Artwork.Theme end,
		set = function(info,val) 
			DBMod.Artwork.FirstLoad = true
			DBMod.Artwork.Theme = val;
			newtheme = spartan:GetModule("Artwork_"..val)
			newtheme:CreateProfile();
			ReloadUI();
		end
	}
	spartan.opt.Artwork.args["Reload"] = {name = "ReloadUI",type = "execute",order=2,
		desc = L["ResetDatabaseDesc"],
		func = function() ReloadUI(); end
	};
	spartan.opt.Artwork.args["Global"] = {name = "Base Options",type="group",order=0,
		args = {
			viewport = {name = "Viewport Enabled", type = "toggle",order=1,
				desc="Allow SpartanUI To manage the viewport",
				get = function(info) return DB.viewport end,
				set = function(info,val)
					if (not val) then
						--Since we are disabling reset the viewport
						WorldFrame:ClearAllPoints();
						WorldFrame:SetPoint("TOPLEFT", 0, 0);
						WorldFrame:SetPoint("BOTTOMRIGHT", 0, 0);
					end
					DB.viewport = val
					if (not DB.viewport) then
						spartan.opt.Artwork.args["Global"].args["viewportoffsetTop"].disabled = true;
						spartan.opt.Artwork.args["Global"].args["viewportoffsetBottom"].disabled = true;
						spartan.opt.Artwork.args["Global"].args["viewportoffsetLeft"].disabled = true;
						spartan.opt.Artwork.args["Global"].args["viewportoffsetRight"].disabled = true;
					else
						spartan.opt.Artwork.args["Global"].args["viewportoffsetTop"].disabled = false;
						spartan.opt.Artwork.args["Global"].args["viewportoffsetBottom"].disabled = false;
						spartan.opt.Artwork.args["Global"].args["viewportoffsetLeft"].disabled = false;
						spartan.opt.Artwork.args["Global"].args["viewportoffsetRight"].disabled = false;
					end
				end,
			},
			viewportoffsets = {
				name = "Viewport offset",order=2,type = "description", fontSize = "large"
			},
			viewportoffsetTop = {name = "Top",type = "range",width="normal",order=2.1,
				min=-100,max=100,step=.1,
				get = function(info) return DBMod.Artwork.Viewport.offset.top end,
				set = function(info,val) DBMod.Artwork.Viewport.offset.top = val; end,
			},
			viewportoffsetBottom = {name = "Bottom",type = "range",width="normal",order=2.2,
				min=-100,max=100,step=.1,
				get = function(info) return DBMod.Artwork.Viewport.offset.bottom end,
				set = function(info,val) DBMod.Artwork.Viewport.offset.bottom = val; end,
			},
			viewportoffsetLeft = {name = "Left",type = "range",width="normal",order=2.3,
				min=-100,max=100,step=.1,
				get = function(info) return DBMod.Artwork.Viewport.offset.left end,
				set = function(info,val) DBMod.Artwork.Viewport.offset.left = val; end,
			},
			viewportoffsetRight = {name = "Right",type = "range",width="normal",order=2.4,
				min=-100,max=100,step=.1,
				get = function(info) return DBMod.Artwork.Viewport.offset.right end,
				set = function(info,val) DBMod.Artwork.Viewport.offset.right = val; end,
			},
		}
	}
	
	if (not DB.viewport) then
		spartan.opt.Artwork.args["Global"].args["viewportoffsetTop"].disabled = true;
		spartan.opt.Artwork.args["Global"].args["viewportoffsetBottom"].disabled = true;
		spartan.opt.Artwork.args["Global"].args["viewportoffsetLeft"].disabled = true;
		spartan.opt.Artwork.args["Global"].args["viewportoffsetRight"].disabled = true;
	end
end