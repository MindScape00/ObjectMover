-------------------------------------------------------------------------------
-- Initialize Variables
-------------------------------------------------------------------------------

local OPmoveLength, OPmoveWidth, OPmoveHeight, OPmoveModifier, MessageCount, ObjectClarifier, SpawnClarifier, ScaleClarifier, RotateClarifier = 0, 0, 0, 1, 0, false, false, false, false
BINDING_HEADER_OBJECTMANIP, SLASH_SHOWCLOSE1, SLASH_SHOWCLOSE2 = "Object Mover", "/obj", "/om"

function loadMasterTable()
	if not OPMasterTable then OPMasterTable = {} end
	if not OPMasterTable.Options then OPMasterTable.Options = {} end
	if not OPMasterTable.Options["debug"] then OPMasterTable.Options["debug"] = false end
	if not OPMasterTable.Options["SliderStep"] then OPMasterTable.Options["SliderStep"] = 0.01 end
	if not OPMasterTable.Options["locked"] then OPMasterTable.Options["locked"] = false end
	if not OPMasterTable.ParamPresetKeys then OPMasterTable.ParamPresetKeys = {"Building Tile","Fine Positioning"} end
	if not OPMasterTable.ParamPresetContent then OPMasterTable.ParamPresetContent = {
		["Building Tile"] = {
			["ObjectID"] = false,
			["Length"] = 4,
			["Width"] = 4,
			["Height"] = 0.25,
			["Scale"] = 1,
			},
		["Fine Positioning"] = {
			["ObjectID"] = false,
			["Length"] = 0.01,
			["Width"] = 0.01,
			["Height"] = 0.01,
			["Scale"] = 1,
			},
		}
	end


	if not OPMasterTable.RotPresetKeys then OPMasterTable.RotPresetKeys = {"Reset (0,0,0)"} end
	if not OPMasterTable.RotPresetContent then 
	OPMasterTable.RotPresetContent = {
		["Reset (0,0,0)"] = {
			["RotX"] = 0,
			["RotY"] = 0,
			["RotZ"] = 0,
			},
		}	
	end
end

loadMasterTable()

OPFramesAreLoaded = false
FrameLoadingPoints = 0
OPSaveType = nil
ObjectSelectLineCount = 3

function OPInitializeLoading()
	FrameLoadingPoints = FrameLoadingPoints+1
	if FrameLoadingPoints >= 3 then
		OPFramesAreLoaded = true
		FrameLoadingPoints = 0
		if OPMasterTable.Options["debug"] then
			print("OPDEBUG: Frames Loaded: Rotation Enabled.")
		end
	end
end

local OPloginhandle = CreateFrame("frame","OPloginhandle");
OPloginhandle:RegisterEvent("PLAYER_LOGIN");
OPloginhandle:SetScript("OnEvent", function()
	OPMiniMapLoadIt()
	loadMasterTable()
end);

local OPAddonDetect = CreateFrame("frame","OPAddonDetect");
OPAddonDetect:RegisterEvent("ADDON_LOADED");
OPAddonDetect:SetScript("OnEvent", function(self,event,name)
	if name == "ObjectMover" then
		--Quickly Show / Hide the Frame on Start-Up to initialize everything for key bindings
		OPMainFrame:Show()
		OPMainFrame:Hide()
	end
	if name == "WIM" then
		print("ObjectMover detected WIM and is now attempting to make it's chat filters compatible. Please note that Relative Move may (Correction: WILL!) break if you are using WIM.")
		ObjectSelectLineCount = 5
		--OPAddonDetect:UnregisterEvent("ADDON_LOADED")
	end
end);

function OPMiniMapSaveIt()
	local point, relativeTo, relativePoint, xOffset, yOffset = ObjectManipulator_MinimapButton:GetPoint()
	OPMasterTable.Options["MinimapButtonSavePoint"] = strjoin(" ", point, "Minimap", relativePoint, xOffset, yOffset)
end

function OPMiniMapLoadIt()
	if OPMasterTable.Options["MinimapButtonSavePoint"] ~= nil and OPMasterTable.Options["MinimapButtonSavePoint"] ~= "" then
		local point, relativeTo, relativePoint, xOffset, yOffset = strsplit(" ", OPMasterTable.Options["MinimapButtonSavePoint"])
		ObjectManipulator_MinimapButton:SetPoint(point, "Minimap", relativePoint, xOffset, yOffset)
	end
end

-------------------------------------------------------------------------------
-- Simple Chat Functions
-------------------------------------------------------------------------------

local function cmd(text)
  SendChatMessage("."..text, "GUILD");
