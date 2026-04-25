// ==================== 常量配置 ====================
Const IMAGE_PATH = "D:\workspace\vbs-script\images\"
Const DELAY_SHORT = 10
Const DELAY_NORMAL = 20
// 倍速：1=正常, 2=2倍速, 5=5倍速, 10=10倍速
Const SPEED = 4

// ==================== 全局状态变量 ====================
Dim hasFlashDetected
hasFlashDetected = False
// 0=大地图, 1=战斗中, 2=识别闪光中, 3=逃跑中
Dim currentState
currentState = 0

// ==================== 辅助函数 ====================

// 纯找图，不按键，返回是否找到
Function FindImage(imgName, x1, y1, x2, y2, similarity)
    Dim intX, intY
    FindPic x1, y1, x2, y2, IMAGE_PATH & imgName, similarity, intX, intY
    FindImage = (intX > 0)
End Function

// 点击按键count次，每次延迟delayMs（延迟会除以倍速）
Function Press(key, count, delayMs)
    Dim i
    If count < 1 Then count = 1
    If delayMs < 0 Then delayMs = 0
    For i = 1 To count
        KeyPress key, 1
        If delayMs > 0 Then Delay delayMs / SPEED
    Next
End Function

// 检测当前是否在战斗中
Function isInBattle()
    Dim battleImg
    For Each battleImg In Array("战斗中战车.bmp", "战斗中战车2.bmp", "战斗中战车3.bmp")
        If FindImage(battleImg, 900, 100, 1300, 768, 0.9) Then
            isInBattle = True
            Exit Function
        End If
    Next
    isInBattle = False
End Function

// 检测是否在大地图
Function isOnMap()
    Dim mapImg
    For Each mapImg In Array("战车上.bmp", "战车右.bmp", "战车左.bmp", "战车上3.bmp", "战车下.bmp", "战车上2.bmp", "战车下2.bmp", "战车左2.bmp", "战车右2.bmp")
        If FindImage(mapImg, 609, 368, 673, 422, 0.9) Then
            isOnMap = True
            Exit Function
        End If
    Next
    isOnMap = False
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

// ==================== 诱敌流程 ====================
Function doBait()
    Press "H", 1, 40
    Press "K", 2, 40
    Press "S", 1, 40
    Press "K", 1, 40
    Press "W", 1, 40
    Press "K", 2, 350
    Press "K", 1, 1500
    Press "K", 1, 40
End Function

// ==================== 主逻辑 ====================

Function run()
    // 检测到闪光，退出脚本
    If hasFlashDetected Then 
    	KeyDown "Ctrl", 1
		KeyDown "Alt", 1
		KeyDown "3", 1
		Delay 300
		KeyUp "Ctrl", 1
		KeyUp "Alt", 1
		KeyUp "3", 1

        TracePrint "检测到闪光怪，退出脚本！"
        ExitScript
    End If

    // 状态0：大地图 → 执行诱敌
    If currentState = 0 Then
        If isOnMap() Then
            doBait
            currentState = 1
        End If
        Exit Function
    End If

    // 状态1：刚进入战斗 → 切到识别状态
    If currentState = 1 Then
        If isInBattle Then
            currentState = 2
        Else
            // 战斗已结束，回到大地图
            currentState = 0
        End If
        Exit Function
    End If

    // 状态3：逃跑中 → 检测是否回到大地图
    If currentState = 3 Then
        If isOnMap() Then
            // 逃跑成功，回到大地图
            currentState = 0
        ElseIf isInBattle Then
            // 逃跑失败，仍在战斗，继续逃跑
            TracePrint "逃跑失败，继续逃跑"
            doEscape
        End If
        Exit Function
    End If

    // 状态2：识别闪光中 → 持续检测1秒
    If currentState = 2 Then
        If Not isInBattle Then
            currentState = 0
            Exit Function
        End If

        Dim hasFlash
        hasFlash = False
        Dim i
        For i = 1 To 10
            If checkFlash() Then
                hasFlash = True
                Exit For
            End If
            Delay 15
        Next

        If hasFlash Then
            hasFlashDetected = True
        Else
            TracePrint "未检测到闪光，执行逃跑"
            doEscape
            currentState = 3
        End If
        Exit Function
    End If
End Function

// ==================== 入口 ====================
Do
    run
    Delay 5
Loop
