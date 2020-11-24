﻿/*
    This started as a simple front end for people that wanted to use my AHK scripts. Most of my scripts have been simplified and/or just copy/pasted into here.


	Lots of work in progress

    TODO:
        Functions/macros:
            -Autowalker/keydown with shift support
            -Public bloodpack
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

; Variable names explained:
; Xli = Xpos Local Inventory
; Yli = Ypos Local Inventory
; Xri = Xpos Remote Inventory
; Yri = Ypos Remote Inventory
; Xwa = Xpos Withdraw All
; Ywa = Ypos Withdraw All
; Xda = Xpos Deposit All
; Yda = Ypox Deposit All
; Xls = Xpos Local Search
; Yls = Ypos Local Search
; Xrs = Xpos Remote Search
; Yrs = Ypos Remote Search
; Xlf = Xpos Local Full(black icon thingy)
; Ylf = Ypos Local Full
; Xrf = Xpos Remote Full
; Yrf = Ypos Remote Full
; Xld = Xpos local dropall
; Yld = Ypos local dropall
; Xrd = Xpos remote dropall
; Yrd = Ypos remote dropall

*/

#NoEnv
SetBatchLines, -1
#SingleInstance Force
ListLines Off ; Can enable for debugging purposes
#Persistent
SetWorkingDir %A_ScriptDir%
SetTitleMatchMode, 1
Process, Priority, , A


#Include Neutron.ahk

Try ; Change the icon from the default AHK icon to something else, to prevent the script from throwing an error when no icon.ico is available
{
    Menu, Tray, Icon, icon.ico
}

curAAVersion := 0.3

whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
whr.Open("GET", "https://raw.githubusercontent.com/ark-automated/Ark-Automated/master/version.txt", true)
whr.Send()
whr.WaitForResponse()
latAAVersion := Round(whr.ResponseText,3)

