-------------------------------------------------------------------------------
-- Initialize Variables
-------------------------------------------------------------------------------

-- local utils = Epsilon.utils
-- local messages = utils.messages
-- local server = utils.server
-- local tabs = utils.tabs

-- local main = Epsilon.main

local addonPrefix = "EPISLON_OBJ_INFO"

local OPmoveLength, OPmoveWidth, OPmoveHeight, OPmoveModifier, MessageCount, ObjectClarifier, SpawnClarifier, ScaleClarifier, RotateClarifier, OPObjectSpell, cmdPref, isGroupSelected, m, isWMO = 0, 0, 0, 1, 0, false, false, false, false, nil, "go", nil, nil, nil
BINDING_HEADER_OBJECTMANIP, SLASH_SHOWCLOSE1, SLASH_SHOWCLOSE2 = "Object Mover", "/obj", "/om"

-------------------------------------------------------------------------------
-- Simple Chat Functions
-------------------------------------------------------------------------------

local function cmd(text)
  SendChatMessage("."..text, "GUILD");
end

local function eprint(text,...)
	local rest = ...
	local line = strmatch(debugstack(2),":(%d+):")
	if line then
		print("|cffFFD700 ObjectMover Error @ "..line..": "..text.." | "..rest.." |r")
	else
		print("|cffFFD700 ObjectMover @ ERROR: "..text.." | "..rest.." |r")
		print(debugstack(2))
	end
end

local function dprint(text, force, ...)
	if force and force ~= true then 
		rest = force,...
	else
		rest = ... or ""
	end
	if force == true or OPMasterTable.Options["debug"] then
		local line = strmatch(debugstack(2),":(%d+):")
		if line then
			print("|cffFFD700 ObjectMover DEBUG "..line..": "..text.." | "..rest.." |r")
		else
			print("|cffFFD700 ObjectMover DEBUG: "..text.." | "..rest.." |r")
			print(debugstack(2))
		end
	end
end

-------------------------------------------------------------------------------
-- Loading Sequence
-------------------------------------------------------------------------------

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

function ClientShowRotate(guid,roll,pitch,yaw)
	C_Epsilon.RotateObject(guid,roll,pitch,yaw)
end

function OPInitializeLoading()
	FrameLoadingPoints = FrameLoadingPoints+1
	if FrameLoadingPoints >= 3 then
		OPFramesAreLoaded = true
		FrameLoadingPoints = 0
		dprint("Frames Loaded: Rotation Enabled.")
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
		
		-- Fix Tint ValueChanged Handlers
		OPTintSliderR:SetScript("OnValueChanged", function(self,value,byUser)
			if byUser then
				if value ~= tonumber(_G[self:GetName().."Text"]:GetText()) then
					OPTintObject();
				end
			end
			_G[self:GetName().."Text"]:SetText(OPTintSliderR:GetValue())
		end)
		OPTintSliderG:SetScript("OnValueChanged", function(self,value,byUser)
			if byUser then
				if value ~= tonumber(_G[self:GetName().."Text"]:GetText()) then
					OPTintObject();
				end
			end
			_G[self:GetName().."Text"]:SetText(OPTintSliderG:GetValue())
		end)
		OPTintSliderB:SetScript("OnValueChanged", function(self,value,byUser)
			if byUser then
				if value ~= tonumber(_G[self:GetName().."Text"]:GetText()) then
					OPTintObject();
				end
			end
			_G[self:GetName().."Text"]:SetText(OPTintSliderB:GetValue())
		end)
		OPTintSliderT:SetScript("OnValueChanged", function(self,value,byUser)
			if byUser then
				if value ~= tonumber(_G[self:GetName().."Text"]:GetText()) then
					OPTintObject();
				end
			end
			_G[self:GetName().."Text"]:SetText(OPTintSliderT:GetValue())
		end)
		
		m = CreateFrame("ModelScene")
		Mixin(m, ModelSceneMixin)
		m.o = m:CreateActor(nil, "ObjectMoverActorTemplate")
		m.o.OnModelLoaded = function()
			dprint("Model Loaded - Getting boundingbox")
			local mX1, mY1, mZ1, mX2, mY2, mZ2 = m.o:GetActiveBoundingBox()
			local mX = mX1-mX2; local mY = mY1-mY2; local mZ = mZ1-mZ2
			OPLengthBox:SetText(roundToNthDecimal(abs(mX),7))
			OPWidthBox:SetText(roundToNthDecimal(abs(mY),7))
			OPHeightBox:SetText(roundToNthDecimal(abs(mZ),7))
			dprint("AUTODIM: X: "..mX.." ("..mX1.." | "..mX2.."), Y: "..mY.." ("..mY1.." | "..mY2.."), Z: "..mZ.." ("..mZ1.." | "..mZ2..")")
			m.o:ClearModel()
		end
		
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
function OPGetObject(button)
	OPObjectIDBox:SetText(tonumber(lastSelectedObjectID))
	dprint("Obejct ID Box updated to: "..tonumber(lastSelectedObjectID))
	if button == "RightButton" then
		if isWMO then
			dprint("Object was WMO")
		else
			if OPLastSelectedObjectData[4] then
				m.o:SetModelByFileID(OPLastSelectedObjectData[4])
				dprint("Generating ModelFrame to get Bounding Box (file ID "..OPLastSelectedObjectData[4]..")")
				if OPLastSelectedObjectData[18] then
					OPScaleBox:SetText(OPLastSelectedObjectData[18])
				end
			end
		end
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

