-------------------------------------------------------------------------------
-- Initialize Variables
-------------------------------------------------------------------------------

local OPmoveLength, OPmoveWidth, OPmoveHeight, OPmoveModifier, MessageCount, ObjectClarifier, SpawnClarifier, ScaleClarifier, RotateClarifier = 0, 0, 0, 1, 0, false, false, false, false
BINDING_HEADER_OBJECTMANIP, SLASH_SHOWCLOSE1, SLASH_SHOWCLOSE2 = "Object Mover", "/obj", "/om"

OPMasterTable = {}
OPMasterTable.Options = {}
OPAutoDimObjectDB = {}
OPMasterTable.Options["SliderStep"] = 0.01

OPDebug = 0 -- // 0 - Off, 1 - On (Verbose)
OPFramesAreLoaded = false
FrameLoadingPoints = 0

function OPInitializeLoading()
	FrameLoadingPoints = FrameLoadingPoints+1
	if FrameLoadingPoints >= 3 then
		OPFramesAreLoaded = true
		FrameLoadingPoints = 0
		if OPDebug == 1 then
			print("Frames Loaded: Rotation Enabled.")
		end
	end
end

local OPloginhandle = CreateFrame("frame","OPloginhandle");
OPloginhandle:RegisterEvent("PLAYER_LOGIN");
OPloginhandle:SetScript("OnEvent", function()
	OPMiniMapLoadIt()
end);

function OPMiniMapSaveIt()
	local point, relativeTo, relativePoint, xOffset, yOffset = ObjectManipulator_MinimapButton:GetPoint()
	OPMasterTable.Options["MinimapButtonSavePoint"] = strjoin(" ", point, "Minimap", relativePoint, xOffset, yOffset)
	--print(OPMasterTable.Options["MinimapButtonSavePoint"])
end

function OPMiniMapLoadIt()
	if OPMasterTable.Options["MinimapButtonSavePoint"] ~= nil and OPMasterTable.Options["MinimapButtonSavePoint"] ~= "" then
		local point, relativeTo, relativePoint, xOffset, yOffset = strsplit(" ", OPMasterTable.Options["MinimapButtonSavePoint"])
		ObjectManipulator_MinimapButton:SetPoint(point, "Minimap", relativePoint, xOffset, yOffset)
	end
	--print(OPMasterTable.Options["MinimapButtonSavePoint"])
end
-------------------------------------------------------------------------------
-- Simple Chat Functions
-------------------------------------------------------------------------------

local function cmd(text)
  SendChatMessage("."..text, "GUILD");
end

local function emote(text)
  SendChatMessage(""..text, "EMOTE");
end

local function msg(text)
  SendChatMessage(""..text, "SAY");
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
	if Halve:GetChecked() == true then OPmoveModifier = 0.5
	elseif Bifold:GetChecked() == true then OPmoveModifier = 2
	else OPmoveModifier = 1 end	
	if ScaleObject:GetChecked() == true then
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
		if OPMoveObjectInstead:GetChecked() == true then
			cmd("go move for "..OPmoveLength)
		else
			cmd("gps for "..OPmoveLength)
		end
		if SpawnonMove:GetChecked() == true then
			OPSpawn()
		end
		if OPDebug == 1 then
			print("Object Mover Debug: Moving "..OPmoveLength.." units forward.")
		end
	else
		print("ObjectMover | Invalid Move Length, please check your Object Parameters.")
	end
end

function OPBackward()
	updateDimensions("length")
	if OPmoveLength and OPmoveLength ~= "" and OPmoveLength ~= 0 and OPmoveLength ~= nil then
		if OPMoveObjectInstead:GetChecked() == true then
			cmd("go move back "..OPmoveLength)
		else
			cmd("gps back "..OPmoveLength)
		end
		if SpawnonMove:GetChecked() == true then
			OPSpawn()
		end
		if OPDebug == 1 then
			print("Object Mover Debug: Moving "..OPmoveLength.." units backwards.")
		end
	else
		print("ObjectMover | Invalid Move Length, please check your Object Parameters.")
	end
end

