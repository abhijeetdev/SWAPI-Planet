import XCTest
import Combine
@testable import StarWars

final class NetworkManagerTests: XCTestCase {
    var networkManager: NetworkManager!
    var mockSession: MockNetworkSession!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockSession = MockNetworkSession()
        networkManager = NetworkManager(session: mockSession)
        cancellables = []
    }
    
    override func tearDown() {
        networkManager = nil
        mockSession = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testLoadWithNilURL() {
        let expectation = self.expectation(description: "Completion handler invoked")
        var receivedError: NetworkError?
        
        networkManager.load(nil)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    receivedError = error
                }
                expectation.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(receivedError, NetworkError.badRequest)
    }
    
    func testLoadWithValidURL() {
        let expectation = self.expectation(description: "Completion handler invoked")
        var receivedData: Data?
        var receivedError: NetworkError?
        
        let url = URL(string: "https://jsonplaceholder.typicode.com/todos/1")!
        let data = "{\"title\": \"Test\"}".data(using: .utf8)!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        mockSession.data = data
        mockSession.response = response
        
        networkManager.load(url)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    receivedError = error
                }
                expectation.fulfill()
            }, receiveValue: { data in
                receivedData = data
            })
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertNotNil(receivedData)
        XCTAssertNil(receivedError)
    }
    
    func testLoadWithBadResponse() {
        let expectation = self.expectation(description: "Completion handler invoked")
        var receivedError: NetworkError?
        
        let url = URL(string: "https://jsonplaceholder.typicode.com/todos/1")!
        let data = Data()
        let response = URLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        
        mockSession.data = data
        mockSession.response = response
        
        networkManager.load(url)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    receivedError = error
                }
                expectation.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(receivedError, NetworkError.badResponse)
    }
    
    func testLoadWithErrorStatusCode() {
        let expectation = self.expectation(description: "Completion handler invoked")
        var receivedError: NetworkError?
        
        let url = URL(string: "https://jsonplaceholder.typicode.com/todos/1")!
        let data = Data()
        let response = HTTPURLResponse(url: url, statusCode: 404, httpVersion: nil, headerFields: nil)!
        
        mockSession.data = data
        mockSession.response = response
        
        networkManager.load(url)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    receivedError = error
                }
                expectation.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(receivedError, NetworkError.error(code: 404))
    }
    
    func testLoadWithNetworkError() {
        let expectation = self.expectation(description: "Completion handler invoked")
        var receivedError: NetworkError?
        
        let url = URL(string: "https://jsonplaceholder.typicode.com/todos/1")!
        let urlError = URLError(.notConnectedToInternet)
        
        mockSession.error = urlError
        
        networkManager.load(url)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    receivedError = error
                }
                expectation.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(receivedError, NetworkError.networkError(from: urlError))
    }
}
