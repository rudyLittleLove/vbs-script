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

// ———————————————— loading  —————————————————————————
Function loading()
	Do
    	If FindImage("大地图.bmp", 561, 45, 599, 51, 1) Then 
    		Exit Function
			Exit Do 	
    	End If
		Delay 1000    
    Loop
End Function

// ————————————————— 存档  —————————————————————————
Press "R", 1, 137
PressHold "D", 200
Press "K", 1, 8000
Press "W", 1, 1500
PressHold "A", 352
PressHold "S", 417
PressHold "A", 296
Press "E", 1, 50
Press "K", 1, 200
PressHold "A", 400
Delay 600
PressHold "W", 362
PressHold "D", 200
Press "K", 14, 500
Press "J", 3, 500
PressHold "A", 50
PressHold "S", 565
Delay 500
Press "S", 1, 150
PressHold "D", 350
PressHold "W", 100
Press "E", 1, 50
Press "K", 1, 100

// ————————————————— 第三镇存档  —————————————————————————
Press "R", 1, 137
Press "D", 2, 100
Press "K", 1, 1000

loading

// 2. 进入城镇
Press "W", 1, 1500
PressHold "D", 100
PressHold "S", 1000
PressHold "D", 1150
PressHold "S", 700
PressHold "D", 1063
PressHold "W", 395
Delay 969
PressHold "W", 220
PressHold "D", 2700
PressHold "W", 700
Press "K", 14, 500
Press "J", 5, 100
	
//———————————————— 存战车物品  —————————————————————————
Press "R", 1, 137
Press "K", 1, 8000
// 2. 进入城镇

Press "W", 1, 1500
PressHold "W", 812
PressHold "D", 233
Press "W", 1, 100
Delay 500
PressHold "W", 2500
PressHold "A", 944
Press "K", 1, 100
Delay 800
Press "S", 1, 119
Press "K", 2, 200
Press "S", 2, 118
Press "K", 1, 116
Press "N", 1, 448
Press "K", 2, 200
Press "J", 2, 200
Press "J", 1, 600
Press "J", 3, 200

//———————————————— 四倍速 走格子耗时  —————————————————————————
PressHold "S", 30  // 一格
PressHold "S", 75  // 二格
PressHold "S", 130  // 三格
PressHold "S", 175  // 四格
PressHold "S", 225  // 五格