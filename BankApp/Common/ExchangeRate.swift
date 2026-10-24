import Foundation

struct ExchangeRate {
    let code: String
    let name: String
    let category: Category
    let rate: Double
    let changePercent: Double

    enum Category: String, CaseIterable {
        case currency = "Валюты"
        case crypto = "Криптовалюты"
        case metal = "Драгметаллы"
    }
}
