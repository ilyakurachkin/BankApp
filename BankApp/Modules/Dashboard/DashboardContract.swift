import Foundation

protocol DashboardViewProtocol: AnyObject {
    func update(rates: [ExchangeRate])
    func setConverterResult(_ text: String)
}

protocol DashboardPresenterProtocol: Presenter {
    func didTapAllRates()
    func didTapConverterAmount(_ text: String)
    func didTapFindATM()
    func didTapConverter()
}
