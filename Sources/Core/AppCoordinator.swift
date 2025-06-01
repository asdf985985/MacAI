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
    
    public init() {
        self.configManager = ConfigManager()
        self.inputManager = InputManager(configManager: configManager)
        self.aiService = AIService(configManager: configManager)
        self.sttManager = STTManager()
        self.floatingWindowController = FloatingWindowController(sttManager: sttManager)
        
        setupDataFlow()
    }
    
    private func setupDataFlow() {
        // 输入管理器发布文本，AI服务订阅并处理
        inputManager.textPublisher
            .sink { [weak self] text in
                self?.aiService.processText(text)
            }
            .store(in: &cancellables)
        
        // AI服务发布结果，浮动窗口订阅并显示
        aiService.resultPublisher
            .sink { [weak self] result in
                self?.floatingWindowController.updateContent(result)
            }
            .store(in: &cancellables)
        
        // 订阅 STTManager 的语音识别结果，发送给 AI 服务处理
        sttManager.publisher
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] text in
                self?.aiService.processText(text)
            })
            .store(in: &cancellables)
    }
}

// 输入管理器
public class InputManager {
    private let configManager: ConfigManager
    private let textSubject = PassthroughSubject<String, Never>()
    
    public var textPublisher: AnyPublisher<String, Never> {
        textSubject.eraseToAnyPublisher()
    }
    
    public init(configManager: ConfigManager) {
        self.configManager = configManager
    }
    
    public func processInput(_ text: String) {
        textSubject.send(text)
    }
}

// AI服务
public class AIService {
    private let configManager: ConfigManager
    private let resultSubject = PassthroughSubject<String, Never>()
    
    public var resultPublisher: AnyPublisher<String, Never> {
        resultSubject.eraseToAnyPublisher()
    }
    
    public init(configManager: ConfigManager) {
        self.configManager = configManager
    }
    
    public func processText(_ text: String) {
        // TODO: 实现实际的AI处理逻辑
        resultSubject.send("处理结果: \(text)")
    }
} 