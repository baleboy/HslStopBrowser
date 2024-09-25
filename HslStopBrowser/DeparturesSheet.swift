//
//  DeparturesSheet.swift
//  HslStopBrowser
//
//  Created by Francesco Balestrieri on 15.9.2024.
//

import SwiftUI
import CoreLocation

struct DeparturesSheet: View {
    let stop: TransitStop?
    let departures: [Departure]
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                if let stop = stop {
                    HStack {
                        Text(stop.name)
                            .font(.headline)
                        Spacer()
                        Button(action: onFavoriteToggle) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .foregroundColor(isFavorite ? .red : .gray)
                        }
                    }
                    .padding()
                    
                    
                    if departures.isEmpty {
                        Text("No upcoming departures")
                            .padding()
                    } else {
                        List(departures) { departure in
                            HStack {
                                Text(departure.route)
                                    .font(.headline)
                                Text(departure.headsign)
                                    .font(.caption)
                                    .opacity(0.7)
                                Spacer()
                                Text(formatDepartureTime(departure.scheduledDeparture))
                                    .font(.subheadline)
                            }
                        }
                    }
                } else {
                    Text("No stop selected")
                        .padding()
                }
            }
        }
    }
    
    private func formatDepartureTime(_ time: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(time))
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    let sampleStop = TransitStop(id: "HSL:1020124", coordinate: CLLocationCoordinate2D(latitude: 60.1699, longitude: 24.9384), name: "Helsinki Central Railway Station")
    let sampleDepartures = [
        Departure(id: "1", route: "550", scheduledDeparture: Int(Date().timeIntervalSince1970) + 300, headsign: "headsign 1"),
        
        Departure(id: "2", route: "560", scheduledDeparture: Int(Date().timeIntervalSince1970) + 600, headsign: "headsign 2"),
        Departure(id: "3", route: "570", scheduledDeparture: Int(Date().timeIntervalSince1970) + 900,
                  headsign: "headsign 3")
    ]
    
    return DeparturesSheet(stop: sampleStop, departures: sampleDepartures, isFavorite: false) {}
}
