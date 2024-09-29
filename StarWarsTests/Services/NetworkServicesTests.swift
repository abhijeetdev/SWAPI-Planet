//
//  NetworkServicesTests.swift
//  StarWarsTests
//
//  Created by Abhijeet Banarase on 29/09/2024.
//

import XCTest
import Combine
@testable import StarWars

class NetworkServicesTests: XCTestCase {
    var networkServices: NetworkServices!
    var mockNetworkManager: MockNetworkManager!
    var mockURLBuilder: MockURLBuilder!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockNetworkManager = MockNetworkManager()
        mockURLBuilder = MockURLBuilder()
        let mockDecode: (Data) -> AnyPublisher<RootResult<Planet>, ServiceError> = { data in
            let planet = Planet(
                name: "Mock Planet Name",
                rotationPeriod: "Mock Rotation Period",
                orbitalPeriod: "Mock Orbital Period",
                diameter: "Mock Diameter",
                climate: "Mock Climate",
                gravity: "Mock Gravity",
                terrain: "Mock Terrain",
                surfaceWater: "Mock Surface Water",
                population: "Mock Population",
                residents: ["https://swapi.co/api/people/mock"],
                films: ["https://swapi.co/api/films/mock"],
                created: "Mock created",
                edited: "Mock edited",
                url: "Mock URl"
            )
            let result = RootResult(count: 10, next: nil, previous: nil, results: [planet])
            return Just(result)
                .setFailureType(to: ServiceError.self)
                .eraseToAnyPublisher()
        }
        networkServices = NetworkServices(networkManager: mockNetworkManager, builder: mockURLBuilder, decode: mockDecode)
        cancellables = []
    }

    override func tearDown() {
        networkServices = nil
        mockNetworkManager = nil
        mockURLBuilder = nil
        cancellables = nil
        super.tearDown()
    }

    func testFetchPlanetsWithoutPage() {
        // Given
        let expectedData = Data() // Replace with actual expected data
        mockNetworkManager.result = .success(expectedData)
        mockURLBuilder.urlToReturn = URL(string: "https://example.com/planets")

        // When
        let expectation = self.expectation(description: "Fetch Planets")
        var receivedResult: Result<RootResult<Planet>, ServiceError>?

        networkServices.fetchPlanets()
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    receivedResult = .failure(error)
                }
            }, receiveValue: { value in
                receivedResult = .success(value)
                expectation.fulfill()
            })
            .store(in: &cancellables)

        // Then
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(mockNetworkManager.loadCalled)
        XCTAssertEqual(mockNetworkManager.url?.absoluteString, "https://example.com/planets")
        XCTAssertNotNil(receivedResult)
    }

    func testFetchPlanetsWithPage() {
        // Given
        let pageUrl = "https://example.com/page"
        let expectedData = Data() // Replace with actual expected data
        mockNetworkManager.result = .success(expectedData)

        // When
        let expectation = self.expectation(description: "Fetch Planets with Page")
        var receivedResult: Result<RootResult<Planet>, ServiceError>?

        networkServices.fetchPlanets(page: pageUrl)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    receivedResult = .failure(error)
                }
            }, receiveValue: { value in
                receivedResult = .success(value)
                expectation.fulfill()
            })
            .store(in: &cancellables)

        // Then
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(mockNetworkManager.loadCalled)
        XCTAssertEqual(mockNetworkManager.url?.absoluteString, pageUrl)
        XCTAssertNotNil(receivedResult)
    }
}


class MockNetworkManager: NetworkManagerProtocol {
    var loadCalled = false
    var url: URL?
    var result: Result<Data, NetworkError>?

    func load(_ url: URL?) -> AnyPublisher<Data, NetworkError> {
        self.loadCalled = true
        self.url = url
        return Future { promise in
            if let result = self.result {
                promise(result)
            }
        }.eraseToAnyPublisher()
    }
}

class MockURLBuilder: URLBuilderProtocol {
    var urlToReturn: URL?
    var idToReturn: URL?

    var url: URL? {
        return urlToReturn
    }

    func url(id: String) -> URL? {
        return idToReturn
    }
}
