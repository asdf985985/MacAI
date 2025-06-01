import Cocoa
import Core
import Utils
import SwiftUI

public class AppDelegate: NSObject, NSApplicationDelegate {
    private var coordinator: AppCoordinator!
    private var statusItem: NSStatusItem!
    private var preferencesWindow: NSWindow?
    
    public func applicationDidFinishLaunching(_ notification: Notification) {
        setupCoordinator()
        setupStatusBar()
    }
    
    private func setupCoordinator() {
        coordinator = AppCoordinator()
    }
    
    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "gear", accessibilityDescription: "Settings")
        }
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Preferences", action: #selector(showPreferences), keyEquivalent: ","))
        menu.addItem(NSMenuItem(title: "Reset Window Size", action: #selector(resetWindowSize), keyEquivalent: "r"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    @objc private func showPreferences() {
        if preferencesWindow == nil {
            let preferencesView = PreferencesView(configManager: coordinator.configManager)
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 500, height: 1500),
                styleMask: [.titled, .closable, .miniaturizable],
                backing: .buffered,
                defer: false
            )
            window.title = "Preferences"
            window.center()
            window.contentView = NSHostingView(rootView: preferencesView)
            window.isReleasedWhenClosed = false
            window.delegate = self
            preferencesWindow = window
        }
        
        preferencesWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc private func resetWindowSize() {
        coordinator.floatingWindowController.resetWindowFrameToDefault()
    }
    
    public func applicationWillTerminate(_ notification: Notification) {
        coordinator.floatingWindowController.saveWindowFrame()
    }
}

extension AppDelegate: NSWindowDelegate {
    public func windowWillClose(_ notification: Notification) {
        if notification.object as? NSWindow == preferencesWindow {
            preferencesWindow = nil
        }
    }
} 
