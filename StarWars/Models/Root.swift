//
//  Root.swift
//  StarWars
//
//  Created by Abhijeet Banarase on 28/09/2024.
//

import Foundation

struct RootResult<T: Decodable>: Decodable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [T]
}
