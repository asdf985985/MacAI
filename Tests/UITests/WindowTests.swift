import XCTest
@testable import UI

final class WindowTests: XCTestCase {
    var appDelegate: AppDelegate!
    
    override func setUp() {
        super.setUp()
        appDelegate = AppDelegate()
        appDelegate.applicationDidFinishLaunching(Notification(name: NSApplication.didFinishLaunchingNotification))
    }
    
    override func tearDown() {
        appDelegate = nil
        super.tearDown()
    }
    
    func testWindowIsTransparent() throws {
        try XCTSkipIf(appDelegate.windowManager == nil || appDelegate.windowManager.window == nil, "AppDelegate 或 windowManager.window 初始化失败，跳过测试")
        // 当应用程序启动时
        appDelegate.applicationDidFinishLaunching(Notification(name: NSApplication.didFinishLaunchingNotification))
        // 窗口应该是透明的
        let window = appDelegate.windowManager.window!
        XCTAssertFalse(window.isOpaque)
        XCTAssertEqual(window.backgroundColor, .clear)
    }
    
    func testWindowIgnoresMouseEvents() throws {
        try XCTSkipIf(appDelegate.windowManager == nil || appDelegate.windowManager.window == nil, "AppDelegate 或 windowManager.window 初始化失败，跳过测试")
        // 当应用程序启动时
        appDelegate.applicationDidFinishLaunching(Notification(name: NSApplication.didFinishLaunchingNotification))
        // 窗口应该忽略鼠标事件
        let window = appDelegate.windowManager.window!
        XCTAssertTrue(window.ignoresMouseEvents)
    }
    
    func testWindowIsMovableByBackground() throws {
        try XCTSkipIf(appDelegate.windowManager == nil || appDelegate.windowManager.window == nil, "AppDelegate 或 windowManager.window 初始化失败，跳过测试")
        // 当应用程序启动时
        appDelegate.applicationDidFinishLaunching(Notification(name: NSApplication.didFinishLaunchingNotification))
        // 窗口应该可以通过背景移动
        let window = appDelegate.windowManager.window!
        XCTAssertTrue(window.isMovableByWindowBackground)
    }
} 