function OPForward()
	updateDimensions("length")
	if OPmoveLength and OPmoveLength ~= "" and OPmoveLength ~= 0 and OPmoveLength ~= nil then
		if OPMoveObjectInstead:GetChecked() then
			if isGroupSelected then cmdPref = "go group" else cmdPref = "go" end
			if RelativeToPlayerToggle:GetChecked() then
				cmd(cmdPref.." relative forward "..OPmoveLength)
			else
				cmd(cmdPref.." move for "..OPmoveLength)
			end
		else
			cmd("gps for "..OPmoveLength)
		end
		if SpawnonMoveButton:GetChecked() == true and not OPMoveObjectInstead:GetChecked() then
			OPSpawn()
		end
		dprint("Moving "..OPmoveLength.." units forward.")
	else
		eprint("Invalid Move Length, please check your Object Parameters.")
	end
end

function OPBackward()
	updateDimensions("length")
	if OPmoveLength and OPmoveLength ~= "" and OPmoveLength ~= 0 and OPmoveLength ~= nil then
		if OPMoveObjectInstead:GetChecked() == true then
			if isGroupSelected then cmdPref = "go group" else cmdPref = "go" end
			if RelativeToPlayerToggle:GetChecked() then
				cmd(cmdPref.." relative back "..OPmoveLength)
			else
				cmd(cmdPref.." move back "..OPmoveLength)
			end
		else
			cmd("gps back "..OPmoveLength)
		end
		if SpawnonMoveButton:GetChecked() == true and not OPMoveObjectInstead:GetChecked() then
			OPSpawn()
		end
		dprint("Moving "..OPmoveLength.." units backwards.")
	else
		eprint("Invalid Move Length, please check your Object Parameters.")
	end
end

function OPLeft()
	updateDimensions("width")
	if OPmoveWidth and OPmoveWidth ~= "" and OPmoveWidth ~= 0 and OPmoveWidth ~= nil then
		if OPMoveObjectInstead:GetChecked() == true then
			if isGroupSelected then cmdPref = "go group" else cmdPref = "go" end
			if RelativeToPlayerToggle:GetChecked() then
				cmd(cmdPref.." relative left "..OPmoveWidth)
			else
				cmd(cmdPref.." move left "..OPmoveWidth)
			end
		else
			cmd("gps left "..OPmoveWidth)
		end
		if SpawnonMoveButton:GetChecked() == true and not OPMoveObjectInstead:GetChecked() then
			OPSpawn()
		end
		dprint("Moving "..OPmoveWidth.." units left.")
	else
		eprint("Invalid Move Width, please check your Object Parameters.")
	end
end

function OPRight()
	updateDimensions("width")
	if OPmoveWidth and OPmoveWidth ~= "" and OPmoveWidth ~= 0 and OPmoveWidth ~= nil then
		if OPMoveObjectInstead:GetChecked() == true then
			if isGroupSelected then cmdPref = "go group" else cmdPref = "go" end
			if RelativeToPlayerToggle:GetChecked() then
				cmd(cmdPref.." relative right "..OPmoveWidth)
			else
				cmd(cmdPref.." move right "..OPmoveWidth)
			end
		else
			cmd("gps right "..OPmoveWidth)
		end
		if SpawnonMoveButton:GetChecked() == true and not OPMoveObjectInstead:GetChecked() then
			OPSpawn()
		end
		dprint("Moving "..OPmoveWidth.." units right.")
	else
		eprint("Invalid Move Width, please check your Object Parameters.")
	end
