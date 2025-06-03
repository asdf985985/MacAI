import AppKit
import Input
import Combine
import Foundation
import SwiftUI

public class FloatingWindowController: NSWindowController {
    // MARK: - Properties
    
    /// 窗口配置
    private let config: WindowConfig
    
    /// 视图模型
    public let viewModel: FloatingWindowViewModel
    
    /// 快捷键订阅
    private var shortcutSubscription: AnyCancellable?
    
    /// 手势模式订阅
    private var gestureModeSubscription: AnyCancellable?
    
    /// 调整大小方向订阅
    private var resizeDirectionSubscription: AnyCancellable?
    
    // MARK: - Initialization
    
    public init(config: WindowConfig = .default) {
        self.config = config
        self.viewModel = FloatingWindowViewModel()
        
        // 创建窗口
        let window = NSWindow(
            contentRect: NSRect(
                origin: config.initialPosition,
                size: config.initialSize
            ),
            styleMask: [
                .borderless,
                .fullSizeContentView
            ],
            backing: .buffered,
            defer: false
        )
        
        // 配置窗口
        window.title = config.title
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = true
        window.level = config.isAlwaysOnTop ? .floating : .normal
        window.isMovableByWindowBackground = config.isMovable
        window.minSize = config.minSize
        window.maxSize = config.maxSize
        
        // 设置内容视图
        window.contentView = NSHostingView(
            rootView: FloatingWindowView(viewModel: viewModel)
        )
        
        super.init(window: window)
        
        // 设置快捷键处理
        setupKeyboardShortcuts()
        
        // 设置手势处理
        setupGestureHandling()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Window Management
    
    /// 显示窗口
    public func show() {
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    /// 隐藏窗口
    public func hide() {
        window?.orderOut(nil)
    }
    
    /// 切换窗口显示状态
    public func toggle() {
        if let window = window {
            if window.isVisible {
                hide()
            } else {
                show()
            }
        }
    }
    
    /// 移动窗口
    public func move(to point: CGPoint) {
        window?.setFrameOrigin(point)
    }
    
    /// 调整窗口大小
    public func resize(to size: CGSize) {
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
    
    /// 调整窗口透明度
    public func setOpacity(_ opacity: CGFloat) {
        window?.alphaValue = opacity
    }
    
    // MARK: - Content Management
    
    /// 添加字幕
    public func addSubtitle(_ text: String, translation: String? = nil) {
        let subtitle = Subtitle(text: text, translation: translation)
        viewModel.subtitleViewModel.addSubtitle(subtitle)
    }
    
    /// 添加 OCR 文本
    public func addOCRText(_ text: String, confidence: Double = 1.0) {
        viewModel.ocrTextViewModel.addText(text, confidence: confidence)
    }
    
    /// 添加 AI 建议
    public func addAISuggestion(_ content: String, type: AISuggestionViewModel.SuggestionType) {
        viewModel.aiSuggestionViewModel.addSuggestion(content, type: type)
    }
    
    /// 显示状态消息
    public func showStatus(_ message: String, type: StatusViewModel.MessageType = .info) {
        viewModel.statusViewModel.show(message, type: type)
    }
    
    // MARK: - Window State Management
    
    /// 保存窗口状态
    public func saveWindowState() {
        guard let window = window else { return }
        let frame = window.frame
        let alpha = window.alphaValue
        
        UserDefaults.standard.set([
            "x": frame.origin.x,
            "y": frame.origin.y,
            "width": frame.width,
            "height": frame.height,
            "alpha": alpha
        ], forKey: WindowConfig.frameSaveKey)
    }
    
    /// 恢复窗口状态
    public func restoreWindowState() {
        guard let window = window else { return }
        let savedState = UserDefaults.standard.dictionary(forKey: "windowState") as? [String: Any] ?? [:]
        
        let frame = NSRect(
            x: savedState["x"] as? CGFloat ?? config.initialPosition.x,
            y: savedState["y"] as? CGFloat ?? config.initialPosition.y,
            width: savedState["width"] as? CGFloat ?? config.initialSize.width,
            height: savedState["height"] as? CGFloat ?? config.initialSize.height
        )
        
        window.setFrame(frame, display: true)
        window.alphaValue = savedState["alpha"] as? CGFloat ?? WindowConfig.defaultOpacity
    }
    
    /// 重置窗口到默认状态
    public func resetWindowFrameToDefault() {
        guard let window = window else { return }
        let frame = NSRect(
            x: config.initialPosition.x,
            y: config.initialPosition.y,
            width: config.initialSize.width,
            height: config.initialSize.height
        )
        window.setFrame(frame, display: true)
        window.alphaValue = WindowConfig.defaultOpacity
    }
    
    // MARK: - Private Methods
    
    private func setupKeyboardShortcuts() {
        shortcutSubscription = KeyboardShortcutManager.shared.shortcutPublisher
            .sink { [weak self] shortcut in
                self?.handleShortcut(shortcut)
            }
    }
    
    private func setupGestureHandling() {
        // 订阅手势模式变化
        gestureModeSubscription = WindowGestureManager.shared.modeSubject
            .sink { [weak self] mode in
                self?.handleGestureMode(mode)
            }
        
        // 订阅调整大小方向变化
        resizeDirectionSubscription = WindowGestureManager.shared.resizeDirectionSubject
            .sink { [weak self] direction in
                self?.handleResizeDirection(direction)
            }
    }
    
    private func handleShortcut(_ shortcut: KeyboardShortcut) {
        switch shortcut.identifier {
        case "toggle_window":
            toggle()
            
        case "move_window_up":
            moveWindow(direction: .up)
        case "move_window_down":
            moveWindow(direction: .down)
        case "move_window_left":
            moveWindow(direction: .left)
        case "move_window_right":
            moveWindow(direction: .right)
            
        case "clear_content":
            clearContent()
            
        case "scroll_up":
            scrollUp()
        case "scroll_down":
            scrollDown()
        case "page_up":
            pageUp()
        case "page_down":
            pageDown()
        case "scroll_to_top":
            scrollToTop()
        case "scroll_to_bottom":
            scrollToBottom()
            
        case "resize_window":
            toggleResizeMode()
            
        case "increase_opacity":
            increaseOpacity()
        case "decrease_opacity":
            decreaseOpacity()
            
        case "activate_move_mode":
            WindowGestureManager.shared.activateMoveMode()
        case "activate_resize_mode":
            WindowGestureManager.shared.activateResizeMode()
            
        case "resize_top":
            WindowGestureManager.shared.setResizeDirection(.top)
        case "resize_bottom":
            WindowGestureManager.shared.setResizeDirection(.bottom)
        case "resize_left":
            WindowGestureManager.shared.setResizeDirection(.left)
        case "resize_right":
            WindowGestureManager.shared.setResizeDirection(.right)
        case "resize_top_left":
            WindowGestureManager.shared.setResizeDirection(.topLeft)
        case "resize_top_right":
            WindowGestureManager.shared.setResizeDirection(.topRight)
        case "resize_bottom_left":
            WindowGestureManager.shared.setResizeDirection(.bottomLeft)
        case "resize_bottom_right":
            WindowGestureManager.shared.setResizeDirection(.bottomRight)
            
        case "next_suggestion":
            viewModel.aiSuggestionViewModel.nextSuggestion()
        case "previous_suggestion":
            viewModel.aiSuggestionViewModel.previousSuggestion()
        case "copy_suggestion":
            viewModel.aiSuggestionViewModel.copyCurrentSuggestion()
        case "dismiss_suggestion":
            viewModel.aiSuggestionViewModel.dismissSuggestion()
            
        default:
            break
        }
    }
    
    private func handleGestureMode(_ mode: WindowGestureManager.GestureMode) {
        switch mode {
        case .none:
            window?.ignoresMouseEvents = true
        case .move:
            window?.ignoresMouseEvents = false
            window?.isMovableByWindowBackground = true
        case .resize:
            window?.ignoresMouseEvents = false
            window?.isMovableByWindowBackground = false
        }
    }
    
    private func handleResizeDirection(_ direction: WindowGestureManager.ResizeDirection) {
        // 根据方向显示调整大小的视觉提示
        switch direction {
        case .none:
            NSCursor.arrow.set()
        case .top, .bottom:
            NSCursor.resizeUpDown.set()
        case .left, .right:
            NSCursor.resizeLeftRight.set()
        case .topLeft, .bottomRight:
            NSCursor.crosshair.set()
        case .topRight, .bottomLeft:
            NSCursor.crosshair.set()
        }
    }
    
    private func moveWindow(direction: Direction) {
        guard let window = window else { return }
        let currentFrame = window.frame
        let step = WindowConfig.moveStep
        
        var newOrigin = currentFrame.origin
        switch direction {
        case .up:
            newOrigin.y += step
        case .down:
            newOrigin.y -= step
        case .left:
            newOrigin.x -= step
        case .right:
            newOrigin.x += step
        }
        
        window.setFrameOrigin(newOrigin)
    }
    
    private func scrollUp() {
        viewModel.subtitleViewModel.scrollUp()
        viewModel.ocrTextViewModel.scrollUp()
        viewModel.aiSuggestionViewModel.scrollUp()
    }
    
    private func scrollDown() {
        viewModel.subtitleViewModel.scrollDown()
        viewModel.ocrTextViewModel.scrollDown()
        viewModel.aiSuggestionViewModel.scrollDown()
    }
    
    private func pageUp() {
        viewModel.subtitleViewModel.pageUp()
        viewModel.ocrTextViewModel.pageUp()
        viewModel.aiSuggestionViewModel.pageUp()
    }
    
    private func pageDown() {
        viewModel.subtitleViewModel.pageDown()
        viewModel.ocrTextViewModel.pageDown()
        viewModel.aiSuggestionViewModel.pageDown()
    }
    
    private func scrollToTop() {
        viewModel.subtitleViewModel.scrollToStart()
        viewModel.ocrTextViewModel.scrollToStart()
        viewModel.aiSuggestionViewModel.scrollToStart()
    }
    
    private func scrollToBottom() {
        viewModel.subtitleViewModel.scrollToEnd()
        viewModel.ocrTextViewModel.scrollToEnd()
        viewModel.aiSuggestionViewModel.scrollToEnd()
    }
    
    private func toggleResizeMode() {
        if WindowGestureManager.shared.isResizeModeActive {
            WindowGestureManager.shared.deactivateResizeMode()
        } else {
            WindowGestureManager.shared.activateResizeMode()
        }
    }
    
    private func increaseOpacity() {
        adjustOpacity(by: 0.1)
    }
    
    private func decreaseOpacity() {
        adjustOpacity(by: -0.1)
    }
    
    private func adjustOpacity(by delta: CGFloat) {
        guard let window = window else { return }
        let newOpacity = max(0.1, min(1.0, window.alphaValue + delta))
        setOpacity(newOpacity)
    }
    
    private func clearContent() {
        viewModel.subtitleViewModel.clearContent()
        viewModel.ocrTextViewModel.clearContent()
        viewModel.aiSuggestionViewModel.clearSuggestions()
    }
}

// MARK: - Direction

private enum Direction {
    case up
    case down
    case left
    case right
}

// MARK: - FloatingWindowView

private struct FloatingWindowView: View {
    // MARK: - Properties
    
    @ObservedObject var viewModel: FloatingWindowViewModel
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // 背景
            Color.clear
            
            // 内容视图
            VStack(spacing: 0) {
                // 字幕视图
                SubtitleView(viewModel: viewModel.subtitleViewModel)
                    .frame(height: 150)
                
                // OCR 文本视图
                OCRTextView(viewModel: viewModel.ocrTextViewModel)
                    .frame(height: 200)
                
                // AI 建议视图
                AISuggestionView(viewModel: viewModel.aiSuggestionViewModel)
                    .frame(height: 100)
            }
            
            // 状态消息视图
            VStack {
                Spacer()
                StatusView(viewModel: viewModel.statusViewModel)
                    .padding(.bottom, 16)
            }
        }
    }
}

// MARK: - FloatingWindowViewModel

public class FloatingWindowViewModel: ObservableObject {
    // MARK: - Properties
    
