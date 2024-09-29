//
//  URLBuilder.swift
//  StarWars
//
//  Created by Abhijeet Banarase on 28/09/2024.
//

import Foundation

/// A struct to build URLs for the Star Wars API (SWAPI).
struct URLBuilder {
    
    /// An enum representing the different resources available in the SWAPI.
    enum Resource: String {
        case planets
    }
    
    /// The URL scheme (e.g., "https").
    private let scheme = "https"
    
    /// The host of the SWAPI.
    private let host = "swapi.dev"
    
    /// The base path for the API.
    private let path = "/api"
    
    /// The specific resource to be accessed.
    private let resource: Resource?
    
    /// Computed property to create the base URL components.
    private var urlComponents: URLComponents {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        return components
    }
    
    /// Computed property to create the base API URL.
    private var baseApi: URL? {
        var baseComponents = urlComponents
        baseComponents.path = path + "/"
        return baseComponents.url
    }
    
    /// Computed property to create the full URL for the specified resource.
    var url: URL? {
        guard let resourceRoot = resource?.rawValue else { return baseApi }
        var resourceComponents = urlComponents
        let rootPath = path.urlPath(withComponents: [resourceRoot])
        resourceComponents.path = rootPath
        return resourceComponents.url
    }
    
    /// Initializes the URLBuilder with an optional resource.
    /// - Parameter resource: The resource to be accessed (e.g., planets).
    init(resource: Resource? = nil) {
        self.resource = resource
    }
    
    /// Creates a URL for a specific resource with an ID.
    /// - Parameter id: The ID of the resource.
    /// - Returns: The full URL for the resource with the specified ID.
    func url(id: String) -> URL? {
        guard let resourceRoot = resource?.rawValue else { return nil }
        
        var resourceComponents = urlComponents
        let resourcePath = path.urlPath(withComponents: [resourceRoot, id])
        resourceComponents.path = resourcePath
        return resourceComponents.url
    }
}

/// An extension to add a helper method for creating URL paths.
private extension String {
    /// Creates a URL path by appending the specified components.
    /// - Parameter pathComponents: The components to be appended to the path.
    /// - Returns: The full URL path as a string.
    func urlPath(withComponents pathComponents: [String]) -> String {
        (self as NSString).appendingPathComponent(pathComponents.joined(separator: "/")) + "/"
    }
}

protocol URLBuilderProtocol {
    var url: URL? { get }
    func url(id: String) -> URL?
}

extension URLBuilder: URLBuilderProtocol {}
