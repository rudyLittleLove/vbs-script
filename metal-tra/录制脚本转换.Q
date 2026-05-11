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

    Press "R", 1, 137
    PressHold "D", 200
    Press "K", 1, 8000
    Press "W", 1, 1500
    PressHold "A", 352
    PressHold "S", 417
    PressHold "A", 296
    Press "E", 1, 50
    Press "K", 1, 200
    PressHold "A", 1000
    PressHold "W", 362
    Press "D", 1, 100
    Press "K", 10, 500
    Press "J", 3, 500
    PressHold "A", 200
    PressHold "S", 565
    Press "S", 1, 150
    PressHold "D", 600
    PressHold "W", 300
    Press "E", 1, 50
    Press "K", 1, 100