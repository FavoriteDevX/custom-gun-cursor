#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%
SendMode Input

; --- CONFIGURAÇÃO INICIAL ---
; Define os caminhos das imagens que devem estar na mesma pasta
CrosshairImg := "crosshair.png"
BulletImg := "bullet-hole.png"

; Verifica se as imagens existem para não dar erro
if (!FileExist(CrosshairImg) || !FileExist(BulletImg)) {
    MsgBox, 48, Error, Please make sure 'crosshair.png' and 'bullet-hole.png' are in the same folder!
    ExitApp
}

; Esconde o cursor padrão do Windows enquanto o script estiver rodando
SystemCursor("Hide")

; Cria a janela do Custom Cursor (Mira)
Gui, Cursor: +AlwaysOnTop -Caption +Owner +LastFound +E0x20 ; E0x20 permite clicar através da imagem
Gui, Cursor: Margin, 0, 0
Gui, Cursor: Add, Picture, w40 h40 vCrosshairPic, %CrosshairImg%
Gui, Cursor: Color, EEAA99
WinSet, TransColor, EEAA99 ; Torna o fundo da imagem transparente
Gui, Cursor: Show, x-100 y-100 NoActivate

; Configura um timer para atualizar a posição da mira a cada 10 milissegundos
SetTimer, UpdateCursor, 10
return

; --- ATUALIZAR POSIÇÃO DA MIRA ---
UpdateCursor:
CoordMode, Mouse, Screen
MouseGetPos, MouseX, MouseY
; Centraliza a mira de 40x40 pixels na ponta do mouse
NewX := MouseX - 20
NewY := MouseY - 20
Gui, Cursor: Show, x%NewX% y%NewY% NoActivate
return

; --- CLIQUE DO MOUSE (EFEITO DE TIRO) ---
~*LButton::
CoordMode, Mouse, Screen
MouseGetPos, ShotX, ShotY

; Cria um ID único para cada marca de tiro para permitir vários cliques seguidos
Random, ShotID, 1000, 9999
Gui, Bullet%ShotID%: +AlwaysOnTop -Caption +Owner +LastFound +E0x20
Gui, Bullet%ShotID%: Margin, 0, 0
Gui, Bullet%ShotID%: Add, Picture, w30 h30, %BulletImg%
Gui, Bullet%ShotID%: Color, EEAA99
WinSet, TransColor, EEAA99

; Posiciona a marca do tiro (30x30 pixels) centralizada no clique
BX := ShotX - 15
BY := ShotY - 15
Gui, Bullet%ShotID%: Show, x%BX% y%BY% NoActivate

; Agenda a destruição da marca de tiro após 3 segundos
SetTimer, DestroyBullet%ShotID%, -3000
return

; Label dinâmico para limpar a marca de tiro da tela
DestroyBullet1000:
DestroyBullet1001:
; (O AutoHotkey gerencia a remoção via timer negativo)
SetTimer, % A_ThisLabel, Off
StringReplace, ThisGuiID, A_ThisLabel, DestroyBullet
Gui, Bullet%ThisGuiID%: Destroy
return

; --- FECHAR O SCRIPT (Aperte ESC para sair) ---
Esc::
SystemCursor("Show") ; Devolve o cursor normal do Windows
ExitApp

; --- FUNÇÃO PARA ESCONDER/MOSTRAR CURSOR DO SISTEMA ---
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