end

-------------------------------------------------------------------------------
-- Main Functions
-------------------------------------------------------------------------------

--Check to make sure entry is valid
function CheckIfValid(Box, IsNotObjectID, Function)
	if IsNotObjectID then
		if Box:GetText() == Box:GetText():match("%d+") or Box:GetText() == Box:GetText():match("%d+%.%d+") or Box:GetText() == Box:GetText():match("%.%d+") then
			if Function then Function() else return true end
			--If we don't want to find an object ID, and the box's text isn't illegal, e.g. ".1d-2.*+", and if we want to run a function, then run the function, else if we don't want to run a function, just tell them that the box's text is legal
		end
	elseif not IsNotObjectID and Box:GetText() == Box:GetText():match("%d+") then
			if Function then Function() else return true end
		--If we want to find an object ID, and the box's text is an object ID, and if we want to run a function, then run the function, else if we don't want to run a function, just tell them that the box's text is legal
	end
end

--Get Object ID Function
function OPGetObject()
	if ObjectClarifier == false then
		ObjectClarifier = true
		cmd("go select")
	end
end

--Update Internal Dimensions for movement when used, factoring in scale, double and halve options
function updateDimensions(val)
	if OPHalveToggle:GetChecked() == true then OPmoveModifier = 0.5
	elseif OPBifoldToggle:GetChecked() == true then OPmoveModifier = 2
	else OPmoveModifier = 1 end	
	if ScaleObject:GetChecked() == true and ScaleObject:IsEnabled() then
		if val == "length" then if tonumber(OPLengthBox:GetText()) ~= nil then OPmoveLength = (tonumber(OPLengthBox:GetText())*tonumber(OPScaleBox:GetText())*OPmoveModifier) end end
		if val == "width" then if tonumber(OPWidthBox:GetText()) ~= nil then OPmoveWidth = (tonumber(OPWidthBox:GetText())*tonumber(OPScaleBox:GetText())*OPmoveModifier) end end
		if val == "height" then if tonumber(OPHeightBox:GetText()) ~= nil then OPmoveHeight = (tonumber(OPHeightBox:GetText())*tonumber(OPScaleBox:GetText())*OPmoveModifier) end end
	else
		if val == "length" then if tonumber(OPLengthBox:GetText()) ~= nil then OPmoveLength = tonumber(OPLengthBox:GetText())*OPmoveModifier end end
		if val == "width" then if tonumber(OPWidthBox:GetText()) ~= nil then OPmoveWidth = tonumber(OPWidthBox:GetText())*OPmoveModifier end end
		if val == "height" then if tonumber(OPHeightBox:GetText()) ~= nil then OPmoveHeight = tonumber(OPHeightBox:GetText())*OPmoveModifier end end
	end
end

-- Relative Movement - Idea and initial coding by shadowbunny88
function OPMoveRelative(val)
	local myOrientation = GetPlayerFacing()
	if val == "forward" then
		distance = OPmoveLength
		direction = 1.57
	elseif val == "back" then
		distance = OPmoveLength
		direction = -1.57
	elseif val == "left" then
		distance = OPmoveWidth
		direction = 0
	elseif val == "right" then
		distance = OPmoveWidth
		direction = -3.141
	end
	
	direction =  OPMasterTable.Options["GobOri"] - myOrientation + direction --1.57
	directionx, directiony, directionz  = math.cos(direction), math.sin(direction), 0
	
	x, y, z = (directionx * distance), (directiony * distance), (directionz * distance)
	SendChatMessage(".gob move l "..x, "GUILD")
	SendChatMessage(".gob move f "..y, "GUILD")
end

function OPForward()
	updateDimensions("length")
	if OPmoveLength and OPmoveLength ~= "" and OPmoveLength ~= 0 and OPmoveLength ~= nil then
		if OPMoveObjectInstead:GetChecked() then
			if RelativeToPlayer:GetChecked() then
				OPMoveRelative("forward")
			else
				cmd("go move for "..OPmoveLength)
			end
		else
			cmd("gps for "..OPmoveLength)
		end
		if SpawnonMove:GetChecked() == true then
			OPSpawn()
		end
		if OPMasterTable.Options["debug"] then
			print("OPDEBUG: Moving "..OPmoveLength.." units forward.")
		end
	else
		print("ObjectMover | Invalid Move Length, please check your Object Parameters.")
	end
end

