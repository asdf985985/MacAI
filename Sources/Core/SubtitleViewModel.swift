import Foundation
import Combine

public class SubtitleViewModel: ObservableObject {
    // MARK: - Properties
    
    /// 所有字幕
    @Published public private(set) var subtitles: [Subtitle] = []
    
    /// 可见字幕行数
    @Published public private(set) var visibleLines: [Subtitle] = []
    
    /// 当前滚动位置
    @Published public private(set) var currentScrollPosition: Int = 0
    
    /// 每页显示的字幕数量
    private let pageSize: Int = 3
    
    /// 最大缓存字幕数量
    private let maxBufferSize: Int = 10
    
    // MARK: - Private Properties
    
    private var buffer: [String] = []
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Methods
    
    /// 添加字幕
    public func addSubtitle(_ subtitle: Subtitle) {
        // 在开头插入新字幕
        subtitles.insert(subtitle, at: 0)
        
        // 限制缓存大小
        if subtitles.count > maxBufferSize {
            subtitles.removeLast()
        }
        
        // 更新可见行
        updateVisibleLines()
    }
    
    /// 清除所有字幕
    public func clearContent() {
        subtitles.removeAll()
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
        guard currentScrollPosition < subtitles.count - pageSize else { return }
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
            subtitles.count - pageSize,
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
        currentScrollPosition = max(0, subtitles.count - pageSize)
        updateVisibleLines()
    }
    
    // MARK: - Private Methods
    
    private func updateVisibleLines() {
        let endIndex = min(currentScrollPosition + pageSize, subtitles.count)
        visibleLines = Array(subtitles[currentScrollPosition..<endIndex])
    }
    
    private func formatSubtitle(_ subtitle: Subtitle) -> String {
        if let translation = subtitle.translation {
            return "\(subtitle.text)\n\(translation)"
        }
        return subtitle.text
    }
} 