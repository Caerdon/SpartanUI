local spartan = LibStub("AceAddon-3.0"):GetAddon("SpartanUI");
local L = LibStub("AceLocale-3.0"):GetLocale("SpartanUI", true);
local Artwork_Core = spartan:GetModule("Artwork_Core");
local module = spartan:GetModule("Style_Minimal");
----------------------------------------------------------------------------------------------------
local anchor, frame = Minimal_AnchorFrame, Minimal_SpartanUI, CurScale

function module:updateViewport() -- handles viewport offset based on settings
	if not InCombatLockdown() then
		WorldFrame:ClearAllPoints();
		WorldFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0);
		WorldFrame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0);
	end
end;

function module:updateScale() -- scales SpartanUI based on setting or screen size
	if (not DB.scale) then -- make sure the variable exists, and auto-configured based on screen size
		local width, height = string.match(GetCVar("gxResolution"),"(%d+).-(%d+)");
		if (tonumber(width) / tonumber(height) > 4/3) then DB.scale = 0.92;
		else DB.scale = 0.78; end
	end
	if DB.scale ~= CurScale then
		module:updateViewport();
		if (DB.scale ~= Artwork_Core:round(Minimal_SpartanUI:GetScale())) then
			frame:SetScale(DB.scale);
		end
		
		-- Minimal_SpartanUI_Base3:ClearAllPoints();
		-- Minimal_SpartanUI_Base5:ClearAllPoints();
		-- Minimal_SpartanUI_Base3:SetPoint("RIGHT", Minimal_SpartanUI_Base2, "LEFT");
		-- Minimal_SpartanUI_Base5:SetPoint("LEFT", Minimal_SpartanUI_Base4, "RIGHT");
		
		CurScale = DB.scale
	end
end;

function module:updateOffset() -- handles SpartanUI offset based on setting or fubar / titan
	local fubar,ChocolateBar,titan,offset = 0,0,0;

	if not DB.yoffsetAuto then
		offset = max(DB.yoffset,1);
	else
		for i = 1,4 do -- FuBar Offset
			if (_G["FuBarFrame"..i] and _G["FuBarFrame"..i]:IsVisible()) then
				local bar = _G["FuBarFrame"..i];
				local point = bar:GetPoint(1);
				if point == "BOTTOMLEFT" then fubar = fubar + bar:GetHeight(); end
			end
		end
		for i = 1,100 do -- Chocolate Bar Offset
			if (_G["ChocolateBar"..i] and _G["ChocolateBar"..i]:IsVisible()) then
				local bar = _G["ChocolateBar"..i];
				local point = bar:GetPoint(1);
				--if point == "TOPLEFT" then ChocolateBar = ChocolateBar + bar:GetHeight(); 	end--top bars
				if point == "RIGHT" then ChocolateBar = ChocolateBar + bar:GetHeight(); 	end-- bottom bars
			end
		end
		TitanBarOrder = {[1]="AuxBar2", [2]="AuxBar"} -- Bottom 2 Bar names
		for i=1,2 do -- Titan Bar Offset
			if (_G["Titan_Bar__Display_"..TitanBarOrder[i]] and TitanPanelGetVar(TitanBarOrder[i].."_Show")) then
				local PanelScale = TitanPanelGetVar("Scale") or 1
				local bar = _G["Titan_Bar__Display_"..TitanBarOrder[i]]
				titan = titan + (PanelScale * bar:GetHeight());
			end
		end
		
		offset = max(fubar + titan + ChocolateBar,1);
	end
	if (Artwork_Core:round(offset) ~= Artwork_Core:round(anchor:GetHeight())) then anchor:SetHeight(offset); end
	DB.yoffset = offset
end;