; check version
if (curAAVersion < latAAVersion){
    MsgBox,4,Ark Automated update available!, Update available! Check the Discord or Github for latest info. `nYour version %curAAVersion% `nLatest version: %latAAVersion% `nWould you like to visit the Github page?
    IfMsgBox Yes
        run https://github.com/ark-automated/Ark-Automated
        return
}

if !FileExist("ArkAutomated.ini") ; If ArkAutomated.ini does not exist it will create one
    Generateini()
    
; Create a new NeutronWindow and navigate to our HTML page
neutron := new NeutronWindow()
neutron.Load("AA_GUI.html")

; Use the Gui method to set a custom label prefix for GUI events. This code is
; equivalent to the line `Gui, name:+LabelNeutron` for a normal GUI.
neutron.Gui("+LabelNeutron")

; Show the Neutron window
neutron.Show("w850 h850")
LoadIni()
return

; FileInstall all your dependencies, but put the FileInstall lines somewhere
; they won't ever be reached. 
FileInstall, AA_GUI.html, AA_GUI.html
FileInstall, Neutron.ahk, Neutron.ahk
FileInstall, bootstrap.min.css, bootstrap.min.css
FileInstall, jquery.min.js, jquery.min.js
FileInstall, bootstrap.bundle.js, bootstrap.bundle.js
FileInstall, icon.ico, icon.ico
FileInstall, V0.3_settings_instructions.png, V0.3_settings_instructions.png

NeutronClose:
ExitApp
return


SetTitle(neutron)
{
    global curAAVersion
    neutron.doc.getElementById("titlebar123").innerHTML := "Ark Automated V" curAAVersion " by Olivier#6863"
}

CheckSettingsSet(neutron)
{
    ; Should make proper function that will iterate through all the ini settings and trigger neutron.wnd.ShowModal() if a value equals 0
    IniRead, Xli, ArkAutomated.ini, InventoryLocations, Xli
    IniRead, Yrd, ArkAutomated.ini, InventoryLocations, Yrd
    if (Xli = 0 or Yrd = 0)
    {
        neutron.wnd.ShowModal()
    }
}

AssignMacro(neutron, event, macro)
{
    ; Prevent the submit button from doing what it wants to do by default(submit itself)
    event.preventDefault()
    
    if (macro==1) ; SIMPLEMACRO
    {
        global SMspamkey := neutron.doc.getElementById("SMKey").options[neutron.doc.getElementById("SMKey").selectedIndex].value
        global SMinterval := neutron.doc.getElementById("SMinterval").value
        if (!SMinterval)
            SMinterval:=250
        IniRead, SSHK, ArkAutomated.ini, SSHK, StartStopHK
        HotKey, %SSHK%, sm ; Can't assign to function, only label 
        
        neutron.doc.getElementById("MacroAssignedAlert").style.display := block
        neutron.doc.getElementById("MacroAssignedAlert1").innerHTML := "Assigned SimpleMacro to <strong>"SSHK "</strong> which will press: <strong>" SMspamkey "</strong> with interval: <strong>" SMinterval "</strong>"
        
        ActiveMacro = SimpleMacro
        MacroStat = Inactive
        UpdateMacroStat(ActiveMacro,MacroStat)
        
    }
    else if (macro==2) ; BABYFEEDER SINGLE
    {
        IniRead, SSHK, ArkAutomated.ini, SSHK, StartStopHK
        HotKey, %SSHK%, bfs
        
        neutron.doc.getElementById("MacroAssignedAlert").style.display := block
        neutron.doc.getElementById("MacroAssignedAlert1").innerHTML := "Assigned BabyFeederSingle to <strong>"SSHK "</strong>"
        
        ActiveMacro = BabyFeederSingle
        MacroStat = Inactive
        UpdateMacroStat(ActiveMacro,MacroStat)
    }
    
    else if (macro==3) ; BABYFEEDERMASS
    {
        global BFMfreeze := neutron.doc.getElementById("BFMfreeze").value
        global BFMinterval := neutron.doc.getElementById("BFMinterval").value
        global BFMinterval1 := BFMfreeze+BFMinterval
        
        IniRead, SSHK, ArkAutomated.ini, SSHK, StartStopHK
        HotKey, %SSHK%, bfm
        
        neutron.doc.getElementById("MacroAssignedAlert").style.display := block
        neutron.doc.getElementById("MacroAssignedAlert1").innerHTML := "Assigned BabyFeederMass to <strong>"SSHK "</strong> which will heal for:<strong>" BFMfreeze "</strong>miliseconds and wait <strong>" BFMinterval "</strong> miliseconds between heals"
        
        ActiveMacro = BabyFeederMass
        MacroStat = Inactive
        UpdateMacroStat(ActiveMacro,MacroStat)
    }
    
    else if (macro==4) ; EMPTY CROPPLOTS
    {
        IniRead, SSHK, ArkAutomated.ini, SSHK, StartStopHK
        HotKey, %SSHK%, ecp
        
        neutron.doc.getElementById("MacroAssignedAlert").style.display := block
        neutron.doc.getElementById("MacroAssignedAlert1").innerHTML := "Assigned EmptyCropPlots to <strong>"SSHK "</strong>"
        
        ActiveMacro = EmptyCropPlots
        MacroStat = Inactive
        UpdateMacroStat(ActiveMacro,MacroStat)
    }
    
    else if (macro==5) ; EMPTY DROP
    {
        IniRead, SSHK, ArkAutomated.ini, SSHK, StartStopHK
        HotKey, %SSHK%, ecp
        
        neutron.doc.getElementById("MacroAssignedAlert").style.display := block
        neutron.doc.getElementById("MacroAssignedAlert1").innerHTML := "Assigned EmptyDrop to <strong>"SSHK "</strong>"
        
        ActiveMacro = EmptyDrop
        MacroStat = Inactive
        UpdateMacroStat(ActiveMacro,MacroStat)
    }
    else if (macro==6) ; OPEN BUNNY EGGS
    {
        MsgBox, "Will become active once eggs can be opened in ARK again."
    }
    
    else if (macro==7) ; FASTDROP DEDICATED STORAGE
    {
        IniRead, SSHK, ArkAutomated.ini, SSHK, StartStopHK
        HotKey, %SSHK%, fdds
        
        neutron.doc.getElementById("MacroAssignedAlert").style.display := block
        neutron.doc.getElementById("MacroAssignedAlert1").innerHTML := "Assigned FastDropDedicatedStorage to <strong>"SSHK "</strong>"
        
        ActiveMacro = FastDropDedicatedStorage
        MacroStat = Inactive
        UpdateMacroStat(ActiveMacro,MacroStat)
    }
    
    else if (macro==8) ; SPAM INVENTORY
    {
        global SIspamkey := neutron.doc.getElementById("SIkey").options[neutron.doc.getElementById("SIkey").selectedIndex].value
        
        IniRead, SSHK, ArkAutomated.ini, SSHK, StartStopHK
        HotKey, %SSHK%, si
        
        neutron.doc.getElementById("MacroAssignedAlert").style.display := block
        neutron.doc.getElementById("MacroAssignedAlert1").innerHTML := "Assigned SpamInventory to <strong>"SSHK "</strong> which will spam the <strong>" SIspamkey "</strong> key across the first row of your inventory"
        
        
        ActiveMacro = SpamInventory
        MacroStat = Inactive
        UpdateMacroStat(ActiveMacro,MacroStat)
    }
    
    else if (macro==9) ; BLOOD PACK FARMER
    {
        MsgBox, "NOT IMPLMEMENTED YET"
    }
    else if (macro==10) ; BABY NAMING AND CLOSING MENU
    {
        MsgBox, "NOT IMPLMEMENTED YET"
    }
    
    else if (macro==11) ; DUST2ELEMENTCRAFTER
    {
        IniRead, SSHK, ArkAutomated.ini, SSHK, StartStopHK
        HotKey, %SSHK%, d2ec
        
        neutron.doc.getElementById("MacroAssignedAlert").style.display := block
        neutron.doc.getElementById("MacroAssignedAlert1").innerHTML := "Assigned Dust2ElementCrafter to <strong>"SSHK "</strong>"
        
        ActiveMacro = Dust2ElementCrafter
        MacroStat = Inactive
        UpdateMacroStat(ActiveMacro,MacroStat)
    }
    
    else if (macro==12) ; FARMASSISTANT
    {
        IniRead, SSHK, ArkAutomated.ini, SSHK, StartStopHK
        HotKey, %SSHK%, fa
        
        global FAdropstuff := neutron.doc.getElementById("FAdropfilter").value
        
        
        neutron.doc.getElementById("MacroAssignedAlert").style.display := block
        neutron.doc.getElementById("MacroAssignedAlert1").innerHTML := "Assigned FarmAssistant to <strong>"SSHK "</strong>. Dropping: " FAdropstuff
        
        ActiveMacro = FarmAssistant
        MacroStat = Inactive
        UpdateMacroStat(ActiveMacro,MacroStat)
    }
    
    else
    {
        MsgBox, "?¿?¿?"
    }
    
    
    
}

; SimpleMacro
sm:
    
    toggle:=!toggle
    if toggle{
        SetTimer, sm2, %SMinterval%
        ActiveMacro = SimpleMacro
        MacroStat = Active
        UpdateMacroStat(ActiveMacro,MacroStat)
    }
    else{
        SetTimer, sm2, off
        MacroStat = Inactive
        UpdateMacroStat(ActiveMacro,MacroStat)
    }
return

sm2:
    
    send, %SMspamkey%
return

; BABYFEEDER SINGLE
bfs:
    toggle:=!toggle
    if toggle{
        SetTimer, bfs1, 1000
        ActiveMacro = BabyFeederSingle
        MacroStat = Active
        UpdateMacroStat(ActiveMacro,MacroStat)
    }
    else
    {
        SetTimer, bfs1, off
        MacroStat = Inactive
        UpdateMacroStat(ActiveMacro,MacroStat)
    }
return

bfs1:
    MouseMove, Xli,Yli
    send, t
return

; BABYFEEDER MASS
bfm:
    toggle:=!toggle
    if toggle
    {
        SetTimer, bfm1, %BFMinterval1%
        Global MacroStat
        Global ActiveMacro
        MacroStat = Active
        UpdateMacroStat(ActiveMacro,MacroStat)
    }
    else
    {
        SetTimer, bfm1, off
        Global MacroStat
        MacroStat = Inactive
        SendInput, {RButton Up}
        Global ActiveMacro
        UpdateMacroStat(ActiveMacro,MacroStat)
    }
return

bfm1:
    SendInput, {RButton Down}
    sleep %BFMfreeze%
    SendInput, {RButton Up}
return

; EMPTY CROPPLOTS
ecp:
    MouseMove, Xwa, Ywa
    sleep, 250
    Click
    sleep, 250
    MouseMove, Xda, Yda
    sleep, 250
    Click
    sleep, 250
    send {Esc}
return

; EMPTY DROP
ed:
    MouseMove, Xwa, Ywa
    Click, 5
    sleep, 100
    Click, 5
return

; FASTDROPDEDICATEDSTORAGE
fdds:
    toggle:=!toggle
    if toggle
    {
        SetTimer, fdds1, 200
        ActiveMacro = FastDropDedicatedStorage
        MacroStat = Active
        UpdateMacroStat(ActiveMacro,MacroStat)
    }
    else
    {
        SetTimer, fdds1, off
        ActiveMacro = FastDropDedicatedStorage
        MacroStat = Active
        UpdateMacroStat(ActiveMacro,MacroStat)
    }
return

fdds1:
    MouseMove, Xwa,Ywa
    sleep 50
    Click
    loop, 2
    {
        MouseMove, Xli, Yli
        loop, 5 
        {
            send, o
            MouseMove, 120, 0 , 0, R
        }
    }
return

; Spam Inventory
si:
    toggle:=!toggle
    if toggle
    {
        SetTimer, si1, 50
        ActiveMacro = SpamInventory
        MacroStat = Active
        UpdateMacroStat(ActiveMacro,MacroStat)
    }
    else
    {
        SetTimer, si1, off
        
        MacroStat = Inactive
        ActiveMacro = SpamInventory
        UpdateMacroStat(ActiveMacro,MacroStat)
    }
return

si1:
    MouseMove, Xli, Yli
    loop, 5 
    {
        SendInput, {%SIspamkey% Down}
        sleep 15
        MouseMove, 120, 0 , 0, R
        sleep 10
    }
    SendInput, {%SIspamkey% Up}
return

; Dust2Elementcrafter
d2ec:
    toggle:=!toggle
    if toggle
    {
        SetTimer, d2ec1, 2500
        ActiveMacro = Dust2ElementCrafter
        MacroStat = Active
        UpdateMacroStat(ActiveMacro,MacroStat)
    }
    else
    {
        SetTimer, d2ec1, off
        ActiveMacro = Dust2ElementCrafter
        MacroStat = Inactive
        UpdateMacroStat(ActiveMacro,MacroStat)
    }
return

d2ec1:
    MouseMove, Xwa, Ywa
    sleep, 250
    Click
    sleep, 250
    send {1 25}
return

; FARM ASSISTANT
fa:
    toggle:=!toggle
    if toggle
    {
        SetTimer, fa1, 500
        ActiveMacro = FarmAssistant
        MacroStat = Active
        UpdateMacroStat(ActiveMacro,MacroStat)
    }
    else
    {
        SetTimer, fa1, off
        ActiveMacro = FarmAssistant
        MacroStat = Inactive
        UpdateMacroStat(ActiveMacro,MacroStat)
    }
return

fa1:
    PixelSearch Px, Py, Xrf, Yrf, Xrf, Yrf, color, 3, Fast
    if ( Px && Py )
    {
        splittexthere := StrSplit(FAdropstuff, ",") ; Put the text from FAdropstuff into an array, split by , 
        send {ins}
        sleep 50
        send DROPPING JUNK {enter}
        sleep 50
        send, f

        
        Loop % splittexthere.MaxIndex() ; Loop for as many items there are in the splittexthere array
        {
            droppeditem := splittexthere[A_Index] ; https://www.autohotkey.com/docs/Variables.htm#Index
            sleep 50
            MouseMove, Xrs, Yrs ; REMOTE SEARCH
            sleep 50
            Click
            sleep 50
            send, ^a ; Ctrl+A to select all text
            sleep 50
            send, %droppeditem%
            sleep 100
            MouseMove, Xrd, Yrd ; Remote drop all
            sleep 100
            Click
        }
        send, f
    }
    Else
    {
        Click
        sleep 100
        
    }
return

SetMacroKey(neutron, event)
{
    static ChosenHotkey
    Gui, Add, Text,, "Enter macro hotkey"
    Gui, Add, Hotkey, vChosenHotkey
    Gui, Add, Button, default, OK
    Gui, Show,, 
return

ButtonOK:
    Gui, Submit
    If (ChosenHotkey) 
    {
        UpdateElement("ahk_MacroKey",ChosenHotkey)
        IniWrite, %ChosenHotkey%, ArkAutomated.ini, SSHK, StartStopHK
        Gui, Destroy
        return
    }
    else
    {
        Gui, Destroy
        msgbox, Didnt update because you didn't enter a hotkey
        return
    }
}

UpdateElement(ElementID, NewElement)
{
    global neutron
    
    Z := NewElement ""
    neutron.doc.getElementById(ElementID).innerText := Z
}

ShowMacroStatusArk(neutron, event)
{    
    SetTimer, ShowMacroStatus2, 100
}

ShowMacroStatusArkOff(neutron, event)
{
    SetTimer, ShowMacroStatus2, off
    Closestatus()
}

ShowMacroStatus1()
{
    SetTimer, ShowMacroStatus2, 100
    GuiControlGet, ShowMacroStatus
}

ShowMacroStatus2:
    Global ActiveMacro
    Global MacroStat
    ShowMacroStatusFunction(ActiveMacro, MacroStat)
return

Macrostatus(Text="",Status="",xPos="",yPos="")
{
    If Text = 
        Text = NoMacroSelected
    If Status = 
        Status = Inactive
    Gui, 99:Font, S20 Cwhite, 
    global MS
    Gui, 99:Add, Text, vMS x10 y10 BackgroundTrans, Macro %Text% is %Status%
    Gui, 99:Color, EEAA99
    Gui, 99:+LastFound -Caption +AlwaysOnTop +ToolWindow
    WinSet, TransColor, EEAA99
    Gui, 99:Show, x%xPos% y%yPos% AutoSize NoActivate, MacroStatusBar
}

ShowMacroStatusFunction(MacroName:="",Active:="Inactive")
{
    If WinActive("ARK: Survival Evolved")
    {
        If !WinExist("MacroStatusBar")
        {
            WinGetPos, Xark, Yark, Wark, Hark,ARK: Survival Evolved,,,
            yMacroPos := (Yark + Hark - 60)
            Macrostatus(MacroName,Active,Xark,yMacroPos) 
        }
        else return
        }
    else
        Closestatus()
return
}

UpdateMacroStat(MacroName:="",MacroStatus:="")
{
    GuiControl, 99:, MS, Macro %MacroName% is %MacroStatus%
return
}

Closestatus()
{
    Gui, 99:Destroy
}

Generateini()
{
    FileAppend,, ArkAutomated.ini
    IniWrite, ^F10, ArkAutomated.ini, SSHK, StartStopHK
    IniWrite, 0, ArkAutomated.ini, InventoryLocations, Xli
    IniWrite, 0, ArkAutomated.ini, InventoryLocations, Yli
    IniWrite, 0, ArkAutomated.ini, InventoryLocations, Xri
    IniWrite, 0, ArkAutomated.ini, InventoryLocations, Yri
    IniWrite, 0, ArkAutomated.ini, InventoryLocations, Xwa
    IniWrite, 0, ArkAutomated.ini, InventoryLocations, Ywa
    IniWrite, 0, ArkAutomated.ini, InventoryLocations, Xda
    IniWrite, 0, ArkAutomated.ini, InventoryLocations, Yda
    IniWrite, 0, ArkAutomated.ini, InventoryLocations, Xls
    IniWrite, 0, ArkAutomated.ini, InventoryLocations, Yls
    IniWrite, 0, ArkAutomated.ini, InventoryLocations, Xrs
    IniWrite, 0, ArkAutomated.ini, InventoryLocations, Yrs
    IniWrite, 0, ArkAutomated.ini, InventoryLocations, Xlf
    IniWrite, 0, ArkAutomated.ini, InventoryLocations, Ylf
    IniWrite, 0, ArkAutomated.ini, InventoryLocations, Xrf
    IniWrite, 0, ArkAutomated.ini, InventoryLocations, Yrf
    IniWrite, 0, ArkAutomated.ini, InventoryLocations, Xld
    IniWrite, 0, ArkAutomated.ini, InventoryLocations, Yld
    IniWrite, 0, ArkAutomated.ini, InventoryLocations, Xrd
    IniWrite, 0, ArkAutomated.ini, InventoryLocations, Yrd
    IniWrite, 0, ArkAutomated.ini, FoodWaterInterval, FWiValue
}

LoadIni()
{
    global
    IniRead, SSHK, ArkAutomated.ini, SSHK, StartStopHK	
    IniRead, Xli, ArkAutomated.ini, InventoryLocations, Xli
    IniRead, Yli, ArkAutomated.ini, InventoryLocations, Yli
    IniRead, Xri, ArkAutomated.ini, InventoryLocations, Xri
    IniRead, Yri, ArkAutomated.ini, InventoryLocations, Yri
    IniRead, Xwa, ArkAutomated.ini, InventoryLocations, Xwa
    IniRead, Ywa, ArkAutomated.ini, InventoryLocations, Ywa
    IniRead, Xda, ArkAutomated.ini, InventoryLocations, Xda
    IniRead, Yda, ArkAutomated.ini, InventoryLocations, Yda
    IniRead, Xls, ArkAutomated.ini, InventoryLocations, Xls
    IniRead, Yls, ArkAutomated.ini, InventoryLocations, Yls
    IniRead, Xrs, ArkAutomated.ini, InventoryLocations, Xrs
    IniRead, Yrs, ArkAutomated.ini, InventoryLocations, Yrs
    IniRead, Xlf, ArkAutomated.ini, InventoryLocations, Xlf
    IniRead, Ylf, ArkAutomated.ini, InventoryLocations, Ylf
    IniRead, Xrf, ArkAutomated.ini, InventoryLocations, Xrf
    IniRead, Yrf, ArkAutomated.ini, InventoryLocations, Yrf
    IniRead, Xld, ArkAutomated.ini, InventoryLocations, Xld
    IniRead, Yld, ArkAutomated.ini, InventoryLocations, Yld
    IniRead, Xrd, ArkAutomated.ini, InventoryLocations, Xrd
    IniRead, Yrd, ArkAutomated.ini, InventoryLocations, Yrd
    IniRead, FWiValue, ArkAutomated.ini, FoodWaterInterval, FWiValue
    SetValues()
}

SetValues()
{
    ; update GUI to match ini values
    global
    neutron.doc.getElementById("ahk_MacroKey").innerText := SSHK
    neutron.doc.getElementById("ahk_Xli").value := Xli
    neutron.doc.getElementById("ahk_Yli").value := Yli
    neutron.doc.getElementById("ahk_Xri").value := Xri
    neutron.doc.getElementById("ahk_Yri").value := Yri
    neutron.doc.getElementById("ahk_Xwa").value := Xwa
    neutron.doc.getElementById("ahk_Ywa").value := Ywa
    neutron.doc.getElementById("ahk_Xda").value := Xda
    neutron.doc.getElementById("ahk_Yda").value := Yda
    neutron.doc.getElementById("ahk_Xls").value := Xls
    neutron.doc.getElementById("ahk_Yls").value := Yls
    neutron.doc.getElementById("ahk_Xrs").value := Xrs
    neutron.doc.getElementById("ahk_Yrs").value := Yrs
    neutron.doc.getElementById("ahk_Xlf").value := Xlf
    neutron.doc.getElementById("ahk_Ylf").value := Ylf
    neutron.doc.getElementById("ahk_Xrf").value := Xrf
    neutron.doc.getElementById("ahk_Yrf").value := Yrf
    neutron.doc.getElementById("ahk_Xld").value := Xld
    neutron.doc.getElementById("ahk_Yld").value := Yld
    neutron.doc.getElementById("ahk_Xrd").value := Xrd
    neutron.doc.getElementById("ahk_Yrd").value := Yrd
    neutron.doc.getElementById("FWiValue").value := FWiValue
    
}

GetGuiValues()
{
    ; Get the values as they currently are in the GUI
    global
    SSHK := neutron.doc.getElementById("ahk_MacroKey").innerText
    Xli := neutron.doc.getElementById("ahk_Xli").value
    Yli := neutron.doc.getElementById("ahk_Yli").value
    Xri := neutron.doc.getElementById("ahk_Xri").value 
    Yri := neutron.doc.getElementById("ahk_Yri").value 
    Xwa := neutron.doc.getElementById("ahk_Xwa").value 
    Ywa := neutron.doc.getElementById("ahk_Ywa").value 
    Xda := neutron.doc.getElementById("ahk_Xda").value 
    Yda := neutron.doc.getElementById("ahk_Yda").value 
    Xls := neutron.doc.getElementById("ahk_Xls").value 
    Yls := neutron.doc.getElementById("ahk_Yls").value 
    Xrs := neutron.doc.getElementById("ahk_Xrs").value
    Yrs := neutron.doc.getElementById("ahk_Yrs").value 
    Xlf := neutron.doc.getElementById("ahk_Xlf").value 
    Ylf := neutron.doc.getElementById("ahk_Ylf").value
    Xrf := neutron.doc.getElementById("ahk_Xrf").value
    Yrf := neutron.doc.getElementById("ahk_Yrf").value
    Xld := neutron.doc.getElementById("ahk_Xld").value 
    Yld := neutron.doc.getElementById("ahk_Yld").value
    Xrd := neutron.doc.getElementById("ahk_Xrd").value
    Yrd := neutron.doc.getElementById("ahk_Yrd").value
    FWiValue := neutron.doc.getElementById("FWiValue").value
    
}

SaveSettings(neutron,event)
{
    global
    GetGuiValues()
    event.preventDefault()    
    
    IniWrite, %SSHK%, ArkAutomated.ini, SSHK, StartStopHK
    IniWrite, %Xli%, ArkAutomated.ini, InventoryLocations, Xli
    IniWrite, %Yli%, ArkAutomated.ini, InventoryLocations, Yli
    IniWrite, %Xri%, ArkAutomated.ini, InventoryLocations, Xri
    IniWrite, %Yri%, ArkAutomated.ini, InventoryLocations, Yri
    IniWrite, %Xwa%, ArkAutomated.ini, InventoryLocations, Xwa
    IniWrite, %Ywa%, ArkAutomated.ini, InventoryLocations, Ywa
    IniWrite, %Xda%, ArkAutomated.ini, InventoryLocations, Xda
    IniWrite, %Yda%, ArkAutomated.ini, InventoryLocations, Yda
    IniWrite, %Xls%, ArkAutomated.ini, InventoryLocations, Xls
    IniWrite, %Yls%, ArkAutomated.ini, InventoryLocations, Yls
    IniWrite, %Xrs%, ArkAutomated.ini, InventoryLocations, Xrs
    IniWrite, %Yrs%, ArkAutomated.ini, InventoryLocations, Yrs
    IniWrite, %Xlf%, ArkAutomated.ini, InventoryLocations, Xlf
    IniWrite, %Ylf%, ArkAutomated.ini, InventoryLocations, Ylf
    IniWrite, %Xrf%, ArkAutomated.ini, InventoryLocations, Xrf
    IniWrite, %Yrf%, ArkAutomated.ini, InventoryLocations, Yrf
    IniWrite, %Xld%, ArkAutomated.ini, InventoryLocations, Xld
    IniWrite, %Yld%, ArkAutomated.ini, InventoryLocations, Yld
    IniWrite, %Xrd%, ArkAutomated.ini, InventoryLocations, Xrd
    IniWrite, %Yrd%, ArkAutomated.ini, InventoryLocations, Yrd
    IniWrite, %FWiValue%, ArkAutomated.ini, FoodWaterInterval, FWiValue
}

SMP(neutron)
{
    gosub ShowMousePos
}
ShowMousePos:
    toggle:=!toggle
    if toggle
        SetTimer, WatchCursor, 100
    else
        SetTimer, WatchCursor, off
    ToolTip
return

WatchCursor:
    MouseGetPos, xpos, ypos, id,
    WinGetTitle, title, ahk_id %id%
    if WinActive("ARK: Survival Evolved") or WinActive
        ToolTip,%title%`n The cursor is at X%xpos% and Y%Ypos% 
    else
        ToolTip, NOT CURRENTLY IN Ark:Survival Evolved WINDOW!
return

OpenImg(neutron, ImageNumber)
{
    run https://raw.githubusercontent.com/ark-automated/Ark-Automated/master/V0.3_settings_instructions.png
}

OpenGithub(neutron)
{
    run https://github.com/ark-automated/Ark-Automated
}

JoinDiscord(neutron, discordoption)
{
    if (discordoption==1)
    {        
        run discord:///invite/7ETcY2N
    }
    else if (discordoption==2)
    {
        run discord:///invite/9sszHzr
    }
    else if (discordoption==3) ; Show Olivier#6863 profile in discord
    {
        run discord:///users/207553438173626368/
    }
}

F2::reload

/*
Mouse locations:
1. Xli / Yli
2. Xri / Yri
3. Xwa / Ywa
4. Xda / Yda
5. Xls / Yls
6. Xrs / Yrs
7. Xlf / Ylf
8. Xrf / Yrf
9. Xld / Yld
10. Xrd / Yrd
*/