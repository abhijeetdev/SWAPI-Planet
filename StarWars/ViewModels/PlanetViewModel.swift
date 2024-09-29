//
//  PlanetViewModel.swift
//  StarWars
//
//  Created by Abhijeet Banarase on 28/09/2024.
//

import Foundation
import Combine
import SwiftUI
import CoreData

/// A view model responsible for managing and providing data related to planets.
/// This class is marked with `@MainActor` to ensure that all its properties and methods
/// are accessed and modified on the main thread.
@MainActor
class PlanetViewModel: ObservableObject {
    /// An array of `Planet` objects that represents the list of planets.
    @Published var planets: [Planet] = []
    
    /// A boolean flag indicating whether the data is currently being loaded.
    @Published var isLoading = false
    
    /// An optional `Error` object that holds any error encountered during data fetching.
    @Published var error: Error?
    
    /// A set of cancellable objects used to manage the lifecycle of Combine subscriptions.
    private var cancellables = Set<AnyCancellable>()
    
    /// The service responsible for fetching planet data.
    let service: PlanetService
    
    /// Initializes a new instance of `PlanetViewModel` with the provided `PlanetService`.
    ///
    /// - Parameter service: The service used to fetch planet data.
    init(service: PlanetService) {
        self.service = service
        //fetchPlanets()
    }
    
    /// Fetches the list of planets from the service.
    /// This method sets the `isLoading` flag to true and clears any existing error.
    /// Upon completion, it updates the `planets` array with the fetched data or sets the `error` property if an error occurs.
    func fetchPlanets() {
        isLoading = true
        error = nil
        
        service
            .fetchPlanets(page: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] rootResult in
                self?.planets.append(contentsOf: rootResult.results)
            }
            .store(in: &cancellables)
    }
}
