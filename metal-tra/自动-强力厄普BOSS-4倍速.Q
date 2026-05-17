// ==================== 常量配置 ====================
Const IMAGE_PATH = "D:\workspace\vbs-script\images\"
Const DELAY_SHORT = 10
Const DELAY_NORMAL = 20

// 单步超时检测（毫秒）
Const STEP_TIMEOUT = 10000

// 记录当前步骤开始时间
Dim stepStartTime
stepStartTime = 0

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
	KeyUp "A", 1
	KeyUp "S", 1
	KeyUp "D", 1
	KeyUp "W", 1
End Function

// 检测是否处于战斗中（通过"攻击"按钮判断）
Function IsInBattle()
	IsInBattle = FindImage("怪物出现边框.bmp", 180, 562, 195, 578, 1)
End Function

// 战斗中逃跑
Function EscapeBattle()
	Press "J", 1, 100
    Press "J", 1, 200
    Do
        // 如果已经在大地图了，说明逃跑成功
        If FindImage("大地图.bmp", 561, 45, 599, 51, 1) Then
            Exit Do
            Exit Function
        End If
        
        // 在攻击菜单界面 → 执行逃跑指令
        If FindImage("攻击.bmp", 212, 508, 327, 552, 1) Then 
            Press "A", 1, 100
            Press "K", 1, 200
            Press "A", 1, 100
            Press "K", 1, 100
        End If
        Delay 300
    Loop
End Function

// 蝎子BOSS战斗流程
Function FightBoss()
	Press "J", 1, 100
    TracePrint "开始战斗"
    Dim athCount
    athCount = 0
    Do
        // 如果已经在大地图了，说明逃跑成功
        If FindImage("大地图.bmp", 561, 45, 599, 51, 1) Then
            Exit Do
            Exit Function
        End If

        If FindImage("怪物出现边框.bmp", 180, 562, 195, 578, 1) Then
            Delay 200
            KeyPress "J", 1
            Exit Function
        End If
        
        // 在攻击菜单界面 → 执行逃跑指令
        If FindImage("攻击.bmp", 212, 508, 327, 552, 1) Then 
            athCount = athCount + 1
            TracePrint "开始攻击"   
            // 一号攻击
            Press "D", 2, 100
            Press "K", 1, 100
            If athCount < 7 Then
                Press "S", 1, 100
            End If
            Press "K", 1, 100
            If athCount < 5 Then
                Press "D", 1, 100
            End If
            Press "K", 2, 100
            // 二号攻击
            Press "K", 2, 100
        End If
        Delay 300
    Loop
End Function

Function HandleBattle()
    // 判断是否进入战斗
    If Not IsInBattle() Then
        Exit Function
    End If
    
    ReleaseAllKeys

    EscapeBattle
End Function

// ==================== 通用循环体 ====================
// needBattle: True=需要执行HandleBattle, False=不需要
Function LoopWithBattle(stepName, needBattle)
    stepStartTime = Plugin.GetSysInfo.GetTime
    Do
        //Dim startTime
        Dim result
        //startTime = Plugin.GetSysInfo.GetTime
        
        // 检测单步超时
        Dim timeLength
        timeLength = Plugin.GetSysInfo.GetTime - stepStartTime
        If timeLength > STEP_TIMEOUT Then
            StartNewRun
        End If
        
        result = False
        Select Case stepName
            Case "Step1"
                result = Step1_SavePoint()
            Case "Step2"
                result = Step2_UpperLeft()
            Case "Step3"
                result = Step3_Floor1Cn()
            Case "Step4"
                result = Step4_Floor1Sym()
            Case "Step5"
                result = Step5_Floor3()
            Case "Step6"
                result = Step6_Left1()
            Case "Step7"
                result = Step7_Down1()
            Case "Step8"
                result = Step8_Right1()
            Case "Step9"
                result = Step9_Down2()
            Case "Step10"
                result = Step10_Right2()
            Case "Step11"
                result = Step11_Down3()
            Case "Step12"
                result = Step12_Left2()
            Case "Step13"
                result = Step13_Up1()
            Case "Step14"
                result = Step14_DownLeft2()
            Case "Step15"
                result = Step15_Down4()
            Case "Step16"
                result = Step16_Right3()
            Case "Step17"
                result = Step17_Down1()
            Case "Step18"
                result = Step18_Right4()
            Case "Step19"
                result = Step19_Down2()
            Case "Step20"
                result = Step20_BaitPosition()
            Case "Step21"
                result = Step21_Found()
        End Select
        
        If result Then
            LoopWithBattle = True
            Exit Function
        End If
        
        If needBattle Then HandleBattle
    Loop
End Function

// ==================== 各步骤判断逻辑 ====================

