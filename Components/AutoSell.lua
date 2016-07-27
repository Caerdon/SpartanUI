local spartan = LibStub("AceAddon-3.0"):GetAddon("SpartanUI");
-- local L = LibStub("AceLocale-3.0"):GetLocale("SpartanUI", true);
local AceHook = LibStub("AceHook-3.0")
local module = spartan:NewModule("Component_AutoSell", "AceTimer-3.0");
----------------------------------------------------------------------------------------------------
local frame = CreateFrame("FRAME");
local totalValue = 0
local iCount = 0
local iSellCount = 0
local Timer = nil
local bag = 0
local OnlyCount = true
local inSet = {}

function module:OnInitialize()
	if not DB.AutoSell then
		DB.AutoSell = {
			FirstLaunch = true,
			NotCrafting = true,
			NotConsumables = true,
			NotInGearset = true,
			MaxILVL = 600,
			Gray = true,
			White = false,
			Green = false,
			Blue = false,
			Purple = false
		}
	end
	if not DB.AutoSell.NotCrafting then
		DB.AutoSell.NotCrafting = true
		DB.AutoSell.NotConsumables = true
		DB.AutoSell.NotInGearset = true
		DB.AutoSell.MaxILVL = 600
	end
	if not DB.AutoSell.NotConsumables then DB.AutoSell.NotConsumables = true end
end

function module:FirstTime()
	local PageData = {
		SubTitle = "Auto Sell",
		Desc1 = "Automatically vendor items when you visit a merchant.",
		Display = function()
			--Container
			SUI_Win.AutoSell = CreateFrame("Frame", nil)
			SUI_Win.AutoSell:SetParent(SUI_Win.content)
			SUI_Win.AutoSell:SetAllPoints(SUI_Win.content)
			
			--TurnInEnabled
			SUI_Win.AutoSell.Enabled = CreateFrame("CheckButton", "SUI_AutoSell_Enabled", SUI_Win.AutoSell, "OptionsCheckButtonTemplate")
			SUI_Win.AutoSell.Enabled:SetPoint("TOP", SUI_Win.AutoSell, "TOP", -90, -30)
			SUI_AutoSell_EnabledText:SetText("Auto Vendor Enabled")
			SUI_Win.AutoSell.Enabled:HookScript("OnClick", function(this)
				if this:GetChecked() == true then
					SUI_AutoSell_SellGray:Enable()
					SUI_AutoSell_SellGray:SetChecked(true)
					SUI_AutoSell_SellWhite:Enable()
					SUI_AutoSell_SellGreen:Enable()
				else
					SUI_AutoSell_SellGray:Disable()
					SUI_AutoSell_SellWhite:Disable()
					SUI_AutoSell_SellGreen:Disable()
				end
			end)
			
			--SellGray
			SUI_Win.AutoSell.SellGray = CreateFrame("CheckButton", "SUI_AutoSell_SellGray", SUI_Win.AutoSell, "OptionsCheckButtonTemplate")
			SUI_Win.AutoSell.SellGray:SetPoint("TOP", SUI_Win.AutoSell.Enabled, "TOP", -90, -40)
			SUI_Win.AutoSell.SellGray:Disable()
			SUI_AutoSell_SellGrayText:SetText("Sell gray items")
			
			--SellWhite
			SUI_Win.AutoSell.SellWhite = CreateFrame("CheckButton", "SUI_AutoSell_SellWhite", SUI_Win.AutoSell, "OptionsCheckButtonTemplate")
			SUI_Win.AutoSell.SellWhite:SetPoint("TOP", SUI_Win.AutoSell.SellGray, "BOTTOM", 0, -5)
			SUI_Win.AutoSell.SellWhite:Disable()
			SUI_AutoSell_SellWhiteText:SetText("Sell white items")
			
			--SellGreen
			SUI_Win.AutoSell.SellGreen = CreateFrame("CheckButton", "SUI_AutoSell_SellGreen", SUI_Win.AutoSell, "OptionsCheckButtonTemplate")
			SUI_Win.AutoSell.SellGreen:SetPoint("TOP", SUI_Win.AutoSell.SellWhite, "BOTTOM", 0, -5)
			SUI_Win.AutoSell.SellGreen:Disable()
			SUI_AutoSell_SellGreenText:SetText("Sell green items")
		end,
		Next = function()
			DB.AutoSell.FirstLaunch = false
			
			DB.EnabledComponents.AutoSell = (SUI_Win.AutoSell.Enabled:GetChecked() == true or false)
			DB.AutoSell.Gray = (SUI_Win.AutoSell.SellGray:GetChecked() == true or false)
			DB.AutoSell.White = (SUI_Win.AutoSell.SellWhite:GetChecked() == true or false)
			DB.AutoSell.Green = (SUI_Win.AutoSell.SellGreen:GetChecked() == true or false)
			
			SUI_Win.AutoSell:Hide()
			SUI_Win.AutoSell = nil
		end
	}
	local SetupWindow = spartan:GetModule("SetupWindow")
	SetupWindow:AddPage(PageData)
	SetupWindow:DisplayPage()