function OPBackward()
	updateDimensions("length")
	if OPmoveLength and OPmoveLength ~= "" and OPmoveLength ~= 0 and OPmoveLength ~= nil then
		if OPMoveObjectInstead:GetChecked() == true then
			if RelativeToPlayer:GetChecked() then
				OPMoveRelative("back")
			else
				cmd("go move back "..OPmoveLength)
			end
		else
			cmd("gps back "..OPmoveLength)
		end
		if SpawnonMove:GetChecked() == true then
			OPSpawn()
		end
		if OPMasterTable.Options["debug"] then
			print("OPDEBUG: Moving "..OPmoveLength.." units backwards.")
		end
	else
		print("ObjectMover | Invalid Move Length, please check your Object Parameters.")
	end
end

function OPLeft()
	updateDimensions("width")
	if OPmoveWidth and OPmoveWidth ~= "" and OPmoveWidth ~= 0 and OPmoveWidth ~= nil then
		if OPMoveObjectInstead:GetChecked() == true then
			if RelativeToPlayer:GetChecked() then
				OPMoveRelative("left")
			else
				cmd("go move left "..OPmoveWidth)
			end
		else
			cmd("gps left "..OPmoveWidth)
		end
		if SpawnonMove:GetChecked() == true then
			OPSpawn()
		end
		if OPMasterTable.Options["debug"] then
			print("OPDEBUG: Moving "..OPmoveWidth.." units left.")
		end
	else
		print("ObjectMover | Invalid Move Width, please check your Object Parameters.")
	end
end

function OPRight()
	updateDimensions("width")
	if OPmoveWidth and OPmoveWidth ~= "" and OPmoveWidth ~= 0 and OPmoveWidth ~= nil then
		if OPMoveObjectInstead:GetChecked() == true then
			if RelativeToPlayer:GetChecked() then
				OPMoveRelative("right")
			else
				cmd("go move right "..OPmoveWidth)
			end
		else
			cmd("gps right "..OPmoveWidth)
		end
		if SpawnonMove:GetChecked() == true then
			OPSpawn()
		end
		if OPMasterTable.Options["debug"] then
			print("OPDEBUG: Moving "..OPmoveWidth.." units right.")
		end
	else
		print("ObjectMover | Invalid Move Width, please check your Object Parameters.")
	end
end

function OPUp()
	updateDimensions("height")
	if OPmoveHeight and OPmoveHeight ~= "" and OPmoveHeight ~= 0 and OPmoveHeight ~= nil then
		if OPMoveObjectInstead:GetChecked() == true then
			cmd("go move up "..OPmoveHeight)
		else
			cmd("gps up "..OPmoveHeight)
		end
		if SpawnonMove:GetChecked() == true then
			OPSpawn()
		end
		if OPMasterTable.Options["debug"] then
			print("OPDEBUG: Moving "..OPmoveHeight.." units up.")
		end
	else
		print("ObjectMover | Invalid Move Height, please check your Object Parameters.")
	end
end

function OPDown()
	updateDimensions("height")
	if OPmoveHeight and OPmoveHeight ~= "" and OPmoveHeight ~= 0 and OPmoveHeight ~= nil then
		if OPMoveObjectInstead:GetChecked() == true then
			cmd("go move down "..OPmoveHeight)
		else
			cmd("gps down "..OPmoveHeight)
		end
		if SpawnonMove:GetChecked() == true then
			OPSpawn()
		end
		if OPMasterTable.Options["debug"] then
			print("OPDEBUG: Moving "..OPmoveHeight.." units down.")
		end
	else
		print("ObjectMover | Invalid Move Height, please check your Object Parameters.")
	end
end

function OPSpawn()
	if CheckIfValid(OPObjectIDBox) then
		if SpawnClarifier == false then
			SpawnClarifier = true
		end
		--Check if we have an object ID in the object ID box, if we do, spawn it
		SendChatMessage(".go spawn "..OPObjectIDBox:GetText())
	end
	if ScaleObject:GetChecked() == true and ScaleObject:IsEnabled() then
		--Do we want to scale it?
		--SendChatMessage(".go select") --Auto Selected on Spawn now, no need to select, as it can cause problems if it selects the wrong one anyways.
		if ScaleClarifier == false then
			ScaleClarifier = true
		end
		C_Timer.After(0.5, function() SendChatMessage(".go scale "..OPScaleBox:GetText()) end) -- Delay the scale because scaling immediately after spawn doesn't save on server restart
	end
end

function OPTeletoObject()
	SendChatMessage(".go go")
end

function EnableBoxes(Box1, Box2)
	--This is just to cut down on the xml size when enabling and disabling the Halve and Bifold checkboxes via binding - make sure we're not both checked
	if Box1:GetChecked() then
		Box1:SetChecked(false)
	else
		Box1:SetChecked(true)
	end
	if Box2:GetChecked() then
		Box2:SetChecked(false)
	end