end

function OPUp()
	updateDimensions("height")
	if OPmoveHeight and OPmoveHeight ~= "" and OPmoveHeight ~= 0 and OPmoveHeight ~= nil then
		if OPMoveObjectInstead:GetChecked() == true then
			if isGroupSelected then cmdPref = "go group" else cmdPref = "go" end
			cmd(cmdPref.." move up "..OPmoveHeight)
		else
			cmd("gps up "..OPmoveHeight)
		end
		if SpawnonMoveButton:GetChecked() == true and not OPMoveObjectInstead:GetChecked() then
			OPSpawn()
		end
		dprint("Moving "..OPmoveHeight.." units up.")
	else
		eprint("Invalid Move Height, please check your Object Parameters.")
	end
end

function OPDown()
	updateDimensions("height")
	if OPmoveHeight and OPmoveHeight ~= "" and OPmoveHeight ~= 0 and OPmoveHeight ~= nil then
		if OPMoveObjectInstead:GetChecked() == true then
			if isGroupSelected then cmdPref = "go group" else cmdPref = "go" end
			cmd(cmdPref.." move down "..OPmoveHeight)
		else
			cmd(cmdPref.." down "..OPmoveHeight)
		end
		if SpawnonMoveButton:GetChecked() == true and not OPMoveObjectInstead:GetChecked() then
			OPSpawn()
		end
		dprint("Moving "..OPmoveHeight.." units down.")
	else
		eprint("Invalid Move Height, please check your Object Parameters.")
	end
end

function OPSpawn()
	if CheckIfValid(OPObjectIDBox) then
		SpawnClarifier = true
		--Check if we have an object ID in the object ID box, if we do, spawn it
		if ScaleObject:GetChecked() == true and ScaleObject:IsEnabled() then
			SendChatMessage(".go spawn "..OPObjectIDBox:GetText().." scale "..OPScaleBox:GetText())
		else
			SendChatMessage(".go spawn "..OPObjectIDBox:GetText())
		end
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

function OPTintObject()
	if OPFramesAreLoaded then
		local r = OPTintSliderR:GetValue()
		local g = OPTintSliderG:GetValue()
		local b = OPTintSliderB:GetValue()
		local t = OPTintSliderT:GetValue()
		--addFilter("Removed GameObject .*\'s tint.")
		if isGroupSelected then cmdPref = "go group" else cmdPref = "go" end
		cmd(cmdPref.." tint "..r.." "..g.." "..b.." "..t)
	end
end

function OPUpdateTints(restore)
	if restore and restore ~= "APPLY" then
		local r,g,b,a = unpack(restore)
		OPTintSliderR:SetValue(r*100)
		OPTintSliderG:SetValue(g*100)
		OPTintSliderB:SetValue(b*100)
		OPTintSliderT:SetValue(a*100)
		OPTintIsControllingColorPicker = false
	else
		local r,g,b = ColorPickerFrame:GetColorRGB()
		OPTintSliderR:SetValue(r*100)
		OPTintSliderG:SetValue(g*100)
		OPTintSliderB:SetValue(b*100)
	end
	if restore == "APPLY" then
		OPTintObject()
	end
end

function OPUpdateTintsApply()
	if OPTintIsControllingColorPicker then
		OPUpdateTints("APPLY")
		OPTintIsControllingColorPicker = false
	end
end

function OPResetTint(applyAfter)
	OPTintSliderR:SetValue(100)
	OPTintSliderG:SetValue(100)
	OPTintSliderB:SetValue(100)
	OPTintSliderT:SetValue(0)
	if applyAfter then
		OPTintObject();
	end
end

