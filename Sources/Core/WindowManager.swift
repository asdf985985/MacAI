import AppKit
import Combine

public class WindowManager {
    // MARK: - Properties
    
    private let configManager: ConfigManager
    private var window: NSWindow?
    
    // MARK: - Published Properties
    
    @Published public private(set) var isVisible = false
    @Published public private(set) var opacity: CGFloat = WindowConfig.defaultOpacity
    @Published public private(set) var windowLevel: NSWindow.Level = WindowConfig.level
    @Published public private(set) var isAlwaysOnTop = false
    
    // MARK: - Initialization
    
    public init(configManager: ConfigManager) {
        self.configManager = configManager
    }
    
    // MARK: - Window Management
    
    public func show(animated: Bool = false) {
        guard let window = window else { return }
        
        if animated {
            window.alphaValue = 0
            window.makeKeyAndOrderFront(nil)
            NSAnimationContext.runAnimationGroup { context in
                context.duration = WindowConfig.animationDuration
                window.animator().alphaValue = opacity
            }
        } else {
            window.makeKeyAndOrderFront(nil)
        }
        
        isVisible = true
    }
    
    public func hide(animated: Bool = false) {
        guard let window = window else { return }
        
        if animated {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = WindowConfig.animationDuration
                window.animator().alphaValue = 0
            } completionHandler: {
                window.orderOut(nil)
            }
        } else {
            window.orderOut(nil)
        }
        
        isVisible = false
    }
    
    public func toggle() {
        if isVisible {
            hide()
        } else {
            show()
        }
    }
    
    public func setPosition(_ position: CGPoint) {
        window?.setFrameOrigin(position)
    }
    
    public func setSize(_ size: CGSize) {
        guard let window = window else { return }
        let frame = window.frame
        window.setFrame(
            NSRect(
                x: frame.origin.x,
                y: frame.origin.y,
                width: size.width,
                height: size.height
            ),
            display: true
        )
    }
    
    public func setOpacity(_ opacity: CGFloat) {
        let newOpacity = max(WindowConfig.minOpacity, min(WindowConfig.maxOpacity, opacity))
        window?.alphaValue = newOpacity
        self.opacity = newOpacity
    }
    
    public func setWindowLevel(_ level: NSWindow.Level) {
        window?.level = level
        windowLevel = level
    }
    
    public func setAlwaysOnTop(_ alwaysOnTop: Bool) {
        window?.level = alwaysOnTop ? .floating : .normal
        isAlwaysOnTop = alwaysOnTop
    }
    
    public func setMinSize(_ size: CGSize) {
        window?.minSize = size
    }
    
    public func setMaxSize(_ size: CGSize) {
        window?.maxSize = size
    }
    
    public func setStyle(_ style: NSWindow.StyleMask) {
        window?.styleMask = style
    }
    
    public func setTitle(_ title: String) {
        window?.title = title
    }
    
    public func saveWindowState() {
        guard let window = window else { return }
        let state = WindowState(
            frame: window.frame,
            isVisible: isVisible,
            opacity: opacity,
            level: windowLevel
        )
        configManager.saveWindowState(state)
    }
    
    public func restoreWindowState() {
        guard let window = window,
              let state = configManager.loadWindowState() else { return }
        
        window.setFrame(state.frame, display: true)
        setOpacity(state.opacity)
        setWindowLevel(state.windowLevel)
        
        if state.isVisible {
            show()
        } else {
            hide()
        }
    }
}

// MARK: - Supporting Types

public struct WindowState: Codable {
    public let frame: CGRect
    public let isVisible: Bool
    public let opacity: CGFloat
    public let level: Int
    
    public init(frame: CGRect, isVisible: Bool, opacity: CGFloat, level: NSWindow.Level) {
        self.frame = frame
        self.isVisible = isVisible
        self.opacity = opacity
        self.level = level.rawValue
    }
    
    public var windowLevel: NSWindow.Level {
        return NSWindow.Level(rawValue: level)
    }
} 