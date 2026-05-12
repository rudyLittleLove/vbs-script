
// ==================== 常量配置 ====================
Const IMAGE_PATH = "D:\workspace\vbs-script\images\"
Const DELAY_NORMAL = 200

// ==================== 全局状态变量 ====================
// 是否无炮弹
Dim hasNotPd
hasNotPd = False

// 是否掉落45 炮
Dim has45
has45 = False

// 是否存档
Dim saveNum
saveNum = 0


// ==================== 辅助函数 ====================

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

// 点击按键count次，每次延迟delayMs
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

// 长按指定按键，按住指定毫秒后松开
// 用法: PressHold "D", 800  -> 按住D 800ms
Function PressHold(key, holdMs)
    If holdMs < 0 Then holdMs = 0
    KeyDown key, 1
    If holdMs > 0 Then Delay holdMs
    KeyUp key, 1
End Function

// 检测闪光（进入战斗时的闪光特效，稀有敌人标识）
// 发现闪光后通过系统音量键提示玩家，然后退出
Function DetectRareEnemyFlash()
    Dim flashImg
    For Each flashImg In Array("闪光1.bmp", "闪光2.bmp", "闪光3.bmp", "闪光4.bmp", "闪光5.bmp", "闪光6.bmp", "闪光7.bmp", "闪光8.bmp", "闪光9.bmp", "闪光10.bmp")
        If FindImage(flashImg, 148, 131, 616, 425, 0.9) Then
            Press "F12",2, 100
            KeyPress 175, 20
    		Delay 1000
    		KeyPress 174, 20
            Exit Function
        End If
    Next
End Function

// 等待传送加载完成，最多等待30秒
// 通过识别大地图标志判断传送是否结束
Function WaitForTeleport()
    Dim i
    For i = 1 To 30
        If FindImage("大地图.bmp", 561, 45, 599, 51, 1) Then
            Exit Function
        End If
        Delay 1000
    Next
End Function

// 存档流程：传送到城镇 -> 走到存档点 -> 执行存档 -> 重置存档计数
Function DoSaveGame()
    // 1. 取消
    KeyPress "J", 3
    Delay 300
    
	Press "R", 1, 137
	Press "D", 2, 100
	Press "K", 1, 1000
	
	WaitForTeleport

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
	saveNum = 0
End Function

// ==================== 补装甲流程 ====================

// 战斗中逃跑（无炮弹或装甲低时执行）
// 按键序列：取消 -> 左移(逃跑) -> 确认 -> 左移 -> 确认
Function EscapeBattle()
    Press "J", 1, 100
    Press "A", 1, 100
    Press "K", 1, 100
    Press "A", 1, 100
    Press "K", 1, 100
End Function

// 补装甲流程：传送回城 -> 走到修理店 -> 购买装甲片 -> 存档检查 -> 返回刷怪点
Function DoRepairArmor()
    saveNum = saveNum + 1
    // 1. 取消
    KeyPress "J", 3
    Delay 300

    Press "R", 1, 300
    Press "S", 1, 100
    Press "K", 1, 1000

    WaitForTeleport

    PressHold "W", 100
    Delay 1300
    PressHold "W", 800
    PressHold "A", 300
    Delay 500
    PressHold "A", 700
    Delay 100
    Press "W", 1, 200
    Press "K", 3, 500
    Press "J", 3, 400

    If saveNum >= 10 Then
        DoSaveGame
    End If

    ReturnToFarmSpot
End Function

// 存物流程：回城 -> 拆卸装甲片 -> 存45mm炮 -> 补装甲
// 触发条件：掉落45mm炮后大地图执行
Function DoStoreItems()
    // 1. 取消
    KeyPress "J", 3
    Delay 300
    
	Press "R", 1, 137
	Press "K", 1, 1000
	WaitForTeleport

//	拆卸装甲片
	Press "W", 1, 1000
	Press "K", 1, 500
	Press "J", 3, 300
	
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
	DoRepairArmor
End Function

// 返回刷怪起点：传送到四镇 -> 走到河马刷新点
Function ReturnToFarmSpot()
	// 传送回四镇
    Press "R", 1, 300
    Press "S", 1, 100
    Press "K", 1, 1000
    WaitForTeleport
    // 重新进入诱侦查蜂
    PressHold "S", 1500
	PressHold "A", 940
End Function

// ==================== 战斗状态检测 ====================


// ==================== 主逻辑 ====================

