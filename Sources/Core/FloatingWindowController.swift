import AppKit

public class FloatingWindowController {
    public let window: NSWindow?
    private let userDefaults = UserDefaults.standard
    private let windowFrameKey = "com.utils.sysmonitorx.floatingWindowFrame"
    private var isInMoveMode: Bool = false
    private var isInResizeMode: Bool = false

    public init() {
        // 默认竖直长方形尺寸，贯穿屏幕
        let defaultWidth: CGFloat = 700
        let screen = NSScreen.main
        let screenRect = screen?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        let x = screenRect.midX - defaultWidth / 2
        let y = screenRect.origin.y
        let defaultRect = NSRect(x: x, y: y, width: defaultWidth, height: screenRect.height)

        let win = NSWindow(
            contentRect: defaultRect,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        win.isOpaque = false
        win.backgroundColor = .clear
        win.level = .floating
        win.ignoresMouseEvents = true
        win.hasShadow = false
        win.alphaValue = 0.8
        win.isMovableByWindowBackground = true
        
        // 内容视图
        let contentView = NSView(frame: win.contentRect(forFrameRect: win.frame))
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.2).cgColor
        win.contentView = contentView
        
        // 恢复 frame
        if let saved = userDefaults.string(forKey: windowFrameKey) {
            let frame = NSRectFromString(saved)
            win.setFrame(frame, display: false)
        }
        self.window = win
    }

    public func saveWindowFrame() {
        guard let frame = window?.frame else { return }
        userDefaults.set(NSStringFromRect(frame), forKey: windowFrameKey)
    }

    public func restoreWindowFrame() {
        guard let win = window else { return }
        if let saved = userDefaults.string(forKey: windowFrameKey) {
            let frame = NSRectFromString(saved)
            win.setFrame(frame, display: false)
        }
    }

    public func resetWindowFrameToDefault() {
        let defaultWidth: CGFloat = 700
        let screen = NSScreen.main
        let screenRect = screen?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        let x = screenRect.midX - defaultWidth / 2
        let y = screenRect.origin.y
        let defaultRect = NSRect(x: x, y: y, width: defaultWidth, height: screenRect.height)
        userDefaults.removeObject(forKey: windowFrameKey)
        window?.setFrame(defaultRect, display: true)
        window?.contentView?.setFrameSize(defaultRect.size)
        window?.orderFrontRegardless()
        window?.display()
        userDefaults.set(NSStringFromRect(defaultRect), forKey: windowFrameKey)
        print("重置窗口尺寸为：", defaultRect, "内容视图：", window?.contentView?.frame ?? "nil")
    }
    
    public func enterMoveMode() {
        isInMoveMode = true
        isInResizeMode = false
        window?.ignoresMouseEvents = false
    }
    
    public func exitMoveMode() {
        isInMoveMode = false
        window?.ignoresMouseEvents = true
    }
    
    public func enterResizeMode() {
        isInResizeMode = true
        isInMoveMode = false
        window?.ignoresMouseEvents = false
    }
    
    public func exitResizeMode() {
        isInResizeMode = false
        window?.ignoresMouseEvents = true
    }
    
    public func moveWindow(dx: CGFloat, dy: CGFloat) {
        guard isInMoveMode, let window = window else { return }
        var frame = window.frame
        frame.origin.x += dx
        frame.origin.y += dy
        window.setFrame(frame, display: true)
    }
    
    public func resizeWindow(dx: CGFloat, dy: CGFloat) {
        guard isInResizeMode, let window = window else { return }
        var frame = window.frame
        frame.size.width += dx
        frame.size.height += dy
        window.setFrame(frame, display: true)
    }
} 