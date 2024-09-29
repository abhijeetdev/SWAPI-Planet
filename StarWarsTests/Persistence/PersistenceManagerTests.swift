//
//  PersistenceManagerTests.swift
//  StarWarsTests
//
//  Created by Abhijeet Banarase on 29/09/2024.
//

import XCTest
import CoreData
@testable import StarWars

class PersistenceManagerTests: XCTestCase {
    
    var persistenceManager: PersistenceManager!
    fileprivate var mockContainer: MockPersistentContainer!
    var mockFailingContainer: MockFailingPersistentContainer!
    
    override func setUp() {
        super.setUp()
        mockContainer = MockPersistentContainer()
        mockFailingContainer = MockFailingPersistentContainer()
    }
    
    override func tearDown() {
        persistenceManager = nil
        mockContainer = nil
        mockFailingContainer = nil
        super.tearDown()
    }
    
    func testInitWithSuccessfulLoad() {
        XCTAssertNoThrow(persistenceManager = PersistenceManager(container: mockContainer))
    }
        
    func testSavePlanetSuccess() {
        persistenceManager = PersistenceManager(container: mockContainer)
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
        
        XCTAssertNoThrow(try persistenceManager.savePlanet(planet))
    }
    
    func testSavePlanetFailure() {
        class MockFailingContext: NSManagedObjectContext {
            override func save() throws {
                throw NSError(domain: "TestErrorDomain", code: 9999, userInfo: [NSLocalizedDescriptionKey: "Mock save error"])
            }
        }
        
        class MockFailingPersistentContainer: MockPersistentContainer {
            override func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
                let context = MockFailingContext(concurrencyType: .privateQueueConcurrencyType)
                block(context)
            }
        }
        
        let mockFailingContainer = MockFailingPersistentContainer()
        persistenceManager = PersistenceManager(container: mockFailingContainer)
        
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
        
        XCTAssertThrowsError(try persistenceManager.savePlanet(planet)) { error in
            XCTAssertEqual((error as NSError).domain, "TestErrorDomain")
            XCTAssertEqual((error as NSError).code, 9999)
        }
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

class MockFailingPersistentContainer: PersistentContainer {
    var viewContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        return context
    }()
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        block(context)
    }
    
    func loadPersistentStores(completionHandler: @escaping (NSPersistentStoreDescription, Error?) -> Void) {
        let description = NSPersistentStoreDescription()
        let error = NSError(domain: "TestErrorDomain", code: 9999, userInfo: [NSLocalizedDescriptionKey: "Mock load error"])
        completionHandler(description, error)
    }
}
