import Foundation
import CoreLocation
import MapKit

// Model for OpenChargeMap API responses
struct ChargingStation: Identifiable, Codable {
    let id: Int
    let uuid: String
    let dataProvider: DataProvider?
    let operatorInfo: OperatorInfo?
    let usageType: UsageType?
    let statusType: StatusType?
    let addressInfo: AddressInfo
    let connections: [Connection]?
    
    // Computed property to create an annotation for MapKit
    func toAnnotation() -> MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(
            latitude: addressInfo.latitude,
            longitude: addressInfo.longitude
        )
        annotation.title = addressInfo.title
        
        // Create subtitle with operator info if available
        var subtitle = "Charging Station"
        if let operatorName = operatorInfo?.title {
            subtitle = operatorName
        }
        annotation.subtitle = subtitle
        
        return annotation
    }
}

struct DataProvider: Codable {
    let websiteURL: String?
    let title: String
}

struct OperatorInfo: Codable {
    let websiteURL: String?
    let title: String
}

struct UsageType: Codable {
    let title: String
}

struct StatusType: Codable {
    let title: String
    let isOperational: Bool
}

struct AddressInfo: Codable {
    let title: String
    let addressLine1: String?
    let town: String?
    let stateOrProvince: String?
    let postcode: String?
    let countryID: Int
    let country: Country
    let latitude: Double
    let longitude: Double
}

struct Country: Codable {
    let title: String
}

struct Connection: Codable {
    let connectionType: ConnectionType?
    let statusType: StatusType?
    let powerKW: Double?
}

struct ConnectionType: Codable {
    let title: String
}

// Service to interact with OpenChargeMap API
class OpenChargeMapService {
    private let apiKey = "2d487708-8ee3-4f80-8001-b48cac0b755f"
    private let baseURL = "https://api.openchargemap.io/v3/poi"
    
    // Fetch charging stations near a location
    func fetchChargingStations(near location: CLLocationCoordinate2D, radius: Int = 10, completion: @escaping ([ChargingStation]?, Error?) -> Void) {
        // Build URL with query parameters
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "latitude", value: String(location.latitude)),
            URLQueryItem(name: "longitude", value: String(location.longitude)),
            URLQueryItem(name: "distance", value: String(radius)),
            URLQueryItem(name: "distanceunit", value: "km"),
            URLQueryItem(name: "maxresults", value: "100"),
            URLQueryItem(name: "compact", value: "true"),
            URLQueryItem(name: "verbose", value: "false")
        ]
        
        guard let url = components?.url else {
            completion(nil, NSError(domain: "OpenChargeMapService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        
        // Create and configure request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("2d487708-8ee3-4f80-8001-b48cac0b755f", forHTTPHeaderField: "X-API-Key")
        
        // Execute request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "OpenChargeMapService", code: 2, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                return
            }
            
            do {
                let stations = try JSONDecoder().decode([ChargingStation].self, from: data)
                completion(stations, nil)
            } catch {
                print("JSON Decoding Error: \(error)")
                completion(nil, error)
            }
        }
        
        task.resume()
    }
    
    // Fetch gas stations using MKLocalSearch
    func fetchGasStations(near location: CLLocationCoordinate2D, radius: Double = 10000, completion: @escaping ([MKMapItem]?, Error?) -> Void) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "gas station"
        
        // Set search region
        let region = MKCoordinateRegion(
            center: location,
            latitudinalMeters: radius,
            longitudinalMeters: radius
        )
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let response = response else {
                completion(nil, NSError(domain: "OpenChargeMapService", code: 3, userInfo: [NSLocalizedDescriptionKey: "No response from local search"]))
                return
            }
            
            completion(response.mapItems, nil)
        }
    }
} 