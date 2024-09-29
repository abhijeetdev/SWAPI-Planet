//
//  PlanetServiceTests.swift
//  StarWarsTests
//
//  Created by Abhijeet Banarase on 29/09/2024.
//

import XCTest
import Combine
@testable import StarWars

final class PlanetServiceTests: XCTestCase {
    
    var planetService: PlanetService!
    fileprivate var mockNetworkServices: MockNetworkServices!
    fileprivate var mockPersistenceServices: MockPersistenceServices!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockNetworkServices = MockNetworkServices()
        mockPersistenceServices = MockPersistenceServices()
        planetService = PlanetService(networkService: mockNetworkServices, persistenceService: mockPersistenceServices)
        cancellables = []
    }
    
    override func tearDown() {
        planetService = nil
        mockNetworkServices = nil
        mockPersistenceServices = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testFetchPlanetsFromPersistenceSuccess() {
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
        mockPersistenceServices.mockPlanets = [planet]
        
        let expectation = self.expectation(description: "Fetch Planets from Persistence Success")
        
        planetService.fetchPlanets(page: nil)
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail("Expected success but got failure")
                }
            }, receiveValue: { rootResult in
                XCTAssertEqual(rootResult.count, 1)
                XCTAssertEqual(rootResult.results.first?.name, "Mock Planet Name")
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testFetchPlanetsFromNetworkSuccess() {
        mockPersistenceServices.shouldFailFetch = true
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
        mockNetworkServices.mockPlanets = [planet]
        
        let expectation = self.expectation(description: "Fetch Planets from Network Success")
        
        planetService.fetchPlanets(page: nil)
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail("Expected success but got failure")
                }
            }, receiveValue: { rootResult in
                XCTAssertEqual(rootResult.count, 1)
                XCTAssertEqual(rootResult.results.first?.name, "Mock Planet Name")
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testFetchPlanetsFromNetworkAndSaveSuccess() {
        mockPersistenceServices.shouldFailFetch = true
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
        mockNetworkServices.mockPlanets = [planet]
        
        let expectation = self.expectation(description: "Fetch Planets from Network and Save Success")
        
        planetService.fetchPlanets(page: nil)
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail("Expected success but got failure")
                }
            }, receiveValue: { rootResult in
                XCTAssertEqual(rootResult.count, 1)
                XCTAssertEqual(rootResult.results.first?.name, "Mock Planet Name")
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
//    func testFetchPlanetsFromNetworkFailure() {
//        mockPersistenceServices.shouldFailFetch = true
//        mockNetworkServices.shouldFailFetch = true
//        
//        let expectation = self.expectation(description: "Fetch Planets from Network Failure")
//        
//        planetService.fetchPlanets(page: nil)
//            .sink(receiveCompletion: { completion in
//                if case .failure(let error) = completion {
//                    if case .networkError(let reason) = error {
//                        XCTAssertEqual(reason, "Mock network fetch error")
//                        expectation.fulfill()
//                    }
//                } else {
//                    XCTFail("Expected failure but got success")
//                }
//            }, receiveValue: { _ in
//                XCTFail("Expected failure but got success")
//            })
//            .store(in: &cancellables)
//        
//        waitForExpectations(timeout: 1, handler: nil)
//    }
    
    func testSavePlanetsFailure() {
        mockPersistenceServices.shouldFailFetch = true
        mockPersistenceServices.shouldFailSave = true
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
        mockNetworkServices.mockPlanets = [planet]
        
        let expectation = self.expectation(description: "Save Planets Failure")
        
        planetService.fetchPlanets(page: nil)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    if case .persistenceError(let persistenceError) = error {
                        if case .fetchError(let fetchError) = persistenceError {
                            XCTAssertEqual((fetchError as NSError).domain, "TestErrorDomain")
                            XCTAssertEqual((fetchError as NSError).code, 9999)
                            expectation.fulfill()
                        }
                    }
                } else {
                    XCTFail("Expected failure but got success")
                }
            }, receiveValue: { _ in
                XCTFail("Expected failure but got success")
            })
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1, handler: nil)
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
