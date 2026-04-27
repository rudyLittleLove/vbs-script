// ==================== 常量配置 ====================
Const IMAGE_PATH = "D:\workspace\vbs-script\images\"
Const DELAY_SHORT = 10
Const DELAY_NORMAL = 20

// ==================== 全局状态变量 ====================
// 是否识别到闪光怪（战斗中有效，退出战斗后重置）
Dim hasFlashDetected
hasFlashDetected = False
// 是否已切换过武器（有闪光时只切换一次）
Dim hasWeaponSwitched
hasWeaponSwitched = False
// 是否无装甲
Dim hasNotZj
hasNotZj = False
// 0=大地图, 1=战斗中, 2=识别闪光中, 3=逃跑中
Dim currentState
currentState = 0

Dim danyaoshao
danyaoshao = false

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
Function PressHold(key, holdMs)
    If holdMs < 0 Then holdMs = 0
    KeyDown key, 1
    If holdMs > 0 Then Delay holdMs
    KeyUp key, 1
End Function

// ==================== 补血 ====================

Function jiaxue()
    KeyPress "A", 1
    KeyPress "W", 1
    Press "K", 1, 100
    Press "S", 1, 100
    Press "K", 1, 100
    Press "S", 1, 100
    Press "K", 4, 100
    Press "K", 3, 300
    Press "J", 4, 50
End Function

// ==================== 补装甲流程 ====================

Function repair()
    // 1. 取消
    KeyPress "J", 3
    Delay 300
    
    If hasNotZj Then 
        Press "E", 1, 100
        Press "K", 1, 200
    End If
    
    // 2. 进入城镇
    Press "W", 1, 1500
    // 3. 按键进入装甲片商铺
    PressHold "D", 100
    PressHold "S", 800
    PressHold "D", 800
    PressHold "W", 600
    Delay 800
    Press "K", 2, 500
    If hasNotZj Then 
        PressHold "W", 1400
    Else 
        PressHold "W", 800
    End If
    Delay 300
    Press "D", 1, 200
    If hasNotZj Then 
        Press "K", 1, 300
        Press "S", 1, 300
        Press "K", 3, 300
        Press "J", 3, 300
        Press "E", 1, 300
        Press "K", 1, 300
        PressHold "S", 500
        Delay 300
        Press "D", 1, 100
    End If
    
    // 对话加装甲
    Press "K", 1, 300
    Press "K", 2, 500
    Press "J", 2, 500
    Press "R", 1, 300
    Press "D", 2, 200
    Press "K", 1, 300

    hasNotZj = False
End Function

// ==================== 武器切换 ====================

Function isAttacking()
    isAttacking = Not FindImage("主炮.bmp", 245, 440, 305, 475, 0.9) And Not FindImage("副炮.bmp", 245, 440, 305, 475, 0.9)
End Function

Function switchWeaponInBattle()
    If isAttacking() Then Exit Function
    
    If hasFlashDetected And Not hasWeaponSwitched And FindImage("副炮.bmp", 245, 440, 305, 475, 0.9) Then
        Press "W", 1, 100
        hasWeaponSwitched = True
        Exit Function
    End If
    
    If Not hasFlashDetected And FindImage("主炮.bmp", 250, 445, 305, 470, 0.9) Then
        Press "W", 1, 100
        Press "S", 1, 100
        Exit Function
    End If
End Function

// ==================== 战斗状态检测 ====================

Const STATE_OTHER = 0
Const STATE_BATTLE = 1
Const STATE_MAP = 2

Function checkBattleState()
//    Dim battleImg
//    For Each battleImg In Array("战斗中战车.bmp", "战斗中战车2.bmp", "战斗中战车3.bmp")
//        If FindImage(battleImg, 900, 100, 1300, 768, 0.9) Then
//            checkBattleState = STATE_BATTLE
//            Exit Function
//        End If
//    Next
	If FindImage("战斗中人物.bmp", 197, 609, 221, 626, 0.95) Then 
    	checkBattleState = STATE_BATTLE
    	Exit Function
	End If
    
    If Not FindImage("菜单栏.bmp", 508, 742, 780, 771, 1) Then
        checkBattleState = STATE_MAP
        Exit Function
    End If
