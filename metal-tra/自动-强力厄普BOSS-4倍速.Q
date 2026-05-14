// ==================== 常量配置 ====================
Const IMAGE_PATH = "D:\workspace\vbs-script\images\"
Const DELAY_SHORT = 10
Const DELAY_NORMAL = 20

// 寻路卡死检测阈值（约300ms未找到地标则重置）
Const STUCK_THRESHOLD = 30


// 重新加载
Dim reload, currDown
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

// 用法: PressHold "K", 100  -> 按住K 100ms
Function PressHold(key, holdMs)
    If holdMs < 0 Then holdMs = 0
    KeyDown key, 1
    If holdMs > 0 Then Delay holdMs
    KeyUp key, 1
    Delay 50
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

Function GetMoveDelay(num)
	If num > 4 Then 
		GetMoveDelay = 225
		Exit Function
	End If
	If num > 3 Then 
		GetMoveDelay = 175
		Exit Function
	End If
	If num > 2 Then 
		GetMoveDelay = 130
		Exit Function
	End If
	If num > 1 Then 
		GetMoveDelay = 75
		Exit Function
	End If
	If num > 0 Then 
		GetMoveDelay = 30
		Exit Function
	End If
End Function

Function ExecuteMoveStep(dir,num)
	PressHold dir, GetMoveDelay(num)
End Function

Function FindImgWithDelay(imgName, x1, y1, x2, y2, similarity, dir, xy)
	Dim intX, intY, startTime, endTime, elapsedTime, delayTime
	delayTime = 0
	startTime = Plugin.GetSysInfo.GetTime 
    FindPic x1, y1, x2, y2, IMAGE_PATH & imgName, similarity, intX, intY
    
    If intX < 0 Then 
    	FindImgWithDelay = False
    	Exit Function
    End If
    
	Select Case dir
        Case "D"
            delayTime = GetMoveDelay((intX - xy) / 49)
        Case "A"
            delayTime = GetMoveDelay((xy - intX) / 49)
        Case "W"
            delayTime = GetMoveDelay((xy - intY) / 49)
        Case "S"
            delayTime = GetMoveDelay((intY - xy) / 49)
    End Select
    
	endTime = Plugin.GetSysInfo.GetTime
    
    elapsedTime = endTime - startTime
    If delayTime > elapsedTime Then Delay delayTime - elapsedTime
    FindImgWithDelay = True
End Function


Function ReleaseAllKeys()
	reload = 0
	KeyUp "A", 1
	KeyUp "S", 1
	KeyUp "D", 1
	KeyUp "W", 1
End Function

// 检测是否处于战斗中（通过"攻击"按钮判断）
Function IsInBattle()
	IsInBattle = FindImage("攻击.bmp", 212, 508, 327, 552, 1)
End Function

// 战斗中逃跑
Function EscapeBattle()
	Press "J", 1, 100
	Press "A", 1, 100
	Press "K", 1, 100
	Press "A", 1, 100
	Press "K", 1, 100
End Function

// 蝎子BOSS战斗流程
Function FightBoss()
	Press "J", 1, 100
	// 一号攻击
	Press "D", 2, 100
	Press "K", 1, 100
	Press "S", 1, 100
	Press "K", 1, 100
	Press "D", 1, 100
	Press "K", 2, 100
	// 二号攻击
	Press "K", 2, 100
End Function

Function HandleBattle()
    Press "J", 1, 0
    
    // 判断是否进入战斗
    If Not IsInBattle() Then
        // 未战斗，累加卡死计数器
        reload = reload + 1
        If reload > STUCK_THRESHOLD Then 
            reload = 0
            // 寻路卡死，重置流程
            StartNewRun
        End If
        Exit Function
    End If
    
    // 进入战斗，重置卡死计数器
    reload = 0
    
    // 判断是否是蝎子BOSS
    If FindImage("蝎子.bmp", 178, 114, 788, 531, 1) Then 
        FightBoss
    Else		
        EscapeBattle
    End If
End Function

