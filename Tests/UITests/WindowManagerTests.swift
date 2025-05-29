import XCTest
@testable import UI

final class WindowManagerTests: XCTestCase {
    var windowManager: WindowManager!
    
    override func setUp() {
        super.setUp()
        windowManager = WindowManager()
    }
    
    override func tearDown() {
        windowManager = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertFalse(windowManager.isVisible)
        XCTAssertFalse(windowManager.isInMoveMode)
        XCTAssertFalse(windowManager.isInResizeMode)
    }
    
    func testShowAndHide() {
        windowManager.show()
        XCTAssertTrue(windowManager.isVisible)
        
        windowManager.hide()
        XCTAssertFalse(windowManager.isVisible)
    }
    
    func testToggle() {
        windowManager.toggle()
        XCTAssertTrue(windowManager.isVisible)
        
        windowManager.toggle()
        XCTAssertFalse(windowManager.isVisible)
    }
    
    func testSaveAndRestoreWindowState() {
        // 保存初始窗口位置
        let originalFrame = windowManager.window?.frame
        windowManager.saveWindowState()
        // 进入移动模式并修改窗口位置
        windowManager.enterMoveMode()
        windowManager.moveWindow(dx: 20, dy: 20)
        let movedFrame = windowManager.window?.frame
        XCTAssertNotEqual(originalFrame, movedFrame)
        // 恢复窗口位置
        windowManager.restoreWindowState()
        let restoredFrame = windowManager.window?.frame
        XCTAssertEqual(originalFrame, restoredFrame)
    }
    
    func testMoveMode() {
        // 进入移动模式
        windowManager.enterMoveMode()
        XCTAssertTrue(windowManager.isInMoveMode)
        XCTAssertFalse(windowManager.isInResizeMode)
        
        // 移动窗口
        let initialFrame = windowManager.window?.frame
        windowManager.moveWindow(dx: 10, dy: 10)
        let newFrame = windowManager.window?.frame
        
        XCTAssertEqual(newFrame?.origin.x, (initialFrame?.origin.x ?? 0) + 10)
        XCTAssertEqual(newFrame?.origin.y, (initialFrame?.origin.y ?? 0) + 10)
        
        // 退出移动模式
        windowManager.exitMoveMode()
        XCTAssertFalse(windowManager.isInMoveMode)
    }
    
    func testResizeMode() {
        // 进入调整大小模式
        windowManager.enterResizeMode()
        XCTAssertTrue(windowManager.isInResizeMode)
        XCTAssertFalse(windowManager.isInMoveMode)
        
        // 调整窗口大小
        let initialFrame = windowManager.window?.frame
        windowManager.resizeWindow(dx: 10, dy: 10)
        let newFrame = windowManager.window?.frame
        
        XCTAssertEqual(newFrame?.size.width, (initialFrame?.size.width ?? 0) + 10)
        XCTAssertEqual(newFrame?.size.height, (initialFrame?.size.height ?? 0) + 10)
        
        // 退出调整大小模式
        windowManager.exitResizeMode()
        XCTAssertFalse(windowManager.isInResizeMode)
    }
    
    func testModeExclusivity() {
        // 进入移动模式
        windowManager.enterMoveMode()
        XCTAssertTrue(windowManager.isInMoveMode)
        XCTAssertFalse(windowManager.isInResizeMode)
        
        // 进入调整大小模式应该自动退出移动模式
        windowManager.enterResizeMode()
        XCTAssertTrue(windowManager.isInResizeMode)
        XCTAssertFalse(windowManager.isInMoveMode)
        
        // 重新进入移动模式应该自动退出调整大小模式
        windowManager.enterMoveMode()
        XCTAssertTrue(windowManager.isInMoveMode)
        XCTAssertFalse(windowManager.isInResizeMode)
    }
} 