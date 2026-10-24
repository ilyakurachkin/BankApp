import Foundation

final class RatesPresenter: RatesPresenterProtocol {

    weak var view: RatesViewProtocol?
    private var searchQuery = ""

    func viewDidLoad() {
        reload()
    }

    func didSearch(_ query: String) {
        searchQuery = query
        reload()
    }

    func didRefresh() {
        reload()
    }

    private func reload() {
        let rates = MockRatesProvider.shared.rates.filter { rate in
            searchQuery.isEmpty ||
            rate.code.localizedCaseInsensitiveContains(searchQuery) ||
            rate.name.localizedCaseInsensitiveContains(searchQuery)
        }

        let sections = ExchangeRate.Category.allCases.compactMap { category -> RatesSection? in
            let items = rates.filter { $0.category == category }
            return items.isEmpty ? nil : RatesSection(title: category.rawValue, items: items)
        }

        view?.update(sections: sections)
    }
}
