
// ==================== 常量配置 ====================
Const IMAGE_PATH = "D:\workspace\vbs-script\images\"
Const DELAY_SHORT = 10
Const DELAY_NORMAL = 20

// ==================== 全局状态变量 ====================

// 是否无装甲/需要回城补充
Dim needRepair
needRepair = False




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

// 检测是否在大地图（有大地图标志且没有菜单钉）
// 返回 True=是大地图, False=不是
Function IsWorldMap()
    If Not FindImage("大地图.bmp", 561, 45, 599, 51, 1) Then
        IsWorldMap = False
        Exit Function
    End If
    Dim i
    For i = 1 To 2
        If FindImage("菜单钉.bmp", 256, 506, 275, 524, 1) Then
            IsWorldMap = False
            Exit Function
        End If
        Delay 100
    Next
    IsWorldMap = True
End Function

// 等待传送加载完成，最多等待30秒
Function WaitForTeleport()
    Dim i
    For i = 1 To 30
        If IsWorldMap() Then
            Exit Function
        End If
        Delay 1000
    Next
End Function

// ==================== 补血 ====================

Function DoHeal()
	If FindImage("手指_特技.bmp", 309, 584, 490, 664, 0.95) 
    	Press "A", 1, 50
    	Press "W", 1, 50
    End If
    Press "K", 1, 100
    Press "S", 1, 100
    Press "K", 1, 100
    Press "S", 1, 100
    Press "K", 4, 100
    Press "K", 2, 300
    Press "J", 4, 50
End Function

// ==================== 补装甲流程 ====================

Function DoRepairArmor()
    // 1. 取消
    KeyPress "J", 3
    Delay 300

    If needRepair Then
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
    Press "K", 1, 100
    Press "J", 4, 300

    If needRepair Then
        PressHold "W", 1300
    Else
        PressHold "W", 700
    End If
    Delay 300
    Press "D", 1, 200

    If needRepair Then
    	Press "K", 1, 500
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
    Press "J", 5, 500

    // 传送回行商刷怪点
    ReturnToFarmSpot
End Function

// ==================== 逃跑流程 ====================

// 战斗中逃跑并等待回到大地图
Function EscapeBattle()
    Press "J", 1, 100
    Do
        // 逃跑成功：检测到大地图标志即可（不需要检查菜单钉，逃跑后菜单通常是关闭的）
        If FindImage("大地图.bmp", 561, 45, 599, 51, 1) Then
            Exit Do
        End If

		// 战斗中遇到对话框，按J取消后继续循环等待回到大地图
        If FindImage("对话框.bmp", 1060, 717, 1087, 736, 0.98) Then
            KeyPress "J", 1
            Delay DELAY_NORMAL
        End If

        If FindImage("攻击.bmp", 212, 508, 327, 552, 1) Then 
            Press "A", 1, 100
            Press "K", 1, 200
            Press "A", 1, 100
            Press "K", 1, 1500
        End If
        Delay 500
    Loop
End Function

// ==================== 武器切换 ====================
// 本版本固定使用主炮，不切换武器

// 检测闪光（进入战斗时的闪光特效）
Function DetectFlash()
    Dim flashImg
    For Each flashImg In Array("闪光1.bmp", "闪光2.bmp", "闪光3.bmp", "闪光4.bmp", "闪光5.bmp", "闪光6.bmp", "闪光7.bmp", "闪光8.bmp", "闪光9.bmp", "闪光10.bmp")
        If FindImage(flashImg, 159, 40, 560, 496, 0.9) Then
            DetectFlash = True
            Exit Function
        End If
    Next
    DetectFlash = False
End Function

// ==================== 场景检测与分发 ====================

// 检测当前场景，返回：1=大地图, 2=战斗中, 3=菜单/对话, 4=战斗结算
Function DetectScene()
    // 战斗中（最高优先级）
    If FindImage("战斗中人物.bmp", 197, 609, 221, 626, 0.95) Then
        DetectScene = 2
        Exit Function
    End If

    // 战斗结算：有菜单钉（战斗结束后的结算界面，比大地图优先）
    If FindImage("菜单钉.bmp", 256, 506, 275, 524, 1) Then
        DetectScene = 4
        Exit Function
    End If

    // 大地图：使用统一检测函数
    If IsWorldMap() Then
        DetectScene = 1
        Exit Function
    End If

    // 其他情况：菜单打开、对话中、传送加载中等
    DetectScene = 3
End Function

// ==================== 诱敌流程 ====================

// 执行诱敌并检测闪光，有闪光则战斗，无闪光则逃跑
Function DoBait()
    // 诱敌菜单导航（K→S→K→W→W→K→K）
    Press "K", 2, 100
    Press "S", 1, 100
    Press "K", 1, 100
    Press "W", 2, 100
    Press "K", 2, 100
    Press "K", 1, 350
    Press "K", 1, 800

    // 循环检测闪光N次
    // 检测到闪光 = 稀有敌人，直接进入战斗（不逃跑）
    Dim i
    For i = 1 To 4
        If DetectFlash() Then 
            Exit Function
        End If
        Delay 50
    Next

    // 没检测到，逃跑
    EscapeBattle
End Function

