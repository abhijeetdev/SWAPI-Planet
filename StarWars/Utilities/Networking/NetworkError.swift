//
//  NetworkError.swift
//  StarWars
//
//  Created by Abhijeet Banarase on 29/09/2024.
//

import Foundation

enum NetworkError: Error, Equatable {
    case apiError(reason: String)
    case badRequest
    case badResponse
    case networkError(from: URLError)
    case unknown
    
    static func error(code: Int) -> NetworkError {
        switch code {
        case 401:
            return .apiError(reason: "Unauthorized")
        case 403:
            return .apiError(reason: "Resource forbidden")
        case 404:
            return .apiError(reason: "Resource not found")
        case 405..<500:
            return .apiError(reason: "Client error")
        case 500..<600:
            return .apiError(reason: "Server Error")
        default:
            return .unknown
        }
    }
}
