//
//  PlanetSevices.swift
//  StarWars
//
//  Created by Abhijeet Banarase on 29/09/2024.
//

import Foundation
import Combine

/// A PlanetService class responsible for fetching planet data.
class PlanetService: Services {
    private let networkService: NetworkServices
    private let persistenceService: PersistenceServices

    /// Initializes a new instance of `PlanetService`.
    ///
    /// - Parameters:
    ///   - networkService: The service responsible for network operations.
    ///   - persistenceService: The service responsible for data persistence operations.
    init(networkService: NetworkServices, persistenceService: PersistenceServices) {
        self.networkService = networkService
        self.persistenceService = persistenceService
    }
    
    /// Fetches planets data, either from persistence storage or network.
    ///
    /// - Parameter page: An optional parameter to specify the page of data to fetch.
    /// - Returns: A publisher that emits `RootResult<Planet>` on success or `ServiceError` on failure.
    func fetchPlanets(page: String? = nil) -> AnyPublisher<RootResult<Planet>, ServiceError> {
        return persistenceService.fetchPlanets(page: page)
            .catch { _ in
                // If persistence data is not available, fetch from network
                return self.networkService.fetchPlanets(page: page)
                    .flatMap { result -> AnyPublisher<RootResult<Planet>, ServiceError> in
                        // Save the fetched data persistently
                        return self.persistenceService.savePlanets(result.results)
                            .map { _ in result }
                            .eraseToAnyPublisher()
                    }
            }
            .eraseToAnyPublisher()
    }
}

