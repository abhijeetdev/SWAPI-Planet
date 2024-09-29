//
//  PersistenceServicesTests.swift
//  StarWarsTests
//
//  Created by Abhijeet Banarase on 29/09/2024.
//

import XCTest
import Combine
@testable import StarWars
import CoreData

final class PersistenceServicesTests: XCTestCase {
    
    var persistenceServices: PersistenceServices!
    fileprivate var mockPersistenceManager: MockPersistenceManager!
    fileprivate var mockFetchableContext: MockFetchableContext!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockFetchableContext = MockFetchableContext()
        mockPersistenceManager = MockPersistenceManager(container: MockPersistentContainer())
        persistenceServices = PersistenceServices(manager: mockPersistenceManager, fetchableContext: mockFetchableContext)
        cancellables = []
    }
    
    override func tearDown() {
        persistenceServices = nil
        mockPersistenceManager = nil
        mockFetchableContext = nil
        cancellables = nil
        super.tearDown()
    }
// TODO: Fix it
//    func testFetchPlanetsSuccess() {
//        mockFetchableContext.mockPlanets = [MockPlanetEntity(name: "Earth")]
//        
//        let expectation = self.expectation(description: "Fetch Planets Success")
//        
//        persistenceServices.fetchPlanets(page: nil)
//            .sink(receiveCompletion: { completion in
//                if case .failure = completion {
//                    XCTFail("Expected success but got failure")
//                }
//            }, receiveValue: { rootResult in
//                XCTAssertEqual(rootResult.count, 1)
//                XCTAssertEqual(rootResult.results.first?.name, "Earth")
//                expectation.fulfill()
//            })
//            .store(in: &cancellables)
//        
//        waitForExpectations(timeout: 10, handler: nil)
//    }
    
    func testFetchPlanetsFailure() {
        mockFetchableContext.shouldFailFetch = true
        let expectation = self.expectation(description: "Fetch Planets Failure")
        
        persistenceServices.fetchPlanets(page: nil)
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
    
    func testSavePlanetsSuccess() {
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
        let expectation = self.expectation(description: "Save Planets Success")
        
        persistenceServices.savePlanets([planet])
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail("Expected success but got failure")
                }
            }, receiveValue: {
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testSavePlanetsFailure() {
        mockPersistenceManager.shouldFailSave = true
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
        let expectation = self.expectation(description: "Save Planets Failure")
        
        persistenceServices.savePlanets([planet])
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
            }, receiveValue: {
                XCTFail("Expected failure but got success")
            })
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}

//class MockPlanetEntity: PlanetEntity {
//    convenience init(name: String) {
//        self.init()
//        self.name = name
//        self.rotationPeriod = ""
//        self.orbitalPeriod = ""
//        self.diameter = ""
//        self.climate = ""
//        self.gravity =   ""
//        self.terrain =  ""
//        self.surfaceWater =  ""
//        self.population = ""
//    }
//}

fileprivate final class MockPersistenceManager: PersistenceManagerProtocol {
    var container: PersistentContainer
    var shouldFailSave = false
    
    init(container: PersistentContainer) {
        self.container = container
    }
    
    func savePlanet(_ planet: Planet) throws {
        if shouldFailSave {
            throw NSError(domain: "TestErrorDomain", code: 9999, userInfo: [NSLocalizedDescriptionKey: "Mock save error"])
        }
    }
}

fileprivate final class MockFetchableContext: Fetchable {
    var shouldFailFetch = false
    var mockPlanets: [PlanetEntity] = []
    
    func fetch<T>(_ request: NSFetchRequest<T>) throws -> [T] where T : NSFetchRequestResult {
        if shouldFailFetch {
            throw NSError(domain: "TestErrorDomain", code: 9999, userInfo: [NSLocalizedDescriptionKey: "Mock fetch error"])
        }
        return mockPlanets as! [T]
    }
}

fileprivate class MockPersistentContainer: PersistentContainer {
    var viewContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        return context
    }()
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        let context = MockManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        block(context)
    }
    
    func loadPersistentStores(completionHandler: @escaping (NSPersistentStoreDescription, Error?) -> Void) {
        let description = NSPersistentStoreDescription()
        completionHandler(description, nil)
    }
}

fileprivate class MockManagedObjectContext: NSManagedObjectContext {
    override func save() throws {
        
    }
}

