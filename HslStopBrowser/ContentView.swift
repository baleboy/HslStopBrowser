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
        ZStack {
            Map(viewport: $viewport) {
                
                Puck2D(bearing: .heading)
                
                TapInteraction(.layer("hsl-stops")) { feature, context in
                    handleTransitStopSelection(feature: feature, context: context)
                    return true
                }
            }
            .mapStyle(.hslTransitMapStyle)
            .ornamentOptions(OrnamentOptions(compass: CompassViewOptions(visibility: .visible)))
            .ignoresSafeArea()
        }
        .onAppear() {
            viewport = .followPuck(zoom: initialZoom, bearing: .constant(0), pitch: defaultPitch)
        }
        .sheet(isPresented: $isSheetPresented) {
            DeparturesSheet(stop: selectedStop, departures: departuresViewModel.departures)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
    
    private func handleTransitStopSelection(feature: InteractiveFeature, context: InteractionContext) {
            if case .string(let stopName) = feature.properties?["stop_name"] as? Turf.JSONValue,
               case .string(let stopId) = feature.properties?["stop_id"] as? Turf.JSONValue {
                let newStop = TransitStop(id: stopId, coordinate: context.coordinate, name: stopName)
                selectedStop = newStop
                isSheetPresented = true
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
