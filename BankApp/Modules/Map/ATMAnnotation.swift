import MapKit

final class ATMAnnotation: MKPointAnnotation {

    let point: ATMPoint

    init(point: ATMPoint) {
        self.point = point
        super.init()
        coordinate = point.coordinate
        title = point.name
        subtitle = point.address
    }
}
