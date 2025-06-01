import AppKit
import Input
import Combine

public class FloatingWindowController {
    public let window: NSWindow?
    private let userDefaults = UserDefaults.standard
    private let windowFrameKey = "com.utils.sysmonitorx.floatingWindowFrame"
    private let windowAlphaKey = "com.utils.sysmonitorx.floatingWindowAlpha"
    private var isInMoveMode: Bool = false
    private var isInResizeMode: Bool = false
    private var isVisible: Bool = true
    private var cancellables = Set<AnyCancellable>()
    private var sttManager: STTManager?
    private var subtitleTextView: NSTextView?
    private var aiResponseTextView: NSTextView?
    
    public init(sttManager: STTManager? = nil) {
        self.sttManager = sttManager
        // 悬浮窗宽度
        let defaultWidth: CGFloat = 1000
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
        win.alphaValue = 0.95
        win.isMovableByWindowBackground = false
        win.collectionBehavior = [.canJoinAllSpaces, .stationary]
        
        // 内容视图
        let contentView = NSView(frame: win.contentRect(forFrameRect: win.frame))
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.15).cgColor
        
        // 字幕组和AI回答区
        let stackView = NSStackView()
        stackView.orientation = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // 字幕textView
        let subtitleTextView = NSTextView()
        subtitleTextView.isEditable = false
        subtitleTextView.isSelectable = false
        subtitleTextView.drawsBackground = false
        subtitleTextView.textColor = .black
        subtitleTextView.backgroundColor = .white
        subtitleTextView.font = NSFont.systemFont(ofSize: 22)
        subtitleTextView.textContainer?.widthTracksTextView = true
        subtitleTextView.textContainerInset = NSSize(width: 0, height: 8)
        subtitleTextView.maxSize = NSSize(width: 960, height: CGFloat.greatestFiniteMagnitude)
        subtitleTextView.textContainer?.containerSize = NSSize(width: 960, height: CGFloat.greatestFiniteMagnitude)
        subtitleTextView.string = "字幕组"
        self.subtitleTextView = subtitleTextView
        let subtitleScroll = NSScrollView()
        subtitleScroll.hasVerticalScroller = true
        subtitleScroll.documentView = subtitleTextView
        subtitleScroll.drawsBackground = false
        subtitleScroll.backgroundColor = NSColor.gray.withAlphaComponent(0.2)
        subtitleScroll.translatesAutoresizingMaskIntoConstraints = false
        subtitleScroll.contentView.postsBoundsChangedNotifications = true
        subtitleScroll.borderType = .noBorder
        subtitleScroll.autohidesScrollers = true
        
        // AI textView
        let aiResponseTextView = NSTextView()
        aiResponseTextView.isEditable = false
        aiResponseTextView.isSelectable = false
        aiResponseTextView.drawsBackground = false
        aiResponseTextView.textColor = .black
        aiResponseTextView.backgroundColor = .white
        aiResponseTextView.font = NSFont.systemFont(ofSize: 22)
        aiResponseTextView.textContainer?.widthTracksTextView = true
        aiResponseTextView.textContainerInset = NSSize(width: 0, height: 8)
        aiResponseTextView.maxSize = NSSize(width: 960, height: CGFloat.greatestFiniteMagnitude)
        aiResponseTextView.textContainer?.containerSize = NSSize(width: 960, height: CGFloat.greatestFiniteMagnitude)
        aiResponseTextView.string = "AI 回答区"
        self.aiResponseTextView = aiResponseTextView
        let aiScroll = NSScrollView()
        aiScroll.hasVerticalScroller = true
        aiScroll.documentView = aiResponseTextView
        aiScroll.drawsBackground = false
        aiScroll.backgroundColor = NSColor.gray.withAlphaComponent(0.2)
        aiScroll.translatesAutoresizingMaskIntoConstraints = false
        aiScroll.contentView.postsBoundsChangedNotifications = true
        aiScroll.borderType = .noBorder
        aiScroll.autohidesScrollers = true
        
