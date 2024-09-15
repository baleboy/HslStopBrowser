import SwiftUI
@_spi(Experimental) import MapboxMaps

let initialZoom: Double = 14.4
let defaultPitch: Double = 30

struct ContentView: View {
    @State private var selectedStop: TransitStop?
    @State private var viewport: Viewport = .followPuck(zoom: initialZoom, bearing: .constant(0))
    @State private var isDrawerOpen = false
        @StateObject private var departuresViewModel = DeparturesViewModel()
    
    var body: some View {
        ZStack {
            Map(viewport: $viewport) {
                
                Puck2D(bearing: .heading)
                
                TapInteraction(.layer("hsl-stops")) { feature, context in
                    handleTransitStopSelection(feature: feature, context: context)
                    return true
                }
            }
            .mapStyle(.hslTransitMapStyle)
            .ignoresSafeArea()
            
            StopDrawer(isOpen: $isDrawerOpen, stop: selectedStop, departures: departuresViewModel.departures)
        }
    }
    
    private func handleTransitStopSelection(feature: InteractiveFeature, context: InteractionContext) {
            if case .string(let stopName) = feature.properties?["stop_name"] as? Turf.JSONValue,
               case .string(let stopId) = feature.properties?["stop_id"] as? Turf.JSONValue {
                let newStop = TransitStop(id: stopId, coordinate: context.coordinate, name: stopName)
                selectedStop = newStop
                isDrawerOpen = true
                departuresViewModel.fetchDepartures(for: stopId)
                print("Selected transit stop: \(stopName)")
            } else {
                print("Tapped a stop, but couldn't get the name or ID")
            }
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
