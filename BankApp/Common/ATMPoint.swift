import CoreLocation

struct ATMPoint {
    let name: String
    let address: String
    let workingHours: String
    let phone: String
    let services: [String]
    let coordinate: CLLocationCoordinate2D
}