        stackView.addArrangedSubview(subtitleScroll)
        stackView.addArrangedSubview(aiScroll)
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            stackView.widthAnchor.constraint(lessThanOrEqualToConstant: 960),
            subtitleScroll.heightAnchor.constraint(equalToConstant: 120),
            aiScroll.heightAnchor.constraint(equalToConstant: 120)
        ])
        win.contentView = contentView
        
        // 恢复 frame
        if let saved = userDefaults.string(forKey: windowFrameKey) {
            let frame = NSRectFromString(saved)
            win.setFrame(frame, display: false)
        }
        self.window = win
        win.orderFrontRegardless()
        subscribeToSTT()
        
        subtitleTextView.frame = subtitleScroll.contentView.bounds
        aiResponseTextView.frame = aiScroll.contentView.bounds
    }

    private func subscribeToSTT() {
        sttManager?.publisher.sink(receiveCompletion: { _ in }, receiveValue: { [weak self] (text: String) in
            print("[调试] 收到语音识别：", text)
            guard let textView = self?.subtitleTextView else { return }
            let shadow = NSShadow()
            shadow.shadowColor = NSColor.black.withAlphaComponent(0.9)
            shadow.shadowBlurRadius = 3
            shadow.shadowOffset = NSMakeSize(1, -1)
            let attrString = NSAttributedString(
                string: text,
                attributes: [
                    .foregroundColor: NSColor(calibratedWhite: 1.0, alpha: 0.65),
                    .font: NSFont.systemFont(ofSize: 22, weight: .semibold),
                    .shadow: shadow
                ]
            )
            textView.textStorage?.setAttributedString(attrString)
            textView.layoutManager?.ensureLayout(for: textView.textContainer!)
            textView.display()
            if let scrollView = textView.enclosingScrollView {
                let range = NSRange(location: textView.string.count, length: 0)
                textView.scrollRangeToVisible(range)
                scrollView.reflectScrolledClipView(scrollView.contentView)
            }
        }).store(in: &cancellables)
    }

    public func saveWindowFrame() {
        guard let frame = window?.frame else { return }
        userDefaults.set(NSStringFromRect(frame), forKey: windowFrameKey)
        userDefaults.set(window?.alphaValue ?? 0.8, forKey: windowAlphaKey)
    }

    public func restoreWindowFrame() {
        guard let win = window else { return }
        if let saved = userDefaults.string(forKey: windowFrameKey) {
            let frame = NSRectFromString(saved)
            win.setFrame(frame, display: false)
        }
        if let alpha = userDefaults.object(forKey: windowAlphaKey) as? Double {
            win.alphaValue = alpha
        }
    }

    public func resetWindowFrameToDefault() {
        let defaultWidth: CGFloat = 1000
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
    }
    
    public func toggleVisibility() {
        isVisible.toggle()
        if isVisible {
            window?.orderFrontRegardless()
        } else {
            window?.orderOut(nil)
        }
    }
    
    public func setAlpha(_ alpha: CGFloat) {
        window?.alphaValue = max(0.1, min(1.0, alpha))
        userDefaults.set(window?.alphaValue, forKey: windowAlphaKey)
    }
    
    public func enterMoveMode() {
        isInMoveMode = true
        isInResizeMode = false
        window?.ignoresMouseEvents = false
        window?.isMovableByWindowBackground = true
    }
    
    public func exitMoveMode() {
        isInMoveMode = false
        window?.ignoresMouseEvents = true
        window?.isMovableByWindowBackground = false
    }
    
    public func enterResizeMode() {
        isInResizeMode = true
        isInMoveMode = false
        window?.ignoresMouseEvents = false
        window?.isMovableByWindowBackground = false
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
    
    public func updateContent(_ content: String) {
        print("[调试] 更新AI区：", content)
        guard let textView = aiResponseTextView else { return }
        let shadow = NSShadow()
        shadow.shadowColor = NSColor.black.withAlphaComponent(0.9)
        shadow.shadowBlurRadius = 3
        shadow.shadowOffset = NSMakeSize(1, -1)
        let attrString = NSAttributedString(
            string: content,
            attributes: [
                .foregroundColor: NSColor(calibratedWhite: 1.0, alpha: 0.65),
                .font: NSFont.systemFont(ofSize: 22, weight: .semibold),
                .shadow: shadow
            ]
        )
        textView.textStorage?.setAttributedString(attrString)
        textView.layoutManager?.ensureLayout(for: textView.textContainer!)
        textView.display()
        if let scrollView = textView.enclosingScrollView {
            let range = NSRange(location: textView.string.count, length: 0)
            textView.scrollRangeToVisible(range)
            scrollView.reflectScrolledClipView(scrollView.contentView)
        }
    }
} 