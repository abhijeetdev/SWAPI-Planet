//
//  StarWarsApp.swift
//  StarWars
//
//  Created by Abhijeet Banarase on 27/09/2024.
//

import SwiftUI

@main
struct StarWarsApp: App {
    let persistenceService = PersistenceServices()
    let networkService = NetworkServices()
    
    var body: some Scene {
        WindowGroup {
            ContentView(networkService: networkService, persistenceService: persistenceService)
                            .environment(\.managedObjectContext, persistenceService.viewContext)
        }
    }
}
