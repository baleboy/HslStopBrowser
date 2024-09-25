//
//  DeparturesViewModel.swift
//  HslStopBrowser
//
//  Created by Francesco Balestrieri on 15.9.2024.
//

import Foundation

import SwiftUI

@MainActor
class DeparturesViewModel: ObservableObject {
    @Published var departures: [Departure] = []
    @Published var errorMessage: String?
    
    private let api = DigitransitAPI()
    
    func fetchDepartures(for stopId: String) {
        Task {
            do {
                self.departures = try await api.fetchDepartures(for: stopId)
                self.errorMessage = nil
            } catch {
                self.departures = []
                self.errorMessage = "Failed to fetch departures: \(error.localizedDescription)"
            }
        }
    }
}

struct Departure: Identifiable {
    let id: String
    let route: String
    let scheduledDeparture: Int
    let headsign: String
}

