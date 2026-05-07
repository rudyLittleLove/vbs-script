
// ==================== 常量配置 ====================
Const IMAGE_PATH = "D:\workspace\vbs-script\images\"
Const DELAY_SHORT = 10
Const DELAY_NORMAL = 20

// ==================== 全局状态变量 ====================
// 是否无炮弹
Dim hasNotPd
hasNotPd= False

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

// 检测闪光（进入战斗时的闪光特效）
Function checkFlash()
    Dim flashImg
    For Each flashImg In Array("闪光1.bmp", "闪光2.bmp", "闪光3.bmp", "闪光4.bmp", "闪光5.bmp", "闪光6.bmp", "闪光7.bmp", "闪光8.bmp", "闪光9.bmp", "闪光10.bmp")
        If FindImage(flashImg, 148, 131, 616, 425, 0.9) Then
            KeyPress "F12", 1
            Exit Function
        End If
    Next
End Function

// ==================== 补装甲流程 ====================

Function repair()
    // 1. 取消
    KeyPress "J", 3
    Delay 300
    
    Press "R", 1, 300
    Press "S", 1, 100
    Press "K", 1, 1000
    
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
    
    // 传送回四镇
    Press "R", 1, 300
    Press "S", 1, 100
    Press "K", 1, 6000
    // 重新进入诱侦查蜂
    PressHold "S", 1500
	PressHold "A", 940
End Function

// ==================== 战斗状态检测 ====================

// 战斗状态：0=其他, 1=战斗中, 2=大地图
Const STATE_OTHER = 0
Const STATE_BATTLE = 1
Const STATE_MAP = 2

// 检测当前战斗状态（战斗中 / 大地图 / 其他）
Function checkBattleState()
    // 先检测是否在战斗中（右侧区域）
    If FindImage("战斗中人物.bmp", 197, 609, 221, 626, 0.95) Then 
    	checkBattleState = STATE_BATTLE
    	Exit Function
	End If
    
    // 再检测是否在大地图（无菜单栏 或 中间区域有战车）
    If Not FindImage("菜单栏.bmp", 508, 742, 780, 771, 1) Then
        checkBattleState = STATE_MAP
        Exit Function
    End If
    
    checkBattleState = STATE_OTHER
End Function

// ==================== 主逻辑 ====================

Function run()
	If FindImage("此处无怪.bmp", 211, 586, 321, 629, 1) Then
        Press "J", 4, 300
        repair
        Exit Function
    End If
    
    // 炮弹0
    If FindImage("炮弹0.bmp", 695, 430, 763, 480, 1) Or FindImage("弹药0.bmp", 213, 585,355, 626, 0.95) Then
        hasNotPd = true
        Press "J", 1, 100
        Press "A", 1, 100
        Press "K", 1, 100
        Press "A", 1, 100
        Press "K", 1, 100
        Exit Function
    End If
    
     // 怪物出现了
    If FindImage("怪物出现了.bmp", 336, 585, 500, 626, 0.95) Then
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
    	checkFlash
    	Press "K", 1, 20
    	Exit Function
    End If
    
    // ====== 正常打怪流程 =====
    // 0. 判断装甲少，进入补装甲流程
    If FindImage("装甲少.bmp", 490, 670, 600, 720, 0.95) Or FindImage("装甲少2.bmp", 658, 689, 753, 706, 0.95) Then
        repair
        Exit Function
    End If

    // 1. 诱河马
    If FindImage("手指_特技.bmp",  309, 584, 490, 664, 0.9) Then
        Press "K", 2, 100
        Press "S", 1, 100
        Press "K", 1, 100
        Press "W", 3, 100
        Press "K", 3, 100
        Exit Function
    End If


    // 1. 按确定键（多张图在不同区域分别查找）
    
    If FindAndPress("手指_红牛.bmp", 480, 500, 670, 610, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("寻找怪.bmp", 280, 510, 790, 620, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("手指_特技.bmp", 309, 584, 490, 664, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("诱敌.bmp", 227, 214, 451, 260, 0.95, "K", DELAY_NORMAL) Then Exit Function
//    If FindAndPress("手指_诱敌.bmp", 200, 200, 620, 430, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("去寻找怪.bmp", 400, 500, 760, 600, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("发现45炮.bmp", 343, 585, 482, 674, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("发现45炮2.bmp", 316, 547, 454, 582, 0.95, "K", DELAY_NORMAL) Then Exit Function
    
    // 取消
    If FindAndPress("仓满.bmp", 315, 580, 508, 635, 0.95, "J", DELAY_NORMAL) Then Exit Function
    If FindAndPress("选猎鹿犬.bmp", 760, 350, 960, 470, 0.95, "J", DELAY_NORMAL) Then Exit Function
    If FindAndPress("战斗中过渡.bmp", 157, 540, 218, 563, 0.95, "J", DELAY_NORMAL) Then Exit Function
    If FindAndPress("放入.bmp", 321, 593, 385, 628, 0.95, "J", DELAY_NORMAL) Then Exit Function
    
    // 战斗结束掉落物处理
    If FindAndPress("不搭载.bmp", 780, 450, 950, 500, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("选是.bmp", 980, 400, 1070, 450, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("包裹满.bmp", 320, 540, 505, 586, 0.95, "K", DELAY_NORMAL) Then Exit Function
    
    // 确定诱敌
    If FindAndPress("巡逻蜂.bmp", 224, 229, 388, 312, 0.95, "K", DELAY_NORMAL) Then Exit Function
    
    // 3. 按下键
    If FindAndPress("手指_猎物气息.bmp", 200, 145, 620, 230, 0.95, "S", DELAY_SHORT) Then Exit Function
    If FindAndPress("乘降.bmp", 325, 554, 459, 598, 0.95, "S", DELAY_SHORT) Then Exit Function
    
    // 4. 按上键
    If FindAndPress("诱饵.bmp", 207, 584, 483, 628, 1.0, "W", DELAY_SHORT) Then Exit Function

    // 4. 按右键
    If FindAndPress("包裹.bmp", 180, 555, 320, 600, 0.95, "D", DELAY_SHORT) Then Exit Function
    
    // 2. 大地图中打开菜单
    If FindImage("大地图.bmp", 561, 45, 599, 51, 1)  Then 
    	If hasNotPd Then 
    	    hasNotPd  = false
    		repair 
    	Else
	    	KeyPress "H", 1
    	End If
        Exit Function
    End If
    
    
End Function

// ==================== 入口 ====================
Do
    run
    Delay 5
Loop
