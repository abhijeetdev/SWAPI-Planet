//
//  PersistenceServices.swift
//  StarWars
//
//  Created by Abhijeet Banarase on 29/09/2024.
//

import Foundation
import CoreData
import Combine

/// Enum representing possible errors that can occur during persistence operations.
enum PersistenceError: Error {
    /// Error related to data issues with a specific reason.
    case dataError(reason: String)
    /// Error that occurred during fetching, wrapping the original error.
    case fetchError(from: Error)
}

/// A service class responsible for handling persistence-related operations.
class PersistenceServices: Services {
    /// Shared instance of `PersistenceServices`.
    static let shared = PersistenceServices()
    
    /// The persistence manager conforming to `PersistenceManagerProtocol`.
    private let persistenceManager: PersistenceManagerProtocol
    
    /// The context used for fetching data, conforming to `Fetchable`.
    private let fetchableContext: Fetchable
    
    /// The view context from the persistence manager's container.
    var viewContext: NSManagedObjectContext {
        return persistenceManager.container.viewContext
    }
    
    /// Initializes a new instance of `PersistenceServices`.
    ///
    /// - Parameters:
    ///   - manager: The persistence manager to use. Defaults to a new instance of `PersistenceManager`.
    ///   - fetchableContext: The context used for fetching data. Defaults to the view context of the manager's container.
    init(manager: PersistenceManagerProtocol = PersistenceManager(), fetchableContext: Fetchable? = nil) {
        self.persistenceManager = manager
        self.fetchableContext = fetchableContext ?? manager.container.viewContext
    }
    
    /// Fetches planets from the persistence store.
    ///
    /// - Parameter page: The page number for pagination (optional).
    /// - Returns: A publisher emitting a `RootResult` containing the fetched planets or a `ServiceError`.
    func fetchPlanets(page: String?) -> AnyPublisher<RootResult<Planet>, ServiceError> {
        let fetchRequest: NSFetchRequest<PlanetEntity> = PlanetEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \PlanetEntity.name, ascending: true)]
        
        return Future<RootResult<Planet>, ServiceError> { promise in
            do {
                let planetEntities = try self.fetchableContext.fetch(fetchRequest)
                guard !planetEntities.isEmpty else {
                    promise(.failure(.persistenceError(error: .dataError(reason: "No data Available"))))
                    return
                }
                
                let savedPlanets = planetEntities.compactMap { entity in
                    return Planet(entity: entity)
                }
                
                // TODO: if Pagination is required update next and previous values accordingly
                promise(.success(RootResult(count: savedPlanets.count, next: nil, previous: nil, results: savedPlanets)))
            } catch {
                promise(.failure(ServiceError.persistenceError(error: PersistenceError.fetchError(from: error))))
            }
        }
        .eraseToAnyPublisher()
    }
    
    /// Saves an array of planets to the persistence store.
    ///
    /// - Parameter planets: The array of `Planet` objects to save.
    /// - Returns: A publisher emitting `Void` on success or a `ServiceError` on failure.
    func savePlanets(_ planets: [Planet]) -> AnyPublisher<Void, ServiceError> {
        return Future { promise in
            do {
                try planets.forEach { planet in
                    try self.persistenceManager.savePlanet(planet)
                }
                promise(.success(()))
            } catch {
                promise(.failure(ServiceError.persistenceError(error: .fetchError(from: error))))
            }
        }.eraseToAnyPublisher()
    }
}

/// Protocol defining a fetchable context.
protocol Fetchable {
    /// Fetches objects of a specified type from the context.
    ///
    /// - Parameter request: The fetch request specifying the type of objects to fetch.
    /// - Returns: An array of fetched objects.
    /// - Throws: An error if the fetch fails.
    func fetch<T: NSFetchRequestResult>(_ request: NSFetchRequest<T>) throws -> [T]
}

/// Extension to make `NSManagedObjectContext` conform to `Fetchable`.
extension NSManagedObjectContext: Fetchable {}