end

-- Sell Items 5 at a time, sometimes it can sell stuff too fast for the game.
function module:SellTrashInBag()
    if GetContainerNumSlots(bag) == 0 then
		return 0;
	end
	
	local solditem = 0;
	for slot = 1, GetContainerNumSlots(bag) do
		local iLink = GetContainerItemID(bag, slot);
		if module:IsSellable(iLink) then
			if OnlyCount then
				iCount = iCount + 1
			elseif solditem ~= 5 then
				solditem = solditem + 1
				iSellCount = iSellCount + 1
				UseContainerItem(bag, slot);
				totalValue = totalValue + (select(11, GetItemInfo(iLink)) * select(2, GetContainerItemInfo(bag, slot)));
			end
		end
	end
	
	if OnlyCount then return end
	
	if solditem == 5 then
		--Process this bag again.
	elseif bag ~= 4 then
		--Next bag
		bag = bag+1
	else
		--Everything sold
		if (totalValue > 0) then
			spartan:Print("Sold item(s) for " .. module:GetFormattedValue(totalValue));
			totalValue = 0
		end
		module:CancelAllTimers()
	end
end

function module:IsSellable(item)
	if not item then return false end
	local name, link, quality, iLevel, reqLevel, itemType, itemSubType, maxStack, equipSlot, texture, vendorPrice = GetItemInfo(item)
	if vendorPrice == 0 then return false end
	
	-- 0. Poor (gray): Broken I.W.I.N. Button
	-- 1. Common (white): Archmage Vargoth's Staff
	-- 2. Uncommon (green): X-52 Rocket Helmet
	-- 3. Rare / Superior (blue): Onyxia Scale Cloak
	-- 4. Epic (purple): Talisman of Ephemeral Power
	-- 5. Legendary (orange): Fragment of Val'anyr
	-- 6. Artifact (golden yellow): The Twin Blades of Azzinoth
	-- 7. Heirloom (light yellow): Bloodied Arcanite Reaper
	local ilvlsellable = false
	local qualitysellable = false
	local Craftablesellable = false
	local NotInGearset = true
	local NotConsumable = true
	
	if (not iLevel) or (iLevel < DB.AutoSell.MaxILVL) then ilvlsellable = true end
	--Crafting Items
	if ((itemType == "Gem" or itemType == "Reagent" or itemType == "Trade Goods" or itemType == "Tradeskill")
	or (itemType == "Miscellaneous" and itemSubType == "Reagent"))
	then
		if not DB.AutoSell.NotCrafting then Craftablesellable = true end
	else
		Craftablesellable = true
	end
	
	--Gearset detection
	if inSet[item] and DB.AutoSell.NotInGearset then
		NotInGearset = false
	end
	
	--Consumable
	--Tome of the Tranquil Mind is consumable but is identified as Other.
	if DB.AutoSell.NotConsumables and (itemType == "Consumable" or item == 141446) then 
		NotConsumable = false
	end
	
	if quality == 0 and  DB.AutoSell.Gray then qualitysellable = true end
	if quality == 1 and  DB.AutoSell.White then qualitysellable = true end
	if quality == 2 and  DB.AutoSell.Green then qualitysellable = true end
	if quality == 3 and  DB.AutoSell.Blue then qualitysellable = true end
	if quality == 4 and  DB.AutoSell.Purple then qualitysellable = true end
	
	if qualitysellable
	and ilvlsellable
	and Craftablesellable
	and NotInGearset
	and NotConsumable
	and itemType ~= "Quest"
	and itemType ~= "Container"
	then
		return true
	end
	
	return false
end

