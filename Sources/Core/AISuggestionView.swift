import SwiftUI
import WebKit
import Down

public struct AISuggestionView: View {
    // MARK: - Properties
    
    @ObservedObject var viewModel: AISuggestionViewModel
    
    // MARK: - Constants
    
    private let backgroundColor = Color.black.opacity(0.5)
    private let textColor = Color.white
    private let typeColor = Color.gray
    private let fontSize: CGFloat = 14
    private let lineSpacing: CGFloat = 8
    private let padding: CGFloat = 16
    
    // MARK: - Body
    
    public var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Text("AI 建议")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // 类型标签
                if let type = viewModel.currentSuggestion?.type {
                    Text(type.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(4)
                }
                
                // 加载指示器
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.8)
                        .padding(.leading, 8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            
            // 内容区域
            if let suggestion = viewModel.currentSuggestion {
                // Markdown 内容
                MarkdownWebView(
                    content: suggestion.content,
                    scrollPosition: viewModel.scrollPosition
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // 空状态
                VStack {
                    Image(systemName: "lightbulb")
                        .font(.system(size: 24))
                        .foregroundColor(.secondary)
                    
                    Text("暂无建议")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color(NSColor.windowBackgroundColor))
    }
}

// MARK: - MarkdownWebView

private struct MarkdownWebView: NSViewRepresentable {
    // MARK: - Properties
    
    let content: String
    let scrollPosition: CGFloat
    
    // MARK: - NSViewRepresentable
    
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        
        // 配置 WebView
        webView.setValue(false, forKey: "drawsBackground")
        
        // 禁用鼠标交互
        webView.allowsBackForwardNavigationGestures = false
        webView.allowsMagnification = false
        webView.allowsLinkPreview = false
        
        // 加载 Markdown 内容
        loadMarkdownContent(in: webView)
        
        return webView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        // 更新内容
        if context.coordinator.lastContent != content {
            loadMarkdownContent(in: webView)
            context.coordinator.lastContent = content
        }
        
        // 更新滚动位置
        webView.evaluateJavaScript("window.scrollTo(0, \(scrollPosition));")
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    // MARK: - Private Methods
    
    private func loadMarkdownContent(in webView: WKWebView) {
        do {
            // 使用 Down 解析 Markdown
            let down = Down(markdownString: content)
            let html = try down.toHTML()
            
            // 创建完整的 HTML 内容
            let fullHTML = """
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.7.0/styles/github.min.css">
                <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.7.0/highlight.min.js"></script>
                <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.7.0/languages/swift.min.js"></script>
                <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.7.0/languages/python.min.js"></script>
                <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.7.0/languages/javascript.min.js"></script>
                <style>
                    body {
                        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
                        font-size: 14px;
                        line-height: 1.5;
                        color: #333;
                        background-color: transparent;
                        padding: 16px;
                        margin: 0;
                    }
                    h1, h2, h3, h4, h5, h6 {
                        margin-top: 24px;
                        margin-bottom: 16px;
                        font-weight: 600;
                        line-height: 1.25;
                    }
                    h1 { font-size: 2em; }
                    h2 { font-size: 1.5em; }
                    h3 { font-size: 1.25em; }
                    p { margin-bottom: 16px; }
                    ul, ol { padding-left: 2em; }
                    code {
                        font-family: SFMono-Regular, Consolas, "Liberation Mono", Menlo, monospace;
                        font-size: 0.9em;
                        padding: 0.2em 0.4em;
                        background-color: rgba(0, 0, 0, 0.05);
                        border-radius: 3px;
                    }
                    pre {
                        padding: 16px;
                        overflow: auto;
                        font-size: 0.9em;
                        line-height: 1.45;
                        background-color: rgba(0, 0, 0, 0.05);
                        border-radius: 3px;
                    }
                    pre code {
                        padding: 0;
                        background-color: transparent;
                    }
                    blockquote {
                        margin: 0 0 16px;
                        padding: 0 1em;
                        color: #6a737d;
                        border-left: 0.25em solid #dfe2e5;
                    }
                    table {
                        border-spacing: 0;
                        border-collapse: collapse;
                        margin-bottom: 16px;
                    }
                    table th, table td {
                        padding: 6px 13px;
                        border: 1px solid #dfe2e5;
                    }
                    table tr {
                        background-color: #fff;
                        border-top: 1px solid #c6cbd1;
                    }
                    table tr:nth-child(2n) {
                        background-color: #f6f8fa;
                    }
                    img {
                        max-width: 100%;
                        height: auto;
                    }
                    a {
                        color: #0366d6;
                        text-decoration: none;
                    }
                    a:hover {
                        text-decoration: underline;
                    }
                </style>
            </head>
            <body>
                \(html)
                <script>
                    document.addEventListener('DOMContentLoaded', function() {
                        document.querySelectorAll('pre code').forEach((block) => {
                            hljs.highlightElement(block);
                        });
                    });
                </script>
            </body>
            </html>
            """
            
            webView.loadHTMLString(fullHTML, baseURL: nil)
        } catch {
            print("Markdown 解析错误: \(error)")
            // 显示错误信息
            let errorHTML = """
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <style>
                    body {
                        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
                        font-size: 14px;
                        line-height: 1.5;
                        color: #dc3545;
                        background-color: transparent;
                        padding: 16px;
                        margin: 0;
                    }
                </style>
            </head>
            <body>
                <p>Markdown 解析错误: \(error.localizedDescription)</p>
            </body>
            </html>
            """
            webView.loadHTMLString(errorHTML, baseURL: nil)
        }
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var lastContent: String = ""
    }
}

// MARK: - Preview

struct AISuggestionView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = AISuggestionViewModel()
        
        return VStack(spacing: 20) {
            // 加载状态
            AISuggestionView(viewModel: {
                let vm = AISuggestionViewModel()
                vm.startLoading()
                return vm
            }())
            .frame(width: 300, height: 100)
            
            // 翻译建议
            AISuggestionView(viewModel: {
                let vm = AISuggestionViewModel()
                vm.addSuggestion(
                    "This is a test translation suggestion.",
                    type: .translation
                )
                return vm
            }())
            .frame(width: 300, height: 100)
            
            // 总结建议
            AISuggestionView(viewModel: {
                let vm = AISuggestionViewModel()
                vm.addSuggestion(
                    "这是一个测试总结建议，可能会包含多行内容。",
                    type: .summary
                )
                return vm
            }())
            .frame(width: 300, height: 100)
            
            // 空状态
            AISuggestionView(viewModel: AISuggestionViewModel())
                .frame(width: 300, height: 100)
        }
        .previewLayout(.sizeThatFits)
    }
} 