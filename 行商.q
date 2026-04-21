// ==================== 常量配置 ====================
Const IMAGE_PATH = "E:\Games\重装机兵\images\"
Const DELAY_SHORT = 5
Const DELAY_NORMAL = 10

// ==================== 全局状态变量 ====================
Dim hasFlashDetected: hasFlashDetected = False
Dim inBattle: inBattle = False
Dim hasWeaponSwitched: hasWeaponSwitched = False

// ==================== 通用按键函数 ====================

// 通用按键：支持循环次数和间隔配置
// key: 按键名, times: 循环次数, interval: 每次间隔(默认100ms)
Sub Press(key, times, interval)
    If IsEmpty(interval) Then interval = 100
    Dim i
    For i = 1 To times
        KeyPress key, 1
        If i < times Then Delay interval
    Next
End Sub

// 长按：按下指定时长后释放
Sub Hold(key, ms)
    KeyDown key, 1
    Delay ms
    KeyUp key, 1
End Sub

// ==================== 找图辅助函数 ====================

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

// 批量找图，任意一张找到即返回 true
Function FindAnyImage(imgArray, x1, y1, x2, y2, similarity)
    Dim img
    For Each img In imgArray
        If FindImage(img, x1, y1, x2, y2, similarity) Then
            FindAnyImage = True
            Exit Function
        End If
    Next
    FindAnyImage = False
End Function

// 批量找图按键，按顺序查找，找到即按键并返回 true
Function FindAnyAndPress(imgArray, x1, y1, x2, y2, similarity, key, delayMs)
    Dim img
    For Each img In imgArray
        If FindAndPress(img, x1, y1, x2, y2, similarity, key, delayMs) Then
            FindAnyAndPress = True
            Exit Function
        End If
    Next
    FindAnyAndPress = False
End Function

// ==================== 补血 ====================
Function jiaxue()
    // 打开道具菜单
    Press "A", 1, 0
    Press "W", 1, 0
    Press "K", 1, 100
    // 选道具并确认3次
    Dim i
    For i = 1 To 3
        Press "S", 1, 100
        Press "K", 1, 100
    Next
    // 连续确认4次
    Press "K", 4, 100
    // 最终确认3次（间隔稍长）
    Press "K", 3, 300
    // 退出
    Press "J", 4, 0
End Function

// ==================== 补装甲流程 ====================
Function repair()
    // 1. 取消
    Press "J", 3, 0
    Delay 300
    // 2. 进入城镇
    Press "W", 1, 1000
    // 3. 移动到修理铺
    Hold "D", 100
    Hold "S", 800
    Hold "D", 800
    Hold "W", 600
    Delay 900
    // 对话让人让开
    Press "K", 2, 500
    // 向上移动到柜台
    Hold "W", 800
    Delay 300
    Press "D", 1, 200
    // 对话加装甲（按K确定5次）
    Press "K", 5, 500
    Press "R", 1, 300
    // 向右选择按2次，确定
    Press "D", 2, 200
    Press "K", 1, 300
End Function

// ==================== 武器切换 ====================

// 检测是否处于攻击中（未显示武器 = 攻击动画中）
Function isAttacking()
    isAttacking = Not FindImage("主炮.bmp", 245, 440, 305, 475, 0.9) And Not FindImage("副炮.bmp", 245, 440, 305, 475, 0.9)
End Function

// 战斗中根据闪光状态切换武器（有闪光只切换一次）
Function switchWeaponInBattle()
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

Function checkInBattle()
    checkInBattle = FindAnyImage(Array("战斗中战车.bmp", "战斗中战车2.bmp", "战斗中战车3.bmp"), 900, 100, 1300, 768, 0.9)
End Function

Function isBackToMap()
    isBackToMap = FindAnyImage(Array("战车上.bmp", "战车右.bmp", "战车左.bmp", "战车上3.bmp", "战车下.bmp", "战车上2.bmp", "战车下2.bmp", "战车左2.bmp", "战车右2.bmp"), 600, 350, 680, 450, 0.9)
