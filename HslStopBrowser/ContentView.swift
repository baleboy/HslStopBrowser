import SwiftUI
@_spi(Experimental) import MapboxMaps

let initialZoom: Double = 16
let defaultPitch: Double = 30

struct ContentView: View {
    @State private var selectedStop: TransitStop?
    @State private var viewport: Viewport = .idle
    @StateObject private var departuresViewModel = DeparturesViewModel()
    @State private var isSheetPresented = false
    
    var body: some View {
        Map(viewport: $viewport) {
            
            Puck2D(bearing: .heading)
                .topImage(UIImage(named: "puck"))
                .bearingImage(nil)

            TapInteraction(.layer("hsl-stops")) { feature, context in
                handleTransitStopSelection(feature: feature, context: context)
                return true
            }
        }
        .mapStyle(.hslTransitMapStyle)
        .ornamentOptions(OrnamentOptions(compass: CompassViewOptions(visibility: .visible)))
        .ignoresSafeArea()
        .overlay(alignment: .bottomTrailing) {
            LocationFollowButton(
                isCameraFollowingUser: isCameraFollowingUser) {
                if (!isCameraFollowingUser) {
                    followUser()
                } else {
                    unfollowUser()
                }
            }
        }
        .onAppear() {
            followUser()
        }
        .sheet(isPresented: $isSheetPresented) {
            DeparturesSheet(stop: selectedStop, departures: departuresViewModel.departures)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
    
    private var isCameraFollowingUser: Bool {
        return viewport.followPuck != nil
    }
    
    private func handleTransitStopSelection(feature: InteractiveFeature, context: InteractionContext) {
        if case .string(let stopName) = feature.properties?["stop_name"] as? Turf.JSONValue,
           case .string(let stopId) = feature.properties?["stop_id"] as? Turf.JSONValue {
            if let coordinate = feature.geometry.point?.coordinates {
                let newStop = TransitStop(id: stopId, coordinate: coordinate, name: stopName)
                selectedStop = newStop
                isSheetPresented = true
                departuresViewModel.fetchDepartures(for: stopId)
                print("Selected transit stop: \(stopName)")
            }

        } else {
            print("Tapped a stop, but couldn't get the name or ID")
        }
    }
    
    private func followUser() {
        withViewportAnimation(.easeIn(duration: 0.4)) {
        viewport = .followPuck(
            zoom: initialZoom, bearing: .constant(0), pitch: defaultPitch)
        }
    }
    
    private func unfollowUser() {
        viewport = .idle
    }

}

struct TransitStop: Identifiable {
    let id: String
    let coordinate: CLLocationCoordinate2D
    let name: String
}

extension MapStyle {
    static let hslTransitMapStyle = MapStyle(uri: StyleURI(rawValue: "mapbox://styles/baleboy/cm10be3wu01d601o3e49ncww4")!)
}

#Preview {
    ContentView()
}
