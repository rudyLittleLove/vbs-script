
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
hasNotZj= False

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
    
    Press "R", 1, 300
    Press "D", 2, 100
    Press "K", 1, 8000
    
    If hasNotZj Then 
    	Press "E", 1, 100
    	Press "K", 1, 200
    End If
    
    // 2. 进入城镇
    Press "W", 1, 1500
    // 3. 按键进入装甲片商铺
    // 向右移动（短按100ms）
    PressHold "D", 100
    // 向下移动（持续800ms）
    PressHold "S", 800
    // 向右移动（持续800ms）
    PressHold "D", 800
    // 向上移动（持续600ms）
    PressHold "W", 600
    // 等待进入修理铺过度
    Delay 800
    // 对话让人让开（按K确定2次）
    Press "K", 2, 500
    // 向上移动（持续800ms）
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
    
    // 对话加装甲（按K确定5次）
    Press "K", 1, 300
    Press "K", 2, 500
    Press "J", 2, 500
    
    // 重新进入地道
    PressHold "S", 1060
	Delay 934
	PressHold "S", 582
	PressHold "D", 382
	PressHold "S", 616
	PressHold "D", 1063
	PressHold "W", 395
	Delay 969
	PressHold "W", 614
	PressHold "A", 1060
	Delay 115
	PressHold "W", 118
	PressHold "A", 500
	Delay 1115
	PressHold "D", 167
	PressHold "W", 583
	PressHold "D", 1060
	PressHold "S", 150
	PressHold "A", 297
	Delay 982
	PressHold "D", 168
	PressHold "W", 274
	PressHold "A", 1060
	Delay 1250
	PressHold "A", 366
	PressHold "S", 568
	PressHold "A", 265
	PressHold "S", 400
	PressHold "A", 500
	PressHold "W", 600
	PressHold "A", 450
	PressHold "W", 600
	PressHold "A", 546
	PressHold "W", 300
	PressHold "A", 600
    
    hasNotZj = false
End Function

// ==================== 武器切换 ====================

// 检测是否处于攻击中（未显示武器 = 攻击动画中）
Function isAttacking()
    isAttacking = Not FindImage("主炮.bmp", 245, 440, 305, 475, 0.9) And Not FindImage("副炮.bmp", 245, 440, 305, 475, 0.9)
End Function

// 战斗中根据闪光状态切换武器（有闪光只切换一次）
Function switchWeaponInBattle()
    // 攻击中不能切换
    If isAttacking() Then Exit Function
    
    // 有闪光怪且当前是副炮 → 切换主炮（只切换一次）
    If hasFlashDetected And Not hasWeaponSwitched And FindImage("副炮.bmp", 245, 440, 305, 475, 0.9) Then
        Press "W", 1, 100
        hasWeaponSwitched = True
        Exit Function
    End If
    
    // 无闪光怪且当前是主炮 → 切换副炮
    If Not hasFlashDetected And FindImage("主炮.bmp", 250, 445, 305, 470, 0.9) Then
        Press "W", 1, 100
        Press "S", 1, 100
        Exit Function
    End If
End Function

// ==================== 战斗状态检测 ====================

// 战斗状态：0=其他, 1=战斗中, 2=大地图
Const STATE_OTHER = 0
Const STATE_BATTLE = 1
Const STATE_MAP = 2

// 检测当前战斗状态（战斗中 / 大地图 / 其他）
Function checkBattleState()
    // 先检测是否在战斗中（右侧区域）
    // Dim battleImg
    // For Each battleImg In Array("战斗中战车.bmp", "战斗中战车2.bmp", "战斗中战车3.bmp")
    //     If FindImage(battleImg, 900, 100, 1300, 768, 0.9) Then
    //         checkBattleState = STATE_BATTLE
    //         Exit Function
    //     End If
    // Next
    If FindImage("战斗中人物.bmp", 197, 609, 221, 626, 0.95) Then 
    	checkBattleState = STATE_BATTLE
    	Exit Function
	End If
    
    // 再检测是否在大地图（无菜单栏 或 中间区域有战车）
    If Not FindImage("菜单栏.bmp", 508, 742, 780, 771, 1) Then
        checkBattleState = STATE_MAP
        Exit Function
    End If
    Dim mapImg
    For Each mapImg In Array("战车上.bmp", "战车右.bmp", "战车左.bmp", "战车上3.bmp", "战车下.bmp", "战车上2.bmp", "战车下2.bmp", "战车左2.bmp", "战车右2.bmp")
        If FindImage(mapImg, 535, 369, 587, 421, 0.9) Then
            checkBattleState = STATE_MAP
            Exit Function
        End If
    Next
    
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

// ==================== 主逻辑 ====================

