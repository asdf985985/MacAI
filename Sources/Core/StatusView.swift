import SwiftUI

public struct StatusView: View {
    @ObservedObject var viewModel: StatusViewModel
    private let animationDuration: Double = 0.3
    
    public init(viewModel: StatusViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        HStack {
            if let message = viewModel.currentMessage {
                Text(message.content)
                    .foregroundColor(message.type.color)
                    .transition(.opacity)
            }
        }
        .frame(height: viewModel.isVisible ? 20 : 0)
        .animation(.easeInOut(duration: animationDuration), value: viewModel.isVisible)
        .onChange(of: viewModel.currentMessage) { _ in
            withAnimation(.easeInOut(duration: animationDuration)) {
                viewModel.show()
            }
        }
    }
}

public class StatusViewModel: ObservableObject {
    public struct Message: Equatable {
        public let content: String
        public let type: MessageType
        
        public init(content: String, type: MessageType) {
            self.content = content
            self.type = type
        }
        
        public static func == (lhs: Message, rhs: Message) -> Bool {
            lhs.content == rhs.content && lhs.type == rhs.type
        }
    }
    
    public enum MessageType: Equatable {
        case info
        case success
        case warning
        case error
        
        public var color: Color {
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
    }
    
    @Published public private(set) var currentMessage: Message?
    @Published public private(set) var isVisible: Bool = false
    
    private var messageQueue: [Message] = []
    private var messageTimer: Timer?
    
    public init() {}
    
    public func show() {
        isVisible = true
        startMessageTimer()
    }
    
    public func hide() {
        isVisible = false
    }
    
    public func show(_ content: String, type: MessageType = .info) {
        let message = Message(content: content, type: type)
        messageQueue.append(message)
        
        if currentMessage == nil {
            showNextMessage()
        }
    }
    
    private func showNextMessage() {
        guard !messageQueue.isEmpty else {
            currentMessage = nil
            hide()
            return
        }
        
        currentMessage = messageQueue.removeFirst()
        show()
    }
    
    private func startMessageTimer() {
        messageTimer?.invalidate()
        messageTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            self?.hide()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self?.showNextMessage()
            }
        }
    }
}

// MARK: - Preview

struct StatusView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = StatusViewModel()
        return VStack(spacing: 20) {
            // 信息消息
            StatusView(viewModel: viewModel)
                .onAppear {
                    viewModel.show("这是一条信息消息", type: .info)
                }
            // 成功消息
            StatusView(viewModel: StatusViewModel())
                .onAppear {
                    viewModel.show("操作成功完成", type: .success)
                }
            // 警告消息
            StatusView(viewModel: StatusViewModel())
                .onAppear {
                    viewModel.show("请注意这个警告", type: .warning)
                }
            // 错误消息
            StatusView(viewModel: StatusViewModel())
                .onAppear {
                    viewModel.show("发生了一个错误", type: .error)
                }
        }
        .frame(width: 400)
        .previewLayout(.sizeThatFits)
    }
} 