import Foundation

enum APIError: Error {
    case networkError
    case decodingError
    case noData
    case serverError(String)
}

class DigitransitAPI {
    private let baseURL = "https://api.digitransit.fi/routing/v1/routers/hsl/index/graphql"
    private let apiKey = "8ccd253267a4423ea1d0838e9ea9dc5e"
    
    func fetchDepartures(for stopId: String) async throws -> [Departure] {
        let formattedStopId = stopId.hasPrefix("HSL:") ? stopId : "HSL:\(stopId)"

        let query = """
        {
          stop(id: "\(formattedStopId)") {
            name
            stoptimesWithoutPatterns(numberOfDepartures: 10) {
              scheduledDeparture
              realtimeDeparture
              departureDelay
              realtime
              realtimeState
              serviceDay
              headsign
              trip {
                routeShortName
              }
            }
          }
        }
        """
        
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "digitransit-subscription-key")
        request.httpBody = try? JSONEncoder().encode(["query": query])
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let json = try JSONDecoder().decode(DigitransitResponse.self, from: data)
            return json.data.stop.stoptimesWithoutPatterns.map { stoptime in
                Departure(id: UUID().uuidString,
                          route: stoptime.trip.routeShortName,
                          scheduledDeparture: stoptime.serviceDay + stoptime.scheduledDeparture,
                          headsign: stoptime.headsign)
            }
        } catch {
            throw APIError.networkError
        }
    }
}

struct DigitransitResponse: Codable {
    let data: StopData
}

struct StopData: Codable {
    let stop: Stop
}

struct Stop: Codable {
    let name: String
    let stoptimesWithoutPatterns: [Stoptime]
}

struct Stoptime: Codable {
    let scheduledDeparture: Int
    let serviceDay: Int
    let trip: Trip
    let headsign: String
}

struct Trip: Codable {
    let routeShortName: String
}
