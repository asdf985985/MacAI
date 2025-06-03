import Foundation
import AppKit
import HotKey
import Combine

public class GlobalHotkey {
    public static let shared = GlobalHotkey()
    
    private var hotkeys: [String: HotKey] = [:]
    private let defaults = UserDefaults.standard
    
    private init() {
        loadHotkeys()
    }
    
    public func register(key: Key, modifiers: NSEvent.ModifierFlags, identifier: String) {
        let hotkey = HotKey(key: key, modifiers: modifiers)
        hotkeys[identifier] = hotkey
        
        // 保存快捷键配置
        saveHotkey(key: key, modifiers: modifiers, identifier: identifier)
    }
    
    public func unregister(identifier: String) {
        hotkeys[identifier] = nil
        defaults.removeObject(forKey: "hotkey_\(identifier)")
    }
    
    public func getHotkey(identifier: String) -> HotKey? {
        return hotkeys[identifier]
    }
    
    private func loadHotkeys() {
        // 从 UserDefaults 加载保存的快捷键配置
        let keys = defaults.dictionaryRepresentation().keys.filter { $0.hasPrefix("hotkey_") }
        
        for key in keys {
            guard let data = defaults.data(forKey: key),
                  let hotkeyData = try? JSONDecoder().decode(HotkeyData.self, from: data) else {
                continue
            }
            
            let identifier = String(key.dropFirst(7)) // 移除 "hotkey_" 前缀
            let hotkey = HotKey(key: hotkeyData.key, modifiers: hotkeyData.modifiers)
            hotkeys[identifier] = hotkey
        }
    }
    
    private func saveHotkey(key: Key, modifiers: NSEvent.ModifierFlags, identifier: String) {
        let hotkeyData = HotkeyData(key: key, modifiers: modifiers)
        if let data = try? JSONEncoder().encode(hotkeyData) {
            defaults.set(data, forKey: "hotkey_\(identifier)")
        }
    }
}

private struct HotkeyData: Codable {
    let key: Key
    let modifiers: NSEvent.ModifierFlags
    
    enum CodingKeys: String, CodingKey {
        case key
        case modifiers
    }
    
    init(key: Key, modifiers: NSEvent.ModifierFlags) {
        self.key = key
        self.modifiers = modifiers
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        key = try container.decode(Key.self, forKey: .key)
        let rawValue = try container.decode(UInt.self, forKey: .modifiers)
        modifiers = NSEvent.ModifierFlags(rawValue: rawValue)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(key, forKey: .key)
        try container.encode(modifiers.rawValue, forKey: .modifiers)
    }
}

// HotKey 框架的 Key 类型需要手动实现 Codable
extension Key: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        self = Key(string: string) ?? .a
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.description)
    }
} 