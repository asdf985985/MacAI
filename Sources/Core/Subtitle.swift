import Foundation

public struct Subtitle: Identifiable, Equatable {
    // MARK: - Properties
    
    /// 唯一标识符
    public let id: UUID
    
    /// 字幕文本
    public let text: String
    
    /// 翻译文本（可选）
    public let translation: String?
    
    /// 时间戳
    public let timestamp: Date
    
    // MARK: - Initialization
    
    public init(
        id: UUID = UUID(),
        text: String,
        translation: String? = nil,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.text = text
        self.translation = translation
        self.timestamp = timestamp
    }
    
    // MARK: - Equatable
    
    public static func == (lhs: Subtitle, rhs: Subtitle) -> Bool {
        lhs.id == rhs.id &&
        lhs.text == rhs.text &&
        lhs.translation == rhs.translation &&
        lhs.timestamp == rhs.timestamp
    }
} 