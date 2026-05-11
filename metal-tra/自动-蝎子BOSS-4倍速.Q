// ==================== 常量配置 ====================
Const IMAGE_PATH = "D:\workspace\vbs-script\images\"
Const DELAY_SHORT = 10
Const DELAY_NORMAL = 20

// 是否无装甲
Dim reload
reload = 0

// 在指定区域找图，找到则按键并返回 true
Function FindAndPress(imgName, x1, y1, x2, y2, similarity, key, delayMs)
    Dim intX, intY
    FindPic x1, y1, x2, y2, IMAGE_PATH & imgName, similarity, intX, intY
    If intX > 0 Then
        KeyPress key, 1
        Delay delayMs
        FindAndPress = True
    Else
        FindAndPress = False
    End If
End Function

// 纯找图，不按键，返回是否找到
Function FindImage(imgName, x1, y1, x2, y2, similarity)
    Dim intX, intY
    FindPic x1, y1, x2, y2, IMAGE_PATH & imgName, similarity, intX, intY
    FindImage = (intX > 0)
End Function

// 用法: Press "K", 3, 100  -> 按3次K，每次延迟100ms
Function PressHold(key, holdMs)
    If holdMs < 0 Then holdMs = 0
    KeyDown key, 1
    If holdMs > 0 Then Delay holdMs
    KeyUp key, 1
End Function

// 用法: Press "K", 3, 100  -> 按3次K，每次延迟100ms
Function Press(key, count, delayMs)
    Dim i
    If count < 1 Then count = 1
    If delayMs < 0 Then delayMs = 0
    For i = 1 To count
        KeyPress key, 1
        If delayMs > 0 Then Delay delayMs
    Next
End Function

Function AllUp()
	reload = 0
	KeyUp "A", 1
	KeyUp "S", 1
	KeyUp "D", 1
	KeyUp "W", 1
End Function

Function battle()
    Press "J", 1, 0
    reload = reload + 1
    If reload > 30 Then 
    	reload = 0
    	run
    End If
	If FindImage("攻击.bmp", 212, 508, 327, 552, 1) Then 
		reload = 0
		If FindImage("蝎子.bmp", 178, 114, 788, 531, 1) Then 
			Press "J", 1, 100
			Press "D", 3, 100
			Press "K", 3, 100
		Else		
			Press "J", 1, 100
			Press "A", 1, 100
			Press "K", 1, 100
		End If
	End If
End Function


//进蝎子洞j
Function move()
	Do
		If FindImage("蝎子洞.bmp", 724, 351, 752, 366, 1) Then 
			AllUp
			PressHold "W", 20
			KeyDown "D", 1
    	End If
    	If FindImage("第一镇2.bmp", 586, 258, 634, 264, 1) Then 
			AllUp
			KeyDown "D", 1
    	End If
		//	往下移动
		If FindImage("第一镇.bmp", 595, 356, 626, 366, 1) Or FindImage("进蝎洞1.bmp", 727, 554, 748, 563, 1) Or FindImage("第一镇3.bmp", 483, 253, 506, 265, 1) Then 
			AllUp
			KeyDown "S", 1
    	End If
		If FindImage("战车达boss.bmp", 639, 382, 646, 448, 1) Then 
			AllUp 
			Press "E", 1, 100
			Press "K", 1, 100
			KeyDown "D", 1
    	End If
		If FindImage("诱蝎位.bmp", 634, 384, 724, 391, 1) Then 
			AllUp 
			Press "h", 1, 100
    		Press "K", 2, 100
        	Press "S", 1, 100
        	Press "K", 1, 100
        	Press "W", 1, 100
        	Press "K", 3, 100
        	Press "J", 5, 100
    	End If
    	
    	If FindImage("5星.bmp", 520, 630, 641, 660, 0.96) Then 
    		KeyPress 175, 20
			KeyDown "Ctrl", 1
			KeyDown "Alt", 1
			KeyDown "3", 1
			Delay 300
			KeyUp "Ctrl", 1
			KeyUp "Alt", 1
			KeyUp "3", 1
			KeyPress "F12", 1
    	End If
    	
    	If FindImage("黑桃铲.bmp", 347, 588, 461, 622, 1) Then 
    		reload = 0
    		run
			Exit Do
    	End If
    	
    	battle 
	Loop
End Function

Function run()
	Press "J", 3, 200
	//		刷新
	Press "F5", 1, 10
	Press "F5", 1, 400
	Press "J", 3, 200
	Press "S", 1, 100
	Press "K", 1, 100
	Press "S", 1, 100
	Press "K", 6, 50
	Press "N", 1, 100
	Press "S", 1, 100
	Press "K", 5, 200
	Delay 600
	Press "K", 2, 200
	Delay 300
	Press "R", 1, 100
	Press "K", 1, 100
	
	//    移动
    move	
End Function

// ==================== 入口 ====================
Do
    run
    Delay 10
Loop


//
