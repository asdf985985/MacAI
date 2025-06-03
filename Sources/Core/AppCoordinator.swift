import Foundation
import Combine
import Input

public class AppCoordinator {
    public let inputManager: InputManager
    public let aiService: AIService
    public let configManager: ConfigManager
    public let floatingWindowController: FloatingWindowController
    public let sttManager: STTManager
    
    private var cancellables = Set<AnyCancellable>()
    private var conversationHistory: [String] = []
    private let maxHistoryLength = 5
    
    public init() {
        self.configManager = ConfigManager()
        self.inputManager = InputManager(configManager: configManager)
        self.aiService = AIService(configManager: configManager)
        self.sttManager = STTManager()
        self.floatingWindowController = FloatingWindowController(sttManager: sttManager)
        
        setupDataFlow()
        setupErrorHandling()
        
        // 订阅OCR结果，批量模式下缓冲，否则直接显示
        OCRManager.shared.ocrResultPublisher
            .sink { [weak self] text in
                guard let self = self else { return }
                if self.inputManager.isBatchMode {
                    self.inputManager.addOCRToBatch(text)
                } else {
                    self.floatingWindowController.updateContent(text)
                    self.processText(text, contextType: .ocrSingle)
                }
            }
            .store(in: &cancellables)
            
        // 订阅批量模式状态，显示在AI区
        inputManager.batchStatusPublisher
            .sink { [weak self] status in
                self?.floatingWindowController.updateContent(status)
            }
            .store(in: &cancellables)
    }
    
    private func setupDataFlow() {
        // 输入管理器发布文本，AI服务订阅并处理
        inputManager.textPublisher
            .sink { [weak self] text in
                self?.handleInput(text)
            }
            .store(in: &cancellables)
        
        // AI服务发布结果，浮动窗口订阅并显示
        aiService.resultPublisher
            .sink { [weak self] result in
                self?.floatingWindowController.updateContent(result)
                self?.updateConversationHistory(result)
            }
            .store(in: &cancellables)
        
        // 订阅 STTManager 的语音识别结果，发送给 AI 服务处理
        sttManager.publisher
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] text in
                self?.processText(text, contextType: .stt)
            })
            .store(in: &cancellables)
    }
    
    private func setupErrorHandling() {
        aiService.errorPublisher
            .sink { [weak self] error in
                self?.handleError(error)
            }
            .store(in: &cancellables)
    }
    
    private func handleInput(_ text: String) {
        // 根据输入类型选择上下文
        let contextType: ContextType = text.contains("图片") ? .ocrSingle : .stt
        
        // 处理文本
        aiService.processText(text, contextType: contextType, previousContext: conversationHistory)
    }
    
    private func processText(_ text: String, contextType: ContextType) {
        let history = conversationHistory.isEmpty ? nil : conversationHistory
        aiService.processText(text, contextType: contextType, previousContext: history)
    }
    
    private func updateConversationHistory(_ text: String) {
        conversationHistory.append(text)
        if conversationHistory.count > maxHistoryLength {
            conversationHistory.removeFirst()
        }
    }
    
    private func handleError(_ error: AIServiceError) {
        var errorMessage = "AI 服务错误："
        
        switch error {
        case .invalidAPIKey:
            errorMessage += "无效的 API 密钥，请在设置中配置有效的 API 密钥。"
        case .networkError(let underlyingError):
            errorMessage += "网络错误：\(underlyingError.localizedDescription)"
        case .apiError(let message):
            errorMessage += message
        case .invalidResponse:
            errorMessage += "无效的 API 响应"
        case .rateLimitExceeded:
            errorMessage += "API 调用频率超限，请稍后重试"
        case .timeout:
            errorMessage += "请求超时，请检查网络连接"
        case .keychainError(let status):
            errorMessage += "密钥存储错误：\(status)"
        }
        
        floatingWindowController.updateContent(errorMessage)
    }
    
    public func start() {
        // floatingWindowController.showWindow(nil)
    }
    
    public func stop() {
        // floatingWindowController.close()
    }
} 