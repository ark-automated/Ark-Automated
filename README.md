# Ark-Automated
AHK tool to automate things with macros for the game ARK: Survival Evolved. 
WILL FOLLOW ALL ARK: Survival Evoled RULES, if Wilcard wants something removed it will be removed.

If you have any suggestions for new macros feel free to send them to me.

Discord: https://discord.gg/9sszHzr

Download latest version here: https://github.com/ark-automated/Ark-Automated/releases/latest


Preview(does not include latest macros added in V0.4):

![Preview](https://raw.githubusercontent.com/ark-automated/Ark-Automated/master/Preview.gif)

Macrostatus in game example:

![Macrostatus preview](https://raw.githubusercontent.com/ark-automated/Ark-Automated/master/MacroStatus.png)

This started as a simple front end for people that wanted to use my AHK macro/scripts. Most of my scripts have been simplified and/or just copy/pasted into here.

## Current macros:
|Macro|Description|
|--|--|
| SimpleMacro| With this macro you can spam the key you set below with the interval you set in the second box.|
| Babyfeeder single |With this macro you can feed one baby by having the babies inventory open and the food you want to give it accessable from the first slot in your inventory.(search for your food if implant is in slot 1)  |
|Babyfeeder mass|With this macro you can raise many babies at once by continuesly healing them over and over again. You must start the macro when sitting on a snow owl. Configure the heal duration and time between heals below. Enter the heal time of the snow owl in the first box(including the time to spin up) and the time between heals in the second one(in miliseconds)|
|Empty cropplots|Removes everything from the cropplot and then puts the fertilizer back.|
|Empty drops|Press the hotkey when the drop is open to quickly withdraw all from the remote inventory. Premium members can use the premium version which will spam open the drop+spam the virtual controller button to withdraw all. (will be added to normal one later, just need to figure out an easy way to emulate a controller)|
|OpenBunnyEggs|Start with bunny eggs in hotbar slot 1 and eggs in inventory. Make sure to aim a litle bit away from the ground and the egg so your character will place the egg without hitting the ground or the egg in case of lag(hitting egg or structure will make your character lose HP.) This only works when easter event is active.|
|Fastdrop DedicatedStorage|Start with the Dedicated Storage Box inventory open. This macro will withdraw all from the Dedicated storage and then drop from inventory until it will take more from the dedicated storage box. This is a lot faster than manually pressing O while hovering over the remote inventory slot. Make sure to either filter for the item you want to drop in your inventory, or have an empty inventory.|
|Spam inventory|This macro will spam the key you set below across the first row of your or the remote inventory. Example usecases: Opening gacha crystals, dropping items instead of creating a bag(useful when emptying anky etc). Will keep running until you stop it. Remote inventory will be added soon|
|Bloodpack farmer|The following 2 methods are available to create bloodpacks: Medbrews and tek pod. REQUIRES USING THE ENGLISH LANGUAGE IN GAME.<br> Medic brew method:<br>Start the script with your inventory open and with enough medical brews and a blood syringe in your inventory. Does not stop when out of brews so it will suicide if you do not stop it in time.<br>Tek pod method:<br>Start the script while laying in the tek pod. Make sure that your tek pod is placed with the head facing north and feet facing south so you can access the tek pod without moving.|
|Baby claiming & closing name menu|This macro will automatically claim the dino you are facing and close the naming popup. NOT YET IMPLEMENTED DUE TO ARK HOTKEY CHANGES THAT MUST BE MADE
|Dust2Elementcrafter|With this macro you can turn dust from a dedicated storage box into element. How to startHave the Dedicated storage with dust open and put the Unstable Element engram in your FIRST hotbar(bar at the bottom) that has the button 1 assigned to it. TODO: Add focal chili consumption toggle|
|FarmAssistant|With this macro you can farm resources and drop the things you do not want. Below you can set what to drop when the inventory is full(black icon displayed). Seperate the drop items with a , (comma). Currently clicks every 500ms(0.5seconds)|
|AutoWalker|Holds down shift+w until toggled off|
|Berry2Seed|This macro will use the seed option on an Iguanodon to make seeds and drop the seeds from the Iguanodon inventory in a bag on the ground. Requires you to have berries in your inv for restacking each time.|



	Lots of work in progress

    TODO:
        Functions/macros:
            -Public Chat translator (requires global font and right now only works with a locally running application for OCR, gotta find public API+better OCR solution for translation on other screensizes)
            -Make the premium fishing script public that works on many resolutions but requires some manual setup for now
            -Mass feeder that feeds babies individually like the premium one currently does, depends on OCR functionality and what is and isn't okay with Wildcard
            -Baby naming closing made easier
            -Search+withdraw function to empty stuff like snails and eventually replace EmptyCropplots
            -Radial menu automator(for stuff like exporting/renaming dinos or changing following distance)

        GUI:
            -Make X/Ypos of ark UI locations Bobby friendly
            -Fix odd glitches
            -Make it possible to change the macrostatus location

        General:
            -Fix lots of weird formatting/bloated/useless code
            -Make it easier for people to add macros
            -Make premium functions public(depends on 2 things: 1. Does Wildcard allow them? 2. One size fits all has to be working without needing manual support)
            -Cleanup the ini junk
            -Only work in ark toggle



Uses https://github.com/G33kDude/Neutron.ahk for the GUI
