import Foundation
import AppKit
import Combine

public class WindowGestureManager {
    // MARK: - Properties
    
    /// 单例实例
    public static let shared = WindowGestureManager()
    
    /// 手势模式
    public enum GestureMode {
        case none
        case move
        case resize
    }
    
    /// 当前手势模式
    @Published public private(set) var currentMode: GestureMode = .none
    
    /// 手势模式发布者
    private let modePublisher = PassthroughSubject<GestureMode, Never>()
    
    /// 手势模式订阅者
    public var modeSubject: AnyPublisher<GestureMode, Never> {
        modePublisher.eraseToAnyPublisher()
    }
    
    /// 调整大小方向
    public enum ResizeDirection {
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
    
    /// 当前调整大小方向
    @Published public private(set) var currentResizeDirection: ResizeDirection = .none
    
    /// 调整大小方向发布者
    private let resizeDirectionPublisher = PassthroughSubject<ResizeDirection, Never>()
    
    /// 调整大小方向订阅者
    public var resizeDirectionSubject: AnyPublisher<ResizeDirection, Never> {
        resizeDirectionPublisher.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// 激活移动模式
    public func activateMoveMode() {
        currentMode = .move
        modePublisher.send(.move)
    }
    
    /// 激活调整大小模式
    public func activateResizeMode() {
        currentMode = .resize
        modePublisher.send(.resize)
    }
    
    /// 停用当前模式
    public func deactivateCurrentMode() {
        currentMode = .none
        currentResizeDirection = .none
        modePublisher.send(.none)
        resizeDirectionPublisher.send(.none)
    }
    
    /// 停用调整大小模式
    public func deactivateResizeMode() {
        if currentMode == .resize {
            deactivateCurrentMode()
        }
    }
    
    /// 设置调整大小方向
    public func setResizeDirection(_ direction: ResizeDirection) {
        currentResizeDirection = direction
        resizeDirectionPublisher.send(direction)
    }
    
    /// 处理键盘事件
    public func handleKeyEvent(_ event: NSEvent) -> Bool {
        guard event.type == .keyDown else { return false }
        
        // 检查是否按下 Escape 键
        if event.keyCode == 0x35 {
            deactivateCurrentMode()
            return true
        }
        
        // 检查是否按下方向键
        if currentMode == .move {
            return handleMoveKeyEvent(event)
        } else if currentMode == .resize {
            return handleResizeKeyEvent(event)
        }
        
        return false
    }
    
    // MARK: - Private Methods
    
    private func handleMoveKeyEvent(_ event: NSEvent) -> Bool {
        let step = WindowConfig.moveStep
        
        switch event.keyCode {
        case 0x7E: // 上箭头
            moveWindow(dx: 0, dy: step)
            return true
        case 0x7D: // 下箭头
            moveWindow(dx: 0, dy: -step)
            return true
        case 0x7B: // 左箭头
            moveWindow(dx: -step, dy: 0)
            return true
        case 0x7C: // 右箭头
            moveWindow(dx: step, dy: 0)
            return true
        default:
            return false
        }
    }
    
    private func handleResizeKeyEvent(_ event: NSEvent) -> Bool {
        let step = WindowConfig.resizeStep
        
        switch event.keyCode {
        case 0x7E: // 上箭头
            resizeWindow(dx: 0, dy: step)
            return true
        case 0x7D: // 下箭头
            resizeWindow(dx: 0, dy: -step)
            return true
        case 0x7B: // 左箭头
            resizeWindow(dx: -step, dy: 0)
            return true
        case 0x7C: // 右箭头
            resizeWindow(dx: step, dy: 0)
            return true
        default:
            return false
        }
    }
    
    private func moveWindow(dx: CGFloat, dy: CGFloat) {
        guard let window = NSApp.windows.first else { return }
        let frame = window.frame
        window.setFrame(
            NSRect(
                x: frame.origin.x + dx,
                y: frame.origin.y + dy,
                width: frame.width,
                height: frame.height
            ),
            display: true
        )
    }
    
    private func resizeWindow(dx: CGFloat, dy: CGFloat) {
        guard let window = NSApp.windows.first else { return }
        let frame = window.frame
        
        var newFrame = frame
        switch currentResizeDirection {
        case .top:
            newFrame.size.height += dy
        case .bottom:
            newFrame.origin.y += dy
            newFrame.size.height -= dy
        case .left:
            newFrame.origin.x += dx
            newFrame.size.width -= dx
        case .right:
            newFrame.size.width += dx
        case .topLeft:
            newFrame.origin.x += dx
            newFrame.size.width -= dx
            newFrame.size.height += dy
        case .topRight:
            newFrame.size.width += dx
            newFrame.size.height += dy
        case .bottomLeft:
            newFrame.origin.x += dx
            newFrame.origin.y += dy
            newFrame.size.width -= dx
            newFrame.size.height -= dy
        case .bottomRight:
            newFrame.origin.y += dy
            newFrame.size.width += dx
            newFrame.size.height -= dy
        case .none:
            break
        }
        
        window.setFrame(newFrame, display: true)
    }
    
    // MARK: - Gesture Mode Management
    
    /// 当前是否处于移动模式
    public var isMoveModeActive: Bool {
        return currentMode == .move
    }
    
    /// 当前是否处于调整大小模式
    public var isResizeModeActive: Bool {
        return currentMode == .resize
    }
} 