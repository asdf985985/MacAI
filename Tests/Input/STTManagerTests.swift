import XCTest
import Speech
import AVFoundation
import Combine
@testable import Core

class STTManagerTests: XCTestCase {
    var sut: STTManager!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        sut = STTManager()
        cancellables = []
    }
    
    override func tearDown() {
        sut = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testRequestPermissions() {
        let expectation = XCTestExpectation(description: "Permissions granted")
        sut.requestPermissions { granted in
            XCTAssertTrue(granted)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testStartListening() {
        let expectation = XCTestExpectation(description: "Recognition started")
        sut.publisher.sink(receiveCompletion: { _ in }, receiveValue: { _ in
            expectation.fulfill()
        }).store(in: &cancellables)
        
        sut.startListening()
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testStopListening() {
        sut.startListening()
        sut.stopListening()
        XCTAssertFalse(sut.audioEngine?.isRunning ?? false)
    }
} 