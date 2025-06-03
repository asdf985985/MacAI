import Foundation

public struct PromptTemplate: Codable {
    public let stt: String
    public let ocrSingle: String
    public let ocrBatch: String
    public let contextPrefix: String
    
    public static let `default` = PromptTemplate(
        stt: "请分析以下语音识别文本，提供关键信息摘要和见解：\n%@",
        ocrSingle: "请分析以下OCR识别的文本内容，提取重要信息：\n%@",
        ocrBatch: "请分析以下批量OCR识别的文本内容，整合信息并提供综合见解：\n%@",
        contextPrefix: "\n\n历史上下文：\n%@"
    )
}

public class PromptConfig {
    private static let configFileName = "prompt_config.json"
    private var template: PromptTemplate
    
    public init() {
        if let loadedTemplate = Self.loadTemplate() {
            self.template = loadedTemplate
        } else {
            self.template = .default
        }
    }
    
    private static func loadTemplate() -> PromptTemplate? {
        guard let url = Bundle.module.url(forResource: configFileName, withExtension: nil),
              let data = try? Data(contentsOf: url),
              let template = try? JSONDecoder().decode(PromptTemplate.self, from: data) else {
            return nil
        }
        return template
    }
    
    public func getPrompt(for text: String, contextType: ContextType, previousContext: [String]?) -> String {
        var prompt: String
        
        switch contextType {
        case .stt:
            prompt = String(format: template.stt, text)
        case .ocrSingle:
            prompt = String(format: template.ocrSingle, text)
        case .ocrBatch:
            prompt = String(format: template.ocrBatch, text)
        }
        
        if let context = previousContext, !context.isEmpty {
            prompt += String(format: template.contextPrefix, context.joined(separator: "\n"))
        }
        
        return prompt
    }
} 