local function updateSpellButton()
	if OPObjectSpell and OPObjectSpell ~= "" and tonumber(OPObjectSpell) ~= 0 then
		OPTintSpellButton.Text:SetFont("Fonts\\FRIZQT__.TTF", 8)
		OPTintSpellButton.Text:SetText("Spell\n("..OPObjectSpell..")")
	else
		OPTintSpellButton.Text:SetFont("Fonts\\FRIZQT__.TTF", 10)
		OPTintSpellButton.Text:SetText("Spell")
	end
end

function OPRotateObject()
	--if RotateClarifier == false then
		RotateClarifier = true
	--end
	local RotationX = OPRotationSliderX:GetValue()
	local RotationY = OPRotationSliderY:GetValue()
	local RotationZ = OPRotationSliderZ:GetValue()
	if RotationX < 0 then RotationX = 0; dprint("RotX < 0, Made 0"); end
	if RotationY < 0 then RotationY = 0; dprint("RotY < 0, Made 0"); end
	if RotationZ < 0 then RotationZ = 0; dprint("RotZ < 0, Made 0"); end
	cmd("go rot "..RotationX.." "..RotationY.." "..RotationZ)
end

function roundToNthDecimal(num, n)
  local mult = 10^(n or 0)
  return math.floor(num * mult+0.5) / mult
end

function OPSpellButtonFunc(button)
	if button == "LeftButton" then
		StaticPopup_Show("OP_TINTS_SPELL")
	elseif button == "RightButton" then
		if isGroupSelected then cmdPref = "go group" else cmdPref = "go" end
		cmd(cmdPref.." spell 0")
	end
end

StaticPopupDialogs["OP_TINTS_SPELL"] = {
	text = STAT_CATEGORY_SPELL,
	button1 = APPLY,
	button2 = CANCEL,
	OnAccept = function( self )
		local spell = self.editBox:GetText()
		if isGroupSelected then cmdPref = "go group" else cmdPref = "go" end
		if tonumber(spell) ~= nil then
			if tonumber(spell) > 0 then
				cmd(cmdPref.." spell "..self.editBox:GetText())
			else
				cmd(cmdPref.." spell 0")
			end
		else
			cmd(cmdPref.." spell 0")
		end
	end,
	EditBoxOnTextChanged = function(self)
		if self:GetText() ~= "" then
			self:GetParent().button1:SetText(APPLY)
		else
			self:GetParent().button1:SetText(REMOVE)
		end
	end,
	EditBoxOnEnterPressed = function(self)
		self:GetParent().button1:Click("LeftButton")
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent().button2:Click("LeftButton")
	end,
	OnShow = function(self)
		if OPObjectSpell and OPObjectSpell ~= "" and OPObjectSpell ~= nil then
			self.editBox:SetText(OPObjectSpell)
		else 
			self.editBox:SetText("")
		end
		self.editBox:SetNumeric(true)
	end,
	OnHide = function(self)
		self.editBox:SetText("")
	end,
	enterClicksFirstButton = true,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	hasEditBox = true,
}

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
		eprint("There was an error saving your pre-set. Please use '/reload' and try again. If this persists, please report it as a bug.")
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
					return
				elseif confirmPSaveOverwrite then
					if name == confirmPSaveOverwriteName then
						confirmPSaveOverwrite = false 
						OPSaveMenuParamSaveForReal(name,false)
					else
						message("The name specified conflicts with an already saved Parameter Pre-set name. Hit save again to confirm that you wish to overwrite the previous save.")
						confirmPSaveOverwrite = true
						confirmPSaveOverwriteName = name
					end
					return
				else
					eprint("You tried to save with the same name as another Parameter Pre-set save, and an error occurred internally. Please remember how you did this and report it as a bug. Thanks you.")
					return
				end
				return
			end
		end
		OPSaveMenuParamSaveForReal(name,true)
	end
end

