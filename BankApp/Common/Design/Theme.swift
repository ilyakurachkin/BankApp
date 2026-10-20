import UIKit

enum Theme {

    enum Color {
        static let background = UIColor.systemGroupedBackground
        static let card = UIColor.secondarySystemGroupedBackground
        static let accent = UIColor(named: "AccentColor") ?? .systemIndigo
        static let positive = UIColor.systemGreen
        static let negative = UIColor.systemRed

        static let balanceGradient: [UIColor] = [
            UIColor(red: 0.27, green: 0.24, blue: 0.86, alpha: 1),
            UIColor(red: 0.53, green: 0.30, blue: 0.93, alpha: 1)
        ]

        static func change(_ percent: Double) -> UIColor {
            if percent > 0 { return positive }
            if percent < 0 { return negative }
            return .secondaryLabel
        }
    }

    enum Radius {
        static let card: CGFloat = 22
        static let small: CGFloat = 14
    }

    enum Spacing {
        static let screen: CGFloat = 16
        static let section: CGFloat = 24
    }
}

enum Format {

    static func amount(_ value: Double, code: String? = nil, fractionDigits: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "\u{2009}"
        formatter.decimalSeparator = ","
        formatter.minimumFractionDigits = fractionDigits
        formatter.maximumFractionDigits = fractionDigits
        let number = formatter.string(from: NSNumber(value: value)) ?? "\(value)"
        guard let code else { return number }
        return "\(number) \(code)"
    }

    static func rate(_ value: Double) -> String {
        amount(value, fractionDigits: value < 0.1 ? 4 : 2)
    }

    static func change(_ percent: Double) -> String {
        let sign = percent > 0 ? "+" : ""
        return sign + String(format: "%.2f%%", percent).replacingOccurrences(of: ".", with: ",")
    }

    static func changeSymbol(_ percent: Double) -> String {
        if percent > 0 { return "arrow.up.right" }
        if percent < 0 { return "arrow.down.right" }
        return "minus"
    }
}

extension ExchangeRate {
    var symbolName: String {
        switch code {
        case "USD": return "dollarsign"
        case "EUR": return "eurosign"
        case "RUB": return "rublesign"
        case "CNY": return "yensign"
        case "BYN": return "banknote"
        case "BTC": return "bitcoinsign"
        case "ETH": return "diamond"
        case "XAU", "XAG": return "circle.hexagongrid.fill"
        default: return "coloncurrencysign"
        }
    }

    var tintColor: UIColor {
        switch category {
        case .currency: return .systemBlue
        case .crypto: return .systemOrange
        case .metal: return code == "XAU" ? .systemYellow : .systemGray
        }
    }
}
