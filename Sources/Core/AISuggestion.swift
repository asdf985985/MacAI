import Foundation

public struct AISuggestion: Identifiable, Equatable {
    // MARK: - Types
    
    public enum SuggestionType: String {
        case translation = "翻译"
        case explanation = "解释"
        case correction = "修正"
        case summary = "总结"
    }
    
    // MARK: - Properties
    
    /// 唯一标识符
    public let id: UUID
    
    /// 建议内容
    public let content: String
    
    /// 建议类型
    public let type: SuggestionType
    
    /// 时间戳
    public let timestamp: Date
    
    // MARK: - Initialization
    
    public init(
        id: UUID = UUID(),
        content: String,
        type: SuggestionType,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.content = content
        self.type = type
        self.timestamp = timestamp
    }
    
    // MARK: - Equatable
    
    public static func == (lhs: AISuggestion, rhs: AISuggestion) -> Bool {
        lhs.id == rhs.id &&
        lhs.content == rhs.content &&
        lhs.type == rhs.type &&
        lhs.timestamp == rhs.timestamp
    }
} 