//    Dim mapImg
//    For Each mapImg In Array("战车上.bmp", "战车右.bmp", "战车左.bmp", "战车上3.bmp", "战车下.bmp", "战车上2.bmp", "战车下2.bmp", "战车左2.bmp", "战车右2.bmp")
//        If FindImage(mapImg, 535, 369, 587, 421, 0.9) Then
//            checkBattleState = STATE_MAP
//            Exit Function
//        End If
//    Next
    
    checkBattleState = STATE_OTHER
End Function

// 检测闪光（进入战斗时的闪光特效）
Function checkFlash()
    Dim flashImg
    For Each flashImg In Array("闪光1.bmp", "闪光2.bmp", "闪光3.bmp", "闪光4.bmp", "闪光5.bmp", "闪光6.bmp", "闪光7.bmp", "闪光8.bmp", "闪光9.bmp", "闪光10.bmp")
        If FindImage(flashImg, 148, 131, 616, 425, 0.9) Then
            checkFlash = True
            Exit Function
        End If
    Next
    checkFlash = False
End Function

// ==================== 逃跑流程 ====================
Function doEscape()
    Press "J", 2, 60
    Press "A", 1, 50
    Press "K", 2, 50
End Function

// ==================== 主逻辑 ====================

Function run()
    Dim state
    state = checkBattleState()
    If Not danyaoshao And FindImage("主炮.bmp", 250, 445, 305, 470, 0.9) And FindImage("弹药少.bmp", 712, 429, 719, 480, 0.95) Then 
    	danyaoshao = true
    End If
    
    // ====== 修车/补血/补甲（最优先）======
    If FindImage("无装甲.bmp", 500, 679, 633, 712, 1) Then
        danyaoshao = false
        hasNotZj = True
        repair
        Exit Function
    End If
    
    If FindImage("装甲少.bmp", 490, 670, 600, 720, 0.95) Or (FindImage("手指_特技.bmp", 309, 584, 490, 664, 0.95) And danyaoshao) Then 
    	danyaoshao = false
        repair
        Exit Function
    End If

    If FindImage("血量少.bmp", 495, 700, 600, 750, 0.95) Then
        jiaxue
        Exit Function
    End If
    
    If FindAndPress("战斗中过渡.bmp", 157, 540, 218, 563, 0.95, "J", DELAY_NORMAL) Then Exit Function
    
    // ====== 战斗中：只打闪光，其他逃跑 ======
    If state = STATE_BATTLE Then
        // 状态0→1：刚进入战斗
        If currentState = 0 Then
            currentState = 1
            Exit Function
        End If
        
        // 状态1：识别闪光
        If currentState = 1 Then
            Dim hasFlash
            hasFlash = False
            Dim i
            For i = 1 To 10
                If checkFlash() Then
                    hasFlash = True
                    Exit For
                End If
                Delay 30
            Next
            
            If hasFlash Then
                hasFlashDetected = True
                currentState = 2
            Else 
            	If FindImage("攻击.bmp", 211, 507, 327, 552, 0.95) Then 
                	TracePrint "未检测到闪光，执行逃跑"
                	doEscape
                	currentState = 3            	
            	End If
            End If
            Exit Function
        End If
        
        // 状态2：有闪光，正常战斗（一直打到战斗结束）
        If currentState = 2 Then
            switchWeaponInBattle
            Press "K", 1, 0
            Exit Function
        End If
        
        // 状态3：逃跑中，检测是否成功
        If currentState = 3 Then
            If Not isInBattle Then
                currentState = 0
            Else
                TracePrint "逃跑失败，继续逃跑"
                doEscape
            End If
            Exit Function
        End If
    End If
    
    // ====== 回到大地图：重置战斗状态 ======
    If state = STATE_MAP Then
        hasFlashDetected = False
        hasWeaponSwitched = False
        currentState = 0
    End If
    
    // ====== 大地图：正常打怪流程（诱敌等）======
    If state = STATE_MAP Then
        If FindAndPress("手指_红牛.bmp", 480, 500, 670, 610, 0.95, "K", DELAY_NORMAL) Then Exit Function
        If FindAndPress("寻找怪.bmp", 280, 510, 790, 620, 0.95, "K", DELAY_NORMAL) Then Exit Function
        If FindAndPress("手指_特技.bmp", 309, 584, 490, 664, 0.95, "K", DELAY_NORMAL) Then Exit Function
        If FindAndPress("手指_诱敌.bmp", 200, 200, 620, 430, 0.95, "K", DELAY_NORMAL) Then Exit Function
        If FindAndPress("去寻找怪.bmp", 400, 500, 760, 600, 0.95, "K", DELAY_NORMAL) Then Exit Function
        
        If FindAndPress("仓满.bmp", 315, 580, 508, 635, 0.95, "J", DELAY_NORMAL) Then Exit Function
        If FindAndPress("选猎鹿犬.bmp", 780, 400, 950, 450, 0.95, "J", DELAY_NORMAL) Then Exit Function
        
        If FindAndPress("不搭载.bmp", 780, 450, 950, 500, 0.95, "K", DELAY_NORMAL) Then Exit Function
        If FindAndPress("选是.bmp", 980, 400, 1070, 450, 0.95, "K", DELAY_NORMAL) Then Exit Function
        If FindAndPress("包裹满.bmp", 320, 540, 505, 586, 0.95, "K", DELAY_NORMAL) Then Exit Function
        
        ' If FindAndPress("蒲公英.bmp", 224, 222, 463, 265, 0.95, "K", DELAY_NORMAL) Then Exit Function
        ' If FindAndPress("飞刀鱼.bmp", 223, 76, 390, 125, 0.95, "K", DELAY_NORMAL) Then Exit Function
        If FindAndPress("行商杀手.bmp", 220, 272, 430, 318, 0.95, "K", DELAY_NORMAL) Then Exit Function
        ' If FindAndPress("沙地蚁.bmp", 225, 275, 389, 315, 0.95, "K", DELAY_NORMAL) Then Exit Function
        ' If FindAndPress("陨石蜗牛.bmp", 225, 275, 430, 515, 0.95, "K", DELAY_NORMAL) Then Exit Function
        ' If FindAndPress("爆破龟.bmp", 210, 350, 430, 445, 0.95, "K", DELAY_NORMAL) Then Exit Function
        ' If FindAndPress("杀人阿米巴.bmp", 225, 75, 468, 167, 0.95, "K", DELAY_NORMAL) Then Exit Function
        
        If FindAndPress("手指_猎物气息.bmp", 200, 145, 620, 230, 0.95, "S", DELAY_SHORT) Then Exit Function
        If FindAndPress("乘降.bmp", 325, 554, 459, 598, 0.95, "S", DELAY_SHORT) Then Exit Function
        
        If FindAndPress("诱饵.bmp", 207, 584, 483, 628, 1.0, "W", DELAY_SHORT) Then Exit Function
        If FindAndPress("包裹.bmp", 180, 555, 320, 600, 0.95, "D", DELAY_SHORT) Then Exit Function
        
        ' If FindAndPress("战车上.bmp", 620, 370, 670, 430, 0.9, "H", DELAY_NORMAL) Then Exit Function
        ' If FindAndPress("战车右.bmp", 610, 370, 670, 430, 0.9, "H", DELAY_NORMAL) Then Exit Function
        ' If FindAndPress("战车左.bmp", 610, 370, 670, 430, 0.9, "H", DELAY_NORMAL) Then Exit Function
        ' If FindAndPress("战车上3.bmp", 620, 370, 670, 430, 0.9, "H", DELAY_NORMAL) Then Exit Function
        ' If FindAndPress("战车下.bmp", 620, 370, 670, 430, 0.9, "H", DELAY_NORMAL) Then Exit Function
        ' If FindAndPress("战车上2.bmp", 620, 370, 670, 430, 0.9, "H", DELAY_NORMAL) Then Exit Function
        ' If FindAndPress("战车下2.bmp", 620, 370, 670, 430, 0.95, "H", DELAY_NORMAL) Then Exit Function
        ' If FindAndPress("战车左2.bmp", 620, 380, 660, 415, 0.95, "H", DELAY_NORMAL) Then Exit Function
        ' If FindAndPress("战车右2.bmp", 620, 380, 655, 415, 0.95, "H", DELAY_NORMAL) Then Exit Function
        If Not FindImage("菜单栏.bmp", 508, 742, 780, 771, 1) Then
            KeyPress "H", 1
            Exit Function
        End If
        Exit Function
    End If
End Function

// ==================== 入口 ====================
Do
    run
    Delay 5
Loop
