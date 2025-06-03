import Foundation
import AppKit
import SwiftUI

public struct WindowConfig {
    // MARK: - Properties
    
    /// 窗口标题
    public let title: String
    
    /// 初始位置
    public let initialPosition: CGPoint
    
    /// 初始大小
    public let initialSize: CGSize
    
    /// 最小大小
    public let minSize: CGSize
    
    /// 最大大小
    public let maxSize: CGSize
    
    /// 背景颜色
    public let backgroundColor: Color
    
    /// 是否可调整大小
    public let isResizable: Bool
    
    /// 是否可移动
    public let isMovable: Bool
    
    /// 是否始终置顶
    public let isAlwaysOnTop: Bool
    
    /// 是否显示标题栏
    public let showsTitleBar: Bool
    
    // MARK: - Initialization
    
    public init(
        title: String = "MacAI",
        initialPosition: CGPoint = .zero,
        initialSize: CGSize = CGSize(width: 400, height: 300),
        minSize: CGSize = CGSize(width: 300, height: 200),
        maxSize: CGSize = CGSize(width: 800, height: 600),
        backgroundColor: Color = .clear,
        isResizable: Bool = true,
        isMovable: Bool = true,
        isAlwaysOnTop: Bool = true,
        showsTitleBar: Bool = false
    ) {
        self.title = title
        self.initialPosition = initialPosition
        self.initialSize = initialSize
        self.minSize = minSize
        self.maxSize = maxSize
        self.backgroundColor = backgroundColor
        self.isResizable = isResizable
        self.isMovable = isMovable
        self.isAlwaysOnTop = isAlwaysOnTop
        self.showsTitleBar = showsTitleBar
    }
    
    // MARK: - Default Configurations
    
    /// 默认配置
    public static let `default` = WindowConfig()
    
    /// 字幕窗口配置
    public static let subtitle = WindowConfig(
        initialSize: CGSize(width: 500, height: 150),
        minSize: CGSize(width: 400, height: 100),
        maxSize: CGSize(width: 800, height: 300)
    )
    
    /// OCR 文本窗口配置
    public static let ocrText = WindowConfig(
        initialSize: CGSize(width: 400, height: 200),
        minSize: CGSize(width: 300, height: 150),
        maxSize: CGSize(width: 600, height: 400)
    )
    
    /// AI 建议窗口配置
    public static let aiSuggestion = WindowConfig(
        initialSize: CGSize(width: 300, height: 100),
        minSize: CGSize(width: 250, height: 80),
        maxSize: CGSize(width: 500, height: 200)
    )
    
    // MARK: - Window Style
    
    /// 窗口样式
    public static let styleMask: NSWindow.StyleMask = [.borderless]
    
    /// 窗口级别
    public static let level: NSWindow.Level = .floating
    
    /// 是否显示阴影
    public static let hasShadow = false
    
    // MARK: - Window Behavior
    
    /// 默认透明度
    public static let defaultOpacity: CGFloat = 0.9
    
    /// 透明度调整步长
    public static let opacityStep: CGFloat = 0.1
    
    /// 最小透明度
    public static let minOpacity: CGFloat = 0.3
    
    /// 最大透明度
    public static let maxOpacity: CGFloat = 1.0
    
    /// 移动步长
    public static let moveStep: CGFloat = 10
    
    /// 调整大小步长
    public static let resizeStep: CGFloat = 20
    
    // MARK: - Window Appearance
    
    /// 边框宽度
    public static let borderWidth: CGFloat = 1.0
    
    /// 圆角半径
    public static let cornerRadius: CGFloat = 8.0
    
    /// 阴影半径
    public static let shadowRadius: CGFloat = 10.0
    
    /// 阴影透明度
    public static let shadowOpacity: Float = 0.3
    
    /// 阴影偏移
    public static let shadowOffset = NSSize(width: 0, height: -2)
    
    // MARK: - Layout
    
    /// 标题栏高度
    public static let titleBarHeight: CGFloat = 32.0
    
    /// 内容边距
    public static let contentInsets = NSEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    
    /// 拖拽区域高度
    public static let dragAreaHeight: CGFloat = 24.0
    
    /// 调整大小区域宽度
    public static let resizeAreaWidth: CGFloat = 8.0
    
    /// 状态栏高度
    public static let statusBarHeight: CGFloat = 24.0
    
    /// 字体大小
    public static let fontSize: CGFloat = 14.0
    
    // MARK: - Animation
    
    /// 动画持续时间
    public static let animationDuration: TimeInterval = 0.3
    
    /// 状态栏动画持续时间
    public static let statusBarAnimationDuration: TimeInterval = 0.2
    
    // MARK: - UserDefaults Keys
    
    /// 窗口位置保存键
    public static let frameSaveKey = "windowFrame"
    
    /// 窗口透明度保存键
    public static let alphaSaveKey = "windowAlpha"
} 