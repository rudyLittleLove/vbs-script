// ==================== 常量配置 ====================
Const IMAGE_PATH = "D:\workspace\vbs-script\images\"
Const DELAY_SHORT = 10
Const DELAY_NORMAL = 20

// ==================== 辅助函数 ====================

// 纯找图，不按键，返回是否找到
Function FindImage(imgName, x1, y1, x2, y2, similarity)
    Dim intX, intY
    FindPic x1, y1, x2, y2, IMAGE_PATH & imgName, similarity, intX, intY
    FindImage = (intX > 0)
End Function

// 点击按键count次，每次延迟delayMs（延迟会除以倍速）
Function Press(key, count, delayMs)
    Dim i
    If count < 1 Then count = 1
    If delayMs < 0 Then delayMs = 0
    For i = 1 To count
        KeyPress key, 1
        If delayMs > 0 Then Delay delayMs / SPEED
    Next
End Function

Function run()
	If FindImage("大地图.bmp", 561, 45, 599, 51, 1) And Not FindImage("菜单栏.bmp", 508, 742, 780, 771, 1) Then
    	Press "h", 1, 100
    	Press "K", 2, 100
        Press "S", 1, 100
        Press "K", 1, 100
        Press "W", 1, 100
        Press "K", 3, 100
    	Exit Function
	End If
    KeyPress "K", 1
    
    If FindImage("血条0.bmp",342, 601, 471, 606, 1) Then 
		KeyDown "Ctrl", 1
		KeyDown "Alt", 1
		KeyDown "3", 1
		Delay 300
		KeyUp "Ctrl", 1
		KeyUp "Alt", 1
		KeyUp "3", 1
		KeyPress "F12", 1

        TracePrint "检测到闪光怪，退出脚本！"    
    End If
End Function

// ==================== 入口 ====================
Do
    run
    Delay 10
Loop