end

function OPRotateObject()
	--if RotateClarifier == false then
		RotateClarifier = true
	--end
	local RotationX = OPRotationSliderX:GetValue()
	local RotationY = OPRotationSliderY:GetValue()
	local RotationZ = OPRotationSliderZ:GetValue()
	if RotationX < 0 then RotationX = 0; if OPMasterTable.Options["debug"] then print("RotX < 0, Made 0") end; end
	if RotationY < 0 then RotationY = 0; if OPMasterTable.Options["debug"] then print("RotY < 0, Made 0") end; end
	if RotationZ < 0 then RotationZ = 0; if OPMasterTable.Options["debug"] then print("RotZ < 0, Made 0") end; end
	cmd("go rot "..RotationX.." "..RotationY.." "..RotationZ)
end

function roundToNthDecimal(num, n)
  local mult = 10^(n or 0)
  return math.floor(num * mult+0.5) / mult
end

-------------------------------------------------------------------------------
-- Save / Load Pre-set System
-------------------------------------------------------------------------------

function OPShowParamSaveMenu()
	OPMainSaveFrameTitleText:SetText("Save Parameters Pre-set Name:")
	OPMainSaveFrame:Show()
	OPSaveType = "param"
end

function OPShowRotSaveMenu()
	OPMainSaveFrameTitleText:SetText("Save Rotation Pre-set Name:")
	OPMainSaveFrame:Show()
	OPSaveType = "rot"
end

function OPSaveMenuActualSave()
	local opsavename = OPMainSaveFrameEditBox:GetText()
	if opsavename == "" or opsavename == " " or not opsavename:find("%S") then
		opsavename = nil
	end
	if OPSaveType == "param" and opsavename then
		--Do Saving for Param Here
		OPSaveMenuParamSave(opsavename)
	elseif OPSaveType == "rot" and opsavename then
		--Do Saving for Rotation Here
		OPSaveMenuRotSave(opsavename)
	elseif not opsavename then
		message("Please enter a valid name!\n\rNames must contain at least one non-space character.")
	else
		print("ObjectMover: There was an error saving your pre-set. Please use '/reload' and try again. If this persists, please report it as a bug.")
	end
end

--Para Saving

function OPSaveMenuParamSave(name)
	if OPMasterTable.ParamPresetKeys then
		for k,v in ipairs(OPMasterTable.ParamPresetKeys) do
			if v == name then
				if not confirmPSaveOverwrite then
					message("The name specified conflicts with an already saved Parameter Pre-set name. Hit save again to confirm that you wish to overwrite the previous save.")
					confirmPSaveOverwrite = true
					confirmPSaveOverwriteName = name
					--savePOverwriteTimer = C_Timer.NewTimer(15, function()
						--confirmPSaveOverwrite = false
						--if OPMasterTable.Options["debug"] then
							--print("OPDEBUG: Exceeded 15 Second Timer for Confirm Save (Param).")
						--end
					--end)
					return
				elseif confirmPSaveOverwrite then
					if name == confirmPSaveOverwriteName then
						--savePOverwriteTimer:Cancel() -- Cancel our last timer so that it doesn't bleed into a future save if they go to save again within the 15 seconds.
						confirmPSaveOverwrite = false -- Set the overwrite check to false since we cancelled the timer to do it
						OPSaveMenuParamSaveForReal(name,false)
					else
						message("The name specified conflicts with an already saved Parameter Pre-set name. Hit save again to confirm that you wish to overwrite the previous save.")
						confirmPSaveOverwrite = true
						confirmPSaveOverwriteName = name
						--savePOverwriteTimer = C_Timer.NewTimer(15, function()
							--confirmPSaveOverwrite = false
						--end)
					end
					return
				else
					print("Error: You tried to save with the same name as another Parameter Pre-set save, and an error occurred internally. Please remember how you did this and report it as a bug. Thanks you.")
					return
				end
				return
			end
		end
		OPSaveMenuParamSaveForReal(name,true)
	end
end

