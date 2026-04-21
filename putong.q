

// ==================== 常量配置 ====================
Const IMAGE_PATH = "D:\games\metal max\images\"
Const DELAY_SHORT = 5
Const DELAY_NORMAL = 10

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

// ==================== 战斗状态检测 ====================

// 检测是否处于战斗中
Function checkInBattle()
    Dim battleImg
    For Each battleImg In Array("战斗中战车.bmp", "战斗中战车2.bmp", "战斗中战车3.bmp")
        If FindImage(battleImg, 900, 100, 1300, 768, 0.9) Then
            checkInBattle = True
            Exit Function
        End If
    Next
    checkInBattle = False
End Function

// ==================== 主逻辑 ====================

Function run()
    
    // ====== 掉落物处理（最优先）======
    // 识别到放仓库选项，按S切换到"不要放"
    If FindImage("选猎鹿犬.bmp", 780, 400, 950, 450, 0.95) Then
        KeyPress "S", 1
        Delay DELAY_SHORT
        Exit Function
    End If
    
	If checkInBattle Then 
        KeyPress 'K', 1
        Delay delayMs
        Exit Function
	End If

    // 1. 按确定键（多张图在不同区域分别查找）
    If FindAndPress("爆破龟.bmp", 210, 350, 430, 445, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("手指_红牛.bmp", 480, 500, 670, 610, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("寻找怪.bmp", 280, 510, 790, 620, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("手指_特技.bmp", 309, 584, 490, 664, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("手指_诱敌.bmp", 200, 200, 620, 430, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("去寻找怪.bmp", 400, 500, 760, 600, 0.95, "K", DELAY_NORMAL) Then Exit Function
    
    // 取消
    If FindAndPress("仓满.bmp", 315, 580, 508, 635, 0.95, "J", DELAY_NORMAL) Then Exit Function
    
    // 战斗结束掉落物处理
    If FindAndPress("不搭载.bmp", 780, 450, 950, 500, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("选是.bmp", 980, 400, 1070, 450, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("包裹满.bmp", 320, 540, 505, 586, 0.95, "K", DELAY_NORMAL) Then Exit Function
    
    // 确定诱敌
    If FindAndPress("行商杀手.bmp", 220, 272, 430, 318, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("影像蝙蝠.bmp", 220, 315, 435, 368, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("沙地蚁.bmp", 225, 275, 389, 315, 0.95, "K", DELAY_NORMAL) Then Exit Function
    
    // 3. 按下键
    If FindAndPress("手指_猎物气息.bmp", 200, 145, 620, 230, 0.95, "S", DELAY_SHORT) Then Exit Function
    If FindAndPress("乘降.bmp", 325, 554, 459, 598, 0.95, "S", DELAY_SHORT) Then Exit Function
    
    // 4. 按上键
    If FindAndPress("诱饵.bmp", 150, 500, 1200, 780, 1.0, "W", DELAY_SHORT) Then Exit Function

    // 4. 按右键
    If FindAndPress("包裹.bmp", 180, 555, 320, 600, 0.95, "D", DELAY_SHORT) Then Exit Function
    
    // 2. 大地图中打开菜单
    If FindAndPress("战车上.bmp", 620, 370, 670, 430, 0.9, "H", DELAY_NORMAL) Then Exit Function
    If FindAndPress("战车右.bmp", 610, 370, 670, 430, 0.9, "H", DELAY_NORMAL) Then Exit Function
    If FindAndPress("战车左.bmp", 610, 370, 670, 430, 0.9, "H", DELAY_NORMAL) Then Exit Function
    If FindAndPress("战车上3.bmp", 620, 370, 670, 430, 0.9, "H", DELAY_NORMAL) Then Exit Function
    If FindAndPress("战车下.bmp", 620, 370, 670, 430, 0.9, "H", DELAY_NORMAL) Then Exit Function
    If FindAndPress("战车上2.bmp", 620, 370, 670, 430, 0.9, "H", DELAY_NORMAL) Then Exit Function
    If FindAndPress("战车下2.bmp", 620, 370, 670, 430, 0.95, "H", DELAY_NORMAL) Then Exit Function
    If FindAndPress("战车左2.bmp", 620, 380, 660, 415, 0.95, "H", DELAY_NORMAL) Then Exit Function
    If FindAndPress("战车右2.bmp", 620, 380, 655, 415, 0.95, "H", DELAY_NORMAL) Then Exit Function
    
End Function

// ==================== 入口 ====================
Do
    run
    Delay 5
Loop
