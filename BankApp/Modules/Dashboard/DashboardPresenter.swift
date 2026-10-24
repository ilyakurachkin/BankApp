import Foundation

final class DashboardPresenter: DashboardPresenterProtocol {

    weak var view: DashboardViewProtocol?
    private let coordinator: AppCoordinator
    private let highlightedCodes = ["USD", "EUR", "RUB", "XAU", "XAG"]

    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }

    func viewDidLoad() {
        let rates = MockRatesProvider.shared.rates.filter { highlightedCodes.contains($0.code) }
        view?.update(rates: rates)
        view?.setConverterResult(Format.amount(0, code: "BYN"))
    }

    func didTapConverterAmount(_ text: String) {
        let amount = Double(text.replacingOccurrences(of: ",", with: ".")) ?? 0
        let result = MockRatesProvider.shared.convert(amount: amount, from: "USD", to: "BYN")
        view?.setConverterResult(Format.amount(result, code: "BYN"))
    }

    func didTapAllRates() {
        coordinator.showRates()
    }

    func didTapFindATM() {
        coordinator.showMap()
    }

    func didTapConverter() {
        coordinator.showConverter()
    }
}