function OPSaveMenuParamSaveForReal(name,saveKey)
	if saveKey then
		table.insert(OPMasterTable.ParamPresetKeys, name)
		saveKey = false
	end
	OPMasterTable.ParamPresetContent[name] = {}
	OPMasterTable.ParamPresetContent[name].ObjectID = OPObjectIDBox:GetText()
	OPMasterTable.ParamPresetContent[name].Length = OPLengthBox:GetText()
	OPMasterTable.ParamPresetContent[name].Width = OPWidthBox:GetText()
	OPMasterTable.ParamPresetContent[name].Height = OPHeightBox:GetText()
	OPMasterTable.ParamPresetContent[name].Scale = OPScaleBox:GetText()
	print("ObjectMover: Saved new Parameter Pre-set with name: "..name)
	OPMainSaveFrame:Hide()
end

-- Rot Saving

function OPSaveMenuRotSave(name)
	if OPMasterTable.RotPresetKeys then
		for k,v in ipairs(OPMasterTable.RotPresetKeys) do
			if v == name then
				if not confirmRSaveOverwrite then
					message("The name specified conflicts with an already saved Rotation Pre-set name. Hit save again confirm that you wish to overwrite the previous save.")
					confirmRSaveOverwrite = true
					confirmRSaveOverwriteName = name
					--saveROverwriteTimer = C_Timer.NewTimer(15, function()
						--confirmRSaveOverwrite = false
						--if OPMasterTable.Options["debug"] then
							--print("OPDEBUG: Exceeded 15 Second Timer for Confirm Save (Rot).")
						--end
					--end)
					return
				elseif confirmRSaveOverwrite then
					if name == confirmRSaveOverwriteName then
						--saveROverwriteTimer:Cancel() -- Cancel our last timer so that it doesn't bleed into a future save if they go to save again within the 15 seconds.
						confirmRSaveOverwrite = false -- Set the overwrite check to false since we cancelled the timer to do it
						OPSaveMenuRotSaveForReal(name,false)
					else
						message("The name specified conflicts with an already saved Rotation Pre-set name. Hit save again to confirm that you wish to overwrite the previous save.")
						confirmRSaveOverwrite = true
						confirmRSaveOverwriteName = name
						--saveROverwriteTimer = C_Timer.NewTimer(15, function()
							--confirmRSaveOverwrite = false
						--end)
					end
					return
				else
					print("Error: You tried to save with the same name as another Rotation Save, and an error occurred internally. Please remember how you did this and report it as a bug. Thanks you.")
					return
				end
				return
			end
		end
		OPSaveMenuRotSaveForReal(name,true)
	end
end

function OPSaveMenuRotSaveForReal(name,saveKey)
	if saveKey then
		table.insert(OPMasterTable.RotPresetKeys, name)
		saveKey = false
	end
	OPMasterTable.RotPresetContent[name] = {}
	OPMasterTable.RotPresetContent[name].RotX = OPRotationSliderX:GetValue()
	OPMasterTable.RotPresetContent[name].RotY = OPRotationSliderY:GetValue()
	OPMasterTable.RotPresetContent[name].RotZ = OPRotationSliderZ:GetValue()
	print("ObjectMover: Saved new Rotation Pre-set with name: "..name)
	OPMainSaveFrame:Hide()
end

-- DropDown Load Boxes

