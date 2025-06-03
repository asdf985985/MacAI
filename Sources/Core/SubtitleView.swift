import SwiftUI

public struct SubtitleView: View {
    // MARK: - Properties
    
    @ObservedObject var viewModel: SubtitleViewModel
    
    // MARK: - Constants
    
    private let textColor = Color.white
    private let translationColor = Color.gray
    private let fontSize: CGFloat = 16
    private let lineSpacing: CGFloat = 8
    private let padding: CGFloat = 16
    
    // MARK: - Body
    
    public var body: some View {
        VStack(alignment: .leading, spacing: lineSpacing) {
            ForEach(viewModel.visibleLines) { subtitle in
                VStack(alignment: .leading, spacing: 4) {
                    // 原文
                    Text(subtitle.text)
                        .font(.system(size: fontSize))
                        .foregroundColor(textColor)
                        .lineLimit(2)
                    
                    // 翻译（如果有）
                    if let translation = subtitle.translation {
                        Text(translation)
                            .font(.system(size: fontSize - 2))
                            .foregroundColor(translationColor)
                            .lineLimit(2)
                    }
                }
                .padding(.horizontal, padding)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.black.opacity(0.5))
    }
}

// MARK: - Preview

struct SubtitleView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = SubtitleViewModel()
        
        // 添加测试数据
        viewModel.addSubtitle(Subtitle(
            text: "Hello, world!",
            translation: "你好，世界！",
            timestamp: Date()
        ))
        
        viewModel.addSubtitle(Subtitle(
            text: "This is a test subtitle with a very long text that might need to be wrapped to multiple lines.",
            translation: "这是一个测试字幕，包含很长的文本，可能需要换行显示。",
            timestamp: Date()
        ))
        
        return SubtitleView(viewModel: viewModel)
            .frame(width: 400, height: 300)
            .previewLayout(.sizeThatFits)
    }
} 