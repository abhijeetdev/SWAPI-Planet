//
//  PlanetDetailView.swift
//  StarWars
//
//  Created by Abhijeet Banarase on 28/09/2024.
//

import SwiftUI

struct PlanetDetailView: View {
    let planet: Planet
    
    var body: some View {
        List {
            Section(header: Text("Basic Info")) {
                LabeledCell("Name", value: planet.name)
                LabeledCell("Climate", value: planet.climate)
                LabeledCell("Terrain", value: planet.terrain)
            }
            
            Section(header: Text("Physical Characteristics")) {
                LabeledCell("Diameter", value: planet.diameter)
                LabeledCell("Gravity", value: planet.gravity)
                LabeledCell("Surface Water", value: planet.surfaceWater)
            }
            
            Section(header: Text("Orbital Characteristics")) {
                LabeledCell("Rotation Period", value: planet.rotationPeriod)
                LabeledCell("Orbital Period", value: planet.orbitalPeriod)
            }
            
            Section(header: Text("Demographics")) {
                LabeledCell("Population", value: planet.population)
            }
        }
        .navigationTitle(planet.name)
    }
}

struct LabeledCell: View {
    let label: String
    let value: String
    
    init(_ label: String, value: String) {
        self.label = label
        self.value = value
    }
    
    var body: some View {
        HStack{
            Text("\(label)")
                .bold()
            Spacer()
            Text("\(value)")
                .foregroundStyle(.secondary)
        }
    }
}

