//
//  StopDrawer.swift
//  HslStopBrowser
//
//  Created by Francesco Balestrieri on 14.9.2024.
//

import SwiftUI
import CoreLocation

struct StopDrawer: View {
    @Binding var isOpen: Bool
    let stop: TransitStop?
    let departures: [Departure]
    
    private let maxHeight: CGFloat = UIScreen.main.bounds.height * 0.4
    @State private var translation: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Handle()
                
                if let stop = stop {
                    StopContent(stop: stop, departures: departures)
                } else {
                    Text("No stop selected")
                        .padding()
                }
            }
            .frame(height: maxHeight)
            .background(Color(.systemBackground))
            .cornerRadius(20, corners: [.topLeft, .topRight])
            .shadow(radius: 5)
            .offset(y: max(self.translation, 0))
            .animation(.interactiveSpring(), value: isOpen)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        self.translation = value.translation.height
                    }
                    .onEnded { value in
                        if value.translation.height > 50 {
                            withAnimation(.interactiveSpring()) {
                                self.isOpen = false
                            }
                        }
                        self.translation = 0
                    }
            )
            .offset(y: isOpen ? geometry.size.height - maxHeight : geometry.size.height)
        }
    }
}

struct Handle: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(Color.secondary)
            .frame(width: 40, height: 5)
            .padding(.top, 10)
            .padding(.bottom, 5)
    }
}

struct StopContent: View {
    let stop: TransitStop
    let departures: [Departure]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(stop.name)
                .font(.title)
                .padding(.horizontal)
            
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
        }
    }
    
    private func formatDepartureTime(_ time: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(time))
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// Existing extension for corner radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

let sampleStop = TransitStop(id: "HSL:1020124", coordinate: CLLocationCoordinate2D(latitude: 60.1699, longitude: 24.9384), name: "Helsinki Central Railway Station")
let sampleDepartures = [
    Departure(id: "1", route: "550", scheduledDeparture: Int(Date().timeIntervalSince1970) + 300),
    Departure(id: "2", route: "560", scheduledDeparture: Int(Date().timeIntervalSince1970) + 600),
    Departure(id: "3", route: "570", scheduledDeparture: Int(Date().timeIntervalSince1970) + 900)
]

#Preview("Closed") {
    return ZStack {
        StopDrawer(isOpen: .constant(false), stop: sampleStop, departures: sampleDepartures)
    }
}

#Preview("Open") {
    return ZStack {
        StopDrawer(isOpen: .constant(true), stop: sampleStop, departures: sampleDepartures)
    }
}
