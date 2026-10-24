import UIKit
import MapKit
import SnapKit

final class MapViewController: UIViewController {

    var presenter: MapPresenterProtocol!

    private let searchController = UISearchController(searchResultsController: nil)
    private let mapView = MKMapView()
    private let locateMeButton = UIButton(type: .system)
    private let nearbyScrollView = UIScrollView()
    private let nearbyStackView = UIStackView()

    private let locationManager = CLLocationManager()
    private var points: [ATMPoint] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Карта"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = Theme.Color.background
        setupViews()
        setupConstraints()
        locationManager.delegate = self
        presenter.viewDidLoad()
    }

    private func setupViews() {
        searchController.searchBar.placeholder = "Поиск адреса или банкомата"
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.pointOfInterestFilter = .excludingAll

        var locateConfig = UIButton.Configuration.filled()
        locateConfig.cornerStyle = .capsule
        locateConfig.baseBackgroundColor = Theme.Color.card
        locateConfig.baseForegroundColor = Theme.Color.accent
        locateConfig.image = UIImage(systemName: "location.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold))
        locateMeButton.configuration = locateConfig
        locateMeButton.layer.shadowColor = UIColor.black.cgColor
        locateMeButton.layer.shadowOpacity = 0.15
        locateMeButton.layer.shadowRadius = 10
        locateMeButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        locateMeButton.accessibilityLabel = "Моё местоположение"
        locateMeButton.addTarget(self, action: #selector(didTapLocateMe), for: .touchUpInside)

        nearbyStackView.axis = .horizontal
        nearbyStackView.spacing = 12
        nearbyScrollView.addSubview(nearbyStackView)
        nearbyScrollView.showsHorizontalScrollIndicator = false
        nearbyScrollView.clipsToBounds = false
        nearbyScrollView.contentInset = UIEdgeInsets(top: 0, left: Theme.Spacing.screen, bottom: 0, right: Theme.Spacing.screen)

        [mapView, locateMeButton, nearbyScrollView].forEach { view.addSubview($0) }
    }

    private func setupConstraints() {
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        nearbyScrollView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(12)
            make.height.equalTo(96)
        }

        nearbyStackView.snp.makeConstraints { make in
            make.edges.equalTo(nearbyScrollView.contentLayoutGuide)
            make.height.equalTo(nearbyScrollView.frameLayoutGuide)
        }

        locateMeButton.snp.makeConstraints { make in
            make.size.equalTo(48)
            make.trailing.equalToSuperview().inset(Theme.Spacing.screen)
            make.bottom.equalTo(nearbyScrollView.snp.top).offset(-12)
        }
    }

    private func makePointCard(_ point: ATMPoint, index: Int) -> UIView {
        let card = TappableCardView()
        card.onTap = { [weak self] in self?.focus(on: index) }

        let isBranch = point.name.hasPrefix("Отделение")
        let badge = IconBadgeView(
            symbol: isBranch ? "building.columns.fill" : "creditcard.fill",
            tint: isBranch ? Theme.Color.accent : .systemOrange,
            size: 40
        )

        let nameLabel = UILabel()
        nameLabel.text = point.name
        nameLabel.font = .preferredFont(forTextStyle: .subheadline).withWeight(.semibold)
        nameLabel.numberOfLines = 2

        let hoursLabel = UILabel()
        hoursLabel.text = point.workingHours
        hoursLabel.font = .preferredFont(forTextStyle: .caption1)
        hoursLabel.textColor = point.workingHours == "24/7" ? Theme.Color.positive : .secondaryLabel

        let textStack = UIStackView(arrangedSubviews: [nameLabel, hoursLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        let row = UIStackView(arrangedSubviews: [badge, textStack])
        row.spacing = 12
        row.alignment = .center
        row.isUserInteractionEnabled = false

        card.addSubview(row)
        row.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(14)
            make.centerY.equalToSuperview()
        }
        card.snp.makeConstraints { make in
            make.width.equalTo(250)
        }
        return card
    }

    private func focus(on index: Int) {
        guard points.indices.contains(index) else { return }
        let point = points[index]
        let region = MKCoordinateRegion(center: point.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
        if let annotation = mapView.annotations.first(where: { ($0 as? ATMAnnotation)?.point.name == point.name }) {
            mapView.selectAnnotation(annotation, animated: true)
        }
    }

    @objc private func didTapLocateMe() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        default:
            break
        }
    }
}

extension MapViewController: MapViewProtocol {
    func showPoints(_ points: [ATMPoint]) {
        self.points = points

        let annotations = points.map { ATMAnnotation(point: $0) }
        mapView.addAnnotations(annotations)

        if let first = points.first {
            let region = MKCoordinateRegion(center: first.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
            mapView.setRegion(region, animated: false)
        }

        nearbyStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        points.enumerated().forEach { nearbyStackView.addArrangedSubview(makePointCard($1, index: $0)) }
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let atmAnnotation = annotation as? ATMAnnotation else { return nil }
        let identifier = "atmAnnotation"
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
            ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        let isBranch = atmAnnotation.point.name.hasPrefix("Отделение")
        annotationView.annotation = annotation
        annotationView.markerTintColor = isBranch ? Theme.Color.accent : .systemOrange
        annotationView.glyphImage = UIImage(systemName: isBranch ? "building.columns.fill" : "creditcard.fill")
        annotationView.canShowCallout = true
        annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        return annotationView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation as? ATMAnnotation else { return }
        presenter.didSelectPoint(annotation.point)
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1500, longitudinalMeters: 1500)
        mapView.setRegion(region, animated: true)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}
}
