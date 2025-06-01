import Foundation
import Combine

public class ConfigManager {
    private let defaults = UserDefaults.standard
    private let apiKeyKey = "apiKey"
    private let hotkeyKey = "hotkey"
    private let hotkeySubject: CurrentValueSubject<String, Never>
    
    public var apiKey: String {
        get { defaults.string(forKey: apiKeyKey) ?? "" }
        set { defaults.set(newValue, forKey: apiKeyKey) }
    }
    
    public var hotkey: String {
        get { defaults.string(forKey: hotkeyKey) ?? "⌘⇧A" }
        set {
            defaults.set(newValue, forKey: hotkeyKey)
            hotkeySubject.send(newValue)
        }
    }
    
    public var hotkeyPublisher: AnyPublisher<String, Never> {
        hotkeySubject.eraseToAnyPublisher()
    }
    
    public init() {
        let initialHotkey = defaults.string(forKey: hotkeyKey) ?? "⌘⇧A"
        hotkeySubject = CurrentValueSubject<String, Never>(initialHotkey)
    }
} 