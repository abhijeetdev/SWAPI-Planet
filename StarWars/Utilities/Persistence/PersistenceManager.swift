//
//  PersistenceController.swift
//  StarWars
//
//  Created by Abhijeet Banarase on 28/09/2024.
//

import CoreData

protocol PersistenceManagerProtocol {
    var container: PersistentContainer { get }
    func savePlanet(_ planet: Planet) throws
}

final class PersistenceManager: PersistenceManagerProtocol {
    /// The Core Data persistent container.
    let container: PersistentContainer
    
    /// Initializes the `PersistenceManager` with a given persistent container.
    ///
    /// - Parameter container: The persistent container conforming to `PersistentContainerProtocol`.
    init(container: PersistentContainer = NSPersistentContainer(name: "PlanetModel")) {
        self.container = container
        self.container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                //TODO: Find proper soluton to handle this issue.
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    /// Saves a `Planet` object to the Core Data store.
    ///
    /// - Parameter planet: The `Planet` object to be saved.
    /// - Throws: An error if the save operation fails.
    func savePlanet(_ planet: Planet) throws {
        var saveError: Error?
        
        container.performBackgroundTask { context in
            let planetEntity = PlanetEntity(context: context)
            planetEntity.id = planet.id
            planetEntity.name = planet.name
            planetEntity.rotationPeriod = planet.rotationPeriod
            planetEntity.orbitalPeriod = planet.orbitalPeriod
            planetEntity.diameter = planet.diameter
            planetEntity.climate = planet.climate
            planetEntity.gravity = planet.gravity
            planetEntity.terrain = planet.terrain
            planetEntity.surfaceWater = planet.surfaceWater
            planetEntity.population = planet.population
            
            do {
                try context.save()
            } catch {
                saveError = error
                print("Failed to save planet: \(error)")
            }
        }
        
        if let error = saveError {
            throw error
        }
    }
}

protocol PersistentContainer {
    var viewContext: NSManagedObjectContext {get}
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void)
    func loadPersistentStores(completionHandler: @escaping (NSPersistentStoreDescription, Error?) -> Void)
}

extension NSPersistentContainer: PersistentContainer {}