function module:updateXOffset() -- handles SpartanUI offset based on setting or fubar / titan
	if not DB.xOffset then return 0; end
	local offset = DB.xOffset
	if Artwork_Core:round(offset) <= -300 then
		Minimal_SpartanUI_Base5:ClearAllPoints();
		Minimal_SpartanUI_Base5:SetPoint("LEFT", Minimal_SpartanUI_Base4, "RIGHT");
		Minimal_SpartanUI_Base5:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT");
	elseif Artwork_Core:round(offset) >= 300 then
		Minimal_SpartanUI_Base3:ClearAllPoints();
		Minimal_SpartanUI_Base3:SetPoint("RIGHT", Minimal_SpartanUI_Base2, "LEFT");
		Minimal_SpartanUI_Base3:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT");
	end
	Minimal_SpartanUI:SetPoint("LEFT", Minimal_AnchorFrame, "LEFT", offset, 0)
	if (Artwork_Core:round(offset) ~= Artwork_Core:round(anchor:GetWidth())) then anchor:SetWidth(offset); end
	DB.xOffset = offset
end;

----------------------------------------------------------------------------------------------------

function module:SetColor()
	local r = 0.6156862745098039
	local b = 0.1215686274509804
	local g = 0.1215686274509804
	local a = .9
	
	for i = 1,2 do
		_G["Minimal_Top_Bar" ..i.. "BG"]:SetVertexColor(r,b,g,a)
	end
	for i = 1,5 do
		_G["Minimal_SpartanUI_Base" ..i]:SetVertexColor(r,b,g,a)
	end
	-- Minimal_SpartanUI:SetVertexColor(0,.8,.9,.1)
end

function module:InitFramework()
	do -- default interface modifications
		SUI_FramesAnchor:SetFrameStrata("BACKGROUND");
		SUI_FramesAnchor:SetFrameLevel(1);
		SUI_FramesAnchor:SetParent(Minimal_SpartanUI);
		SUI_FramesAnchor:ClearAllPoints();
		SUI_FramesAnchor:SetPoint("BOTTOMLEFT", "Minimal_AnchorFrame", "TOPLEFT", 0, 0);
		SUI_FramesAnchor:SetPoint("TOPRIGHT", "Minimal_AnchorFrame", "TOPRIGHT", 0, 155);
		
		FramerateLabel:ClearAllPoints();
		FramerateLabel:SetPoint("TOP", "WorldFrame", "TOP", -15, -50);
		
		MainMenuBar:Hide();
		hooksecurefunc(Minimal_SpartanUI,"Hide",function() module:updateViewport(); end);
		hooksecurefunc(Minimal_SpartanUI,"Show",function() module:updateViewport(); end);
		--Minimal_SpartanUI:SetAlpha(.5);
		--Minimal_SpartanUI:SetVertexColor(0,.8,.9,.1)
		
		hooksecurefunc("UpdateContainerFrameAnchors",function() -- fix bag offsets
			local frame, xOffset, yOffset, screenHeight, freeScreenHeight, leftMostPoint, column
			local screenWidth = GetScreenWidth()
			local containerScale = 1
			local leftLimit = 0
			if ( BankFrame:IsShown() ) then
				leftLimit = BankFrame:GetRight() - 25
			end
			while ( containerScale > CONTAINER_SCALE ) do
				screenHeight = GetScreenHeight() / containerScale
				-- Adjust the start anchor for bags depending on the multibars
				xOffset = 1 / containerScale
				yOffset = 155;
				-- freeScreenHeight determines when to start a new column of bags
				freeScreenHeight = screenHeight - yOffset
				leftMostPoint = screenWidth - xOffset
				column = 1
				local frameHeight
				for index, frameName in ipairs(ContainerFrame1.bags) do
					frameHeight = getglobal(frameName):GetHeight()
					if ( freeScreenHeight < frameHeight ) then
						-- Start a new column
						column = column + 1
						leftMostPoint = screenWidth - ( column * CONTAINER_WIDTH * containerScale ) - xOffset
						freeScreenHeight = screenHeight - yOffset
					end
					freeScreenHeight = freeScreenHeight - frameHeight - VISIBLE_CONTAINER_SPACING
				end
				if ( leftMostPoint < leftLimit ) then
					containerScale = containerScale - 0.01
				else
					break
				end
			end
			if ( containerScale < CONTAINER_SCALE ) then
				containerScale = CONTAINER_SCALE
			end
			screenHeight = GetScreenHeight() / containerScale
			-- Adjust the start anchor for bags depending on the multibars
			xOffset = 1 / containerScale
			yOffset = 154
			-- freeScreenHeight determines when to start a new column of bags
			freeScreenHeight = screenHeight - yOffset
			column = 0
			for index, frameName in ipairs(ContainerFrame1.bags) do
				frame = getglobal(frameName)
				frame:SetScale(containerScale)
				if ( index == 1 ) then
					-- First bag
					frame:SetPoint("BOTTOMRIGHT", frame:GetParent(), "BOTTOMRIGHT", -xOffset, (yOffset + (DB.yoffset or 1)) * (DB.scale or 1) )
				elseif ( freeScreenHeight < frame:GetHeight() ) then
					-- Start a new column
					column = column + 1
					freeScreenHeight = screenHeight - yOffset
					frame:SetPoint("BOTTOMRIGHT", frame:GetParent(), "BOTTOMRIGHT", -(column * CONTAINER_WIDTH) - xOffset, yOffset )
				else
					-- Anchor to the previous bag
					frame:SetPoint("BOTTOMRIGHT", ContainerFrame1.bags[index - 1], "TOPRIGHT", 0, CONTAINER_SPACING)
				end
				freeScreenHeight = freeScreenHeight - frame:GetHeight() - VISIBLE_CONTAINER_SPACING
			end
		end);
		hooksecurefunc(GameTooltip,"SetPoint",function(tooltip,point,parent,rpoint) -- fix GameTooltip offset
			if (point == "BOTTOMRIGHT" and parent == "UIParent" and rpoint == "BOTTOMRIGHT") then
				tooltip:ClearAllPoints();
				tooltip:SetPoint("BOTTOMRIGHT",Minimal_SpartanUI,"BOTTOMRIGHT",-20,20);
			end
		end);
	end
