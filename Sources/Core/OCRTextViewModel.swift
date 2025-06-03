import Foundation
import Combine

public class OCRTextViewModel: ObservableObject {
    // MARK: - Properties
    
    /// 所有 OCR 文本
    @Published public private(set) var texts: [OCRText] = []
    
    /// 可见文本行
    @Published public private(set) var visibleLines: [OCRText] = []
    
    /// 当前滚动位置
    @Published public private(set) var currentScrollPosition: Int = 0
    
    /// 每页显示的行数
    private let pageSize: Int = 10
    
    /// 最大缓存文本数量
    private let maxBufferSize: Int = 20
    
    // MARK: - Content Management
    
    /// 添加 OCR 文本
    public func addText(_ text: String, confidence: Double = 1.0) {
        let ocrText = OCRText(text: text, confidence: confidence)
        addText(ocrText)
    }
    
    /// 添加 OCR 文本对象
    public func addText(_ text: OCRText) {
        // 在开头插入新文本
        texts.insert(text, at: 0)
        
        // 限制缓存大小
        if texts.count > maxBufferSize {
            texts.removeLast()
        }
        
        // 更新可见行
        updateVisibleLines()
    }
    
    /// 清除所有文本
    public func clearContent() {
        texts.removeAll()
        visibleLines.removeAll()
        currentScrollPosition = 0
    }
    
    // MARK: - Navigation
    
    /// 向上滚动
    public func scrollUp() {
        guard currentScrollPosition > 0 else { return }
        currentScrollPosition -= 1
        updateVisibleLines()
    }
    
    /// 向下滚动
    public func scrollDown() {
        guard currentScrollPosition < texts.count - pageSize else { return }
        currentScrollPosition += 1
        updateVisibleLines()
    }
    
    /// 向上翻页
    public func pageUp() {
        currentScrollPosition = max(0, currentScrollPosition - pageSize)
        updateVisibleLines()
    }
    
    /// 向下翻页
    public func pageDown() {
        currentScrollPosition = min(
            texts.count - pageSize,
            currentScrollPosition + pageSize
        )
        updateVisibleLines()
    }
    
    /// 滚动到顶部
    public func scrollToStart() {
        currentScrollPosition = 0
        updateVisibleLines()
    }

    /// 滚动到底部
    public func scrollToEnd() {
        currentScrollPosition = max(0, texts.count - pageSize)
        updateVisibleLines()
    }
    
    // MARK: - Private Methods
    
    private func updateVisibleLines() {
        let endIndex = min(currentScrollPosition + pageSize, texts.count)
        visibleLines = Array(texts[currentScrollPosition..<endIndex])
    }
} 