// 处理战斗场景
Function HandleBattleScene()
    // 本版本固定使用主炮，不切换武器
    // 检测主炮弹药为0 → 逃跑回城补充
    If FindImage("炮弹0.bmp", 695, 430, 763, 480, 1) Or FindImage("弹药0.bmp", 213, 585, 355, 626, 0.95) Then
        needRepair = True
        EscapeBattle
        Exit Function
    End If
    // 弹药剩余7发以下：本场继续攻击，战斗结束后回城补甲（避免下场战斗弹药不足）
    If FindImage("弹药7.bmp", 702, 429, 743, 481, 1) Then
        needRepair = True
    End If

    // 检测装甲低(SP_LOW) → 逃跑回城补充
    If FindImage("攻击.bmp", 212, 508, 327, 552, 1) Then
        If FindImage("SP_LOW_1.bmp", 342, 582, 435, 606, 0.98) Or FindImage("SP_LOW_2.bmp", 342, 676, 437, 700, 0.98) Then
            needRepair = True
            EscapeBattle
            Exit Function
        End If
    End If

    // 普通攻击
    Press "K", 1, 0
End Function

// 处理大地图场景
Function HandleWorldScene()

    // 需要回城补充（弹药0或SP_LOW逃跑后）
    If needRepair Then 
    	needRepair = False
        DoRepairArmor
        Exit Function
    End If

    // 打开菜单开始诱敌
    KeyPress "H", 1
End Function

// 处理菜单/对话场景
Function HandleMenuScene()
    // 确定类
    // If FindAndPress("手指_红牛.bmp", 480, 500, 670, 610, 0.95, "K", DELAY_NORMAL) Then Exit Function
    // If FindAndPress("寻找怪.bmp", 280, 510, 790, 620, 0.95, "K", DELAY_NORMAL) Then Exit Function
    // If FindAndPress("手指_特技.bmp", 309, 584, 490, 664, 0.95, "K", DELAY_NORMAL) Then Exit Function
    // If FindAndPress("手指_诱敌.bmp", 200, 200, 620, 430, 0.95, "K", DELAY_NORMAL) Then Exit Function
    // If FindAndPress("诱敌.bmp", 227, 214, 451, 260, 0.95, "K", DELAY_NORMAL) Then Exit Function
    // If FindAndPress("去寻找怪.bmp", 400, 500, 760, 600, 0.95, "K", DELAY_NORMAL) Then Exit Function
    // 检测到特技指向（此页面可同时查看装甲量和血量，故在此统一判断状态）
    If FindImage("手指_特技.bmp", 309, 584, 490, 664, 0.95) 
        // 检测无装甲
        If FindImage("无装甲.bmp", 500, 679, 633, 712, 1) Then
            needRepair = True
            DoRepairArmor
            Exit Function
        End If

        // 检测装甲少
        If FindImage("装甲少.bmp", 490, 670, 600, 720, 0.95) Then
            DoRepairArmor
            Exit Function
        End If

        // 检测血量少
        If FindImage("血条少一点.bmp", 614, 737, 632, 745, 0.98) Then
            DoHeal
            Exit Function
        End If
        doBait
        Exit Function
    End If

    If FindAndPress("对话框.bmp", 1060, 717, 1087, 736, 0.98, "J", DELAY_NORMAL) Then Exit Function

    // 取消类
    If FindAndPress("战斗中过渡.bmp", 157, 540, 218, 563, 0.95, "J", DELAY_NORMAL) Then Exit Function

    // 方向键导航
     If FindAndPress("乘降.bmp", 325, 554, 459, 598, 0.95, "S", DELAY_SHORT) Then Exit Function
     If FindAndPress("包裹.bmp", 180, 555, 320, 600, 0.95, "D", DELAY_SHORT) Then Exit Function

End Function

// 处理战斗结算场景（战斗结束后的掉落/经验结算界面）
Function HandleBattleSettlement()
    // 结算界面通用确认/取消处理
    If FindAndPress("选是.bmp", 980, 400, 1070, 450, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("包裹满.bmp", 320, 540, 505, 586, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("仓满.bmp", 315, 580, 508, 635, 0.95, "J", DELAY_NORMAL) Then Exit Function
    If FindAndPress("选猎鹿犬.bmp", 780, 400, 950, 450, 0.95, "J", DELAY_NORMAL) Then Exit Function
    If FindAndPress("选猎鹿犬2.bmp", 760, 357, 916, 392, 0.95, "J", DELAY_NORMAL) Then Exit Function
    If FindAndPress("对话框.bmp", 1060, 717, 1087, 736, 0.98, "J", DELAY_NORMAL) Then Exit Function
End Function

// ==================== 主逻辑 ====================

// 主循环逻辑：每5ms执行一次，先检测场景，再分发到对应处理函数
Function MainLoop()
    Dim scene
    scene = DetectScene()

    Select Case scene
        Case 1
            HandleWorldScene
        Case 2
            HandleBattleScene
        Case 3
            HandleMenuScene
        Case 4
            HandleBattleSettlement
    End Select
End Function

// 统一传送回行商刷怪点（补装甲和入口共用）
Function ReturnToFarmSpot()
    // 传送回行商附近城镇
    Press "R", 1, 300
    Press "D", 2, 100
    Press "K", 1, 1000
    WaitForTeleport
    // 走到行商刷新点（根据实际位置调整）
    // TODO: 根据实际行商位置调整移动路径
End Function

// ==================== 入口 ====================
If Not IsWorldMap() And Not FindImage("战斗中人物.bmp", 197, 609, 221, 626, 0.95) Then
    ReturnToFarmSpot
End If
Do
    MainLoop
    Delay 5
Loop
