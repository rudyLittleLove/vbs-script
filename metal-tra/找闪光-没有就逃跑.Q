// ==================== 常量配置 ====================
Const IMAGE_PATH = "D:\workspace\vbs-script\images\"
Const DELAY_SHORT = 10
Const DELAY_NORMAL = 20

// ==================== 辅助函数 ====================

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

// 战斗中根据闪光状态切换武器（有闪光只切换一次）
Function switchWeaponInBattle(flash)
    // 有闪光怪且当前是副炮 → 切换主炮（只切换一次）
    If flash And FindImage("副炮.bmp", 245, 440, 305, 475, 0.9) Then
        Press "W", 1, 100
        hasWeaponSwitched = True
        Exit Function
    End If
    
    // 无闪光怪且当前是主炮 → 切换副炮
    If Not flash And FindImage("主炮.bmp", 250, 445, 305, 470, 0.9) Then
        Press "W", 1, 100
        Press "S", 1, 100
        Exit Function
    End If
End Function

// ==================== 逃跑流程 ====================
// 持续尝试逃跑直到离开战斗（检测到大世界）
Function doEscape()
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
            Press "K", 1, 2000
        End If
        Delay 500
    Loop
End Function

// 检测到闪光，停止运行
Function stopRun() 
    KeyDown "Ctrl", 1
    KeyDown "Alt", 1
    KeyDown "3", 1
    Delay 300
    KeyUp "Ctrl", 1
    KeyUp "Alt", 1
    KeyUp "3", 1

    TracePrint "检测到闪光怪，退出脚本！"
    KeyPress "F12", 1
    ExitScript
End Function

// ==================== 诱敌流程 ====================
Function doBait()
    Press "K", 2, 40
    Press "S", 1, 40
    Press "K", 1, 40
    Press "S", 2, 40 // 切换上下选怪-------------------------------------------------------------------------------
    Press "K", 2, 350
    Press "K", 1, 800
    For i = 1 To 20
        If checkFlash() Then
            // 有闪光，切换武器
            // switchWeaponInBattle(True)
            // 有闪光，停止运行
            stopRun
            Exit For
        End If
        Delay 15
    Next
    Press "K", 1, 40
    // 无闪光，切换武器
    // switchWeaponInBattle(False)
    // 无闪光，逃跑
    doEscape
End Function

// ==================== 主逻辑 ====================

Function run()
    If FindImage("手指_特技.bmp", 309, 584, 490, 664, 0.95) 
        doBait
        Exit Function
    End If

    If FindImage("大地图.bmp", 561, 45, 599, 51, 1) Then
        Press "h", 1, 100
        Exit Function
	End If
End Function

// ==================== 入口 ====================
Do
    run
    Delay 5
Loop
