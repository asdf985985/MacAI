import SwiftUI

struct PreferencesView: View {
    var body: some View {
        TabView {
            ShortcutsView()
                .tabItem {
                    Label("Shortcuts", systemImage: "keyboard")
                }
            GeneralView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
        }
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