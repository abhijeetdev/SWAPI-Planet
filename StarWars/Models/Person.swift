//
//  Person.swift
//  StarWars
//
//  Created by Abhijeet Banarase on 28/09/2024.
//

import Foundation

struct Person: Decodable, Hashable {
    let name: String
    let height: String
    let mass: String
    let hairColor: String
    let skinColor: String
    let eyeColor: String
    let birthYear: String
    let gender: String
    let homeworld: String
    let films: [String]
    let species: [String]
    let vehicles: [String]
    let starships: [String]
    let created: Date
    let edited: Date
    let url: String

  enum CodingKeys: String, CodingKey {
      case name, height, mass, gender, homeworld, films, species, vehicles, starships, created, edited, url
      case hairColor = "hair_color"
      case skinColor = "skin_color"
      case eyeColor = "eye_color"
      case birthYear = "birth_year"
  }
}
