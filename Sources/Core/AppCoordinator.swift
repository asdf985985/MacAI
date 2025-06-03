import Foundation
import Combine
import Input

public struct AIResult {
    public enum ResultType {
        case general
        case translation
        case summary
    }
    public let type: ResultType
    public let content: String
}

public class AppCoordinator {
    public let configManager: ConfigManager
    public let inputManager: InputManager
    public let sttManager: STTManager
    let aiService: AIService
    public let floatingWindowController: FloatingWindowController
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
        self.configManager = ConfigManager()
        self.inputManager = InputManager(configManager: configManager)
        self.sttManager = STTManager()
        self.aiService = AIService(configManager: configManager)
        self.floatingWindowController = FloatingWindowController()
        setupBindings()
    }
    
    private func setupBindings() {
        // 处理输入文本
        inputManager.textPublisher
            .sink { [weak self] text in
                self?.handleInputText(text)
            }
            .store(in: &cancellables)
        
        // 处理批量输入状态
        inputManager.batchStatusPublisher
            .sink { [weak self] status in
                self?.floatingWindowController.showStatus(status)
            }
            .store(in: &cancellables)
        
        // 处理 AI 服务结果
        aiService.resultPublisher
            .sink { [weak self] result in
                let aiResult = AIResult(type: .general, content: result)
                self?.handleAIResult(aiResult)
            }
            .store(in: &cancellables)
    }
    
    private func handleInputText(_ text: String) {
        if inputManager.isBatchMode {
            self.inputManager.addOCRToBatch(text)
        } else {
            self.processText(text, contextType: .ocrSingle)
        }
    }
    
    private func handleAIResult(_ result: AIResult) {
        switch result.type {
        case .translation:
            floatingWindowController.addAISuggestion(result.content, type: .translation)
        case .summary:
            floatingWindowController.addAISuggestion(result.content, type: .summary)
        case .general:
            floatingWindowController.addAISuggestion(result.content, type: .general)
        }
    }
    
    private func processText(_ text: String, contextType: ContextType) {
        aiService.processText(text, contextType: contextType)
    }
    
    public func start() {
        floatingWindowController.show()
    }
    
    public func stop() {
        floatingWindowController.hide()
    }
} 