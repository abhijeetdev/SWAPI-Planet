//
//  Planet.swift
//  StarWars
//
//  Created by Abhijeet Banarase on 28/09/2024.
//

import Foundation

struct Planet: Decodable, Identifiable, Hashable {
    let id = UUID()
    
    let name: String
    let rotationPeriod: String
    let orbitalPeriod: String
    let diameter: String
    let climate: String
    let gravity: String
    let terrain: String
    let surfaceWater: String
    let population: String
    let residents: [String]
    let films: [String]
    let created: String
    let edited: String
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case name, diameter, climate, gravity, terrain, population, residents, films, created, edited, url
        case rotationPeriod = "rotation_period"
        case orbitalPeriod = "orbital_period"
        case surfaceWater = "surface_water"
    }
}

extension Planet {
    init(entity: PlanetEntity) {
        self.name = entity.name ?? ""
        self.rotationPeriod =  entity.rotationPeriod ?? ""
         self.orbitalPeriod =  entity.orbitalPeriod ?? ""
         self.diameter =  entity.diameter ?? ""
         self.climate =  entity.climate ?? ""
         self.gravity =  entity.gravity ?? ""
         self.terrain =  entity.terrain ?? ""
         self.surfaceWater =  entity.surfaceWater ?? ""
         self.population =  entity.population ?? ""
         self.residents =  []
         self.films =  []
         self.created =  ""
         self.edited =  ""
         self.url =  ""
    }
}
