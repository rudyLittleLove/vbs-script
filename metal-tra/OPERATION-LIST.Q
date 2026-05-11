// 点击按键count次，每次延迟delayMs
Function Press(key, count, delayMs)
    Dim i
    If count < 1 Then count = 1
    If delayMs < 0 Then delayMs = 0
    For i = 1 To count
        KeyPress key, 1
        If delayMs > 0 Then Delay delayMs
    Next
End Function

// —————————————————诱敌—————————————————————————
Press "K", 2, 40
Press "S", 1, 40
Press "K", 1, 40
Press "W", 2, 40 // ----------切换上下选怪---------------
Press "K", 2, 350
Press "K", 1, 800

// —————————————————还原倍速—————————————————————————
KeyDown "Ctrl", 1
KeyDown "Alt", 1
KeyDown "3", 1
Delay 300
KeyUp "Ctrl", 1
KeyUp "Alt", 1
KeyUp "3", 1

// —————————————————音量 + -  —————————————————————————
KeyPress 175, 20
Delay 1000
KeyPress 174, 20

// ————————————————— 脚本停止  —————————————————————————
Press "F12",1, 100

// ————————————————— 指定快速诱敌  —————————————————————————
If FindImage("手指_特技.bmp",  309, 584, 490, 664, 0.9) Then
    Press "K", 2, 100
    Press "S", 1, 100
    Press "K", 1, 100
    Press "W", 1, 100 // 上下选择
    Press "K", 3, 100
    Press "J", 5, 100
    Exit Function
End If