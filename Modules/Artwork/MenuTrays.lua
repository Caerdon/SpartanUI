local _G, SUI = _G, SUI
local module = SUI:GetModule('Artwork_Core')


local trayWatcherEvents = function()
	module:updateOffset()
	local trayIDs = {'left', 'right'}
	War_MenuBarBG:SetAlpha(0)
	War_StanceBarBG:SetAlpha(0)

	for _, key in ipairs(trayIDs) do
		if SUI.DB.Styles.War.SlidingTrays[key].collapsed then
			module.Trays[key].expanded:Hide()
			module.Trays[key].collapsed:Show()
			SetBarVisibility(module.Trays[key], 'hide')
		else
			module.Trays[key].expanded:Show()
			module.Trays[key].collapsed:Hide()
			SetBarVisibility(module.Trays[key], 'show')
		end
	end
end

function module:trayWatcherEvents()
	trayWatcherEvents()
end

-- Artwork Stuff
function module:SlidingTrays(settings)
	War_MenuBarBG:SetAlpha(0)
	War_StanceBarBG:SetAlpha(0)

	for _, key in ipairs(settings.trayIDs) do
		local tray = CreateFrame('Frame', nil, UIParent)
		tray:SetFrameStrata('BACKGROUND')
		tray:SetAlpha(.8)
		tray:SetSize(400, 45)

		local expanded = CreateFrame('Frame', nil, tray)
		expanded:SetAllPoints()
		local collapsed = CreateFrame('Frame', nil, tray)
		collapsed:SetAllPoints()

		local bg = expanded:CreateTexture(nil, 'BACKGROUND', expanded)
		bg:SetTexture('Interface\\AddOns\\SpartanUI_Style_War\\Images\\Trays-' .. UnitFactionGroup('Player'))
		bg:SetAllPoints()
		bg:SetTexCoord(0.076171875, 0.92578125, 0, 0.18359375)

		local bgCollapsed = collapsed:CreateTexture(nil, 'BACKGROUND', collapsed)
		bgCollapsed:SetTexture('Interface\\AddOns\\SpartanUI_Style_War\\Images\\Trays-' .. UnitFactionGroup('Player'))
		bgCollapsed:SetPoint('TOPLEFT', tray)
		bgCollapsed:SetPoint('TOPRIGHT', tray)
		bgCollapsed:SetHeight(18)
		bgCollapsed:SetTexCoord(0.076171875, 0.92578125, 1, 0.92578125)

		local btnUp = CreateFrame('BUTTON', nil, expanded)
		local UpTex = expanded:CreateTexture()
		UpTex:SetTexture('Interface\\AddOns\\SpartanUI_Style_War\\Images\\Trays-' .. UnitFactionGroup('Player'))
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
		DownTex:SetTexture('Interface\\AddOns\\SpartanUI_Style_War\\Images\\Trays-' .. UnitFactionGroup('Player'))
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

		if SUI.DB.Styles.War.SlidingTrays[key].collapsed then
			tray.expanded:Hide()
			SetBarVisibility(key, 'hide')
		else
			tray.collapsed:Hide()
		end
		module.Trays[key] = tray
	end

	module.Trays.left:SetPoint('TOP', UIParent, 'TOP', -300, 0)
	module.Trays.right:SetPoint('TOP', UIParent, 'TOP', 300, 0)

	trayWatcher:SetScript('OnEvent', trayWatcherEvents)
	trayWatcher:RegisterEvent('PLAYER_LOGIN')
	trayWatcher:RegisterEvent('PLAYER_ENTERING_WORLD')
	trayWatcher:RegisterEvent('ZONE_CHANGED')
	trayWatcher:RegisterEvent('ZONE_CHANGED_INDOORS')
	trayWatcher:RegisterEvent('ZONE_CHANGED_NEW_AREA')

	-- Default movetracker ignores stuff attached to UIParent (Tray items are)
	local FrameList = {
		BT4BarBagBar,
		BT4BarStanceBar,
		BT4BarPetBar,
		BT4BarMicroMenu
	}

	for _, v in ipairs(FrameList) do
		if v then
			v.SavePosition = function()
				if not SUI.DB.Styles[SUI.DBMod.Artwork.Style].MovedBars[v:GetName()] and not SUI.DBG.BartenderChangesActive then
					SUI.DB.Styles[SUI.DBMod.Artwork.Style].MovedBars[v:GetName()] = true
					LibStub('LibWindow-1.1').windowData[v].storage.parent = UIParent
					v:SetParent(UIParent)
				end

				LibStub('LibWindow-1.1').SavePosition(v)
			end
		end
	end
end
