import XCTest
import Vision
import CoreGraphics
@testable import Core

final class OCRManagerTests: XCTestCase {
    var ocrManager: OCRManager!
    var inputManager: InputManager!
    var configManager: ConfigManager!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        configManager = ConfigManager()
        inputManager = InputManager(configManager: configManager)
        ocrManager = OCRManager.shared
        ocrManager.setInputManager(inputManager)
        cancellables = []
    }

    override func tearDown() {
        ocrManager = nil
        inputManager = nil
        configManager = nil
        cancellables = nil
        super.tearDown()
    }

    func testOCRProcessing() {
        // 创建模拟图像（示例：白色背景，黑色文本）
        let size = CGSize(width: 200, height: 100)
        let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
        context.fill(CGRect(origin: .zero, size: size))
        context.setFillColor(CGColor(red: 0, green: 0, blue: 0, alpha: 1))
        context.fill(CGRect(x: 50, y: 40, width: 100, height: 20))
        guard let image = context.makeImage() else {
            XCTFail("Failed to create test image")
            return
        }

        // 验证OCR处理
        let expectation = XCTestExpectation(description: "OCR result")
        ocrManager.ocrResultPublisher.sink { text in
            XCTAssertFalse(text.isEmpty)
            expectation.fulfill()
        }.store(in: &cancellables)
        ocrManager.processOCR(image: image)
        wait(for: [expectation], timeout: 5.0)
    }
} 