function OPSaveMenuParamSaveForReal(name,newKey)
	if newKey then
		table.insert(OPMasterTable.ParamPresetKeys, name)
		newKey = false
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
		for k,v in ipairs(OPMasterTable.RotPresetKeys) do -- Scan all our current saved rotation preset and confirm if we're overwriting one
			if v == name then -- if already saved name == new save name
				if not confirmRSaveOverwrite then -- If this is the first time, we'll do this, otherwise go to the second step
					message("The name specified conflicts with an already saved Rotation Pre-set name. Hit save again confirm that you wish to overwrite the previous save.") -- Warn the user about overwriting a current preset
					confirmRSaveOverwrite = true -- save that we've already warned them
					confirmRSaveOverwriteName = name -- keep the name in memory, so that if they close the menu and then save as a new name, we know to recheck again
					return
				elseif confirmRSaveOverwrite then -- if we're in the confirmation state
					if name == confirmRSaveOverwriteName then -- if the name matches the last warned overwrite name
						confirmRSaveOverwrite = false -- reset the check so we're back to normal
						OPSaveMenuRotSaveForReal(name,false) -- Save the actual preset yay!
					else -- if the name they're trying to save no longer matches the last warned name, we need to re-warn them that this name is also still taken!!
						message("The name specified conflicts with an already saved Rotation Pre-set name. Hit save again to confirm that you wish to overwrite the previous save.")
						confirmRSaveOverwrite = true -- Set the check to true again to make sure
						confirmRSaveOverwriteName = name -- and keep the new name in memory again, just incase they change it again
					end
					return
				else
					eprint("You tried to save with the same name as another Rotation Save, and an error occurred internally. Please remember how you did this and report it as a bug. Thanks you.")
					return
				end
				return
			end
		end
		OPSaveMenuRotSaveForReal(name,true)
	end
end

