import Foundation
import Vision
import Combine
import CoreGraphics
import AppKit

public class OCRManager {
    public static let shared = OCRManager()
    private let ocrResultSubject = PassthroughSubject<String, Never>()
    public var ocrResultPublisher: AnyPublisher<String, Never> { ocrResultSubject.eraseToAnyPublisher() }
    private var screenshots: [CGImage] = []
    private var inputManager: InputManager? = nil

    public func setInputManager(_ manager: InputManager) {
        self.inputManager = manager
    }

    // 截图后处理
    private func handleOCRResult(_ text: String) {
        if let inputManager = inputManager, inputManager.isBatchMode {
            inputManager.addOCRToBatch(text)
        } else {
            ocrResultSubject.send(text)
        }
    }

    // 全屏截图
    public func captureFullScreen() {
        print("触发全屏截图")
        guard let screen = NSScreen.main else { return }
        let rect = screen.frame
        if let image = CGWindowListCreateImage(rect, .optionOnScreenOnly, kCGNullWindowID, .bestResolution) {
            screenshots.append(image)
            processOCR(image: image)
        }
    }

    // 区域截图（简化版，使用全屏截图后裁剪）
    public func captureRegion(_ rect: CGRect) {
        print("触发区域截图: \(rect)")
        guard let screen = NSScreen.main else { return }
        let screenRect = screen.frame
        if let fullImage = CGWindowListCreateImage(screenRect, .optionOnScreenOnly, kCGNullWindowID, .bestResolution) {
            let croppedImage = fullImage.cropping(to: rect)
            if let croppedImage = croppedImage {
                screenshots.append(croppedImage)
                processOCR(image: croppedImage)
            }
        }
    }

    // OCR处理
    private func processOCR(image: CGImage) {
        let request = VNRecognizeTextRequest()
        request.recognitionLanguages = ["en-US", "zh-Hans"]
        request.recognitionLevel = .accurate
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        do {
            try handler.perform([request])
            if let observations = request.results {
                let texts = observations.compactMap { $0.topCandidates(1).first?.string }
                let resultText = texts.joined(separator: "\n")
                print("OCR结果: \(resultText)")
                handleOCRResult(resultText)
            }
        } catch {
            print("OCR processing error: \(error)")
        }
    }

    // 处理所有截图
    public func processAllScreenshots() {
        for image in screenshots {
            processOCR(image: image)
        }
        screenshots.removeAll()
    }
} 