    /// 字幕视图模型
    public let subtitleViewModel = SubtitleViewModel()
    
    /// OCR 文本视图模型
    public let ocrTextViewModel = OCRTextViewModel()
    
    /// AI 建议视图模型
    public let aiSuggestionViewModel = AISuggestionViewModel()
    
    /// 状态消息视图模型
    public let statusViewModel = StatusViewModel()
    
    // MARK: - Content Management
    
    /// 添加字幕
    public func addSubtitle(_ text: String, translation: String? = nil) {
        let subtitle = Subtitle(text: text, translation: translation)
        subtitleViewModel.addSubtitle(subtitle)
    }
    
    /// 添加 OCR 文本
    public func addOCRText(_ text: String, confidence: Double = 1.0) {
        ocrTextViewModel.addText(text, confidence: confidence)
    }
    
    /// 添加 AI 建议
    public func addAISuggestion(_ content: String, type: AISuggestionViewModel.SuggestionType) {
        aiSuggestionViewModel.addSuggestion(content, type: type)
    }
    
    /// 显示状态消息
    public func showStatus(_ message: String, type: StatusViewModel.MessageType = .info) {
        statusViewModel.show(message, type: type)
    }
}

extension FloatingWindowController: NSWindowDelegate {
    public func windowDidMove(_ notification: Notification) {
        saveWindowState()
    }
    
