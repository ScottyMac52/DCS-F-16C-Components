#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

; ============================================================
; DCS / VAICOM Push-To-Talk Bridge
;
; Physical device/buttons:
;   5Joy1 -> TX1
;   5Joy2 -> TX2
;   5Joy3 -> TX3
;   5Joy4 -> TX4
;   5Joy5 -> TX5
;
; VoiceAttack / VAICOM bindings:
;   TX1 = Left Ctrl + Left Alt + Left Shift + 1
;   TX2 = Left Ctrl + Left Alt + Left Shift + 2
;   TX3 = Left Ctrl + Left Alt + Left Shift + 3
;   TX4 = Left Ctrl + Left Alt + Left Shift + 4
;   TX5 = Left Ctrl + Left Alt + Left Shift + 5
; ============================================================

; TX1 - VHF AM
5Joy1::
{
    SendEvent "{LCtrl down}{LAlt down}{LShift down}{vk31 down}"
    KeyWait "5Joy1"
    SendEvent "{vk31 up}{LShift up}{LAlt up}{LCtrl up}"
}

; TX2 - UHF
5Joy2::
{
    SendEvent "{LCtrl down}{LAlt down}{LShift down}{vk32 down}"
    KeyWait "5Joy2"
    SendEvent "{vk32 up}{LShift up}{LAlt up}{LCtrl up}"
}

; TX3 - VHF FM
5Joy3::
{
    SendEvent "{LCtrl down}{LAlt down}{LShift down}{vk33 down}"
    KeyWait "5Joy3"
    SendEvent "{vk33 up}{LShift up}{LAlt up}{LCtrl up}"
}

; TX4 - AUTO
5Joy4::
{
    SendEvent "{LCtrl down}{LAlt down}{LShift down}{vk34 down}"
    KeyWait "5Joy4"
    SendEvent "{vk34 up}{LShift up}{LAlt up}{LCtrl up}"
}

; TX5 - Interphone
5Joy5::
{
    SendEvent "{LCtrl down}{LAlt down}{LShift down}{vk35 down}"
    KeyWait "5Joy5"
    SendEvent "{vk35 up}{LShift up}{LAlt up}{LCtrl up}"
}

OnExit(ReleaseAll)

ReleaseAll(*)
{
    SendEvent "{vk31 up}{vk32 up}{vk33 up}{vk34 up}{vk35 up}"
    SendEvent "{LShift up}{LAlt up}{LCtrl up}"
}
