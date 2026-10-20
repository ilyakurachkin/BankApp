import Foundation
import CoreLocation

final class MapPresenter: MapPresenterProtocol {

    weak var view: MapViewProtocol?
    private let coordinator: AppCoordinator

    private let points: [ATMPoint] = [
        ATMPoint(
            name: "Отделение на Ленина, 10",
            address: "г. Минск, ул. Ленина, 10",
            workingHours: "Пн–Пт 9:00–19:00",
            phone: "+375171234567",
            services: ["Обмен валют", "Кредиты", "Оплата ЖКХ"],
            coordinate: CLLocationCoordinate2D(latitude: 53.9006, longitude: 27.5590)
        ),
        ATMPoint(
            name: "Банкомат на Независимости, 5",
            address: "г. Минск, пр-т Независимости, 5",
            workingHours: "24/7",
            phone: "+375171112233",
            services: ["Оплата ЖКХ"],
            coordinate: CLLocationCoordinate2D(latitude: 53.9045, longitude: 27.5615)
        ),
        ATMPoint(
            name: "Отделение на Немиге, 3",
            address: "г. Минск, ул. Немига, 3",
            workingHours: "Пн–Сб 9:00–20:00",
            phone: "+375171445566",
            services: ["Обмен валют", "Кредиты"],
            coordinate: CLLocationCoordinate2D(latitude: 53.9020, longitude: 27.5525)
        )
    ]

    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }

    func viewDidLoad() {
        view?.showPoints(points)
    }

    func didSelectPoint(_ point: ATMPoint) {
        coordinator.showATMDetail(point)
    }
}