    public func windowDidResize(_ notification: Notification) {
        saveWindowState()
    }
    
    public func windowWillClose(_ notification: Notification) {
        saveWindowState()
    }
    
    public func windowDidChangeScreen(_ notification: Notification) {
        // 当窗口移动到不同屏幕时，确保窗口位置和大小在屏幕范围内
        guard let window = window,
              let screen = window.screen else { return }
        
        let visibleFrame = screen.visibleFrame
        var frame = window.frame
        
        // 确保窗口在屏幕范围内
        if frame.maxX > visibleFrame.maxX {
            frame.origin.x = visibleFrame.maxX - frame.width
        }
        if frame.minX < visibleFrame.minX {
            frame.origin.x = visibleFrame.minX
        }
        if frame.maxY > visibleFrame.maxY {
            frame.origin.y = visibleFrame.maxY - frame.height
        }
        if frame.minY < visibleFrame.minY {
            frame.origin.y = visibleFrame.minY
        }
        
        // 如果窗口大小超过屏幕范围，调整大小
        if frame.width > visibleFrame.width {
            frame.size.width = visibleFrame.width
        }
        if frame.height > visibleFrame.height {
            frame.size.height = visibleFrame.height
        }
        
        window.setFrame(frame, display: true)
        saveWindowState()
    }
}

private enum ResizeDirection {
    case none
    case top
    case bottom
    case left
    case right
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
} 