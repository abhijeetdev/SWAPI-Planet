//
//  MockNetworkSession.swift
//  StarWarsTests
//
//  Created by Abhijeet Banarase on 29/09/2024.
//

import Foundation
import Combine
@testable import StarWars

final class MockNetworkSession: NetworkSession {
    var data: Data?
    var response: URLResponse?
    var error: URLError?
    
    func networkTaskPublisher(for request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        let publisher = PassthroughSubject<(data: Data, response: URLResponse), URLError>()
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            if let error = self.error {
                publisher.send(completion: .failure(error))
            } else if let data = self.data, let response = self.response {
                publisher.send((data: data, response: response))
                publisher.send(completion: .finished)
            }
        }
        
        return publisher.eraseToAnyPublisher()
    }
}
