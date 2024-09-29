//
//  URLBuilderTests.swift
//  StarWarsTests
//
//  Created by Abhijeet Banarase on 29/09/2024.
//

import XCTest
@testable import StarWars

final class URLBuilderTests: XCTestCase {
    
    func testURLBuilderWithResource() {
        // Positive path: URL with resource
        let builder = URLBuilder(resource: .planets)
        let expectedURL = URL(string: "https://swapi.dev/api/planets/")
        XCTAssertEqual(builder.url, expectedURL)
    }
    
    func testURLBuilderWithoutResource() {
        // Positive path: URL without resource
        let builder = URLBuilder()
        let expectedURL = URL(string: "https://swapi.dev/api/")
        XCTAssertEqual(builder.url, expectedURL)
    }
    
    func testURLBuilderWithResourceAndID() {
        // Positive path: URL with resource and ID
        let builder = URLBuilder(resource: .planets)
        let expectedURL = URL(string: "https://swapi.dev/api/planets/1/")
        XCTAssertEqual(builder.url(id: "1"), expectedURL)
    }
    
    func testURLBuilderWithResourceAndInvalidID() {
        // Negative path: URL with resource and invalid ID
        let builder = URLBuilder(resource: .planets)
        let expectedURL = URL(string: "https://swapi.dev/api/planets/invalidID/")
        XCTAssertEqual(builder.url(id: "invalidID"), expectedURL)
    }
    
    func testURLBuilderWithoutResourceAndID() {
        // Negative path: URL without resource and with ID
        let builder = URLBuilder()
        XCTAssertNil(builder.url(id: "1"))
    }
    
    func testURLBuilderWithEmptyResource() {
        // Negative path: URL with empty resource
        let builder = URLBuilder(resource: nil)
        let expectedURL = URL(string: "https://swapi.dev/api/")
        XCTAssertEqual(builder.url, expectedURL)
    }
}