end

function module:SetupVehicleUI()
	if DBMod.Artwork.VehicleUI then��#������d��t�P   [o9�̗��� ݐ����Bu	   �
ä�e43��Ћ?�����   +9���~�m�6�A�����_   �B�����n����׵y��   -R��M���lB���4�   �^�iU���$RK��u�   �?��=�#y�o���}��    d����s�#�5P���e�   Zޫ�}C�I���T���
  %�@���\���p�=  �鵴q���؄y�y��   Qkp��$@JA{j��p�p   �KL����d���9��٧fL   )�缭*��.�����'ad   Y?����e�"v���|�^�  ¢q�ūl������7ױ   ^ݦ�q������q�?)�)   seݪ��뫝����r�8  "���eu��Qj����}2�   �=����]��s7���"�;`          �������e�nÞ�`�9�  ���i�7�W����-G�{  ����I�R;A���
��   �PG�����n ���c��    c\`�g�s{��-���)/�   =�ˉm���0�g���䮩��  AQ��i�k��~��Q�   n֮Y�)���a��N��Z   �ޓ��e�6�/���z4��  (�}���_�Gk]����:�    �Z��f��Z�������i   �o��l鏋�V��,�=�   IaS��*�m��&;��Nm   �(��`1��1w����m   5���ϗ=D���/�/�   /=O���σ_��4��0�8�  �P�+�E ���7T�   ������]5�	�	��K�L$   /��G[���(?'`�k S#:   _���"Ϩ�Ǆ���X���  T�	��|DA0epb���Ug4           �6b�RV,C+�8��5���  ���v1������>t��  ��MKSӄ�Z
��,Z�b  �Z�5ќ�r�0����   =�k��o[1-GQ���v�;  �hٗ��kPz���&�K%�  ewO�%���Ҍ��1^>f   ������EB���Z���   ��6�6ߗS�W��d<+�U   ��ɗz�1ǣ_xt�o�/   i?D��מ��<�oy�'   	����L������c�i�   m���p��U������BQ   B7��w@�,�������^<a7    ?��M��w�����(T   �<��˄m�}��̤�%   �iޥc�G�@e0a��R@�5   #�/Ξ�������řk�A   ���>T����{a��9�   ��}�1�I'̂�A����9   ]���1�/g#�H��&�g=F          �Jh��I�W�Ͷ�[�-Ol   ?����wT(2PE��-tcp)   B������H�Rr�.1�V1   VR/����wLU4���)"�c  1���x��k���ܹ�*  C[��z�����R���)��   z������+��U��
�w  Y�7�v�e��m�X��b�r�   v�chNk����0�A�   ����� ��بbþ�C�  ������G�gf}�t�i��F   �	�~�^o�X�[�k�KT   A��c?XRvE���}_��6  �7ʐ�L��я��CԀ_�y   �Z��.���s�$�ԃĜSM   ��YŪI0ٵ��?ԋ�%�n   ~��X
�ګ�EW�џ�>   �ܬ�a$.ǿ�8�i�`�  j��2k%�'���:i��   :3��yȰ���6�W4�|A   ʓ��Wݞ+�.HVp�b�i�,           tJ�86q��g�ek�3   \	��\`\��@K�h!�m   '���g�g���7�i�t   �Sm�.����_��jݍ�C   �R�l�7�Ԍ��o�2�    �j��3�e��v�p�$   P���ɒ8�#Όv-ՏT�F   q�� vq{�`���Ցb�p7   �{��`Sc��eL�Ց��>   ڼZ�����$�|�,ՒJ�   ����YGy*�Cwy�՚D�L   yA�����i�Fo՝ThK{   ��i�����j��եŎ�   ������7~p��զ !   9�h���Q�IL���զ�v�U   ̒��Te3�ջ{C8,   �����9�Q�@cվI5   >����N��h7��˱�  �⭃�؈n��,�(��  �W�+B��j䊏=ւŲ5:   N�y���E�`�	8���rP3�          ��4�����m*��/F��,   �]����GK�A��RA_�0   �3�S�s^�:)���R���0   ���0C���Wa]��W��L0   �ٸ�2QZXL8��v ^��  p�ҽ��}Ӑ�׺�^�O   ����vB�;l׿@[��   �Or��oͻ���8|�&^!   ι��~f@+;R��*JzMd   ������>x�.�,(b�(   �X�y�(\Ė��.bZ  �&��Lm�hj��E��:   [�F��^W��U�N�}  ߕ�t�y��u����e����   =�4����!w��fU/#   ��Z���m�$���-؈���l   ����Vgb*���[���0{�  Ӆ��-��*���v��D�W  ���jf�'h��c��to~  MS8ϻܵ��#N��ޚ�   r�f����03�#�uF_ؠ           2�Ş�7X���D:���c   YdH��/�!�d�QMڄS�eJ   �ӣ��V�\Qlڄ�K�I   �K��\�oV�-e��ڋ���H   5P�`�y�g*$ڏmK l   |���
��l���ړ��06   ̴��	� p�t�ڔ)za%   IYD�+��&���2ڔs.   W���E��7����sڕ��$   S"S�~���H����ژ����   �IV�u=���=Q�ڛK��/   itL�b�I*�A}��ڣ g�%   ?�)QD��$a%Cڦ����   �Z��&6��}ګ:
Y   � #��)���~�#ڴAd�w   B�����nm��<7�ڵ׳�5   K�+���_Â�
%3ڷ�X�c   �[J��L��O.Y@�ڸ�{#   �8��ɼ%�Ƴؤڻ4�5   5r��m�>5,uA��25 W   ���5��$ݘ`�����8�           �����	֞�����ʣE	   �ݭ�/�-h��b*���t�:   ��q��D�
;:(�K��-   0�Ԅ��[yKQg�$�`�w   ����t������k�&�+�<   ��Ͷj����Ax��u��B   N�A�0>�;J�?���y�/   �.湃��ohP��{:1�g   ��9� �{/�a�ަے*�ZE   �Ӻ�U�[yKz�}ە�#F   8��W%�}y/2�4ۚvF@   ���ﶮ;;��=�ۜj8�   ʻ�s���[��ۜܢ�e   ݬ���;Q:��6�ۡ��M   f�����