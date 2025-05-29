import Foundation
import HotKey
import Core

class HotkeyManager {
    private var toggleWindowHotKey: HotKey?
    private var moveModeHotKey: HotKey?
    private var resizeModeHotKey: HotKey?
    private weak var floatingWindowController: FloatingWindowController?
    
    init(floatingWindowController: FloatingWindowController) {
        self.floatingWindowController = floatingWindowController
        registerDefaultHotkeys()
    }
    
    private func registerDefaultHotkeys() {
        // Command+Control+Option+F
        toggleWindowHotKey = HotKey(key: .f, modifiers: [.command, .control, .option])
        toggleWindowHotKey?.keyDownHandler = { [weak self] in
            print("[Hotkey] Command+Control+Option+F 被触发，切换浮窗显示/隐藏")
            if let window = self?.floatingWindowController?.window {
                if window.isVisible {
                    window.orderOut(nil)
                } else {
                    window.orderFrontRegardless()
                }
            }
        }
        
        // Command+Control+Option+M
        moveModeHotKey = HotKey(key: .m, modifiers: [.command, .control, .option])
        moveModeHotKey?.keyDownHandler = { [weak self] in
            print("[Hotkey] Command+Control+Option+M 被触发，进入移动模式")
            self?.floatingWindowController?.enterMoveMode()
        }
        
        // Command+Control+Option+R
        resizeModeHotKey = HotKey(key: .r, modifiers: [.command, .control, .option])
        resizeModeHotKey?.keyDownHandler = { [weak self] in
            print("[Hotkey] Command+Control+Option+R 被触发，进入调整大小模式")
            self?.floatingWindowController?.enterResizeMode()
        }
    }
} 