function OPSaveMenuRotSaveForReal(name,newKey)
	if newKey then
		table.insert(OPMasterTable.RotPresetKeys, name)
		newKey = false
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
		paramPresetDropSelect.Timer = C_Timer.NewTimer(0.5,function()
			GameTooltip:SetText("Select a previously saved parameter pre-set to load.\r\n", nil, nil, nil, nil, true)
			GameTooltip:AddLine("You can use '/opdelparam Name' in chat (where Name is the pre-set name, case sensitive) to delete any of these pre-sets including the default ones.",1,1,1,true)
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
			dprint("Tried to load Param Pre-set: "..self.value)
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
	local rotPresetDropSelect = CreateFrame("Frame", "rotPresetDropDownMenu", OPPanel4Rotation, "UIDropDownMenuTemplate")
	rotPresetDropSelect:SetPoint("LEFT", OPRotSaveButton, "RIGHT", -15, -1)
	rotPresetDropSelect:SetScript("OnEnter",function()
		GameTooltip:SetOwner(rotPresetDropSelect, "ANCHOR_LEFT")
		rotPresetDropSelect.Timer = C_Timer.NewTimer(0.5,function()
			GameTooltip:SetText("Select a previously saved rotation pre-set to load.\r\n", nil, nil, nil, nil, true)
			GameTooltip:AddLine("You can use '/opdelrot Name' in chat (where Name is the pre-set name, case sensitive) to delete any of these pre-sets including the default ones.",1,1,1,true)
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
			dprint("Tried to load Rot Pre-set: "..self.value)
			dprint(origx.." | "..origy.." | "..origz)
			if origx == OPRotationSliderX:GetValue() and origy == OPRotationSliderY:GetValue() and origz == OPRotationSliderZ:GetValue() then
				OPRotateObject();
				OPIMFUCKINGROTATINGDONTSPAMME = true
				OPClearRotateChatFilter()
				dprint("Loaded the same as whatever it is currently, so we're gonna apply the rotation anyways!")
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
	
	local clearmsg = gsub(Message,"|cff%x%x%x%x%x%x","");
	local clearmsg = clearmsg:gsub("|r","")

-- GObject Rotate Message Filter
	if RotateClarifier and Message:gsub("|.........",""):find("rotated") then
		dprint("RotateClarifier Caught Message")
		return true

-- GObject Spawn Message Filter
	elseif SpawnClarifier and clearmsg:find("[Spawned gameobject|Map:|Syntax|was not found|You do not have]") then
		if clearmsg:find("Spawned gameobject") then
			dprint("SpawnClarifier Caught SPAWNED Message")
			return true
		elseif clearmsg:find("Map:") then
			SpawnClarifier = false
			dprint("SpawnClarifier Caught MAP Message")
			return true
		elseif clearmsg:find("[Syntax|was not found|You do not have]") then
			SpawnClarifier = false
			dprint("SpawnClarifier Caught Syntax or Failure, Disabled.")
		end

-- GObject Scale Message Filter
	elseif ScaleClarifier and clearmsg:find("[Syntax|was not found|You do not have|Incorrect|GameObject .* has been set to scale]") then
		if clearmsg:find("Syntax") or clearmsg:find("was not found") or clearmsg:find("You do not have") or clearmsg:find("Incorrect") then
			ScaleClarifier = false
			dprint("ScaleClarifier Caught Syntax or Failure, Disabled.")
			return false
		elseif clearmsg:find("GameObject .* has been set to scale") then 
			ScaleClarifier = false
			dprint("ScaleClarifier Caught SCALE Message")
			return true
		end
	else
		dprint("No Clarifier Caught this, so lets let it pass")
		return false
	end
end

function Filter(Self,Event,Message)
	
	local clearmsg = gsub(Message,"|cff%x%x%x%x%x%x","");
	local clearmsg = clearmsg:gsub("|r","");
	
	if clearmsg:find("[Selected|Spawned] gameobject [^group]") and not clearmsg:find("[aA]dd") then
		lastSelectedObjectID = clearmsg:match("[Selected|Spawned] gameobject .* - (.*)%]")
		dprint("Last Selected|Spawned Object = "..tostring(lastSelectedObjectID))
		if OPParamAutoUpdateButton:GetChecked() then
			OPGetObject("RightButton")
		end
		isGroupSelected = false
		dprint("isGroupSelected false")
	elseif clearmsg:find("[Selected|Spawned] gameobject group") then
		isGroupSelected = true
		dprint("isGroupSelected true")
	elseif clearmsg:find("Spawned blueprint") or clearmsg:find("added %d+ objects to gameobject group") then
		isGroupSelected = true
		dprint("isGroupSelected true")
	end
		
	---------- Auto Update Rotation CAPTURES ----------
	
	if OPRotAutoUpdate:GetChecked()==true and not RotateClarifier then -- Is the AutoUpdate Rot enabled? (Check if RotateClarifier is enabled - if it is, we don't do anything as to not impact the sliders functioning normally)
		if clearmsg:find("You have rotated .* [%X%Y%Z]+") then -- Did we get a rotated object message?
			dontFuckingRotate = true -- Stop the sliders from actually causing a rotation
			if clearmsg:find("X:") then
				local x
				if clearmsg:find("from X.*to X") then
					x = tonumber(clearmsg:match("to X: (%-?%d*%.%d*)"))
					dprint("Relative Rotation Caught")
				else
					x = tonumber(clearmsg:match("X: (%-?%d*%.%d*)"))
				end
				if x < 0 then x = x+360 elseif x > 360 then x = x-360 end
				OPRotationSliderX:SetValueStep(0.0001)
				OPRotationSliderX:SetValue(x)
				dprint("Set Slider X to "..x)
			end
			if clearmsg:find("Y:") then
				local y
				if clearmsg:find("from Y.*to Y") then
					y = tonumber(clearmsg:match("to Y: (%-?%d*%.%d*)"))
					dprint("Relative Rotation Caught")
				else
					y = tonumber(clearmsg:match("Y: (%-?%d*%.%d*)"))
				end
				if y < 0 then y = y+360 elseif y > 360 then y = y-360 end
				OPRotationSliderY:SetValueStep(0.0001)
				OPRotationSliderY:SetValue(y)
				dprint("Set Slider Y to "..y)
			end
			if clearmsg:find("Z:") then
				local z
				if clearmsg:find("from Z.*to Z") then
					z = tonumber(clearmsg:match("to Z: (%-?%d*%.%d*)"))
					dprint("Relative Rotation Caught")
				else
					z = tonumber(clearmsg:match("Z: (%-?%d*%.%d*)"))
				end
				if z < 0 then z = z+360 elseif z > 360 then z = z-360 end
				OPRotationSliderZ:SetValueStep(0.0001)
				OPRotationSliderZ:SetValue(z)
				dprint("Set Slider Z to "..z)
			end
			dontFuckingRotate = false -- Allow sliders to cause rotation again
		end
		
		--[[
		if clearmsg:find("Pitch: %-?%d*%.%d*, Roll: %-?%d*%.%d*, Yaw/Turn: %-?%d*%.%d*") then
			local pitch = tonumber(clearmsg:match("Pitch: (%-?%d*%.%d*), Roll: %-?%d*%.%d*, Yaw/Turn: %-?%d*%.%d*"))
			if pitch < 0 then pitch = pitch+360 end
			local roll = tonumber(clearmsg:match("Pitch: %-?%d*%.%d*, Roll: (%-?%d*%.%d*), Yaw/Turn: %-?%d*%.%d*"))
			if roll < 0 then roll = roll+360 end
			local yaw = tonumber(clearmsg:match("Pitch: %-?%d*%.%d*, Roll: %-?%d*%.%d*, Yaw/Turn: (%-?%d*%.%d*)"))
			if yaw < 0 then yaw = yaw+360 end
			dprint(clearmsg)
			
			dontFuckingRotate = true
			OPRotationSliderX:SetValueStep(0.0001)
			OPRotationSliderY:SetValueStep(0.0001)
			OPRotationSliderZ:SetValueStep(0.0001)
			OPRotationSliderX:SetValue(roll)
			OPRotationSliderY:SetValue(pitch)
			OPRotationSliderZ:SetValue(yaw)
			dontFuckingRotate = false
			
			dprint("Roll: "..roll.." | Pitch: "..pitch.." | Turn: "..yaw)
		end
		--]]
	end
	
	-- Auto Update Tint --
	if OPTintAutoUpdateButton:GetChecked() then
		if OPTintDragging ~= true then
			if clearmsg:find("Removed GameObject.*'s tint") then
				OPResetTint();
			elseif clearmsg:find("Removed GameObject.*'s spell") then
				OPObjectSpell = nil
				updateSpellButton()
			elseif clearmsg:find("Set GameObject.* to .* tint .*") or clearmsg:find("GameObject group.*now uses tint") then
				local r, g, b, a = clearmsg:match("tint (%d+) (%d+) (%d+) %(transparency (%d+)%)")
				OPTintSliderR:SetValue(r)
				OPTintSliderG:SetValue(g)
				OPTintSliderB:SetValue(b)
				OPTintSliderT:SetValue(a)
				dprint("R:"..r.." G:"..g.." B:"..b.." T:"..a)
			elseif clearmsg:find("Set GameObject.* to .* spell effect") or clearmsg:find("GameObject group.*uses spell effect") then
				OPObjectSpell = clearmsg:match("spell effect (%d+)")
				updateSpellButton()
				dprint("OPObjectSpell set: "..OPObjectSpell)
			end
		else
			if clearmsg:find("Removed GameObject.*'s [tint|spell]") or clearmsg:find("Set GameObject.* to .* tint .*") or clearmsg:find("GameObject group.*now uses tint") then
				if OPShowMessagesToggle:GetChecked() ~= true then
					return true;
				end
			end
		end
	end
	
	------------------------------------------------
	
	
	---- Handling Hiding Messages to avoid Spam ----
	
	if ObjectClarifier or SpawnClarifier or ScaleClarifier or RotateClarifier then
		--Check to see if we sent a request and we don't want to see messages
		if OPShowMessagesToggle:GetChecked() ~= true then
			if (RunChecks(Message)) then
				return true
			end
		else
			RunChecks(Message)
		end
	end
	
	
end

--Apply filter
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", Filter)


-------------------------------------------------------------------------------
-- Recieving GObject Info on Select
-------------------------------------------------------------------------------

--[[
1 guid / 2 entry / 3 name / 4 filedataid / 5 x / 6 y / 7 z / 8 rx / 9 ry / 10 rz / 11 UNKNOWN / 12 HasTint / 13 red / 14 green / 15 blue / 16 alpha / 17 spell / 18 scale / 19 isWMO
85308046 829506 7du_karazhanb_globe01.m2 1522793 -147.125 6287.19 315.226 0 5.99998 -0 0 1 20 20 60 0 0 1
]]

local function Addon_OnEvent(self, event, ...)
	if event == "CHAT_MSG_ADDON" then
		local prefix = select(1,...)
		if prefix == "EPSILON_OBJ_INFO" then
			local objdetails = select(2,...)
			local sender = select(4,...)
			local self = table.concat({UnitFullName("PLAYER")}, "-")
			if sender == self then
				local guid, entry, name, filedataid, x, y, z, UNKNOWN, rx, ry, rz, HasTint, red, green, blue, alpha, spell, scale = strsplit(strchar(31),objdetails)
				OPLastSelectedObjectData = {guid, entry, name, filedataid, x, y, z, UNKNOWN, rx, ry, rz, HasTint, red, green, blue, alpha, spell, scale}
				if OPMasterTable.Options["debug"] then
					print("GOBINFO:",guid, entry, name, filedataid, x, y, z, UNKNOWN, rx, ry, rz, HasTint, red, green, blue, alpha, spell, scale)
				end
				
				-- Set Spell Tracker - Not saved so no fancy stuff needed

				
				-- Update Tints
				if OPTintAutoUpdateButton:GetChecked() then
					OPTintSliderR:SetValue(red)
					OPTintSliderG:SetValue(green)
					OPTintSliderB:SetValue(blue)
					OPTintSliderT:SetValue(alpha)
					dprint("Updating Tint Sliders")
					
					
					if spell and spell ~= "" and tonumber(spell) > 0 then
						OPObjectSpell = spell
						updateSpellButton()
					else
						OPObjectSpell = nil
						updateSpellButton()
					end
				end
				
				-- Update Rotations
				if OPRotAutoUpdate:GetChecked() then
					rx, ry, rz = tonumber(rx),tonumber(ry),tonumber(rz)
					if rx < 0 then rx = rx+360 elseif rx > 360 then rx = rx-360 end
					if ry < 0 then ry = ry+360 elseif ry > 360 then ry = ry-360 end
					if rz < 0 then rz = rz+360 elseif rz > 360 then rz = rz-360 end
					OPRotationSliderX:SetValueStep(0.0001)
					OPRotationSliderY:SetValueStep(0.0001)
					OPRotationSliderZ:SetValueStep(0.0001)
					OPRotationSliderX:SetValue(rx)
					OPRotationSliderY:SetValue(ry)
					OPRotationSliderZ:SetValue(rz)
				end
			else
				eprint("Illegal Sender ("..sender..") | (Expected:"..self..")")
			end
			dprint("Caught EPSILON_OBJ_INFO prefix")
			dprint(event, ...)
		end
	elseif event == "PLAYER_LOGIN" then
		local successfulRequest = C_ChatInfo.RegisterAddonMessagePrefix(addonPrefix)
		if successfulRequest ~= true then
			eprint("ObjectMover failed to create AddonMessage listener, automatic Rotation & Tint options disabled.")
		end
	end
end
local f = CreateFrame("Frame")
f:SetScript("OnEvent", Addon_OnEvent)
f:RegisterEvent("CHAT_MSG_ADDON");
f:RegisterEvent("PLAYER_LOGIN");

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
	if msg:find("clarifier") then
		dprint("RotateClarifier = "..tostring(RotateClarifier).." | SpawnClarifier = "..tostring(SpawnClarifier).." | ObjectClarifier = "..tostring(ObjectClarifier).." | ScaleClarifier = "..tostring(ScaleClarifier), true)
	else
		OPMasterTable.Options["debug"] = not OPMasterTable.Options["debug"]
		dprint("Object Mover Debug Set to: "..tostring(OPMasterTable.Options["debug"]), true)
	end
end

SLASH_OPDELPARAM1 = '/opdelparam';
function SlashCmdList.OPDELPARAM(msg, editbox) -- 4.
	if msg then
		for k,v in ipairs(OPMasterTable.ParamPresetKeys) do
			if msg == v then
				table.remove(OPMasterTable.ParamPresetKeys, k)
				OPMasterTable.ParamPresetContent[msg] = nil
				print("ObjectMover: Deleting Parameter Pre-set "..msg)
			else
				dprint(""..msg.." is not a saved Param Pre-set?")
			end
		end
	else
		print("ObjectMover SYNTAX: '/opdelparam [name of Parameter Pre-set to delete]'")
	end
end

SLASH_OPDELROT1 = '/opdelrot';
function SlashCmdList.OPDELROT(msg, editbox) -- 4.
	if msg then
		for k,v in ipairs(OPMasterTable.RotPresetKeys) do
			if msg == v then
				table.remove(OPMasterTable.RotPresetKeys, k)
				OPMasterTable.RotPresetContent[msg] = nil
				print("ObjectMover: Deleting Rotation Pre-set: "..msg)
			else
				dprint(""..msg.." is not a saved Rot Pre-set?")
			end
		end
	else
		print("ObjectMover SYNTAX: '/opdelparam [name of Parameter Pre-set to delete]'")
	end
end