function OPLeft()
	updateDimensions("width")
	if OPmoveWidth and OPmoveWidth ~= "" and OPmoveWidth ~= 0 and OPmoveWidth ~= nil then
		if OPMoveObjectInstead:GetChecked() == true then
			cmd("go move left "..OPmoveWidth)
		else
			cmd("gps left "..OPmoveWidth)
		end
		if SpawnonMove:GetChecked() == true then
			OPSpawn()
		end
		if OPDebug == 1 then
			print("Object Mover Debug: Moving "..OPmoveWidth.." units left.")
		end
	else
		print("ObjectMover | Invalid Move Width, please check your Object Parameters.")
	end
end

function OPRight()
	updateDimensions("width")
	if OPmoveWidth and OPmoveWidth ~= "" and OPmoveWidth ~= 0 and OPmoveWidth ~= nil then
		if OPMoveObjectInstead:GetChecked() == true then
			cmd("go move right "..OPmoveWidth)
		else
			cmd("gps right "..OPmoveWidth)
		end
		if SpawnonMove:GetChecked() == true then
			OPSpawn()
		end
		if OPDebug == 1 then
			print("Object Mover Debug: Moving "..OPmoveWidth.." units right.")
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
		if OPDebug == 1 then
			print("Object Mover Debug: Moving "..OPmoveHeight.." units up.")
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
		if OPDebug == 1 then
			print("Object Mover Debug: Moving "..OPmoveHeight.." units down.")
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
	if ScaleObject:GetChecked() == true then
		--Do we want to scale it?
		--SendChatMessage(".go select") --Auto Selected on Spawn now, no need to select, as it can cause problems if it selects the wrong one anyways.
		if ScaleClarifier == false then
			ScaleClarifier = true
		end
		SendChatMessage(".go scale "..OPScaleBox:GetText())
	end
end

function OPTeletoObject()
	SendChatMessage(".go go")
end

function EnableBoxes(Box1, Box2)
	--This is just to cut down on the xml size when enabling and disabling the Halve and Bifold checkboxes via binding - make sure we're not both checked
	if Box1:GetChecked() == 1 then
		Box1:SetChecked(false)
	else
		Box1:SetChecked(true)
	end
	if Box2:GetChecked() == 1 then
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
	cmd("go rot "..RotationX.." "..RotationY.." "..RotationZ)
end

function roundToNthDecimal(num, n)
  local mult = 10^(n or 0)
  return math.floor(num * mult + 0.5) / mult
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
		if OPDebug == 1 then
			print("RotateClarifier Caught Message")
		end
	end

-- GObject Spawn Message Filter
	if SpawnClarifier and Message:gsub("|.........",""):find("Spawned") then
		SpawnClarifier = false
		if OPDebug == 1 then
			print("SpawnClarifier Caught Message")
		end
	end

-- GObject Scale Message Filter
	if ScaleClarifier and Message:gsub("|.........",""):find("scale") then
		ScaleClarifier = false
		if OPDebug == 1 then
			print("ScaleClarifier Caught Message")
		end
	end
	
-- Get Object ID Message Filter
	if ObjectClarifier and Message:gsub("|.........",""):find("%-%s%d+") then
		OPObjectIDBox:SetText(gsub(Message:gsub("(|.........)", ""):match("- %d+"), "- ", ""))
	end
	if ObjectClarifier then
		MessageCount = MessageCount+1
		if MessageCount >= 3 then
			ObjectClarifier = false
			MessageCount = 0
			if OPDebug == 1 then
				print("ObjectClarifier disabled.")
			end
		end
	end
end

function Filter(Self,Event,Message)
	if ObjectClarifier or SpawnClarifier or ScaleClarifier or RotateClarifier then
		--Check to see if we sent a request and we don't want to see messages
		if Messages:GetChecked() ~= true then
			--If so, run the checks and delete the message
			RunChecks(Message)
			return true
		else
			--If we do want to see messages, keep the message and run the checks any ways since we sent a request
			RunChecks(Message)
		end
	end
end
--

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

--SLASH_OPAUTODIMADD1, SLASH_OPAUTODIMADD2 = '/addobject', '/omadd';
function SlashCmdList.OPAUTODIMADD(msg, editbox)
	if msg:find("%d+%s+%d+%.*%d*%s+%d+%.*%d*%s+%d+%.*%d*") then
		local ObjID,ObjX,ObjY,ObjZ = strsplit(" ", msg)
		print("Object (ID: "..ObjID..") added with parameters, X: "..ObjX..", Y: "..ObjY..", Z: "..ObjZ..".")
	end
	--print("Feature not available. Please check for updates in the future.")
end