// 步骤1：存档位开始
Function Step1_SavePoint()
    If FindImage("3_boss_d_l.bmp", 633, 325, 649, 339, 1) Then
        ReleaseAllKeys
        PressHold "S", 25
        KeyDown "A", 1
        Step1_SavePoint = True
        Exit Function
    End If
    Step1_SavePoint = False
End Function

// 步骤2：上左拐角
Function Step2_UpperLeft()
    //If FindImage("3_boss_u_l2.bmp", 760, 349, 811, 380, 0.9) Then
    If FindImage("3_boss_u_l.bmp", 604, 364, 624, 394, 1) Then
        ReleaseAllKeys
        PressHold "W", 25
        PressHold "A", 50
        Step2_UpperLeft = True
        Exit Function
    End If
    Step2_UpperLeft = False
End Function

// 步骤3：负1楼（中文）
Function Step3_Floor1Cn()
    If FindImage("3_boss_负1楼.bmp", 1012, 334, 1049, 354, 1) Then
        ReleaseAllKeys
        PressHold "D", 35
        PressHold "W", 130
        PressHold "D", 280
        PressHold "S", 25
        PressHold "A", 50
        Step3_Floor1Cn = True
        Exit Function
    End If
    Step3_Floor1Cn = False
End Function

// 步骤4：-1楼（符号）
Function Step4_Floor1Sym()
    If FindImage("3_boss_-1楼.bmp", 645, 360, 669, 424, 1) Then
        ReleaseAllKeys
        PressHold "D", 40
        PressHold "W", 75
        PressHold "A", 190
        Step4_Floor1Sym = True
        Exit Function
    End If
    Step4_Floor1Sym = False
End Function

// 步骤5：负3楼
Function Step5_Floor3()
    If FindImage("3_boss_负3楼.bmp", 608, 367, 630, 420, 1) Then
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
        Step5_Floor3 = True
        Exit Function
    End If
    Step5_Floor3 = False
End Function

// 步骤6：往左 l1
Function Step6_Left1()
    If FindImage("3_boss_l1.bmp", 617, 407, 664, 431, 1) Then
        ReleaseAllKeys
        KeyDown "A", 1
        Step6_Left1 = True
        Exit Function
    End If
    Step6_Left1 = False
End Function

// 步骤7：往下 d1
Function Step7_Down1()
    KeyDown "A", 1
    If FindImage("3_boss_d1.bmp", 602, 379, 630, 423, 1) Then
        ReleaseAllKeys
        KeyDown "S", 1
        Step7_Down1 = True
        Exit Function
    End If
    Step7_Down1 = False
End Function

// 步骤8：往右 r1
Function Step8_Right1()
    KeyDown "S", 1
    // If FindImgWithDelay("3_boss_r1.bmp", 803, 223, 866, 441, 0.95, "S", 223) Then
    // If FindImage("3_boss_r1.bmp", 803, 223, 866, 289, 0.95) Then
    If FindImage("3_boss_r1.bmp", 803, 223, 866, 290, 0.95) Then
        ReleaseAllKeys
        KeyDown "D", 1
        Step8_Right1 = True
        Exit Function
    End If
    Step8_Right1 = False
End Function

// 步骤9：往下 d2
Function Step9_Down2()
    KeyDown "D", 1
    If FindImage("3_boss_d_r.bmp", 660, 380, 683, 417, 1) Then
        ReleaseAllKeys
        PressHold "S", 25
        KeyDown "D", 1
    End If
    If FindImage("3_boss_d2.bmp", 649, 356, 671, 391, 1) Then
        ReleaseAllKeys
        KeyDown "S", 1
        Step9_Down2 = True
        Exit Function
    End If
    Step9_Down2 = False
End Function

// 步骤10：往右 r2
Function Step10_Right2()
    KeyDown "S", 1
    If FindImage("3_boss_r2.bmp", 613, 401, 633, 427, 1) Then
        ReleaseAllKeys
        KeyDown "D", 1
        Step10_Right2 = True
        Exit Function
    End If
    Step10_Right2 = False
End Function

// 步骤11：往下 d3
Function Step11_Down3()
    KeyDown "D", 1
    If FindImage("3_boss_d3.bmp", 651, 378, 671, 411, 1) Then
        ReleaseAllKeys
        KeyDown "S", 1
        Step11_Down3 = True
        Exit Function
    End If
    Step11_Down3 = False
End Function

// 步骤12：往左 l2
Function Step12_Left2()
    KeyDown "S", 1
    If FindImage("3_boss_l2.bmp", 621, 397, 683, 440, 1) Then
        ReleaseAllKeys
        KeyDown "A", 1
        Step12_Left2 = True
        Exit Function
    End If
    Step12_Left2 = False
End Function

