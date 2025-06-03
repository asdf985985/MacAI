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

extension ConfigManager {
    // MARK: - Window State
    
    public func saveWindowState(_ state: WindowState) {
        do {
            let data = try JSONEncoder().encode(state)
            UserDefaults.standard.set(data, forKey: "windowState")
        } catch {
            print("Failed to save window state: \(error)")
        }
    }
    
    public func loadWindowState() -> WindowState? {
        guard let data = UserDefaults.standard.data(forKey: "windowState") else {
            return nil
        }
        
        do {
            return try JSONDecoder().decode(WindowState.self, from: data)
        } catch {
            print("Failed to load window state: \(error)")
            return nil
        }
    }
} 