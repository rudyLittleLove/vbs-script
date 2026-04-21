
// ==================== 常量配置 ====================
Const IMAGE_PATH = "E:\Games\重装机兵\images\"
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

// 批量找图，任一找到则按键并返回 true（当前未使用）
// Function FindAnyAndPress(imgList, x1, y1, x2, y2, similarity, key)
//     Dim i, intX, intY
//     For i = 0 To UBound(imgList)
//         FindPic x1, y1, x2, y2, IMAGE_PATH & imgList(i), similarity, intX, intY
//         If intX > 0 Then
//             KeyPress key, 1
//             Delay DELAY_NORMAL
//             FindAnyAndPress = True
//             Exit Function
//         End If
//     Next
//     FindAnyAndPress = False
// End Function

// ==================== 修理流程 ====================

Function repair()
    // 1. 取消
    KeyPress "J", 3
    Delay 300
    // 2. 进入城镇
    KeyPress "W", 1
    // 等待进入城镇过度
    Delay 1000
    // 3. 按键进入修理铺
    // 向右移动（短按100ms）
    KeyDown "D", 1
    Delay 100
    KeyUp "D", 1
    // 向下移动（持续700ms）
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
    // 对话让人让开
    // 按K确定（按2次，每次等待300ms）
    KeyPress "K", 1
    Delay 500
    KeyPress "K", 1
    Delay 500
    // 向上移动（持续400ms）
    KeyDown "W", 1
    Delay 800
    KeyUp "W", 1
    Delay 300
    KeyPress "D", 1
    Delay 200
    // 对话加装甲
    // 按K确定（按5次，每次等待300ms）
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
    // 按K确定（等待300ms）
    KeyPress "K", 1
    Delay 300
    Exit Function
End Function

// ==================== 主逻辑 ====================

Function run()

    // 0. 判断装甲少，进入修理流程
    If FindAndPress("装甲少.bmp",      490, 670, 600, 720, 0.95, "K", DELAY_NORMAL) Then
        repair
        Exit Function
    End If

    // 1. 按确定键（多张图在不同区域分别查找）
    If FindAndPress("爆破龟.bmp",      210, 350, 430, 445, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("手指_红牛.bmp",   480, 500, 670, 610, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("寻找怪.bmp",      280, 510, 790, 620, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("手指_特技.bmp",   309, 584, 490, 664, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("手指_诱敌.bmp",   200, 200, 620, 430, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("去寻找怪.bmp", 400, 500, 760, 600, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("行商杀手.bmp", 220, 272, 430, 318, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("影像蝙蝠.bmp", 220, 315, 435, 368, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("沙地蚁.bmp", 225, 275, 389, 315, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("不搭载.bmp", 780, 450, 950, 500, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("选是.bmp", 980, 400, 1070, 450, 0.95, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("包裹满.bmp",    320, 540, 505, 586, 0.95, "K", DELAY_NORMAL) Then Exit Function
    
    // 3. 按下键
    If FindAndPress("手指_猎物气息.bmp", 200, 145, 620, 230, 0.95, "S", DELAY_SHORT) Then Exit Function
    If FindAndPress("选猎鹿犬.bmp", 780, 400, 950, 450, 0.95, "S", DELAY_SHORT) Then Exit Function
    
    // 4. 按上键
    If FindAndPress("诱饵.bmp", 150, 500, 1200, 780, 1.0, "W", DELAY_SHORT) Then Exit Function
    
    // 5. 战斗确认
    If FindAndPress("战斗中战车.bmp", 900, 100, 1300, 768, 0.9, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("战斗中战车2.bmp", 900, 100, 1300, 768, 0.9, "K", DELAY_NORMAL) Then Exit Function
    If FindAndPress("战斗中战车3.bmp", 900, 100, 1300, 768, 0.9, "K", DELAY_NORMAL) Then Exit Function
    
    
    // 2. 大地图中打开菜单
    If FindAndPress("战车上.bmp", 620, 370, 670, 430, 0.9, "H", DELAY_NORMAL) Then Exit Function
    If FindAndPress("战车右.bmp", 610, 370, 670, 430, 0.9, "H", DELAY_NORMAL) Then Exit Function
    If FindAndPress("战车左.bmp", 610, 370, 670, 430, 0.9, "H", DELAY_NORMAL) Then Exit Function
    If FindAndPress("战车上3.bmp",   620, 370, 670, 430, 0.9, "H", DELAY_NORMAL) Then Exit Function
    If FindAndPress("战车下.bmp",   620, 370, 670, 430, 0.9, "H", DELAY_NORMAL) Then Exit Function
    If FindAndPress("战车上2.bmp",  620, 370, 670, 430, 0.9, "H", DELAY_NORMAL) Then Exit Function
    If FindAndPress("战车下2.bmp", 620, 370, 670, 430, 0.95, "H", DELAY_NORMAL) Then Exit Function
    If FindAndPress("战车左2.bmp", 620, 380, 660, 415, 0.95, "H", DELAY_NORMAL) Then Exit Function
    If FindAndPress("战车右2.bmp",  620, 380, 655, 415, 0.95, "H", DELAY_NORMAL) Then Exit Function
    
End Function

// ==================== 入口 ====================
Do
    If FindAndPress("闪光1.bmp", 148, 131, 616, 425, 0.9, "J", 0) Then Exit Do
    If FindAndPress("闪光2.bmp", 148, 131, 616, 425, 0.9, "J", 0) Then Exit Do
    If FindAndPress("闪光3.bmp", 148, 131, 616, 425, 0.9, "J", 0) Then Exit Do
    If FindAndPress("闪光4.bmp", 148, 131, 616, 425, 0.9, "J", 0) Then Exit Do
    If FindAndPress("闪光5.bmp", 148, 131, 616, 425, 0.9, "J", 0) Then Exit Do
    If FindAndPress("闪光6.bmp", 148, 131, 616, 425, 0.9, "J", 0) Then Exit Do
    run 
    Delay 5
Loop
