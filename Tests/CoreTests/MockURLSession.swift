import Foundation
import Core

class MockURLSession: URLSessionProtocol {
    var mockData: Data?
    var mockResponse: HTTPURLResponse?
    var mockError: Error?
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let error = mockError {
            throw error
        }
        if mockResponse == nil {
            throw AIServiceError.invalidAPIKey
        }
        guard let response = mockResponse, let data = mockData else {
            throw AIServiceError.invalidAPIKey
        }
        return (data, response)
    }
}

// 可选：用于传统 completion handler 风格的接口
class MockURLSessionDataTask: URLSessionDataTask {
    private let closure: () -> Void
    init(closure: @escaping () -> Void) {
        self.closure = closure
        super.init()
    }
    
    override func resume() {
        closure()
    }
} 