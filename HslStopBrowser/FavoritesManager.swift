//
//  FavoritesManager.swift
//  HslStopBrowser
//
//  Created by Francesco Balestrieri on 25.9.2024.
//


import Foundation

class FavoritesManager: ObservableObject {
    @Published private(set) var favoriteStops: Set<String> = Set()
    
    func toggleFavorite(for stopId: String) {
        if favoriteStops.contains(stopId) {
            favoriteStops.remove(stopId)
        } else {
            favoriteStops.insert(stopId)
        }
    }
    
    func isFavorite(_ stopId: String) -> Bool {
        favoriteStops.contains(stopId)
    }
}