function OPCreateLoadDropDownMenus()
	
	--Param Loading
	local paramPresetDropSelect = CreateFrame("Frame", "paramPresetDropDownMenu", OPPanel2, "UIDropDownMenuTemplate")
	paramPresetDropSelect:SetPoint("LEFT", OPParamSaveButton, "RIGHT", -15, -1)
	paramPresetDropSelect:SetScript("OnEnter",function()
		GameTooltip:SetOwner(paramPresetDropSelect, "ANCHOR_LEFT")
		paramPresetDropSelect.Timer = C_Timer.NewTimer(0.7,function()
			GameTooltip:SetText("Select a previously saved parameter pre-set to load.\n\rYou can use '/opdelparam Name' in chat (where Name is the pre-set name, case sensitive) to delete any of these pre-sets including the default ones.", nil, nil, nil, nil, true)
			GameTooltip:Show()
			end)
	end)
	paramPresetDropSelect:SetScript("OnLeave",function()
		GameTooltip_Hide()
		paramPresetDropSelect.Timer:Cancel()
	end)
	
	local function ParamPresetOnClick(self)
		UIDropDownMenu_SetSelectedID(paramPresetDropSelect, self:GetID())
		if self.value ~= "Select a Preset" then
			_OPMTPPC = OPMasterTable.ParamPresetContent[self.value]
			if _OPMTPPC.ObjectID and tostring(_OPMTPPC.ObjectID) ~= "" and tostring(_OPMTPPC.ObjectID) ~= "0" then
				OPObjectIDBox:SetText(OPMasterTable.ParamPresetContent[self.value].ObjectID)
			end
			if _OPMTPPC.Length and tostring(_OPMTPPC.Length) ~= "" and tostring(_OPMTPPC.Length) ~= "0" then
				OPLengthBox:SetText(OPMasterTable.ParamPresetContent[self.value].Length)
			end
			if _OPMTPPC.Width and tostring(_OPMTPPC.Width) ~= "" and tostring(_OPMTPPC.Width) ~= "0" then
				OPWidthBox:SetText(OPMasterTable.ParamPresetContent[self.value].Width)
			end
			if _OPMTPPC.Height and tostring(_OPMTPPC.Height) ~= "" and tostring(_OPMTPPC.Height) ~= "0" then
				OPHeightBox:SetText(OPMasterTable.ParamPresetContent[self.value].Height)
			end
			if _OPMTPPC.Scale and tostring(_OPMTPPC.Scale) ~= "" and tostring(_OPMTPPC.Scale) ~= "0" then
				OPScaleBox:SetText(OPMasterTable.ParamPresetContent[self.value].Scale)
			end
			if OPMasterTable.Options["debug"] then
				print("OPDEBUG: Tried to load Param Pre-set: "..self.value)
			end
		end
	end
	local function paramPresetInitialize(self,level)
		local info = UIDropDownMenu_CreateInfo()
		for k,v in ipairs(OPMasterTable.ParamPresetKeys) do
			info = UIDropDownMenu_CreateInfo()
			info.text = v
			info.value = v
			info.func = ParamPresetOnClick
			UIDropDownMenu_AddButton(info,level)
		end
	end
	UIDropDownMenu_Initialize(paramPresetDropSelect, paramPresetInitialize)
	UIDropDownMenu_SetWidth(paramPresetDropSelect, 65);
	UIDropDownMenu_SetButtonWidth(paramPresetDropSelect, 80)
	UIDropDownMenu_SetSelectedID(paramPresetDropSelect, 0)
	UIDropDownMenu_JustifyText(paramPresetDropSelect, "LEFT")
	UIDropDownMenu_SetText(paramPresetDropSelect, "Load")
	paramPresetDropDownMenuText:SetFontObject("GameFontWhiteTiny2")
	local fontName,fontHeight,fontFlags = paramPresetDropDownMenuText:GetFont()
	paramPresetDropDownMenuText:SetFont(fontName, 6)
	
	-- Rot Loading
	local rotPresetDropSelect = CreateFrame("Frame", "rotPresetDropDownMenu", OPPanel4, "UIDropDownMenuTemplate")
	rotPresetDropSelect:SetPoint("LEFT", OPRotSaveButton, "RIGHT", -15, -1)
	rotPresetDropSelect:SetScript("OnEnter",function()
		GameTooltip:SetOwner(rotPresetDropSelect, "ANCHOR_LEFT")
		rotPresetDropSelect.Timer = C_Timer.NewTimer(0.7,function()
			GameTooltip:SetText("Select a previously saved rotation pre-set to load.\n\rYou can use '/opdelrot Name' in chat (where Name is the pre-set name, case sensitive) to delete any of these pre-sets including the default ones.", nil, nil, nil, nil, true)
			GameTooltip:Show()
			end)
	end)
	rotPresetDropSelect:SetScript("OnLeave",function()
		GameTooltip_Hide()
		rotPresetDropSelect.Timer:Cancel()
	end)
	
	local function RotPresetOnClick(self)
		UIDropDownMenu_SetSelectedID(rotPresetDropSelect, self:GetID())
		if self.value ~= "Select a Preset" then
			local origx, origy, origz = OPRotationSliderX:GetValue(), OPRotationSliderY:GetValue(), OPRotationSliderZ:GetValue()
			_OPMTRPC = OPMasterTable.RotPresetContent[self.value]
			if _OPMTRPC.RotX and tostring(_OPMTRPC.RotX) ~= "" and tonumber(_OPMTRPC.RotX) >= 0 then
				OPRotationSliderX:SetValue(tonumber(OPMasterTable.RotPresetContent[self.value].RotX))
			end
			if _OPMTRPC.RotY and tostring(_OPMTRPC.RotY) ~= "" and tonumber(_OPMTRPC.RotY) >= 0 then
				OPRotationSliderY:SetValue(tonumber(OPMasterTable.RotPresetContent[self.value].RotY))
			end
			if _OPMTRPC.RotZ and tostring(_OPMTRPC.RotZ) ~= "" and tonumber(_OPMTRPC.RotZ) >= 0 then
				OPRotationSliderZ:SetValue(tonumber(OPMasterTable.RotPresetContent[self.value].RotZ))
			end
			if OPMasterTable.Options["debug"] then
				print("OPDEBUG: Tried to load Rot Pre-set: "..self.value)
				print(origx.." | "..origy.." | "..origz)
			end
			if origx == OPRotationSliderX:GetValue() and origy == OPRotationSliderY:GetValue() and origz == OPRotationSliderZ:GetValue() then
				OPRotateObject();
				OPIMFUCKINGROTATINGDONTSPAMME = true
				OPClearRotateChatFilter()
				if OPMasterTable.Options["debug"] then
					print("OPDEBUG: Loaded the same as whatever it is currently, so we're gonna apply the rotation anyways!")
				end
			end
		end
	end
	local function rotPresetInitialize(self,level)
		local info = UIDropDownMenu_CreateInfo()
		for k,v in ipairs(OPMasterTable.RotPresetKeys) do
			info = UIDropDownMenu_CreateInfo()
			info.text = v
			info.value = v
			info.func = RotPresetOnClick
			UIDropDownMenu_AddButton(info,level)
		end
	end
	UIDropDownMenu_Initialize(rotPresetDropSelect, rotPresetInitialize)
	UIDropDownMenu_SetWidth(rotPresetDropSelect, 65)
	--UIDropDownMenu_SetHeight(rotPresetDropSelect, 24)
	UIDropDownMenu_SetButtonWidth(rotPresetDropSelect, 80)
	UIDropDownMenu_SetSelectedID(rotPresetDropSelect, 0)
	UIDropDownMenu_JustifyText(rotPresetDropSelect, "LEFT")
	UIDropDownMenu_SetText(rotPresetDropSelect, "Load")
	rotPresetDropDownMenuText:SetFontObject("GameFontWhiteTiny2")
	local fontName,fontHeight,fontFlags = rotPresetDropDownMenuText:GetFont()
	rotPresetDropDownMenuText:SetFont(fontName, 6)
	--rotPresetDropSelect:SetHeight(24)
