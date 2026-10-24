import Foundation

final class MockRatesProvider {

    static let shared = MockRatesProvider()

    private(set) var rates: [ExchangeRate] = [
        ExchangeRate(code: "BYN", name: "Белорусский рубль", category: .currency, rate: 1.00, changePercent: 0.00),
        ExchangeRate(code: "USD", name: "Доллар США", category: .currency, rate: 3.30, changePercent: 0.32),
        ExchangeRate(code: "EUR", name: "Евро", category: .currency, rate: 3.57, changePercent: -0.15),
        ExchangeRate(code: "RUB", name: "Российский рубль", category: .currency, rate: 0.036, changePercent: 0.00),
        ExchangeRate(code: "CNY", name: "Китайский юань", category: .currency, rate: 0.46, changePercent: 0.08),
        ExchangeRate(code: "BTC", name: "Bitcoin", category: .crypto, rate: 214_500, changePercent: 2.1),
        ExchangeRate(code: "ETH", name: "Ethereum", category: .crypto, rate: 11_500, changePercent: 1.4),
        ExchangeRate(code: "XAU", name: "Золото (унция)", category: .metal, rate: 7_100, changePercent: 0.5),
        ExchangeRate(code: "XAG", name: "Серебро (унция)", category: .metal, rate: 88, changePercent: -0.2)
    ]

    private init() {}

    func rate(for code: String) -> ExchangeRate? {
        rates.first { $0.code == code }
    }

    func convert(amount: Double, from: String, to: String) -> Double {
        guard let fromRate = rate(for: from)?.rate, let toRate = rate(for: to)?.rate, toRate != 0 else { return 0 }
        return amount * fromRate / toRate
    }
}
