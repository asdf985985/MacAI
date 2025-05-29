public class AppCoordinator {
    public let inputManager: InputManager
    public let aiService: AIService
    public let configManager: ConfigManager

    public init() {
        self.inputManager = InputManager()
        self.aiService = AIService()
        self.configManager = ConfigManager()
    }
}

// 占位模块
public class InputManager { public init() {} }
public class AIService { public init() {} }
public class ConfigManager { public init() {} } 