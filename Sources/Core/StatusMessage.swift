import Foundation
import SwiftUI

public struct StatusMessage: Identifiable, Equatable {
    // MARK: - Types
    
    public enum MessageType {
        case info
        case success
        case warning
        case error
        
        var color: Color {
            switch self {
            case .info:
                return .blue
            case .success:
                return .green
            case .warning:
                return .orange
            case .error:
                return .red
            }
        }
        
        var icon: String {
            switch self {
            case .info:
                return "info.circle"
            case .success:
                return "checkmark.circle"
            case .warning:
                return "exclamationmark.triangle"
            case .error:
                return "xmark.circle"
            }
        }
    }
    
    // MARK: - Properties
    
    /// 唯一标识符
    public let id: UUID
    
    /// 消息内容
    public let content: String
    
    /// 消息类型
    public let type: MessageType
    
    /// 时间戳
    public let timestamp: Date
    
    /// 显示时长（秒）
    public let duration: TimeInterval
    
    // MARK: - Initialization
    
    public init(
        id: UUID = UUID(),
        content: String,
        type: MessageType = .info,
        timestamp: Date = Date(),
        duration: TimeInterval = 3.0
    ) {
        self.id = id
        self.content = content
        self.type = type
        self.timestamp = timestamp
        self.duration = duration
    }
    
    // MARK: - Equatable
    
    public static func == (lhs: StatusMessage, rhs: StatusMessage) -> Bool {
        lhs.id == rhs.id &&
        lhs.content == rhs.content &&
        lhs.type == rhs.type &&
        lhs.timestamp == rhs.timestamp &&
        lhs.duration == rhs.duration
    }
} 