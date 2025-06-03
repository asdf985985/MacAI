import Foundation
import AppKit
import Combine
import HotKey

public class KeyboardShortcutManager {
    // MARK: - Properties
    
    /// 单例实例
    public static let shared = KeyboardShortcutManager()
    
    /// 快捷键事件发布者
    public let shortcutPublisher = PassthroughSubject<KeyboardShortcut, Never>()
    
    /// 快捷键事件订阅者
    public var publisher: AnyPublisher<KeyboardShortcut, Never> {
        shortcutPublisher.eraseToAnyPublisher()
    }
    
    /// 快捷键注册表
    private var shortcuts: [String: HotKey] = [:]
    
    /// 取消令牌集合
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    private init() {
        registerDefaultShortcuts()
        setupNotificationObservers()
    }
    
    // MARK: - Public Methods
    
    /// 注册快捷键
    public func registerShortcut(_ identifier: String, key: Key, modifiers: NSEvent.ModifierFlags) {
        let hotKey = HotKey(key: key, modifiers: modifiers)
        shortcuts[identifier] = hotKey
        
        hotKey.keyDownHandler = { [weak self] in
            self?.shortcutPublisher.send(KeyboardShortcut(identifier: identifier))
        }
    }
    
    /// 注销快捷键
    public func unregisterShortcut(_ identifier: String) {
        shortcuts.removeValue(forKey: identifier)
    }
    
    /// 获取快捷键
    public func getShortcut(_ identifier: String) -> HotKey? {
        return shortcuts[identifier]
    }
    
    /// 处理键盘事件
    public func handleKeyEvent(_ event: NSEvent) {
        let allHotKeys: [HotKey] = shortcuts.values.compactMap { $0 }
        if let hotKey = allHotKeys.first(where: {
            $0.keyCombo.carbonKeyCode == event.keyCode && $0.keyCombo.modifiers == event.modifierFlags
        }) {
            hotKey.keyDownHandler?()
        }
    }
    
    // MARK: - Private Methods
    
    private func setupNotificationObservers() {
        NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)
            .sink { [weak self] _ in
                self?.cleanup()
            }
            .store(in: &cancellables)
    }
    
    private func cleanup() {
        shortcuts.removeAll()
        cancellables.removeAll()
    }
    
    private func registerDefaultShortcuts() {
        // 滚动控制
        registerShortcut("scroll_up", key: .upArrow, modifiers: [.command])
        registerShortcut("scroll_down", key: .downArrow, modifiers: [.command])
        registerShortcut("page_up", key: .pageUp, modifiers: [.command])
        registerShortcut("page_down", key: .pageDown, modifiers: [.command])
        registerShortcut("scroll_to_top", key: .home, modifiers: [.command])
        registerShortcut("scroll_to_bottom", key: .end, modifiers: [.command])
        
        // 窗口大小控制
        registerShortcut("resize_window", key: .r, modifiers: [.command, .shift])
        registerShortcut("increase_opacity", key: .equal, modifiers: [.command, .shift])
        registerShortcut("decrease_opacity", key: .minus, modifiers: [.command, .shift])
        
        // 手势模式
        registerShortcut("activate_move_mode", key: .m, modifiers: [.command, .shift])
        registerShortcut("activate_resize_mode", key: .r, modifiers: [.command, .shift])
        
        // 调整大小方向
        registerShortcut("resize_top", key: .upArrow, modifiers: [.command, .shift])
        registerShortcut("resize_bottom", key: .downArrow, modifiers: [.command, .shift])
        registerShortcut("resize_left", key: .leftArrow, modifiers: [.command, .shift])
        registerShortcut("resize_right", key: .rightArrow, modifiers: [.command, .shift])
        registerShortcut("resize_top_left", key: .leftArrow, modifiers: [.command, .shift, .option])
        registerShortcut("resize_top_right", key: .rightArrow, modifiers: [.command, .shift, .option])
        registerShortcut("resize_bottom_left", key: .leftArrow, modifiers: [.command, .shift, .control])
        registerShortcut("resize_bottom_right", key: .rightArrow, modifiers: [.command, .shift, .control])
        
        // AI 建议视图控制
        registerShortcut("next_suggestion", key: .rightArrow, modifiers: [.command, .option])
        registerShortcut("previous_suggestion", key: .leftArrow, modifiers: [.command, .option])
        registerShortcut("copy_suggestion", key: .c, modifiers: [.command, .option])
        registerShortcut("dismiss_suggestion", key: .escape, modifiers: [])
    }
}

// MARK: - KeyboardShortcut

public struct KeyboardShortcut: Equatable {
    // MARK: - Properties
    
    /// 快捷键标识符
    public let identifier: String
    
    /// 描述
    public let description: String
    
    // MARK: - Initialization
    
    public init(
        identifier: String,
        description: String = ""
    ) {
        self.identifier = identifier
        self.description = description
    }
    
    // MARK: - Methods
    
    /// 检查是否匹配键盘事件
    public func matches(modifiers: NSEvent.ModifierFlags, keyCode: UInt16) -> Bool {
        return self.identifier == identifier
    }
    
    // MARK: - Equatable
    
    public static func == (lhs: KeyboardShortcut, rhs: KeyboardShortcut) -> Bool {
        return lhs.identifier == rhs.identifier
    }
} 