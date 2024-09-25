//
//  TransitStop.swift
//  HslStopBrowser
//
//  Created by Francesco Balestrieri on 25.9.2024.
//

import CoreLocation

struct TransitStop: Identifiable {
    let id: String
    let coordinate: CLLocationCoordinate2D
    let name: String
}