end

-------------------------------------------------------------------------------
-- Message Filters
-------------------------------------------------------------------------------

function OPClearRotateChatFilter()
	if RotateClarifier then
		OPIMFUCKINGROTATINGDONTSPAMME = false
		C_Timer.After(0.25, OPClearRotateChatFilterDontSpamIfStillRotating);
	end
end

function OPClearRotateChatFilterDontSpamIfStillRotating()
	if OPIMFUCKINGROTATINGDONTSPAMME ~= true then
		RotateClarifier = false
	end
end

function RunChecks(Message)
-- GObject Rotate Message Filter
	if RotateClarifier and Message:gsub("|.........",""):find("rotated") then
		if OPMasterTable.Options["debug"] then
			print("OPDEBUG: RotateClarifier Caught Message")
		end
	end

-- GObject Spawn Message Filter
	if SpawnClarifier then
		local clearmsg = gsub(Message,"|cff%x%x%x%x%x%x","");
		if clearmsg:find("Spawned") then
			SpawnClarifier = false
			if OPMasterTable.Options["debug"] then
				print("OPDEBUG: SpawnClarifier Caught Message")
			end
		elseif clearmsg:find("Syntax") or clearmsg:find("was not found") or clearmsg:find("You do not have") then
			SpawnClarifier = false
			if OPMasterTable.Options["debug"] then
				print("OPDEBUG: SpawnClarifier Caught Syntax or Failure, Disabled.")
			end
		end
	end

-- GObject Scale Message Filter
	if ScaleClarifier then
		local clearmsg = gsub(Message,"|cff%x%x%x%x%x%x","");
		if clearmsg:find("Syntax") or clearmsg:find("was not found") or clearmsg:find("You do not have") or clearmsg:find("Incorrect") then
			ScaleClarifier = false
			if OPMasterTable.Options["debug"] then
				print("OPDEBUG: ScaleClarifier Caught Syntax or Failure, Disabled.")
			end
		elseif clearmsg:find("scale") then 
			ScaleClarifier = false
			if OPMasterTable.Options["debug"] then
				print("OPDEBUG: ScaleClarifier Caught Message")
			end
		end
	end
	
