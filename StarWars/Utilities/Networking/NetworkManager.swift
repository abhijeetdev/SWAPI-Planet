//
//  NetworkManager.swift
//  StarWars
//
//  Created by Abhijeet Banarase on 28/09/2024.
//

import Foundation
import Combine

protocol NetworkManagerProtocol {
    func load(_ url: URL?) -> AnyPublisher<Data, NetworkError>
}

/// A manager responsible for handling network requests.
final class NetworkManager: NetworkManagerProtocol {
    
    /// The session used to perform network tasks.
    private let session: NetworkSession
    
    /// Initializes a new instance of `NetworkManager`.
    ///
    /// - Parameter session: The session used to perform network tasks. Defaults to `URLSession.shared`.
    init(session: NetworkSession = URLSession.shared) {
        self.session = session
    }
    
    /// Loads data from the specified URL.
    ///
    /// - Parameter url: The URL to load data from.
    /// - Returns: A publisher that emits the loaded data or a `NetworkError`.
    func load(_ url: URL?) -> AnyPublisher<Data, NetworkError> {
        guard let url else {
            return Fail(error: NetworkError.badRequest).eraseToAnyPublisher()
        }
        
        let request = URLRequest(url: url)
        return session.networkTaskPublisher(for: request)
            .tryMap { (data: Data, response: URLResponse) in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.badResponse
                }
                
                guard httpResponse.statusCode == 200 || httpResponse.statusCode == 300 else {
                    throw NetworkError.error(code: httpResponse.statusCode)
                }
                
                return data
            }
            .mapError { error in
                if let networkError = error as? NetworkError {
                    return networkError
                }
                
                if let urlError = error as? URLError {
                    return NetworkError.networkError(from: urlError)
                }
                
                return NetworkError.unknown
            }
            .eraseToAnyPublisher()
    }
}

/// A protocol defining the requirements for a network session.
protocol NetworkSession {
    /// Creates a publisher that wraps a network task for the given request.
    ///
    /// - Parameter request: The request to perform.
    /// - Returns: A publisher that emits the data and response or a `URLError`.
    func networkTaskPublisher(for request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError>
}

extension URLSession: NetworkSession {
    /// Creates a publisher that wraps a network task for the given request.
    ///
    /// - Parameter request: The request to perform.
    /// - Returns: A publisher that emits the data and response or a `URLError`.
    func networkTaskPublisher(for request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        return self.dataTaskPublisher(for: request).eraseToAnyPublisher()
    }
}
