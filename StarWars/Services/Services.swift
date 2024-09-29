//
//  ApiService.swift
//  StarWars
//
//  Created by Abhijeet Banarase on 28/09/2024.
//

import Foundation
import Combine

enum ServiceError: Error {
    case unknown
    case networkError(error: NetworkError)
    case parsingError(error: Error)
    case persistenceError(error: PersistenceError)
}

protocol Services {
    func fetchPlanets(page: String?) -> AnyPublisher<RootResult<Planet>, ServiceError>
}
