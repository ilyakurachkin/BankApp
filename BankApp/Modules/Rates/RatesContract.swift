import Foundation

struct RatesSection {
    let title: String
    let items: [ExchangeRate]
}

protocol RatesViewProtocol: AnyObject {
    func update(sections: [RatesSection])
}

protocol RatesPresenterProtocol: Presenter {
    func didSearch(_ query: String)
    func didRefresh()
}