End Function

Function checkFlash()
    checkFlash = FindAnyImage(Array("闪光1.bmp", "闪光2.bmp", "闪光3.bmp", "闪光4.bmp", "闪光5.bmp", "闪光6.bmp"), 148, 131, 616, 425, 0.9)
End Function

// ==================== 主逻辑 ====================

Function run()
    
    // ====== 掉落物处理（最优先）======
    If FindImage("选猎鹿犬.bmp", 780, 400, 950, 450, 0.95) Then
        Press "S", 1, DELAY_SHORT
        Exit Function
    End If
    
    // ====== 状态1：战斗中 ======
    If inBattle Then
        If Not hasFlashDetected Then
            If checkFlash() Then hasFlashDetected = True
        End If
        
        switchWeaponInBattle
        Press "K", 1, 100
        
        If isBackToMap() Then
            hasFlashDetected = False
            hasWeaponSwitched = False
            inBattle = False
        End If
        Exit Function
    End If
    
    // ====== 状态2：非战斗状态 ======
    
    // 检测是否进入战斗
    If checkInBattle() Then
        inBattle = True
        hasWeaponSwitched = False
        If checkFlash() Then hasFlashDetected = True
        switchWeaponInBattle
        Press "K", 1, 100
        Exit Function
    End If
    
    // ====== 正常打怪流程 ======
    
    // 0. 判断装甲少/血量少
    If FindImage("装甲少.bmp", 490, 670, 600, 720, 0.95) Then
        repair
        Exit Function
    End If

    If FindImage("血量少.bmp", 495, 700, 600, 750, 0.95) Then
        jiaxue
        Exit Function
    End If

    // 1. 按确定键
    If FindAndPress("爆破龟.bmp", 210, 350, 430, 445, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("手指_红牛.bmp", 480, 500, 670, 610, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("寻找怪.bmp", 280, 510, 790, 620, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("手指_特技.bmp", 309, 584, 490, 664, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("手指_诱敌.bmp", 200, 200, 620, 430, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("去寻找怪.bmp", 400, 500, 760, 600, 0.95, "K", DELAY_NORMAL) Then Exit Function
    
    // 战斗结束掉落物处理
    If FindAndPress("不搭载.bmp", 780, 450, 950, 500, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("选是.bmp", 980, 400, 1070, 450, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("包裹满.bmp", 320, 540, 505, 586, 0.95, "K", DELAY_NORMAL) Then Exit Function
    
    // 2. 确定诱敌目标
    If FindAndPress("行商杀手.bmp", 220, 272, 430, 318, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("影像蝙蝠.bmp", 220, 315, 435, 368, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("沙地蚁.bmp", 225, 275, 389, 315, 0.95, "K", DELAY_NORMAL) Then Exit Function
    
    // 2. 方向键找图
    If FindAndPress("手指_猎物气息.bmp", 200, 145, 620, 230, 0.95, "S", DELAY_SHORT) Then Exit Function
    If FindAndPress("乘降.bmp", 325, 554, 459, 598, 0.95, "S", DELAY_SHORT) Then Exit Function
    If FindAndPress("诱饵.bmp", 150, 500, 1200, 780, 1.0, "W", DELAY_SHORT) Then Exit Function
    If FindAndPress("包裹.bmp", 180, 555, 320, 600, 0.95, "D", DELAY_SHORT) Then Exit Function
    
    // 3. 大地图中打开菜单（9张战车图合并）
    If FindAnyAndPress(Array("战车上.bmp", "战车右.bmp", "战车左.bmp", "战车上3.bmp", "战车下.bmp", "战车上2.bmp", "战车下2.bmp", "战车左2.bmp", "战车右2.bmp"), 610, 370, 670, 430, 0.9, "H", DELAY_NORMAL) Then Exit Function
    
End Function

// ==================== 入口 ====================
Do
    run
    Delay 5
Loop
