//
//  PlanetListView.swift
//  StarWars
//
//  Created by Abhijeet Banarase on 29/09/2024.
//

import SwiftUI

struct PlanetListView: View {
    let planets: [Planet]
    @State private var selectedPlanet: Planet?
    
    var body: some View {
        List(planets, selection: $selectedPlanet) { planet in
            NavigationLink(destination: PlanetDetailView(planet: planet)) {
                Text(planet.name)
            }
        }
        .navigationTitle("Planets")
    }
}

#Preview {
    PlanetListView(planets: [
        Planet(
            name: "Mock Planet Name",
            rotationPeriod: "Mock Rotation Period",
            orbitalPeriod: "Mock Orbital Period",
            diameter: "Mock Diameter",
            climate: "Mock Climate",
            gravity: "Mock Gravity",
            terrain: "Mock Terrain",
            surfaceWater: "Mock Surface Water",
            population: "Mock Population",
            residents: ["https://swapi.co/api/people/mock"],
            films: ["https://swapi.co/api/films/mock"],
            created: "Mock created",
            edited: "Mock edited",
            url: "Mock URl"
        )
    ]
                  )
}
