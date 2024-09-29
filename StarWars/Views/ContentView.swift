//
//  ContentView.swift
//  StarWars
//
//  Created by Abhijeet Banarase on 27/09/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: PlanetViewModel
    @State private var selectedPlanet: Planet?
    
    init(networkService: NetworkServices,
         persistenceService: PersistenceServices
    ) {
        _viewModel = StateObject(wrappedValue:
                                    PlanetViewModel(
            service: PlanetService(
                networkService: networkService,
                persistenceService: persistenceService
            )))
    }
    
    var body: some View {
        NavigationView {
            PlanetListView(planets: viewModel.planets)
            .overlay(Group {
                if viewModel.isLoading {
                    ProgressView()
                }
            })
            .onAppear {
                if viewModel.planets.isEmpty {
                    viewModel.fetchPlanets()
                }
            }
            .alert("Error", isPresented: Binding<Bool>(
                get: { viewModel.error != nil },
                set: { if !$0 { viewModel.error = nil } }
            ), presenting: viewModel.error) { error in
                Button("OK") { }
            } message: { error in
                Text(error.localizedDescription)
            }
            
            // Default view for iPad
            Text("Select a planet")
        }
    }
}

//#Preview {
//    ContentView(networkService: NetworkServices.shared, persistenceService: PersistenceServices.shared)
//}
