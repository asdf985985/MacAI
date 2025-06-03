import Foundation

public struct OCRText: Identifiable, Equatable {
    // MARK: - Properties
    
    /// 唯一标识符
    public let id: UUID
    
    /// OCR 文本内容
    public let text: String
    
    /// 时间戳
    public let timestamp: Date
    
    /// 置信度（0-1）
    public let confidence: Double
    
    // MARK: - Initialization
    
    public init(
        id: UUID = UUID(),
        text: String,
        timestamp: Date = Date(),
        confidence: Double = 1.0
    ) {
        self.id = id
        self.text = text
        self.timestamp = timestamp
        self.confidence = confidence
    }
    
    // MARK: - Equatable
    
    public static func == (lhs: OCRText, rhs: OCRText) -> Bool {
        lhs.id == rhs.id &&
        lhs.text == rhs.text &&
        lhs.timestamp == rhs.timestamp &&
        lhs.confidence == rhs.confidence
    }
} 