// 步骤13：往上 u1
Function Step13_Up1()
    KeyDown "A", 1
    If FindImage("3_boss_u1.bmp", 605, 395, 625, 417, 1) Then
        ReleaseAllKeys
        KeyDown "W", 1
        Step13_Up1 = True
        Exit Function
    End If
    Step13_Up1 = False
End Function

// 步骤14：下左拐角2
Function Step14_DownLeft2()
    KeyDown "W", 1
    If FindImage("3_boos_d_l.bmp", 597, 376, 679, 398, 1) Then
        ReleaseAllKeys
        PressHold "S", 25
        KeyDown "A", 1
        Step14_DownLeft2 = True
        Exit Function
    End If
    Step14_DownLeft2 = False
End Function

// 步骤15：往下 d4
Function Step15_Down4()
    KeyDown "A", 1
    //If FindImgWithDelay("3_boss_d4.bmp", 311, 177, 542, 204, 0.95, "A", 511) Then
    //If FindImage("3_boss_d4.bmp", 464, 177, 542, 204, 0.95) Then
    If FindImage("3_boss_d4.bmp", 464, 177, 542, 204, 0.95) Then
        ReleaseAllKeys
        KeyDown "S", 1
        Step15_Down4 = True
        Exit Function
    End If
    Step15_Down4 = False
End Function

// 步骤16：往右 r3
Function Step16_Right3()
    KeyDown "S", 1
    //If FindImgWithDelay("3_boss_r3.bmp", 264, 468, 298, 700, 0.95, "S", 468) Then
    //If FindImage("3_boss_r3.bmp", 264, 468, 298, 547, 0.95) Then
    If FindImage("3_boss_r3.bmp", 264, 468, 298, 557, 0.95) Then
        ReleaseAllKeys
        KeyDown "D", 1
        Step16_Right3 = True
        Exit Function
    End If
    Step16_Right3 = False
End Function

// 步骤17：往下 d1
Function Step17_Down1()
    KeyDown "D", 1
    If FindImage("3_boos_d_r.bmp", 643, 376, 687, 440, 1) Then
        ReleaseAllKeys
        PressHold "S", 25
        KeyDown "D", 1
    End If
    If FindImage("3_boos_u_r.bmp", 619, 375, 667, 405, 0.95) Then
        ReleaseAllKeys
        PressHold "w", 25
        KeyDown "D", 1
    End If
    If FindImage("3_boss_d2.bmp", 649, 356, 671, 391, 1) Then
        ReleaseAllKeys
        KeyDown "S", 1
        Step17_Down1 = True
        Exit Function
    End If
    Step17_Down1 = False
End Function

// 步骤18：往右 r4
Function Step18_Right4()
    KeyDown "S", 1
    If FindImage("3_boss_r4.bmp", 609, 410, 631, 430, 1) Then
        ReleaseAllKeys
        KeyDown "D", 1
        Step18_Right4 = True
        Exit Function
    End If
    Step18_Right4 = False
End Function

// 步骤19：往下 d2
Function Step19_Down2()
    KeyDown "D", 1
    If FindImage("3_boss_d2.bmp", 649, 356, 671, 391, 1) Then
        ReleaseAllKeys
        KeyDown "S", 1
        Step19_Down2 = True
        Exit Function
    End If
    Step19_Down2 = False
End Function

// 步骤20：诱敌位置
Function Step20_BaitPosition()
    KeyDown "S", 1
    If FindImage("3_boss_over.bmp", 621, 419, 665, 435, 1) Then
        ReleaseAllKeys
        Step20_BaitPosition = True
        Exit Function
    End If
    Step20_BaitPosition = False
End Function

// 步骤21：发现了
Function Step21_Found()
    If FindImage("发现了.bmp", 216, 584, 322, 625, 1) Then
        Step21_Found = True
        Exit Function
    End If
    Step21_Found = False
End Function

// ==================== 5星判断 ====================
Function Check5Star()
    // 410, 580, 702, 628 盖亚机组坐标
    // FindImage("惊雷.bmp", 343, 584, 422, 625, 0.96)
    // FindImage("机组.bmp", 410, 580, 702, 628, 0.96)
    // FindImage("猛犸.bmp", 344, 585, 419, 623, 0.96)
    //If FindImage("惊雷.bmp", 343, 584, 423, 626, 0.96) And FindImage("机组.bmp", 410, 580, 702, 628, 0.96) Then
    //If FindImage("机组.bmp", 450, 580, 702, 628, 0.96) And FindImage("惊雷.bmp", 343, 584, 423, 626, 0.96) And FindImage("5星.bmp", 530, 552, 773, 637, 0.92) Then
    If FindImage("惊雷.bmp", 343, 584, 422, 625, 0.96) Then
        KeyPress 175, 20
        KeyDown "Ctrl", 1
        KeyDown "Alt", 1
        KeyDown "3", 1
        Delay 300
        KeyUp "Ctrl", 1
        KeyUp "Alt", 1
        KeyUp "3", 1
        KeyPress 174, 22
        KeyPress "F12", 1
        Check5Star = True
        Exit Function
    End If
    Check5Star = False