// 地图导航配置：地标图 -> 检测区域 -> 到达后执行的动作
// 使用数组风格，但Q语言不支持数组，直接用顺序判断
Function NavigateToBoss()
	// 当前循环内地标命中标记（通用方向不需要标记）
	Dim hitBossDl, hitBossUl, hitBossF1Cn, hitBossF1Sym, hitBossF3, hitBossDL2
	hitBossDl = False
	hitBossUl = False
	hitBossF1Cn = False
	hitBossF1Sym = False
	hitBossF3 = False
	hitBossDL2 = False
	
	Do
        Dim foundLandmark
        foundLandmark = False
        
        // 存档位开始（下+左）
		If Not hitBossDl And FindImage("3_boss_d_l.bmp", 633, 325, 649, 339, 1) Then 
			ReleaseAllKeys 
			Delay 500
			PressHold "S", 25
			KeyDown "A", 1
			hitBossDl = True
            foundLandmark = True
    	End If
    	
        // 上左拐角（上+左）
    	If Not hitBossUl And Not foundLandmark And FindImage("3_boss_u_l.bmp", 604, 364, 624, 394, 1) Then 
			ReleaseAllKeys
			Delay 500
			PressHold "W", 25
			PressHold "A", 50
			hitBossUl = True
            foundLandmark = True
    	End If
        
        // 负1楼（中文）
    	If Not hitBossF1Cn And Not foundLandmark And FindImage("3_boss_负1楼.bmp", 1012, 334, 1049, 354, 1) Then 
			ReleaseAllKeys 
			Delay 500
			PressHold "D", 35
			PressHold "W", 130
			PressHold "D", 280
			PressHold "S", 30
			PressHold "A", 50
			hitBossF1Cn = True
            foundLandmark = True
    	End If
        
        // -1楼（符号）
    	If Not hitBossF1Sym And Not foundLandmark And FindImage("3_boss_-1楼.bmp", 645, 360, 669, 424, 1) Then 
			ReleaseAllKeys
			PressHold "D", 40
			PressHold "W", 75
			PressHold "A", 190
			hitBossF1Sym = True
            foundLandmark = True
    	End If
        
        // 负3楼
    	If Not hitBossF3 And Not foundLandmark And FindImage("3_boss_负3楼.bmp", 608, 367, 630, 420, 1) Then 
			ReleaseAllKeys
			PressHold "S", 140
			PressHold "A", 140
			PressHold "S", 140
			PressHold "A", 75
			PressHold "W", 400
			PressHold "A", 50
			PressHold "W", 400
			PressHold "A", 120
			PressHold "W", 60
			PressHold "A", 70
			KeyDown "S", 1
			hitBossF3 = True
            foundLandmark = True
    	End If
    	
    	// 下左拐角（下+左）
    	If Not hitBossDL2 And Not foundLandmark And FindImage("3_boos_d_l.bmp", 650, 369, 673, 391, 1) Then 
			ReleaseAllKeys 
			Delay 100
			PressHold "S", 30
			KeyDown "A", 1
			hitBossDL2 = True
            foundLandmark = True
    	End If
        
        // 往左（通用方向，不标记）
    	If Not foundLandmark  Then 
    	    If FindImage("3_boss_l1.bmp", 617, 407, 664, 431, 1) Or FindImage("3_boss_l2.bmp", 647, 408, 677, 429, 1) Then     	    	
				ReleaseAllKeys
				KeyDown "A", 1
            	foundLandmark = True
    	    End If
    	End If
        
        // 往下（通用方向，不标记）
    	If Not foundLandmark Then 
    		If FindImage("3_boss_d1.bmp", 602, 379, 630, 423, 1) Or FindImage("3_boss_d2.bmp", 649, 356, 671, 391, 1) Or FindImage("3_boss_d3.bmp", 651, 378, 671, 411, 1) Or FindImgWithDelay("3_boss_d4.bmp", 311, 177, 542, 204, 0.95, "A", 511) Then 					
				ReleaseAllKeys
				KeyDown "S", 1
            	foundLandmark = True
    		End If
    	End If
        
        // 往右（带预找图补偿，通用方向，不标记）
    	If Not foundLandmark  Then 
    		If FindImgWithDelay("3_boss_r1.bmp", 803, 223, 866, 441, 0.95, "S", 223) Or FindImage("3_boss_r2.bmp", 613, 401, 633, 427, 1) Or FindImgWithDelay("3_boss_r3.bmp", 264, 468, 298, 700, 0.95, "S", 468) Or FindImage("3_boss_r4.bmp", 609, 410, 631, 430, 1) Then     			
				ReleaseAllKeys
				KeyDown "D", 1
            	foundLandmark = True
    		End If
    	End If

		// 往上（通用方向，不标记）
		If Not foundLandmark And FindImage("3_boss_u1.bmp", 605, 395, 625, 417, 1) Then 
			ReleaseAllKeys
			KeyDown "W", 1
            foundLandmark = True
    	End If
    	
    	// 到达诱敌位置
		If Not foundLandmark And FindImage("3_boss_over.bmp", 621, 419, 665, 435, 1) Then 
			ReleaseAllKeys 
			Press "h", 1, 100
    		Press "K", 2, 100
        	Press "S", 1, 100
        	Press "K", 1, 100
        	Press "W", 1, 100
        	Press "K", 3, 100
        	Press "J", 5, 100
            foundLandmark = True
    	End If
    	
    	// 检测到发现了（战斗结束有掉落），跳出寻路循环进入5星判断
    	If FindImage("发现了.bmp", 216, 584, 322, 625, 1) Then 
    		reload = 0
			Exit Do
    	End If
    	
    	HandleBattle 
	Loop
	
	// 战斗结束有掉落，单次判断5星
	// 检测到5星掉落，停止脚本
	If FindImage("5星.bmp", 530, 552, 673, 637, 0.96) Then 
		KeyPress 175, 20
		KeyDown "Ctrl", 1
		KeyDown "Alt", 1
		KeyDown "3", 1
		Delay 300
		KeyUp "Ctrl", 1
		KeyUp "Alt", 1
		KeyUp "3", 1
		KeyPress "F12", 1 // 退出脚本快捷键
		
	End If
	// 非5星，直接返回，外层循环会调用StartNewRun重置流程
End Function

// 刷新游戏并导航到目标位置
Function StartNewRun()
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
	Press "K", 1, 100
	Delay 1000
	Press "K", 2, 200
	Delay 2000
	Press "K", 2, 200
	Delay 300
	
	//    移动
    NavigateToBoss	
End Function

// ==================== 入口 ====================
Do
    StartNewRun
    Delay 10
Loop