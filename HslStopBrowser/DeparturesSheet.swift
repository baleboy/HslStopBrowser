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
    
    var body: some View {
        NavigationView {
            VStack {
                if let stop = stop {
                    Text(stop.name)
                        .font(.headline)
                        .padding()
                    
                    if departures.isEmpty {
                        Text("No upcoming departures")
                            .padding()
                    } else {
                        List(departures) { departure in
                            HStack {
                                Text(departure.route)
                                    .font(.headline)
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
            .navigationTitle("Departures")
            .navigationBarTitleDisplayMode(.inline)
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
        Departure(id: "1", route: "550", scheduledDeparture: Int(Date().timeIntervalSince1970) + 300),
        Departure(id: "2", route: "560", scheduledDeparture: Int(Date().timeIntervalSince1970) + 600),
        Departure(id: "3", route: "570", scheduledDeparture: Int(Date().timeIntervalSince1970) + 900)
    ]

    return DeparturesSheet(stop: sampleStop, departures: sampleDepartures)
}