Function run()
	If FindImage("此处无怪.bmp", 211, 586, 321, 629, 1) Then
        Press "J", 4, 300
        repair
        Exit Function
    End If

    // ====== 检测战斗状态 ======
    Dim state
    state = checkBattleState()
    
    // 战斗中：持续识别闪光（直到识别到或战斗结束），切换武器，按K攻击
    If state = STATE_BATTLE Then
        // 持续识别闪光，只要没识别到就一直尝试
        If Not hasFlashDetected Then
            If checkFlash() Then hasFlashDetected = True
        End If
        switchWeaponInBattle
        Press "K", 1, 0
        Exit Function
    End If
    
    // 回到大地图：战斗真正结束，重置所有战斗状态
    If state = STATE_MAP Then
        hasFlashDetected = False
        hasWeaponSwitched = False
    End If
    
    // ====== 正常打怪流程 ======
     // 0. 判断无装甲，进入修车流程
    If FindImage("无装甲.bmp", 500, 679, 633, 712, 1) Then
        hasNotZj = true
        repair
        Exit Function
    End If
    
    // 0. 判断装甲少，进入补装甲流程
    If FindImage("装甲少.bmp", 490, 670, 600, 720, 0.95) Then
        repair
        Exit Function
    End If

    // 0. 判断血量少，进入加血流程
    If FindImage("血量少.bmp", 495, 700, 600, 750, 0.95) Then
        jiaxue
        Exit Function
    End If

    // 1. 按确定键（多张图在不同区域分别查找）
    
    If FindAndPress("手指_红牛.bmp", 480, 500, 670, 610, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("寻找怪.bmp", 280, 510, 790, 620, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("手指_特技.bmp", 309, 584, 490, 664, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("手指_诱敌.bmp", 200, 200, 620, 430, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("去寻找怪.bmp", 400, 500, 760, 600, 0.95, "K", DELAY_NORMAL) Then Exit Function
    
    // 取消
    If FindAndPress("仓满.bmp", 315, 580, 508, 635, 0.95, "J", DELAY_NORMAL) Then Exit Function
    If FindAndPress("选猎鹿犬.bmp", 780, 400, 950, 450, 0.95, "J", DELAY_NORMAL) Then Exit Function
    If FindAndPress("战斗中过渡.bmp", 157, 540, 218, 563, 0.95, "J", DELAY_NORMAL) Then Exit Function
    
    // 战斗结束掉落物处理
    If FindAndPress("不搭载.bmp", 780, 450, 950, 500, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("选是.bmp", 980, 400, 1070, 450, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("包裹满.bmp", 320, 540, 505, 586, 0.95, "K", DELAY_NORMAL) Then Exit Function
    
    // 确定诱敌
    
    If FindAndPress("一发屋.bmp", 224, 368, 388, 415, 0.95, "K", DELAY_NORMAL) Then Exit Function
    // If FindAndPress("蒲公英.bmp", 224, 222, 463, 265, 0.95, "K", DELAY_NORMAL) Then Exit Function
    // If FindAndPress("飞刀鱼.bmp", 223, 76, 390, 125, 0.95, "K", DELAY_NORMAL) Then Exit Function
    // If FindAndPress("行商杀手.bmp", 220, 272, 430, 318, 0.95, "K", DELAY_NORMAL) Then Exit Function
    // If FindAndPress("影像蝙蝠.bmp", 220, 315, 435, 368, 0.95, "K", DELAY_NORMAL) Then Exit Function
    // If FindAndPress("沙地蚁.bmp", 225, 275, 389, 315, 0.95, "K", DELAY_NORMAL) Then Exit Function
    // If FindAndPress("陨石蜗牛.bmp", 225, 275, 430, 515, 0.95, "K", DELAY_NORMAL) Then Exit Function
    // If FindAndPress("爆破龟.bmp", 210, 350, 430, 445, 0.95, "K", DELAY_NORMAL) Then Exit Function
    // If FindAndPress("杀人阿米巴.bmp", 225, 75, 468, 167, 0.95, "K", DELAY_NORMAL) Then Exit Function
    
    // 3. 按下键
    If FindAndPress("手指_猎物气息.bmp", 200, 145, 620, 230, 0.95, "S", DELAY_SHORT) Then Exit Function
    If FindAndPress("乘降.bmp", 325, 554, 459, 598, 0.95, "S", DELAY_SHORT) Then Exit Function
    
    // 4. 按上键
    If FindAndPress("诱饵.bmp", 207, 584, 483, 628, 1.0, "W", DELAY_SHORT) Then Exit Function

    // 4. 按右键
    If FindAndPress("包裹.bmp", 180, 555, 320, 600, 0.95, "D", DELAY_SHORT) Then Exit Function
    
    // 2. 大地图中打开菜单
    // If FindAndPress("战车上.bmp", 620, 370, 670, 430, 0.9, "H", DELAY_NORMAL) Then Exit Function
    // If FindAndPress("战车右.bmp", 610, 370, 670, 430, 0.9, "H", DELAY_NORMAL) Then Exit Function
    // If FindAndPress("战车左.bmp", 610, 370, 670, 430, 0.9, "H", DELAY_NORMAL) Then Exit Function
    // If FindAndPress("战车上3.bmp", 620, 370, 670, 430, 0.9, "H", DELAY_NORMAL) Then Exit Function
    // If FindAndPress("战车下.bmp", 620, 370, 670, 430, 0.9, "H", DELAY_NORMAL) Then Exit Function
    // If FindAndPress("战车上2.bmp", 620, 370, 670, 430, 0.9, "H", DELAY_NORMAL) Then Exit Function
    // If FindAndPress("战车下2.bmp", 620, 370, 670, 430, 0.95, "H", DELAY_NORMAL) Then Exit Function
    // If FindAndPress("战车左2.bmp", 620, 380, 660, 415, 0.95, "H", DELAY_NORMAL) Then Exit Function
    // If FindAndPress("战车右2.bmp", 620, 380, 655, 415, 0.95, "H", DELAY_NORMAL) Then Exit Function
    If Not FindImage("菜单栏.bmp", 508, 742, 780, 771, 1) Then
        KeyPress "H", 1
        Exit Function
    End If
    
    
End Function

// ==================== 入口 ====================
Do
    run
    Delay 5
Loop
