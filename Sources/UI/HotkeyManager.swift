import Foundation
import HotKey
import Core
import Combine
import AppKit
import Input

class HotkeyManager {
    private var toggleWindowHotKey: HotKey?
    private var moveModeHotKey: HotKey?
    private var resizeModeHotKey: HotKey?
    private var sttToggleHotKey: HotKey?
    private weak var floatingWindowController: FloatingWindowController?
    private var cancellable: AnyCancellable?
    private let configManager: ConfigManager
    private let sttManager: STTManager
    private let inputManager: InputManager
    private var ocrCaptureHotKey: HotKey?
    private var ocrProcessHotKey: HotKey?
    private var batchToggleHotKey: HotKey?
    private var batchFinalizeHotKey: HotKey?
    private var ocrRegionHotKey: HotKey?
    
    init(floatingWindowController: FloatingWindowController, configManager: ConfigManager, sttManager: STTManager, inputManager: InputManager) {
        self.floatingWindowController = floatingWindowController
        self.configManager = configManager
        self.sttManager = sttManager
        self.inputManager = inputManager
        registerDefaultHotkeys()
        observeHotkeyChange()
        // 注册OCR相关热键
        ocrCaptureHotKey = HotKey(key: .h, modifiers: [.command, .option, .shift])
        ocrCaptureHotKey?.keyDownHandler = {
            print("热键触发: 全屏截图") // 断点日志
            OCRManager.shared.captureFullScreen()
        }
        // 注册批量模式相关热键
        batchToggleHotKey = HotKey(key: .k, modifiers: [.command, .option, .shift])
        batchToggleHotKey?.keyDownHandler = { [weak self] in
            print("热键触发: 切换批量模式") // 断点日志
            self?.sttManager.stopListening() // 可选：批量模式下暂停语音识别
            self?.configManager // 保证configManager可用
            self?.inputManager.toggleBatchMode()
            print("批量模式状态: \(self?.inputManager.isBatchMode ?? false ? "开启" : "关闭")") // 断点日志
        }
        batchFinalizeHotKey = HotKey(key: .l, modifiers: [.command, .option, .shift])
        batchFinalizeHotKey?.keyDownHandler = { [weak self] in
            print("热键触发: 批量提交") // 断点日志
            self?.inputManager.finalizeBatch()
            print("批量OCR结果已提交") // 断点日志
        }
        // 注册区域截图热键
        ocrRegionHotKey = HotKey(key: .r, modifiers: [.command, .option, .shift])
        ocrRegionHotKey?.keyDownHandler = {
            // 简化版：使用全屏截图后裁剪，实际应用中可集成ScreenCaptureKit或自定义UI选择区域
            let rect = CGRect(x: 100, y: 100, width: 200, height: 200) // 示例区域
            OCRManager.shared.captureRegion(rect)
        }
    }
    
    private func observeHotkeyChange() {
        cancellable = configManager.hotkeyPublisher.sink { [weak self] newHotkey in
            self?.registerToggleWindowHotkey(hotkeyString: newHotkey)
        }
    }
    
    private func registerDefaultHotkeys() {
        print("注册默认热键") // 断点日志
        // 注册初始热键
        registerToggleWindowHotkey(hotkeyString: configManager.hotkey)
        // 其它热键保持原样
        moveModeHotKey = HotKey(key: .m, modifiers: [.command, .control, .option])
        moveModeHotKey?.keyDownHandler = { [weak self] in
            print("热键触发: 移动模式") // 断点日志
        }
        resizeModeHotKey = HotKey(key: .r, modifiers: [.command, .control, .option])
        resizeModeHotKey?.keyDownHandler = { [weak self] in
            print("热键触发: 调整大小模式") // 断点日志
        }
        // 新增语音识别开关热键
        sttToggleHotKey = HotKey(key: .s, modifiers: [.command, .control, .option])
        sttToggleHotKey?.keyDownHandler = { [weak self] in
            print("热键触发: 语音识别开关") // 断点日志
            self?.sttManager.toggleListening()
        }
    }
    
    private func registerToggleWindowHotkey(hotkeyString: String) {
        // 注销旧热键
        toggleWindowHotKey = nil
        // 解析字符串，注册新热键
        if let (key, modifiers) = HotkeyManager.parseHotkey(hotkeyString) {
            toggleWindowHotKey = HotKey(key: key, modifiers: modifiers)
            toggleWindowHotKey?.keyDownHandler = { [weak self] in
                if let window = self?.floatingWindowController?.window {
                    if window.isVisible {
                        window.orderOut(nil)
                    } else {
                        window.orderFrontRegardless()
                    }
                }
            }
        }
    }
    
    // 支持解析字符串如 "⌘⇧A" 为 HotKey.Key 和 NSEvent.ModifierFlags
    static func parseHotkey(_ string: String) -> (Key, NSEvent.ModifierFlags)? {
        var modifiers: NSEvent.ModifierFlags = []
        var key: Key? = nil
        for char in string.lowercased() {
            switch char {
            case "⌘": modifiers.insert(.command)
            case "⌥": modifiers.insert(.option)
            case "⌃": modifiers.insert(.control)
            case "⇧": modifiers.insert(.shift)
            case "a": key = .a
            case "b": key = .b
            case "c": key = .c
            case "d": key = .d
            case "e": key = .e
            case "f": key = .f
            case "g": key = .g
            case "h": key = .h
            case "i": key = .i
            case "j": key = .j
            case "k": key = .k
            case "l": key = .l
            case "m": key = .m
            case "n": key = .n
            case "o": key = .o
            case "p": key = .p
            case "q": key = .q
            case "r": key = .r
            case "s": key = .s
            case "t": key = .t
            case "u": key = .u
            case "v": key = .v
            case "w": key = .w
            case "x": key = .x
            case "y": key = .y
            case "z": key = .z
            case "0": key = .zero
            case "1": key = .one
            case "2": key = .two
            case "3": key = .three
            case "4": key = .four
            case "5": key = .five
            case "6": key = .six
            case "7": key = .seven
            case "8": key = .eight
            case "9": key = .nine
            default: break
            }
        }
        if let key = key { return (key, modifiers) }
        return nil
    }
} 