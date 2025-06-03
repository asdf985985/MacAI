import Foundation

public class MarkdownParser {
    public enum MarkdownError: Error {
        case invalidFormat
        case parsingError
    }
    
    public static func parse(_ text: String) throws -> String {
        // 移除可能的 JSON 转义
        let unescapedText = text.replacingOccurrences(of: "\\n", with: "\n")
            .replacingOccurrences(of: "\\\"", with: "\"")
        
        // 检查是否是有效的 Markdown
        guard !unescapedText.isEmpty else {
            throw MarkdownError.invalidFormat
        }
        
        // 处理常见的 Markdown 格式
        var processedText = unescapedText
        
        // 处理代码块
        processedText = processCodeBlocks(processedText)
        
        // 处理列表
        processedText = processLists(processedText)
        
        // 处理标题
        processedText = processHeaders(processedText)
        
        // 处理强调
        processedText = processEmphasis(processedText)
        
        return processedText
    }
    
    private static func processCodeBlocks(_ text: String) -> String {
        var result = text
        let codeBlockPattern = "```(?:\\w+)?\\n([\\s\\S]*?)```"
        
        if let regex = try? NSRegularExpression(pattern: codeBlockPattern, options: []) {
            let range = NSRange(result.startIndex..., in: result)
            result = regex.stringByReplacingMatches(
                in: result,
                options: [],
                range: range,
                withTemplate: "\n$1\n"
            )
        }
        
        return result
    }
    
    private static func processLists(_ text: String) -> String {
        var result = text
        
        // 处理有序列表
        let orderedListPattern = "(?:^|\\n)(\\d+)\\.\\s+(.+?)(?=\\n\\d+\\.|$)"
        if let regex = try? NSRegularExpression(pattern: orderedListPattern, options: [.anchorsMatchLines]) {
            let range = NSRange(result.startIndex..., in: result)
            result = regex.stringByReplacingMatches(
                in: result,
                options: [],
                range: range,
                withTemplate: "\n• $2"
            )
        }
        
        // 处理无序列表
        let unorderedListPattern = "(?:^|\\n)[*+-]\\s+(.+?)(?=\\n[*+-]|$)"
        if let regex = try? NSRegularExpression(pattern: unorderedListPattern, options: [.anchorsMatchLines]) {
            let range = NSRange(result.startIndex..., in: result)
            result = regex.stringByReplacingMatches(
                in: result,
                options: [],
                range: range,
                withTemplate: "\n• $1"
            )
        }
        
        return result
    }
    
    private static func processHeaders(_ text: String) -> String {
        var result = text
        
        // 处理 # 标题
        let headerPattern = "(?:^|\\n)(#{1,6})\\s+(.+?)(?=\\n|$)"
        if let regex = try? NSRegularExpression(pattern: headerPattern, options: [.anchorsMatchLines]) {
            let range = NSRange(result.startIndex..., in: result)
            result = regex.stringByReplacingMatches(
                in: result,
                options: [],
                range: range,
                withTemplate: "\n$2\n"
            )
        }
        
        return result
    }
    
    private static func processEmphasis(_ text: String) -> String {
        var result = text
        
        // 处理粗体
        result = result.replacingOccurrences(
            of: "\\*\\*(.+?)\\*\\*",
            with: "$1",
            options: .regularExpression
        )
        
        // 处理斜体
        result = result.replacingOccurrences(
            of: "\\*(.+?)\\*",
            with: "$1",
            options: .regularExpression
        )
        
        return result
    }
} 