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
    
    init(floatingWindowController: FloatingWindowController, configManager: ConfigManager, sttManager: STTManager) {
        self.floatingWindowController = floatingWindowController
        self.configManager = configManager
        self.sttManager = sttManager
        registerDefaultHotkeys()
        observeHotkeyChange()
    }
    
    private func observeHotkeyChange() {
        cancellable = configManager.hotkeyPublisher.sink { [weak self] newHotkey in
            self?.registerToggleWindowHotkey(hotkeyString: newHotkey)
        }
    }
    
    private func registerDefaultHotkeys() {
        // 注册初始热键
        registerToggleWindowHotkey(hotkeyString: configManager.hotkey)
        // 其它热键保持原样
        moveModeHotKey = HotKey(key: .m, modifiers: [.command, .control, .option])
        moveModeHotKey?.keyDownHandler = { [weak self] in
            self?.floatingWindowController?.enterMoveMode()
        }
        resizeModeHotKey = HotKey(key: .r, modifiers: [.command, .control, .option])
        resizeModeHotKey?.keyDownHandler = { [weak self] in
            self?.floatingWindowController?.enterResizeMode()
        }
        // 新增语音识别开关热键
        sttToggleHotKey = HotKey(key: .s, modifiers: [.command, .control, .option])
        sttToggleHotKey?.keyDownHandler = { [weak self] in
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