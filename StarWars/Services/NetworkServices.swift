//
//  NatewokServices.swift
//  StarWars
//
//  Created by Abhijeet Banarase on 29/09/2024.
//

import Foundation
import Combine

/// `NetworkServices` is a struct that conforms to the `Services` protocol. It is responsible for
/// handling network requests and decoding the responses.
///
/// - Parameters:
///   - networkManager: An instance conforming to `NetworkManagerProtocol` responsible for making network requests.
///   - builder: An instance conforming to `URLBuilderProtocol` responsible for building URLs.
///   - decode: A closure that takes `Data` and returns an `AnyPublisher` of `RootResult<Planet>` or `ServiceError`.
class NetworkServices: Services {
    
    private let networkManager: NetworkManagerProtocol
    private let builder: URLBuilderProtocol
    private let decode: (Data) -> AnyPublisher<RootResult<Planet>, ServiceError>?
    
    /// Initializes a new instance of `NetworkServices`.
    ///
    /// - Parameters:
    ///   - networkManager: An instance conforming to `NetworkManagerProtocol`. Defaults to `NetworkManager()`.
    ///   - builder: An instance conforming to `URLBuilderProtocol`. Defaults to `URLBuilder(resource: .planets)`.
    ///   - decode: A closure that takes `Data` and returns an `AnyPublisher` of `RootResult<Planet>` or `ServiceError`.
    ///             Defaults to `decode(_:)`.
    init(networkManager: NetworkManagerProtocol = NetworkManager(),
         builder: URLBuilderProtocol = URLBuilder(resource: .planets),
         decode: @escaping (Data) -> AnyPublisher<RootResult<Planet>, ServiceError> = decode(_:)
    ) {
        self.networkManager = networkManager
        self.builder = builder
        self.decode = decode
    }
    
    /// Fetches a list of planets.
    ///
    /// - Parameter page: An optional string representing the page URL. Defaults to `nil`.
    /// - Returns: An `AnyPublisher` of `RootResult<Planet>` or `ServiceError`.
    func fetchPlanets(page: String? = nil) -> AnyPublisher<RootResult<Planet>, ServiceError> {
        guard let pageUrl = page else {
            return resource(url: builder.url)
        }
        
        return resource(url: URL(string: pageUrl))
    }
    //
    //     Work on this later
    //    /// Fetches a list of films.
    //    ///
    //    /// - Parameter urls: An array of strings representing the URLs of the films.
    //    /// - Returns: An `AnyPublisher` of `[Film]` or `ServiceError`.
    //    func fetchfilms(urls: [String]) -> AnyPublisher<[Film], ServiceError> {
    //
    //    }
    //
    //    /// Fetches a list of people.
    //    ///
    //    /// - Parameter urls: An array of strings representing the URLs of the people.
    //    /// - Returns: An `AnyPublisher` of `[Person]` or `ServiceError`.
    //    func people(urls: [String]) -> AnyPublisher<[Person], ServiceError> {
    //
    //    }
    
    /// Fetches a resource from the given URL.
    ///
    /// - Parameter url: An optional `URL` representing the resource URL.
    /// - Returns: An `AnyPublisher` of a generic type `T` conforming to `Decodable` or `ServiceError`.
    private func resource<T: Decodable>(url: URL?) -> AnyPublisher<T, ServiceError> {
        return networkManager.load(url)
            .mapError { error in
                ServiceError.networkError(error: error)
            }
            .flatMap(maxPublishers: .max(1)) { data in
                self.decode(data) as! AnyPublisher<T, ServiceError>
            }
            .eraseToAnyPublisher()
    }
}
