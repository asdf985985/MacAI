import SwiftUI

public struct OCRTextView: View {
    // MARK: - Properties
    
    @ObservedObject var viewModel: OCRTextViewModel
    
    // MARK: - Constants
    
    private let textColor = Color.white
    private let confidenceColor = Color.gray
    private let fontSize: CGFloat = 14
    private let lineSpacing: CGFloat = 8
    private let padding: CGFloat = 16
    
    // MARK: - Body
    
    public var body: some View {
        VStack(alignment: .leading, spacing: lineSpacing) {
            ForEach(viewModel.visibleLines) { text in
                VStack(alignment: .leading, spacing: 4) {
                    // 文本内容
                    Text(text.text)
                        .font(.system(size: fontSize))
                        .foregroundColor(textColor)
                        .lineLimit(3)
                    
                    // 置信度
                    HStack {
                        Text("置信度：")
                            .font(.system(size: fontSize - 2))
                            .foregroundColor(confidenceColor)
                        
                        Text(String(format: "%.1f%%", text.confidence * 100))
                            .font(.system(size: fontSize - 2))
                            .foregroundColor(confidenceColor)
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

struct OCRTextView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = OCRTextViewModel()
        
        // 添加测试数据
        viewModel.addText(
            "这是一段测试文本，用于预览 OCR 文本的显示效果。",
            confidence: 0.95
        )
        
        viewModel.addText(
            "This is a test text with a very long content that might need to be wrapped to multiple lines. The confidence level is set to 0.8.",
            confidence: 0.8
        )
        
        return OCRTextView(viewModel: viewModel)
            .frame(width: 400, height: 300)
            .previewLayout(.sizeThatFits)
    }
} 