function module:GetFormattedValue(rawValue)
	local gold = math.floor(rawValue / 10000);
	local silver = math.floor((rawValue % 10000) / 100);
	local copper = (rawValue % 10000) % 100;
	
	return format(GOLD_AMOUNT_TEXTURE.." "..SILVER_AMOUNT_TEXTURE.." "..COPPER_AMOUNT_TEXTURE, gold, 0, 0, silver, 0, 0, copper, 0, 0);
end

function module:SellTrash()
	--Reset Locals
	totalValue = 0
	iCount = 0
	iSellCount = 0
	Timer = nil
	bag = 0
	
	--Populate Gearsets
	for i=1,GetNumEquipmentSets() do
		local name, _ = GetEquipmentSetInfo(i)
		local items = GetEquipmentSetItemIDs(name)
		for slot,item in pairs(items) do
			inSet[item] = name
		end
	end
	
	--Count Items to sell
    OnlyCount=true
	for b = 0, 4 do
		bag = b
		module:SellTrashInBag();
    end
	if iCount == 0 then
		spartan:Print("No items are to be auto sold")
	else
		spartan:Print("Need to sell " .. iCount .. " item(s)")
		--Start Loop to sell, reset locals
		OnlyCount=false
		bag = 0
		-- C_Timer.After(.2, SellTrashInBag)
		self.SellTimer = self:ScheduleRepeatingTimer("SellTrashInBag", .3)
	end
end

function module:OnEnable()
	if DB.AutoSell.FirstLaunch then module:FirstTime() end
	-- if not DB.EnabledComponents.AutoSell then return end
	
	frame:RegisterEvent("MERCHANT_SHOW");
	frame:RegisterEvent("MERCHANT_CLOSED");
	local function MerchantEventHandler(self, event, ...)
		if not DB.EnabledComponents.AutoSell then return end
		if event == "MERCHANT_SHOW" then
			module:SellTrash();
		else
			module:CancelAllTimers()
			if (totalValue > 0) then
				spartan:Print("Sold items for " .. module:GetFormattedValue(totalValue));
				totalValue = 0
			end
		end
	end
	frame:SetScript("OnEvent", MerchantEventHandler);
	module:BuildOptions()
end

function module:BuildOptions()
	spartan.opt.args["ModSetting"].args["AutoSell"] = {type="group",name="Auto Sell",
		args = {
			NotCrafting = {name="Don't Sell crafting items",type="toggle",order=1,width = "full",
					get = function(info) return DB.AutoSell.NotCrafting end,
					set = function(info,val) DB.AutoSell.NotCrafting = val end
			},
			NotConsumables = {name="Don't Sell Consumables",type="toggle",order=1,width = "full",
					get = function(info) return DB.AutoSell.NotConsumables end,
					set = function(info,val) DB.AutoSell.NotConsumables = val end
			},
			NotInGearset = {name="Don't Sell items in a equipment set",type="toggle",order=2,width = "full",
					get = function(info) return DB.AutoSell.NotInGearset end,
					set = function(info,val) DB.AutoSell.NotInGearset = val end
			},
			MaxILVL ={name = "Maximum iLVL to sell",type = "range",order = 10,width = "full",min = 1,max = 900,step=1,
				set = function(info,val) DB.AutoSell.MaxILVL = val; end,
				get = function(info) return DB.AutoSell.MaxILVL; end
			},
			Gray = {name="Sell Gray",type="toggle",order=20,width="double",
					get = function(info) return DB.AutoSell.Gray end,
					set = function(info,val) DB.AutoSell.Gray = val end
			},
			White = {name="Sell White",type="toggle",order=21,width="double",
					get = function(info) return DB.AutoSell.White end,
					set = function(info,val) DB.AutoSell.White = val end
			},
			Green = {name="Sell Green",type="toggle",order=22,width="double",
					get = function(info) return DB.AutoSell.Green end,
					set = function(info,val) DB.AutoSell.Green = val end
			},
			Blue = {name="Sell Blue",type="toggle",order=23,width="double",
					get = function(info) return DB.AutoSell.Blue end,
					set = function(info,val) DB.AutoSell.Blue = val end
			},
			Purple = {name="Sell Purple",type="toggle",order=24,width="double",
					get = function(info) return DB.AutoSell.Purple end,
					set = function(info,val) DB.AutoSell.Purple = val end
			}
		}
	}
end