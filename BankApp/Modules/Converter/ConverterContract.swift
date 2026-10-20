import Foundation

struct ConversionRecord {
    let amount: Double
    let from: String
    let to: String
    let result: Double
}

protocol ConverterViewProtocol: AnyObject {
    func setSourceCurrency(_ code: String)
    func setTargetCurrency(_ code: String)
    func setResult(_ text: String)
    func reloadHistory()
}

protocol ConverterPresenterProtocol: Presenter {
    var history: [ConversionRecord] { get }
    func didChangeAmount(_ text: String)
    func didTapSwap()
    func didSelectSourceCurrency(_ code: String)
    func didSelectTargetCurrency(_ code: String)
    func didTapSave()
}
