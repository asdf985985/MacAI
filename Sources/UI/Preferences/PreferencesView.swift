import SwiftUI
import Core

struct PreferencesView: View {
    @State private var apiKey: String
    @State private var hotkey: String
    private let configManager: ConfigManager
    
    init(configManager: ConfigManager) {
        self.configManager = configManager
        _apiKey = State(initialValue: configManager.apiKey)
        _hotkey = State(initialValue: configManager.hotkey)
    }
    
    var body: some View {
        Form {
            Section(header: Text("API 设置")) {
                SecureField("API Key", text: $apiKey)
                    .onChange(of: apiKey) { newValue in
                        configManager.apiKey = newValue
                    }
            }
            
            Section(header: Text("快捷键设置")) {
                TextField("如：⌘⇧A（支持⌘⌥⌃⇧+字母/数字）", text: $hotkey)
                    .onChange(of: hotkey) { newValue in
                        configManager.hotkey = newValue
                    }
            }
        }
        .padding()
        .frame(width: 400, height: 200)
    }
}

struct ShortcutsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("全局快捷键（不可自定义，后续可扩展）:")
                .font(.headline)
            Text("显示/隐藏浮窗：Command + Control + Option + F")
            Text("进入移动模式：Command + Control + Option + M")
            Text("进入调整大小模式：Command + Control + Option + R")
            Spacer()
        }
        .padding()
    }
}

struct GeneralView: View {
    var body: some View {
        Form {
            Section(header: Text("Window Behavior")) {
                Toggle("Start at Login", isOn: .constant(false))
                Toggle("Show in Dock", isOn: .constant(false))
            }
        }
        .padding()
    }
} 