ObjectMoverChangelog = [[
#v7.2.0 (June?? 1st, 2022)
	
	- NEW: You can now toggle the mouse-over Tooltips in the 
	      ObjectMover 'Options' tab (right-click the ObjectMover Icon)
	- NEW: Text Generator option within the Manager Tab! This allows you 
	      to type text (letters, numbers, and supported symbols) into a 
	      dialogue box, then hit Start to spawn the text using the 
	      Epsilon_Haven objects! Objects are automatically grouped once 
	      spawned for easy moving & scaling.
	- UPDATED: Rotate Sliders now use Client-Side rotation until you let go,
	      then it saves - others will only see the final rotation after it saves.
	- UPDATED: Rotate Z Slider now works - kinda - on Groups. 
	      You NEED TO HAVE AUTO-UPDATE ON & SELECT THE LEAD OBJECT
	      FIRST, OR start at 0 when selecting the group. It's the best I 
	      could do at 2am, leave me alone :(
	- UPDATED: ObjectMover now has a new Minimap icon, made by Tia!! 
	      Look for the new Blue & Gold icon. Thanks T! <3
	- UPDATED: Extended Information (i) panel renamed to "Selected 
	      Object Info" to better describe what it shows. 
	   - This panel can now be separated from the main panel by dragging
	   from the title. You can also resize it on it's own.
	   - This panel can be toggled to auto-show on login in the 'Options' 
	      tab.
	   - Added more object data to the Selected Object Info panel (Scale &
	   Object Dimensions).
	      - Object Dimensions will show a pop-up of the non-rounded
	         dimensions if you hover over it. Does not turn off with the
	         Tooltip toggle.
	   - Object Preview is now able to be zoomed using the mouse-wheel.
	      Hold Shift to zoom faster.
	   - Object Preview now shows the tint & transparency of a selected
	      object. 
	      - If an object is completely transparent, it will show the
	         non-transparent object so you can see what's selected!
	- CHANGED: Tint & Overlay pannel now let's you better control if you're using Tint or Overlay - this comes on the heels of Tint now supporting Saturation as well!
	- CHANGED: Move Object has been replaced with Move Player. It made no sense that OBJECTMOVER moved PLAYERS by default, not objects. This is corrected. Thank you everyone asking "Why is object mover moving my character and not the object?" in discord for pointing out this logical flaw.

## _________________________________________________

#v7.1.0 (February 26th, 2022)
	
	- UPDATED: Tint now supports the new |cffFFAAAA!go overlay|r system.
	- - - NOTE: Tint is still supported - ObjectMover will use |cffFFAAAA!go tint|r system if Saturation is 0!
	- ADDED: ObjectMover will now display the name of the object selected at the top of the Object Info panel.
	- NEW: Manager Tab! This allows you quicker access to basic object controls & management, such as Select, Copy, Delete, and more. This area is still a heavy WIP and more features will be added later!
	- NEW: Extended Information Panel! Click the 'i' icon in the top left to show a new pop-out menu with extended object information & a preview of the object selected. This area is still a WIP and some data will remain "No Data Available" until future support is added.

## _________________________________________________

#v7.0.2 (December 18, 2021)
	
	- Improved Group Support (Go To supports Group)	
	- Disabled Rotation Sliders when selecting a group to be more clear that they only work on single objects - sorry, no Rotating Groups yet!
	
### Did you know: ObjectMover supports moving Groups! Simply select a group, and ObjectMover will switch to moving the group instead!


## _________________________________________________

# v7.0.1 (b/No Version Change) (August 31, 2021)

	- Added more GameObject_Type's to isWMO to help prevent crashes on |cffFFAAAA!go select|r.

# v7.0.1 (August 3, 2021)

	- Added an in-game Changelog/Help Manual (Options tab added but not functional yet)
	- Made the main window respect ALT+Z + Better UI Frame
	- Made the main window resizable (Grabby button in the bottom right - |cffFFAAAARight-Click|r to reset the size to default)
	
	- Reminded everyone that "Double" and "Half" features are still here. You can |cffFFAAAAShift-Click|r on the x2 and 1/2 buttons on Length/Width/Height in order to update all three at the same time, which is exactly what the old checkboxes did in the background.

## _________________________________________________

# v7.0.0 (July 29, 2021)

	- NEW: Added Tint & Object Spell Support
	- NEW: Object Group Support (Automatic)
	- NEW: Automatic Dimension Detection for M2's
	- NEW: Auto Update mode for Object Parameters (Will auto fill selected objects ID, Scale, and if it's an M2, the dimensions as well)
	- NEW: Auto Show option - Toggle on to automatically show ObjectMover when you load in
	- NEW: Fade Out option - Toggle on to fade ObjectMover to be less distracting when not in immediate use
	- UPDATED: Scale Object now works with Macro Spawning instead of delayed scale commands (No Delay, No Desync)
	- UPDATED: Scale Object now applies to the selected object when entered
	- UPDATED: Saved Presets can now be deleted directly from the UI (Right-Click in Load Dropdown to delete, no need to use chat commands now)
	- CHANGED: Spawn is now in Object section; Revised Movement button placements
	- CHANGED: Added a "Classic Layout" button in Movement to revert the movement buttons to closer to the original layout
	- REMOVED: Double & Halve checkboxes. 
		- You can still use the Double (x2) and Halve (1/2) buttons to change each dimension, or SHIFT-CLICK them to update all dimensions together.
	Behind the Scenes:
	- Minimap Icon is better and more adaptable to if you use other minimaps / UI's
	- Improved ToolTips & UI Indications when things are disabled
	- Improved Slider Logic
	- Keybindings are sorted into their own category to be easier to find

## _________________________________________________

# v6.0.0 (March 21, 2020)

	- Auto Update Rot. finished and activated  (note: ".go pitch/roll/turn" will be off until the next server mini-update due to syntax issues in the old reply - it will automatically work perfect once the server updates to the new command syntax!)
	- Major restructure of the ChatFilter to clean it up. It should be way more reliable. No more "My commands aren't showing in chat anymore wtf?" hopefully.
	- Move Relative now uses the server commands for best performance
	- More Cowbell
	
## _________________________________________________

See [https://forums.epsilonwow.net/topic/467-addon-objectmover/](https://forums.epsilonwow.net/topic/467-addon-objectmover/) for more.
]]

ObjectMoverHelpManual = [[
# Object Mover Manual

## Spawn/Move Info

### Parameters:
|cffFFCC00 - Object ID|r - This is where you would fill in the ID of the Object you want to spawn. Only single objects are supported here, not Blueprints.
|cffFFCC00 - Length/Width/Height|r - This determines how far you, or the object, will move when using the Movement buttons. AKA: The object dimensions.
|cffFFCC00 - Scale|r - Changing this will scale your currently selected object, and, |cffFFAAAAif the checkbox is enabled|r, apply the scale to any newly spawned objected. If the checkbox is enabled, all Length/Width/Height will be automatically adjusted for the scale as well. |cffAAAAAA(Example: Length 4 at Scale 2 will move by 8.)|r

### Buttons:
|cffFFCC00 - Get ID|r - This will get the ID of the currently selected Object and fill it into the Object ID box. |cffFFAAAARight-Click|r will also try and auto-fill the Length/Width/Height parameters.
|cffFFCC00 - x2 (Double)|r - This will double the number in the dimension that it is in line with. |cffFFAAAAShift-Click|r to double all 3 dimensions.
|cffFFCC00 - 1/2 (Half)|r - This will halve the number in the dimension that it is in line with. |cffFFAAAAShift-Click|r to halve all 3 dimensions.
|cffFFCC00 - Save|r - Saves all the current information in the Object Info section to a new pre-set for later use. Leaving something blank, or as 0, will not 'save' that specific setting, allowing you to save just the data you want if needed.
|cffFFCC00 - Load|r - Loads a previously saved pre-set. |cffFFAAAARight-Click|r a pre-set to delete it.
|cffFFCC00 - Auto Update|r - Updates Object ID, Length/Width/Height, and Scale info when selecting an object. Note that Length/Width/Height will only update when selecting an |cffFFAAAAM2 object|r, not a WMO.
|cffFFCC00 - Spawn|r - Spawns the currently selected object. Automatically scales it if Scale is set & checked.
|cffFFCC00 - (i) Button|r - Shows the "Selected Object Info" Pop-out (see below for more info).

## _________________________________________________

## Movement

|cffFFCC00 - Forward/Back|r - Moves you, or the object, Forward/Back by the 'Length' amount.
|cffFFCC00 - Left/Right|r - Moves you, or the object, Left/Right by the 'Width' amount.
|cffFFCC00 - Up/Down|r - Moves you, or the object, Up/Down by the 'Height' amount.
|cffFFCC00 - Go To|r - Teleports you to the selected object.
|cffFFCC00 - Classic Layout|r - Adjusts the Movement buttons to a more classic (WASD) style layout.

## _________________________________________________

## Options

|cffFFCC00 - Move Player|r - Move the Player Character instead of your selected object/group.
|cffFFCC00 - Spawn on Move|r - Spawns an object each time you move - Only available in |cffFFAAAAMove Player|r mode.
|cffFFCC00 - Move Relative|r - Moves the object relative to the direction YOU are facing instead of the direction the object is facing. Not usable in |cffFFAAAAMove Player|r mode. 
|cffFFCC00 - Auto Show|r - Always Show the ObjectMover UI when first loading in.
|cffFFCC00 - Fade Out|r - Fade the UI out when not currently moused over.
|cffFFCC00 - Messages|r - Show Rotation & Tint messages in chat. This will spam your chat.

## _________________________________________________

## Rotation Tab

### Sliders

These will automatically apply to the object as you drag the sliders:
|cffFFCC00 - Roll|r - Rotate/Tilt the object on a side-to-side horizonatal axis.
|cffFFCC00 - Pitch|r - Pitch/Tilt the object on a forward-to-back horizontal axis.
|cffFFCC00 - Turn|r - Rotate the object around it's center on a vertical axis.

|cffFFAAAA - Hold Shift or Alt|r while dragging a slider to adjust it's decimal places to get a more percise rotation.

### Buttons

|cffFFCC00 - Save|r - Save the current rotations as a pre-set. Set a rotation to -1 to ignore it when saving/loading.
|cffFFCC00 - Load|r - Load a saved pre-set. Values saved as -1 will be ignored. |cffFFAAAARight-Click|r a pre-set to delete it.
|cffFFCC00 - Auto Update|r - Updates the Roll/Pitch/Turn sliders to match an object when selected.
|cffFFCC00 - Apply|r - Apply the current rotation to the selected object.

## _________________________________________________

## Tint/Overlay Tab

|cffFFCC00 - Red/Green/Blue|r - Adjust the tint colors of an object.
|cffFFCC00 - Transparency|r - Adjust the transparency of an object.
|cffFFCC00 - Saturation|r - Adjust the color saturation (strength) on an object.
|cffFFCC00 - Color Picker|r - Open a color wheel to select a color & saturation from there.
|cffFFCC00 - Apply|r - Apply the current color to the selected object. |cffFFAAAARight-Click|r to remove/reset the tint on an object.
|cffFFCC00 - Spell|r - Apply a spell as a visual effect on an object. |cffFFAAAARight-Click|r to remove/reset the spells on an object.
|cffFFCC00 - Auto Update|r - Updates the sliders & spell button to match an object when selected.
|cffFFCC00 - Use Overlay|r - Use Overlay as your coloring method. Overlay has a shine, and better replaces the color to a more consistent coloring.

## _________________________________________________

## Manager Tab

|cffFFCC00 - Select|r - Select the nearest object.
|cffFFCC00 - Unselect|r - Unselect an object. No object will be selected after.
|cffFFCC00 - Copy|r - Copies the current object ontop of itself.
|cffFFCC00 - Delete|r - Delete the selected object. You must |cffFFAAAARight-Click|r this button for it to work.
|cffFFCC00 - Visibility|r - Open a dropdown to select from pre-set visibility options, or select |cffFFAAAACustom|r to enter your own number. Max of 533, or -1 for permanent (~3000).
|cffFFCC00 - Animation|r - Open a dropdown to select from the most common object animations, or select |cffFFAAAACustom|r to enter your any number.
|cffFFCC00 - Face Object|r - Use these buttons to quickly face an object in cardinal directions |cffFFAAAA[North (N), East (E), South (S), West(W)]|r, or face the direction your character is facing |cffFFAAAA(C)|r.

## _________________________________________________

## "Selected Object Info" Pop-out
|cffFFCC00 - This pop-out panel shows data on your currently selected object.|r - All data is fairly self-explanatory, but a few have extra functions:
|cffFFCC00 - Dimensions|r - Dimensions are rounded to the nearest 4 decimal places so they fit in the box. |cffFFAAAAHover your mouse|r over them for a tooltip with their full un-rounded* dimensions. Only works for M2 objects, not WMO objects.
|cffFFCC00 - Preview|r - Only shows previews for M2 objects, not WMO objects. 
|cffFFAAAAScroll|r to zoom in & out. |cffFFAAAAHold shift|r to zoom faster. #ZoomZoom

]]
--[[ Blank Space for Tabbing : Copy this : ' ' ]]