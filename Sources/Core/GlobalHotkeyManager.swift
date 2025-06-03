import Foundation
import AppKit
import Combine
import Carbon

public class GlobalHotkeyManager {
    public static let shared = GlobalHotkeyManager()
    
    private var eventHandler: EventHandlerRef?
    private var hotkeys: [HotkeyAction: EventHotKeyRef] = [:]
    private let notificationCenter = NotificationCenter.default
    
    private init() {
        setupEventHandler()
        registerDefaultHotkeys()
    }
    
    private func setupEventHandler() {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: OSType(kEventHotKeyPressed)
        )
        
        let status = InstallEventHandler(
            GetApplicationEventTarget(),
            { (_, event, _) -> OSStatus in
                GlobalHotkeyManager.shared.handleHotkey(event!)
                return noErr
            },
            1,
            &eventType,
            nil,
            &eventHandler
        )
        
        if status != noErr {
            print("Failed to install event handler: \(status)")
        }
    }
    
    private func handleHotkey(_ event: EventRef) -> OSStatus {
        var hotKeyID = EventHotKeyID()
        let status = GetEventParameter(
            event,
            EventParamName(kEventParamDirectObject),
            EventParamType(typeEventHotKeyID),
            nil,
            MemoryLayout<EventHotKeyID>.size,
            nil,
            &hotKeyID
        )
        
        if status == noErr {
            let action = HotkeyAction(rawValue: String(hotKeyID.id)) ?? .scrollUp
            notificationCenter.post(name: .hotkeyPressed, object: nil, userInfo: ["action": action])
        }
        
        return noErr
    }
    
    private func registerDefaultHotkeys() {
        for action in HotkeyAction.allCases {
            registerHotkey(action)
        }
    }
    
    public func registerHotkey(_ action: HotkeyAction) {
        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = OSType("MACS".utf8.first!)
        hotKeyID.id = UInt32(action.rawValue.hashValue)
        
        var hotKeyRef: EventHotKeyRef?
        let status = RegisterEventHotKey(
            action.keyCode,
            action.modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        
        if status == noErr, let hotKeyRef = hotKeyRef {
            hotkeys[action] = hotKeyRef
        } else {
            print("Failed to register hotkey for action: \(action.rawValue)")
        }
    }
    
    public func unregisterHotkey(_ action: HotkeyAction) {
        if let hotKeyRef = hotkeys[action] {
            UnregisterEventHotKey(hotKeyRef)
            hotkeys.removeValue(forKey: action)
        }
    }
    
    deinit {
        if let eventHandler = eventHandler {
            RemoveEventHandler(eventHandler)
        }
        
        for (_, hotKeyRef) in hotkeys {
            UnregisterEventHotKey(hotKeyRef)
        }
    }
}

public enum HotkeyAction: String, CaseIterable {
    case scrollUp = "scroll_up"
    case scrollDown = "scroll_down"
    case pageUp = "page_up"
    case pageDown = "page_down"
    case scrollToTop = "scroll_to_top"
    case scrollToBottom = "scroll_to_bottom"
    case resizeWindow = "resize_window"
    case increaseOpacity = "increase_opacity"
    case decreaseOpacity = "decrease_opacity"
    case activateMoveMode = "activate_move_mode"
    case activateResizeMode = "activate_resize_mode"
    case resizeTop = "resize_top"
    case resizeBottom = "resize_bottom"
    case resizeLeft = "resize_left"
    case resizeRight = "resize_right"
    case resizeTopLeft = "resize_top_left"
    case resizeTopRight = "resize_top_right"
    case resizeBottomLeft = "resize_bottom_left"
    case resizeBottomRight = "resize_bottom_right"
    case nextSuggestion = "next_suggestion"
    case previousSuggestion = "previous_suggestion"
    case copySuggestion = "copy_suggestion"
    case dismissSuggestion = "dismiss_suggestion"
    
    var keyCode: UInt32 {
        switch self {
        case .scrollUp:
            return UInt32(kVK_UpArrow)
        case .scrollDown:
            return UInt32(kVK_DownArrow)
        case .pageUp:
            return UInt32(kVK_PageUp)
        case .pageDown:
            return UInt32(kVK_PageDown)
        case .scrollToTop:
            return UInt32(kVK_Home)
        case .scrollToBottom:
            return UInt32(kVK_End)
        case .resizeWindow:
            return UInt32(kVK_ANSI_R)
        case .increaseOpacity:
            return UInt32(kVK_ANSI_Equal)
        case .decreaseOpacity:
            return UInt32(kVK_ANSI_Minus)
        case .activateMoveMode:
            return UInt32(kVK_ANSI_M)
        case .activateResizeMode:
            return UInt32(kVK_ANSI_R)
        case .resizeTop:
            return UInt32(kVK_UpArrow)
        case .resizeBottom:
            return UInt32(kVK_DownArrow)
        case .resizeLeft:
            return UInt32(kVK_LeftArrow)
        case .resizeRight:
            return UInt32(kVK_RightArrow)
        case .resizeTopLeft:
            return UInt32(kVK_LeftArrow)
        case .resizeTopRight:
            return UInt32(kVK_RightArrow)
        case .resizeBottomLeft:
            return UInt32(kVK_LeftArrow)
        case .resizeBottomRight:
            return UInt32(kVK_RightArrow)
        case .nextSuggestion:
            return UInt32(kVK_RightArrow)
        case .previousSuggestion:
            return UInt32(kVK_LeftArrow)
        case .copySuggestion:
            return UInt32(kVK_ANSI_C)
        case .dismissSuggestion:
            return UInt32(kVK_Escape)
        }
    }
    
    var modifiers: UInt32 {
        switch self {
        case .scrollUp, .scrollDown, .pageUp, .pageDown, .scrollToTop, .scrollToBottom:
            return UInt32(cmdKey)
        case .resizeWindow, .increaseOpacity, .decreaseOpacity:
            return UInt32(cmdKey | shiftKey)
        case .activateMoveMode, .activateResizeMode:
            return UInt32(cmdKey | shiftKey)
        case .resizeTop, .resizeBottom, .resizeLeft, .resizeRight:
            return UInt32(cmdKey | shiftKey)
        case .resizeTopLeft, .resizeTopRight:
            return UInt32(cmdKey | shiftKey | optionKey)
        case .resizeBottomLeft, .resizeBottomRight:
            return UInt32(cmdKey | shiftKey | controlKey)
        case .nextSuggestion, .previousSuggestion, .copySuggestion:
            return UInt32(cmdKey | optionKey)
        case .dismissSuggestion:
            return 0
        }
    }
}

extension Notification.Name {
    static let hotkeyPressed = Notification.Name("hotkeyPressed")
} 