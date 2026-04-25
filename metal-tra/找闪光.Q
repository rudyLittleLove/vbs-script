// ==================== 常量配置 ====================
Const IMAGE_PATH = "D:\workspace\vbs-script\images\"
Const DELAY_SHORT = 10
Const DELAY_NORMAL = 20

// 纯找图，不按键，返回是否找到
Function FindImage(imgName, x1, y1, x2, y2, similarity)
    Dim intX, intY
    FindPic x1, y1, x2, y2, IMAGE_PATH & imgName, similarity, intX, intY
    FindImage = (intX > 0)
End Function

// 检测闪光（进入战斗时的闪光特效），返回检测到的图片名，未检测到返回空字符串
Function checkFlash()
    Dim flashImg
    For Each flashImg In Array("闪光1.bmp", "闪光2.bmp", "闪光3.bmp", "闪光4.bmp", "闪光5.bmp", "闪光6.bmp", "闪光7.bmp", "闪光8.bmp", "闪光9.bmp", "闪光10.bmp")
        If FindImage(flashImg, 148, 131, 616, 425, 0.9) Then
            checkFlash = flashImg
            Exit Function
        End If
    Next
    checkFlash = ""
End Function

Dim flashResult
Do
    flashResult = checkFlash()
    
    If flashResult <> "" Then
        TracePrint "检测到闪光：" & flashResult
    Else
        TracePrint "未检测到闪光"
    End If
    
    Delay 100
Loop
