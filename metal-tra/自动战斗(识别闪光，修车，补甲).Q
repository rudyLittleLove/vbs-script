
// ==================== 常量配置 ====================
Const IMAGE_PATH = "D:\workspace\vbs-script\images\"
Const DELAY_SHORT = 10
Const DELAY_NORMAL = 20

// ==================== 全局状态变量 ====================
// 是否识别到闪光怪（战斗中有效，退出战斗后重置）
Dim hasFlashDetected
hasFlashDetected = False
// 是否处于战斗中（减少重复识别）
Dim inBattle
inBattle = False
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

// ==================== 补血 ====================

Function jiaxue()
    KeyPress "A", 1
    KeyPress "W", 1
    KeyPress "K", 1
    Delay 100
    KeyPress "S", 1
    Delay 100
    KeyPress "K", 1
    Delay 100
    KeyPress "S", 1
    Delay 100
    KeyPress "K", 1
    Delay 100
    KeyPress "K", 1
    Delay 100
    KeyPress "K", 1
    Delay 100
    KeyPress "K", 1
    Delay 300
    KeyPress "K", 1
    Delay 300
    KeyPress "K", 1
    Delay 300
    KeyPress "J", 4
End Function

// ==================== 补装甲流程 ====================

Function repair()
    // 1. 取消
    KeyPress "J", 3
    Delay 300
    
    If hasNotZj Then 
    	KeyPress "E", 1
    	Delay 100
    	KeyPress "K", 1
    	Delay 200
    End If
    
    // 2. 进入城镇
    KeyPress "W", 1
    Delay 1000
    // 3. 按键进入装甲片商铺
    // 向右移动（短按100ms）
    KeyDown "D", 1
    Delay 100
    KeyUp "D", 1
    // 向下移动（持续800ms）
    KeyDown "S", 1
    Delay 800
    KeyUp "S", 1
    // 向右移动（持续800ms）
    KeyDown "D", 1
    Delay 800
    KeyUp "D", 1
    // 向上移动（持续600ms）
    KeyDown "W", 1
    Delay 600
    KeyUp "W", 1
    Delay 100
    // 等待进入修理铺过度
    Delay 800
    // 对话让人让开（按K确定2次）
    KeyPress "K", 1
    Delay 500
    KeyPress "K", 1
    Delay 500
    // 向上移动（持续800ms）
    KeyDown "W", 1
    	If hasNotZj Then 
    		Delay 1400
    	Else 
    		Delay 800
    	End If
    KeyUp "W", 1
    Delay 300
    KeyPress "D", 1
    Delay 200
    	If hasNotZj Then 
    		KeyPress "K", 1
    		Delay 300
    		KeyPress "S", 1
    		Delay 300
    		KeyPress "K", 1
    		Delay 300
    		KeyPress "K", 1
    		Delay 300
    		KeyPress "K", 1
    		Delay 300
    		KeyPress "J", 1
    		Delay 300
    		KeyPress "J", 1
    		Delay 300
    		KeyPress "J", 1
    		Delay 300
    		KeyPress "E", 1
    		Delay 300
    		KeyPress "K", 1
    		Delay 300
    		KeyDown "S", 1
    		Delay 500
    		KeyUp "S", 1
    		Delay 300
    		KeyPress "D", 1
    		Delay 100
    		hasNotZj = false
    	End If
    
    // 对话加装甲（按K确定5次）
    KeyPress "K", 1
    Delay 300
    KeyPress "K", 1
    Delay 500
    KeyPress "K", 1
    Delay 500
    KeyPress "K", 1
    Delay 500
    KeyPress "K", 1
    Delay 500
    KeyPress "R", 1
    Delay 300
    // 向右选择按2次
    KeyPress "D", 2
    Delay 200
    // 按K确定
    KeyPress "K", 1
    Delay 300
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
        KeyPress "W", 1
        Delay 100
        hasWeaponSwitched = True
        Exit Function
    End If
    
    // 无闪光怪且当前是主炮 → 切换副炮
    If Not hasFlashDetected And FindImage("主炮.bmp", 250, 445, 305, 470, 0.9) Then
        KeyPress "W", 1
        Delay 100
        KeyPress "S", 1
        Delay 100
        Exit Function
    End If
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

// 检测是否回到大地图（识别大地图战车 = 战斗真正结束）
Function isBackToMap()
    // 识别没有菜单栏，就是大地图
    If Not FindImage("菜单栏.bmp", 508, 742, 780, 771, 1) Then
       isBackToMap = True
       KeyPress "H", 1
       Exit Function	
    End If
    Dim mapImg
    For Each mapImg In Array("战车上.bmp", "战车右.bmp", "战车左.bmp", "战车上3.bmp", "战车下.bmp", "战车上2.bmp", "战车下2.bmp", "战车左2.bmp", "战车右2.bmp")
        If FindImage(mapImg, 535, 369, 587, 421, 0.9) Then
            isBackToMap = True
            Exit Function
        End If
    Next
    isBackToMap = False
End Function

// 检测闪光（进入战斗时的闪光特效）
Function checkFlash()
    Dim flashImg
    For Each flashImg In Array("闪光1.bmp", "闪光2.bmp", "闪光3.bmp", "闪光4.bmp", "闪光5.bmp", "闪光6.bmp")
        If FindImage(flashImg, 148, 131, 616, 425, 0.9) Then
            checkFlash = True
            Exit Function
        End If
    Next
    checkFlash = False
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
    
    // ====== 状态1：战斗中 ======
    If inBattle Then
        // 未识别到闪光时，持续识别（动态效果需要多次尝试）
        If Not hasFlashDetected Then
            If checkFlash() Then hasFlashDetected = True
        End If
        
        // 根据闪光状态切换武器
        switchWeaponInBattle
        
        // 检测到回到大地图 = 真正结束战斗
        If isBackToMap() Then
            hasFlashDetected = False
            hasWeaponSwitched = False
            inBattle = False
            Exit Function
        End If
        
        // 按K攻击（每轮循环都执行）
        KeyPress "K", 1
        Delay 50
        
        Exit Function
    End If
    
    // ====== 状态2：非战斗状态 ======
    
    // 检测是否进入战斗
    If checkInBattle() Then
        inBattle = True
        hasWeaponSwitched = False  // 新战斗，重置切换状态
        // 首次进入战斗，尝试识别闪光
        If checkFlash() Then hasFlashDetected = True
        // 切换武器
        switchWeaponInBattle
        // 按K攻击
        KeyPress "K", 1
        Delay 100
        Exit Function
    End If
    
    // ====== 正常打怪流程 ======
     // 0. 判断无装甲，进入修车流程
    If FindImage("无装甲.bmp", 500, 679, 633, 712, 0.95) Then
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
    
    // 战斗结束掉落物处理
    If FindAndPress("不搭载.bmp", 780, 450, 950, 500, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("选是.bmp", 980, 400, 1070, 450, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("包裹满.bmp", 320, 540, 505, 586, 0.95, "K", DELAY_NORMAL) Then Exit Function
    
    // 确定诱敌
    If FindAndPress("行商杀手.bmp", 220, 272, 430, 318, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("影像蝙蝠.bmp", 220, 315, 435, 368, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("沙地蚁.bmp", 225, 275, 389, 315, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("陨石蜗牛.bmp", 225, 275, 430, 515, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("爆破龟.bmp", 210, 350, 430, 445, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("杀人阿米巴.bmp", 225, 75, 468, 167, 0.95, "K", DELAY_NORMAL) Then Exit Function
    
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
