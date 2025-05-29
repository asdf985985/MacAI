import Cocoa
import Core
import Utils
import SwiftUI

public class AppDelegate: NSObject, NSApplicationDelegate {
    private var hotkeyManager: HotkeyManager!
    private var statusItem: NSStatusItem!
    private var preferencesWindow: NSWindow?
    private var floatingWindowController: FloatingWindowController!
    
    public func applicationDidFinishLaunching(_ notification: Notification) {
        setupManagers()
        setupStatusBar()
    }
    
    private func setupManagers() {
        floatingWindowController = FloatingWindowController()
        hotkeyManager = HotkeyManager(floatingWindowController: floatingWindowController)
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
            let preferencesView = PreferencesView()
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
        floatingWindowController.resetWindowFrameToDefault()
    }
    
    public func applicationWillTerminate(_ notification: Notification) {
        floatingWindowController.saveWindowFrame()
    }
}

extension AppDelegate: NSWindowDelegate {
    public func windowWillClose(_ notification: Notification) {
        if notification.object as? NSWindow == preferencesWindow {
            preferencesWindow = nil
        }
    }
} 
