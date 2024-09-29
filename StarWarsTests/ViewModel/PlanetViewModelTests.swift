//
//  PlanetViewModelTests.swift
//  StarWarsTests
//
//  Created by Abhijeet Banarase on 29/09/2024.
//

import XCTest
import Combine
@testable import StarWars

class PlanetViewModelTests: XCTestCase {
    var viewModel: PlanetViewModel!
    fileprivate var mockNetworkServices: MockNetworkServices!
    fileprivate var mockPersistenceServices: MockPersistenceServices!
    var mockService: MockPlanetService!
    var cancellables: Set<AnyCancellable>!

    @MainActor override func setUp() {
        super.setUp()
        mockNetworkServices = MockNetworkServices()
        mockPersistenceServices = MockPersistenceServices()
        mockService = MockPlanetService(networkService: mockNetworkServices, persistenceService: mockPersistenceServices)
        
        viewModel = PlanetViewModel(service: mockService)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        cancellables = nil
        super.tearDown()
    }
//TODO: fix it
//    @MainActor func testFetchPlanetsSuccess() {
//        // Given
//        let planet = Planet(
//            name: "Mock Planet Name",
//            rotationPeriod: "Mock Rotation Period",
//            orbitalPeriod: "Mock Orbital Period",
//            diameter: "Mock Diameter",
//            climate: "Mock Climate",
//            gravity: "Mock Gravity",
//            terrain: "Mock Terrain",
//            surfaceWater: "Mock Surface Water",
//            population: "Mock Population",
//            residents: ["https://swapi.co/api/people/mock"],
//            films: ["https://swapi.co/api/films/mock"],
//            created: "Mock created",
//            edited: "Mock edited",
//            url: "Mock URl"
//        )
//        let planets = [planet]
//        mockService.rootResult = RootResult(count: 1, next: nil, previous: nil, results: planets)
//
//        // When
//        viewModel.fetchPlanets()
//
//        // Then
//        XCTAssertTrue(viewModel.isLoading)
//        let expectation = XCTestExpectation(description: "Fetch planets")
//        viewModel.$planets
//            .dropFirst()
//            .sink { fetchedPlanets in
//                XCTAssertEqual(fetchedPlanets, planets)
//                XCTAssertFalse(self.viewModel.isLoading)
//                XCTAssertNil(self.viewModel.error)
//                expectation.fulfill()
//            }
//            .store(in: &cancellables)
//
//        wait(for: [expectation], timeout: 1.0)
//    }

    @MainActor func testFetchPlanetsFailure() {
        // Given
        let error = ServiceError.networkError(error: .apiError(reason: "Test"))
        mockService.error = error

        // When
        viewModel.fetchPlanets()

        // Then
        XCTAssertTrue(viewModel.isLoading)
        let expectation = XCTestExpectation(description: "Fetch planets failure")
        viewModel.$error
            .dropFirst()
            .sink { receivedError in
                XCTAssertFalse(self.viewModel.isLoading)
                XCTAssertTrue(self.viewModel.planets.isEmpty)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }
}

class MockPlanetService: PlanetService {
    var rootResult: RootResult<Planet>?
    var error: Error?

    override func fetchPlanets(page: String? = nil) -> AnyPublisher<RootResult<Planet>, ServiceError> {
        if let error = error {
            return Fail(error: error as! ServiceError).eraseToAnyPublisher()
        } else {
            let data = rootResult ?? RootResult(count: 0, next: nil, previous: nil, results: [])
            return Just(data)
                .setFailureType(to: ServiceError.self)
                .eraseToAnyPublisher()
        }
    }
}

fileprivate class MockNetworkServices: NetworkServices {
    var shouldFailFetch = false
    var mockPlanets: [Planet] = []
    
    override func fetchPlanets(page: String?) -> AnyPublisher<RootResult<Planet>, ServiceError> {
        if shouldFailFetch {
            return Fail(error: ServiceError.networkError(error: .apiError(reason: "Mock network fetch error")))
                .eraseToAnyPublisher()
        } else {
            let rootResult = RootResult(count: mockPlanets.count, next: nil, previous: nil, results: mockPlanets)
            return Just(rootResult)
                .setFailureType(to: ServiceError.self)
                .eraseToAnyPublisher()
        }
    }
}

fileprivate class MockPersistenceServices: PersistenceServices {
    var shouldFailFetch = false
    var shouldFailSave = false
    var mockPlanets: [Planet] = []
    
    override func fetchPlanets(page: String?) -> AnyPublisher<RootResult<Planet>, ServiceError> {
        if shouldFailFetch {
            return Fail(error: ServiceError.persistenceError(error: .dataError(reason: "Mock persistence fetch error")))
                .eraseToAnyPublisher()
        } else {
            let rootResult = RootResult(count: mockPlanets.count, next: nil, previous: nil, results: mockPlanets)
            return Just(rootResult)
                .setFailureType(to: ServiceError.self)
                .eraseToAnyPublisher()
        }
    }
    
    override func savePlanets(_ planets: [Planet]) -> AnyPublisher<Void, ServiceError> {
        if shouldFailSave {
            return Fail(error: ServiceError.persistenceError(error: .fetchError(from: NSError(domain: "TestErrorDomain", code: 9999, userInfo: [NSLocalizedDescriptionKey: "Mock save error"]))))
                .eraseToAnyPublisher()
        } else {
            return Just(())
                .setFailureType(to: ServiceError.self)
                .eraseToAnyPublisher()
        }
    }
}

