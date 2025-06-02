import Foundation
import Combine

public class InputManager {
    private let configManager: ConfigManager
    private let textSubject = PassthroughSubject<String, Never>()
    public var textPublisher: AnyPublisher<String, Never> { textSubject.eraseToAnyPublisher() }
    
    // 批量OCR相关
    public private(set) var isBatchMode = false
    private var ocrBatchBuffer: [String] = []
    private let batchStatusSubject = PassthroughSubject<String, Never>()
    public var batchStatusPublisher: AnyPublisher<String, Never> { batchStatusSubject.eraseToAnyPublisher() }

    public init(configManager: ConfigManager) {
        self.configManager = configManager
    }
    
    public func processInput(_ text: String) {
        textSubject.send(text)
    }
    
    // 批量模式开关
    public func toggleBatchMode() {
        isBatchMode.toggle()
        batchStatusSubject.send(isBatchMode ? "Batch mode ON" : "Batch mode OFF")
    }
    // 添加OCR结果到缓冲区
    public func addOCRToBatch(_ text: String) {
        ocrBatchBuffer.append(text)
        print("批量OCR结果已添加: \(text)")
        batchStatusSubject.send("OCR text added to batch")
    }
    // 批量提交
    public func finalizeBatch() {
        let combined = ocrBatchBuffer.joined(separator: "\n")
        print("批量OCR结果已提交: \(combined)")
        textSubject.send(combined)
        ocrBatchBuffer.removeAll()
        batchStatusSubject.send("Batch sent")
    }
} 