import UIKit
import SnapKit

final class ConverterViewController: UIViewController {

    var presenter: ConverterPresenterProtocol!

    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()

    private let amountTextField = UITextField()
    private let sourceCurrencyButton = UIButton(type: .system)
    private let swapButton = UIButton(type: .system)
    private let targetCurrencyButton = UIButton(type: .system)
    private let resultLabel = UILabel()
    private let rateHintLabel = UILabel()
    private let saveButton = PrimaryButton.make(title: "Сохранить в историю", symbol: "clock.arrow.circlepath")

    private let historyCard = CardView()
    private let historyStackView = UIStackView()
    private let historyEmptyLabel = UILabel()

    private var sourceCode = ""
    private var targetCode = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Конвертер"
        view.backgroundColor = Theme.Color.background
        setupViews()
        setupConstraints()
        hideKeyboardOnTap()
        presenter.viewDidLoad()
        reloadHistory()
    }

    private func setupViews() {
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
        view.addSubview(scrollView)

        contentStackView.axis = .vertical
        contentStackView.spacing = 12
        scrollView.addSubview(contentStackView)

        amountTextField.placeholder = "0"
        amountTextField.font = .rounded(size: 34, weight: .bold)
        amountTextField.keyboardType = .decimalPad
        amountTextField.adjustsFontSizeToFitWidth = true
        amountTextField.minimumFontSize = 18
        amountTextField.addTarget(self, action: #selector(didChangeAmount), for: .editingChanged)

        resultLabel.font = .rounded(size: 34, weight: .bold)
        resultLabel.textColor = Theme.Color.accent
        resultLabel.adjustsFontSizeToFitWidth = true
        resultLabel.minimumScaleFactor = 0.5

        [sourceCurrencyButton, targetCurrencyButton].forEach { button in
            var config = UIButton.Configuration.gray()
            config.cornerStyle = .capsule
            config.image = UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .bold))
            config.imagePlacement = .trailing
            config.imagePadding = 6
            config.baseForegroundColor = .label
            config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 14, bottom: 8, trailing: 12)
            button.configuration = config
            button.showsMenuAsPrimaryAction = true
            button.setContentHuggingPriority(.required, for: .horizontal)
            button.setContentCompressionResistancePriority(.required, for: .horizontal)
        }

        var swapConfig = UIButton.Configuration.filled()
        swapConfig.cornerStyle = .capsule
        swapConfig.image = UIImage(systemName: "arrow.up.arrow.down", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold))
        swapButton.configuration = swapConfig
        swapButton.addTarget(self, action: #selector(didTapSwap), for: .touchUpInside)

        let sourceCard = makeFieldCard(title: "Отдаю", valueView: amountTextField, currencyButton: sourceCurrencyButton)
        let targetCard = makeFieldCard(title: "Получаю", valueView: resultLabel, currencyButton: targetCurrencyButton)

        let pairContainer = UIView()
        let pairStack = UIStackView(arrangedSubviews: [sourceCard, targetCard])
        pairStack.axis = .vertical
        pairStack.spacing = 8
        pairContainer.addSubview(pairStack)
        pairContainer.addSubview(swapButton)
        pairStack.snp.makeConstraints { make in make.edges.equalToSuperview() }
        swapButton.snp.makeConstraints { make in
            make.size.equalTo(44)
            make.centerX.equalToSuperview()
            make.centerY.equalTo(pairStack)
        }

        rateHintLabel.font = .preferredFont(forTextStyle: .footnote)
        rateHintLabel.textColor = .secondaryLabel
        rateHintLabel.textAlignment = .center

        saveButton.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)

        historyStackView.axis = .vertical
        historyCard.addSubview(historyStackView)
        historyStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16))
        }

        historyEmptyLabel.text = "Здесь появятся сохранённые конвертации"
        historyEmptyLabel.font = .preferredFont(forTextStyle: .subheadline)
        historyEmptyLabel.textColor = .secondaryLabel
        historyEmptyLabel.textAlignment = .center
        historyEmptyLabel.numberOfLines = 0

        [pairContainer, rateHintLabel, saveButton].forEach { contentStackView.addArrangedSubview($0) }
        contentStackView.setCustomSpacing(Theme.Spacing.section, after: rateHintLabel)
        contentStackView.setCustomSpacing(32, after: saveButton)
        contentStackView.addArrangedSubview(SectionHeaderView(title: "История"))
        contentStackView.addArrangedSubview(historyCard)
    }

    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentStackView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.contentLayoutGuide).offset(8)
            make.bottom.equalTo(scrollView.contentLayoutGuide).inset(Theme.Spacing.section)
            make.leading.trailing.equalTo(scrollView.frameLayoutGuide).inset(Theme.Spacing.screen)
        }
    }

    private func makeFieldCard(title: String, valueView: UIView, currencyButton: UIButton) -> UIView {
        let card = CardView()

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .preferredFont(forTextStyle: .subheadline).withWeight(.medium)
        titleLabel.textColor = .secondaryLabel

        let row = UIStackView(arrangedSubviews: [valueView, currencyButton])
        row.spacing = 12
        row.alignment = .center

        let stack = UIStackView(arrangedSubviews: [titleLabel, row])
        stack.axis = .vertical
        stack.spacing = 6

        card.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 18, bottom: 18, right: 16))
        }
        return card
    }

    private func makeCurrencyMenu(selected: String, handler: @escaping (String) -> Void) -> UIMenu {
        let groups = ExchangeRate.Category.allCases.map { category in
            let actions = MockRatesProvider.shared.rates
                .filter { $0.category == category }
                .map { rate in
                    UIAction(
                        title: rate.code,
                        subtitle: rate.name,
                        image: UIImage(systemName: rate.symbolName),
                        state: rate.code == selected ? .on : .off
                    ) { _ in handler(rate.code) }
                }
            return UIMenu(title: category.rawValue, options: .displayInline, children: actions)
        }
        return UIMenu(title: "Выберите валюту", children: groups)
    }

    private func updateMenus() {
        sourceCurrencyButton.menu = makeCurrencyMenu(selected: sourceCode) { [weak self] code in
            self?.presenter.didSelectSourceCurrency(code)
        }
        targetCurrencyButton.menu = makeCurrencyMenu(selected: targetCode) { [weak self] code in
            self?.presenter.didSelectTargetCurrency(code)
        }

        let rate = MockRatesProvider.shared.convert(amount: 1, from: sourceCode, to: targetCode)
        rateHintLabel.text = "1 \(sourceCode) = \(Format.rate(rate)) \(targetCode)"
    }

    private func makeHistoryRow(_ record: ConversionRecord, showsDivider: Bool) -> UIView {
        let badge = IconBadgeView(symbol: "arrow.left.arrow.right", tint: Theme.Color.accent, size: 32)

        let pairLabel = UILabel()
        pairLabel.text = "\(record.from) → \(record.to)"
        pairLabel.font = .preferredFont(forTextStyle: .subheadline).withWeight(.semibold)

        let amountLabel = UILabel()
        amountLabel.text = Format.amount(record.amount, code: record.from)
        amountLabel.font = .preferredFont(forTextStyle: .footnote)
        amountLabel.textColor = .secondaryLabel

        let textStack = UIStackView(arrangedSubviews: [pairLabel, amountLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        let resultLabel = UILabel()
        resultLabel.text = Format.amount(record.result, code: record.to)
        resultLabel.font = .rounded(size: 16, weight: .semibold)
        resultLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [badge, textStack, resultLabel])
        row.spacing = 12
        row.alignment = .center
        row.isLayoutMarginsRelativeArrangement = true
        row.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0)

        guard showsDivider else { return row }
        let divider = UIView()
        divider.backgroundColor = .separator
        row.addSubview(divider)
        divider.snp.makeConstraints { make in
            make.height.equalTo(1 / max(traitCollection.displayScale, 1))
            make.bottom.trailing.equalToSuperview()
            make.leading.equalTo(textStack)
        }
        return row
    }

    @objc private func didChangeAmount() {
        presenter.didChangeAmount(amountTextField.text ?? "")
    }

    @objc private func didTapSwap() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        UIView.animate(withDuration: 0.3) {
            self.swapButton.transform = self.swapButton.transform.rotated(by: .pi)
        }
        presenter.didTapSwap()
    }

    @objc private func didTapSave() {
        view.endEditing(true)
        presenter.didTapSave()
    }
}

extension ConverterViewController: ConverterViewProtocol {
    func setSourceCurrency(_ code: String) {
        sourceCode = code
        sourceCurrencyButton.configuration?.title = code
        updateMenus()
    }

    func setTargetCurrency(_ code: String) {
        targetCode = code
        targetCurrencyButton.configuration?.title = code
        updateMenus()
    }

    func setResult(_ text: String) {
        let parts = text.split(separator: " ")
        if let value = parts.first.flatMap({ Double($0) }) {
            resultLabel.text = Format.amount(value)
        } else {
            resultLabel.text = text
        }
    }

    func reloadHistory() {
        historyStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let history = presenter.history
        guard !history.isEmpty else {
            historyStackView.addArrangedSubview(historyEmptyLabel)
            historyEmptyLabel.snp.remakeConstraints { make in make.height.greaterThanOrEqualTo(72) }
            return
        }

        for (index, record) in history.enumerated() {
            historyStackView.addArrangedSubview(makeHistoryRow(record, showsDivider: index < history.count - 1))
        }
    }
}
