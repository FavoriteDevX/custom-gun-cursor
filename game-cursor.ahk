#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%
SendMode Input

; --- INITIAL CONFIGURATION ---
CrosshairImg := "crosshair.png"
BulletImg := "bullet-hole.png"

; Check if required images exist in the folder
if (!FileExist(CrosshairImg) || !FileExist(BulletImg)) {
    MsgBox, 48, Error, Please make sure 'crosshair.png' and 'bullet-hole.png' are in the same folder!
    ExitApp
}

; Hide the default Windows cursor
SystemCursor("Hide")

; Setup Custom Crosshair Window
Gui, Cursor: +AlwaysOnTop -Caption +Owner +LastFound +E0x20
Gui, Cursor: Margin, 0, 0
Gui, Cursor: Add, Picture, w40 h40, %CrosshairImg%
Gui, Cursor: Color, EEAA99
WinSet, TransColor, EEAA99 
Gui, Cursor: Show, x-100 y-100 NoActivate

; Timer to update crosshair position (every 10ms)
SetTimer, UpdateCursor, 10
return

; --- UPDATE CROSSHAIR POSITION ---
UpdateCursor:
CoordMode, Mouse, Screen
MouseGetPos, MouseX, MouseY
NewX := MouseX - 20
NewY := MouseY - 20
Gui, Cursor: Show, x%NewX% y%NewY% NoActivate
return

; --- MOUSE CLICK (BULLET HOLE EFFECT) ---
~*LButton::
CoordMode, Mouse, Screen
MouseGetPos, ShotX, ShotY

; Generate a unique ID for each bullet hole
Random, ShotID, 1000, 9999
Gui, Bullet%ShotID%: +AlwaysOnTop -Caption +Owner +LastFound +E0x20
Gui, Bullet%ShotID%: Margin, 0, 0
Gui, Bullet%ShotID%: Add, Picture, w30 h30, %BulletImg%
Gui, Bullet%ShotID%: Color, EEAA99
WinSet, TransColor, EEAA99

BX := ShotX - 15
BY := ShotY - 15
Gui, Bullet%ShotID%: Show, x%BX% y%BY% NoActivate

; Dynamically schedule destruction of this specific bullet hole after 3 seconds
BoundFunc := Func("DestroyBullet").Bind(ShotID)
SetTimer, %BoundFunc%, -3000
return

; Function to clean up the screen
DestroyBullet(Id) {
    Gui, Bullet%Id%: Destroy
}

; --- CLOSE SCRIPT AND RESTORE CURSOR (Press ESC) ---
Esc::
SystemCursor("Show")
ExitApp

; --- SYSTEM FUNCTION TO TOGGLE WINDOWS CURSOR ---
SystemCursor(OnOff="Show") {
    Static AndMask, XorMask
    If (OnOff = "Hide") {
        VarSetCapacity(AndMask, 32*4, 0xFF)
        VarSetCapacity(XorMask, 32*4, 0)
        BC := 0
    } Else {
        BC := 1
    }
    Cursors = 32512,32513,32514,32515,32516,32640,32641,32642,32643,32644,32645,32646,32648,32649,32650,32651
    Loop, Parse, Cursors, `,
    {
        If (OnOff = "Hide")
            DllCall("SetSystemCursor", "Uint", DllCall("CreateCursor", "Uint", 0, "Int", 0, "Int", 0, "Int", 32, "Int", 32, "Uint", &AndMask, "Uint", &XorMask), "Uint", A_LoopField)
        Else
            DllCall("SystemParametersInfo", "Uint", 0x57, "Uint", 0, "Uint", 0, "Uint", 0)
    }
}