End Function

// ==================== 主流程：一步一步执行 ====================
Function NavigateToBoss()
    // 第1步：存档位
    LoopWithBattle "Step1", False
    
    // 第2步：上左拐角
    LoopWithBattle "Step2", False
    
    // 第3步：负1楼（中文）
    LoopWithBattle "Step3", False
    
    // 第4步：-1楼（符号）
    LoopWithBattle "Step4", False
    
    // 第5步：负3楼
    LoopWithBattle "Step5", False
    
    // 左 下 右 下 右 下 左 上 下左 下 右 下 右 下
    // 第6步：往左 l1
    LoopWithBattle "Step6", True
    // 第7步：往下 d1
    LoopWithBattle "Step7", True
    // 第8步：往右 r1
    LoopWithBattle "Step8", True
    // 第9步：往下 d2
    LoopWithBattle "Step9", True
    // 第10步：往右 r2
    LoopWithBattle "Step10", True
    // 第11步：往下 d3
    LoopWithBattle "Step11", True
    // 第12步：往左 l2
    LoopWithBattle "Step12", True
    // 第13步：往上 u1
    LoopWithBattle "Step13", True
    // 第14步：下左拐角2
    LoopWithBattle "Step14", True
    // 第15步：往下 d4
    LoopWithBattle "Step15", True
    // 第16步：往右 r3
    LoopWithBattle "Step16", True
    // 第17步：往下 d1
    LoopWithBattle "Step17", True
    // 第18步：往右 r4
    LoopWithBattle "Step18", True
    // 第19步：往下 d2
    LoopWithBattle "Step19", True
    // 第20步：诱敌位置
    LoopWithBattle "Step20", True
    
    ReleaseAllKeys

    Do
        If FindImage("3_boss_over.bmp", 621, 419, 665, 435, 1) Then
            ReleaseAllKeys
            Press "h", 1, 100
            Press "K", 2, 100
            Press "S", 1, 100
            Press "K", 1, 100
            Press "W", 1, 100
            Press "K", 3, 100
            Press "J", 5, 100
        End If

        If FindImage("厄普.bmp", 178, 114, 788, 531, 1) Then 
            FightBoss
        Else
            If FindImage("攻击.bmp", 212, 508, 327, 552, 1) Then 
                EscapeBattle
            End If
        End If

        If FindImage("红牛获得.bmp", 212, 578, 380, 626, 1) Then 
            Delay 200
            If FindImage("红牛获得.bmp", 212, 578, 380, 626, 1) Then 
                Press "J", 1, 100
            End If
        End If

        If FindImage("发现了.bmp", 216, 584, 322, 625, 1) Then
            // 5星判断
            Check5Star

            If FindImage("加特林.bmp", 338, 583, 574, 630, 1)
                Press "K", 4, 200
            End If

            ReleaseAllKeys
            StartNewRun
            Exit Function
        End If
    Loop
End Function

// 刷新游戏并导航到目标位置
Function StartNewRun()
    ReleaseAllKeys
//
//    KeyDown "Ctrl", 1
//    KeyDown "Alt", 1
//    KeyDown "1", 1
//    Delay 100
//    KeyUp "Ctrl", 1
//    KeyUp "Alt", 1
//    KeyUp "1", 1

	Press "J", 3, 200
	//		刷新
	Press "F5", 1, 10
	Press "F5", 1, 400
	Press "J", 2, 200
    Dim count1
    count1 = 0
    Do
        count1 = count1 + 1
        If count1 > 10 Then
            StartNewRun
        End If
        If FindImage("指账号.bmp", 381, 299, 442, 331, 1) Then
            Exit Do
        End If
        Delay 500
    Loop
    Press "S", 1, 100
	Press "K", 1, 100
	Press "S", 1, 100
	Press "K", 6, 50
	Press "N", 1, 100
	Press "S", 1, 100
	Press "K", 1, 100
	Delay 1000
	Press "K", 3, 200
    count1 = 0
	Do
        count1 = count1 + 1
        If count1 > 10 Then
            StartNewRun
        End If
        If FindImage("指开始游戏.bmp", 290, 672, 442, 716, 1) Then
            Exit Do
        End If
        Delay 500
    Loop
	Press "K", 2, 200
	Delay 300
	
	//    移动
    NavigateToBoss	
End Function

// ==================== 入口 ====================
Do
    StartNewRun
    Delay 100
Loop