-- Get Object ID Message Filter
	if ObjectClarifier and Message:gsub("|.........",""):find("%-%s%d+") then
		OPObjectIDBox:SetText(gsub(Message:gsub("(|.........)", ""):match("- %d+"), "- ", ""))
	end
	if ObjectClarifier then
		local clearmsg = gsub(Message,"|cff%x%x%x%x%x%x","");
		if clearmsg:find("Nothing found!") then
			ObjectClarifier = false
			if OPMasterTable.Options["debug"] then
				print("OPDEBUG: No GObject nearby to set the ID :( Disabling the clarifier.")
			end
		elseif clearmsg:find("Selected gameobject") or clearmsg:find("SpawnTime") or clearmsg:find("Built by:") then -- Make sure it's actually a reply to our gameobject select.
			MessageCount = MessageCount+1
			if MessageCount >= ObjectSelectLineCount then -- We must check it's greater than a certain amount that changes if WIM is on (because WIM doubles the messages seen, for some reason, but only shows the one it copied - it's weird..)
				ObjectClarifier = false
				MessageCount = 0
				if OPMasterTable.Options["debug"] then
					print("OPDEBUG: ObjectClarifier disabled (Object Found and ID inserted: "..OPObjectIDBox:GetText()..")")
				end
			end
		end
	end
end

function Filter(Self,Event,Message)
	local clearmsg = gsub(Message,"|cff%x%x%x%x%x%x","");
	if clearmsg:find("with orientation:") then
		OPMasterTable.Options["GobOri"] = tonumber(clearmsg:match("orientation: (%-?%d+%.%d+)"))
		--print(OPMasterTable.Options["GobOri"])

	elseif clearmsg:find("You have rotated") then
		if clearmsg:find("X: ") then
			if clearmsg:find("Z: %-?") then 
				--print("X Found.."..clearmsg:match("Z: (%-?%d*%.%d*)"))
				OPMasterTable.Options["GobOri"] = math.rad(tonumber(clearmsg:match("Z: (%-?%d*%.%d*)")))
			end
			--print(OPMasterTable.Options["GobOri"])
		elseif OPMasterTable.Options["GobOri"] then
			if clearmsg:find("Z: %-?") then
				--print("Ori Change.."..clearmsg:match("Z: (%-?%d+%.%d+)"))
				OPMasterTable.Options["GobOri"] = OPMasterTable.Options["GobOri"] + math.rad(tonumber(clearmsg:match("Z: (%-?%d+%.%d+)")))
			end
			--print(OPMasterTable.Options["GobOri"])
		else
			print("ObjectMover Error: We could not find your current object's orientation. Please use '.go sel' on it again to collect this information. If you continue to see this message (after using .go sel), please report it as a bug.")
		end
	end

	if ObjectClarifier or SpawnClarifier or ScaleClarifier or RotateClarifier then
		--Check to see if we sent a request and we don't want to see messages
		if OPShowMessages:GetChecked() ~= true then
			--If so, run the checks and delete the message
			RunChecks(Message)
			return true
		else
			--If we do want to see messages, keep the message and run the checks any ways since we sent a request
			RunChecks(Message)
		end
	end
end

--Apply filter
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", Filter)

-------------------------------------------------------------------------------
-- Slash Command Handlers
-------------------------------------------------------------------------------

function SlashCmdList.SHOWCLOSE()
	if not OPMainFrame:IsShown() then
		OPMainFrame:Show()
	else
		OPMainFrame:Hide()
	end
end

SLASH_OPDEBUG1 = '/opdebug';
function SlashCmdList.OPDEBUG(msg, editbox) -- 4.
	OPMasterTable.Options["debug"] = not OPMasterTable.Options["debug"]
	print("Object Mover Debug Set to: "..tostring(OPMasterTable.Options["debug"]))
end

SLASH_OPDELPARAM1 = '/opdelparam';
function SlashCmdList.OPDELPARAM(msg, editbox) -- 4.
	for k,v in ipairs(OPMasterTable.ParamPresetKeys) do
		if msg == v then
			table.remove(OPMasterTable.ParamPresetKeys, k)
			OPMasterTable.ParamPresetContent[msg] = nil
			print("ObjectMover: Deleting Parameter Pre-set "..msg)
		else
			if OPMasterTable.Options["debug"] then
				print("OPDEBUG: "..msg.." is not a saved Param Pre-set?")
			end
		end
	end
end

SLASH_OPDELROT1 = '/opdelrot';
function SlashCmdList.OPDELROT(msg, editbox) -- 4.
	for k,v in ipairs(OPMasterTable.RotPresetKeys) do
		if msg == v then
			table.remove(OPMasterTable.RotPresetKeys, k)
			OPMasterTable.RotPresetContent[msg] = nil
			print("ObjectMover: Deleting Rotation Pre-set: "..msg)
		else
			if OPMasterTable.Options["debug"] then
				print("OPDEBUG: "..msg.." is not a saved Rot Pre-set?")
			end
		end
	end
end