// 主循环逻辑：每5ms执行一次，按优先级检测各种游戏状态并响应
Function MainLoop()

    If FindImage("45mm-.bmp", 315, 552, 415, 580, 0.95) And FindImage("45mm列鹿.bmp", 763, 356, 915, 395, 0.95)  Then 
    	Press "K", 2, 200
    	Press "J", 2, 200
        has45 = True
    End If

	If FindImage("此处无怪.bmp", 211, 586, 321, 629, 1) Then
        Press "J", 4, 300
        DoRepairArmor
        Exit Function
    End If
    
    // 炮弹0
    If FindImage("炮弹0.bmp", 695, 430, 763, 480, 1) Or FindImage("弹药0.bmp", 213, 585,355, 626, 0.95) Then
        hasNotPd = True
        EscapeBattle
        Exit Function
    End If

    // 战斗中装甲少
    If FindImage("攻击.bmp", 212, 508, 327, 552, 1) Then
        If FindImage("SP_LOW_1.bmp", 342, 582, 435, 606, 0.98) Or FindImage("SP_LOW_2.bmp", 342, 676, 437, 700, 0.98) Then
            hasNotPd = True
            EscapeBattle
            Exit Function
        End If
    End If
    
     // 怪物出现了
    If FindImage("巡逻蜂出现.bmp", 217, 586, 455, 597, 0.98) Then
        Press "J", 2, 100
        Press "A", 2, 100
        Press "K", 2, 100
        Press "A", 2, 100
        Press "K", 2, 100
        Exit Function
    End If
    
    If FindImage("战斗中人物.bmp", 197, 609, 221, 626, 0.95) Then
    	If FindImage("主炮选敌人.bmp", 373, 518, 420, 541, 0.95) Then 
    		Press "S", 2, 100
    	End If
    	If FindImage("副炮选敌人.bmp", 376, 518, 417, 538, 0.95) Then 
    		Press "W", 2, 100
    	End If
//    	DetectRareEnemyFlash  // 暂时禁用稀有敌人闪光检测
    	Press "K", 1, 20
    	Exit Function
    End If
    
    // ====== 正常打怪流程 =====
    // 0. 判断装甲少，进入补装甲流程
    If FindImage("装甲少.bmp", 490, 670, 600, 720, 0.97) Or FindImage("装甲少2.bmp", 658, 689, 753, 706, 0.97) Then
        DoRepairArmor
        Exit Function
    End If
    
    If FindImage("手指_特技.bmp", 309, 584, 490, 664, 0.95) 
        Press "K", 2, 100
    	Press "S", 1, 100
    	Press "K", 1, 100
    	Press "W", 3, 100 // 切换上下选怪-------------------------------------------------------------------------------
    	Press "K", 2, 350
    	Press "K", 1, 800
        Exit Function
    End If

    If FindAndPress("选是.bmp", 980, 400, 1070, 450, 0.95, "K", DELAY_NORMAL) Then Exit Function

    // 取消
    If FindAndPress("仓满.bmp", 315, 580, 508, 635, 0.95, "J", DELAY_NORMAL) Then Exit Function
    If FindAndPress("选猎鹿犬.bmp", 760, 350, 960, 470, 0.95, "J", DELAY_NORMAL) Then Exit Function
    If FindAndPress("45mm列鹿.bmp", 763, 356, 915, 395, 0.95, "J", DELAY_NORMAL) Then Exit Function
    If FindAndPress("战斗中过渡.bmp", 157, 540, 218, 563, 0.95, "J", DELAY_NORMAL) Then Exit Function
    If FindAndPress("放入.bmp", 321, 593, 385, 628, 0.95, "J", DELAY_NORMAL) Then Exit Function
    If FindAndPress("对话框.bmp", 1060, 717, 1087, 736, 0.98, "J", DELAY_NORMAL) Then Exit Function
    If FindAndPress("菜单钉.bmp", 256, 506, 275, 524, 1, "J", DELAY_NORMAL) Then Exit Function
    
    // 战斗结束掉落物处理
    If FindAndPress("不搭载.bmp", 780, 450, 950, 500, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("包裹满.bmp", 320, 540, 505, 586, 0.95, "K", DELAY_NORMAL) Then Exit Function
    
    // 2. 大地图中打开菜单
    If FindImage("大地图.bmp", 561, 45, 599, 51, 1) Then
    	Dim i
    	For i = 1 To 10
        	If  FindImage("菜单钉.bmp", 256, 506, 275, 524, 1) Then
            	Exit Function
        	End If
        	Delay 20
    	Next
    	
    	If has45 Then
    		has45 = false
    		DoStoreItems
    		Exit Function
    	End If
    	
    	If hasNotPd Then
    	    hasNotPd  = false
    		DoRepairArmor
    		Exit Function
    	End If 
	    KeyPress "H", 1  
    Exit Function
    End If
    
    
End Function

// ==================== 入口 ====================
If Not FindImage("大地图.bmp", 561, 45, 599, 51, 1)  And Not FindImage("战斗中人物.bmp", 197, 609, 221, 626, 0.95)  Then
    Dim i
    For i = 1 To 10
        If  FindImage("菜单钉.bmp", 256, 506, 275, 524, 1) Then
            Exit Function
        End If
        Delay 20
    Next
    ReturnToFarmSpot
End If
Do
    MainLoop
    Delay 5
Loop
