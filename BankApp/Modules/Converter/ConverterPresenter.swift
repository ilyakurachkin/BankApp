import Foundation

final class ConverterPresenter: ConverterPresenterProtocol {

    weak var view: ConverterViewProtocol?

    private(set) var history: [ConversionRecord] = []
    private var amount: Double = 0
    private var sourceCode = "USD"
    private var targetCode = "BYN"

    func viewDidLoad() {
        view?.setSourceCurrency(sourceCode)
        view?.setTargetCurrency(targetCode)
        recalculate()
    }

    func didChangeAmount(_ text: String) {
        amount = Double(text.replacingOccurrences(of: ",", with: ".")) ?? 0
        recalculate()
    }

    func didTapSwap() {
        swap(&sourceCode, &targetCode)
        view?.setSourceCurrency(sourceCode)
        view?.setTargetCurrency(targetCode)
        recalculate()
    }

    func didSelectSourceCurrency(_ code: String) {
        sourceCode = code
        view?.setSourceCurrency(code)
        recalculate()
    }

    func didSelectTargetCurrency(_ code: String) {
        targetCode = code
        view?.setTargetCurrency(code)
        recalculate()
    }

    func didTapSave() {
        guard amount > 0 else { return }
        let result = MockRatesProvider.shared.convert(amount: amount, from: sourceCode, to: targetCode)
        history.insert(ConversionRecord(amount: amount, from: sourceCode, to: targetCode, result: result), at: 0)
        view?.reloadHistory()
    }

    private func recalculate() {
        let result = MockRatesProvider.shared.convert(amount: amount, from: sourceCode, to: targetCode)
        view?.setResult(String(format: "%.2f %@", result, targetCode))
    }
}
