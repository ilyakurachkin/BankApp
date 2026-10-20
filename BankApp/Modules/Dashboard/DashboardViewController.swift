import UIKit
import SnapKit

final class DashboardViewController: UIViewController {

    var presenter: DashboardPresenterProtocol!

    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()

    private let balanceCardView = GradientView(colors: Theme.Color.balanceGradient)
    private let balanceValueLabel = UILabel()
    private let balanceVisibilityButton = UIButton(type: .system)
    private var isBalanceHidden = false
    private let balanceText = Format.amount(12_480, code: "BYN")

    private let ratesScrollView = UIScrollView()
    private let ratesStackView = UIStackView()

    private let converterCardView = CardView()
    private let converterAmountTextField = UITextField()
    private let converterResultLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Главная"
        view.backgroundColor = Theme.Color.background
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "bell"), style: .plain, target: nil, action: nil)
        setupViews()
        setupConstraints()
        hideKeyboardOnTap()
        observeKeyboard()
        presenter.viewDidLoad()
    }

    private func setupViews() {
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
        view.addSubview(scrollView)

        contentStackView.axis = .vertical
        contentStackView.spacing = Theme.Spacing.section
        scrollView.addSubview(contentStackView)

        contentStackView.addArrangedSubview(makeBalanceCard())
        contentStackView.addArrangedSubview(makeQuickActions())

        contentStackView.addArrangedSubview(makeSection(
            header: SectionHeaderView(title: "Курсы", actionTitle: "Все", action: UIAction { [weak self] _ in
                self?.presenter.didTapAllRates()
            }),
            content: makeRatesCarousel(),
            insetContent: false
        ))

        contentStackView.addArrangedSubview(makeSection(
            header: SectionHeaderView(title: "Быстрый обмен"),
            content: makeConverterCard(),
            insetContent: true
        ))
    }

    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentStackView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.contentLayoutGuide).offset(8)
            make.bottom.equalTo(scrollView.contentLayoutGuide).inset(Theme.Spacing.section)
            make.leading.trailing.equalTo(scrollView.frameLayoutGuide)
        }
    }

    private func makeBalanceCard() -> UIView {
        balanceCardView.layer.cornerRadius = Theme.Radius.card
        balanceCardView.layer.cornerCurve = .continuous
        balanceCardView.clipsToBounds = true

        let decorCircle = UIView()
        decorCircle.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        decorCircle.layer.cornerRadius = 110
        balanceCardView.addSubview(decorCircle)
        decorCircle.snp.makeConstraints { make in
            make.size.equalTo(220)
            make.trailing.equalToSuperview().offset(70)
            make.top.equalToSuperview().offset(-90)
        }

        let titleLabel = UILabel()
        titleLabel.text = "Основной счёт"
        titleLabel.font = .preferredFont(forTextStyle: .subheadline).withWeight(.medium)
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.8)

        var eyeConfig = UIButton.Configuration.plain()
        eyeConfig.baseForegroundColor = UIColor.white.withAlphaComponent(0.8)
        eyeConfig.contentInsets = .zero
        balanceVisibilityButton.configuration = eyeConfig
        balanceVisibilityButton.addTarget(self, action: #selector(didToggleBalance), for: .touchUpInside)
        updateBalanceVisibility()

        balanceValueLabel.font = .rounded(size: 36, weight: .bold)
        balanceValueLabel.textColor = .white
        balanceValueLabel.adjustsFontSizeToFitWidth = true
        balanceValueLabel.minimumScaleFactor = 0.6

        let cardNumberLabel = UILabel()
        cardNumberLabel.text = "••••  4821"
        cardNumberLabel.font = .monospacedDigitSystemFont(ofSize: 15, weight: .medium)
        cardNumberLabel.textColor = UIColor.white.withAlphaComponent(0.8)

        let systemLabel = UILabel()
        systemLabel.text = "VISA"
        systemLabel.font = .systemFont(ofSize: 17, weight: .heavy).withTraits(.traitItalic)
        systemLabel.textColor = .white

        [titleLabel, balanceVisibilityButton, balanceValueLabel, cardNumberLabel, systemLabel].forEach {
            balanceCardView.addSubview($0)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(20)
        }
        balanceVisibilityButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.leading.equalTo(titleLabel.snp.trailing).offset(8)
        }
        balanceValueLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        cardNumberLabel.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(balanceValueLabel.snp.bottom).offset(28)
            make.leading.bottom.equalToSuperview().inset(20)
        }
        systemLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalTo(cardNumberLabel)
        }
        balanceCardView.snp.makeConstraints { make in
            make.height.equalTo(balanceCardView.snp.width).multipliedBy(0.55)
        }

        return inset(balanceCardView)
    }

    private func updateBalanceVisibility() {
        balanceValueLabel.text = isBalanceHidden ? "••••• BYN" : balanceText
        balanceVisibilityButton.configuration?.image = UIImage(
            systemName: isBalanceHidden ? "eye.slash" : "eye",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        )
    }

    @objc private func didToggleBalance() {
        isBalanceHidden.toggle()
        UISelectionFeedbackGenerator().selectionChanged()
        UIView.transition(with: balanceValueLabel, duration: 0.2, options: .transitionCrossDissolve) {
            self.updateBalanceVisibility()
        }
    }

    private func makeQuickActions() -> UIView {
        let actions: [(String, String, UIColor, () -> Void)] = [
            ("Курсы", "chart.line.uptrend.xyaxis", .systemBlue, { [weak self] in self?.presenter.didTapAllRates() }),
            ("Обмен", "arrow.left.arrow.right", .systemPurple, { [weak self] in self?.presenter.didTapConverter() }),
            ("Банкоматы", "mappin.and.ellipse", .systemOrange, { [weak self] in self?.presenter.didTapFindATM() })
        ]

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 12

        for (title, symbol, tint, handler) in actions {
            let card = TappableCardView()
            card.onTap = handler

            let badge = IconBadgeView(symbol: symbol, tint: tint, size: 44)
            let label = UILabel()
            label.text = title
            label.font = .preferredFont(forTextStyle: .footnote).withWeight(.semibold)
            label.textAlignment = .center

            let vStack = UIStackView(arrangedSubviews: [badge, label])
            vStack.axis = .vertical
            vStack.alignment = .center
            vStack.spacing = 8
            vStack.isUserInteractionEnabled = false

            card.addSubview(vStack)
            vStack.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 14, left: 4, bottom: 12, right: 4))
            }
            stack.addArrangedSubview(card)
        }

        return inset(stack)
    }

    private func makeRatesCarousel() -> UIView {
        ratesScrollView.showsHorizontalScrollIndicator = false
        ratesScrollView.clipsToBounds = false
        ratesScrollView.contentInset = UIEdgeInsets(top: 0, left: Theme.Spacing.screen, bottom: 0, right: Theme.Spacing.screen)

        ratesStackView.axis = .horizontal
        ratesStackView.spacing = 12
        ratesScrollView.addSubview(ratesStackView)

        ratesStackView.snp.makeConstraints { make in
            make.edges.equalTo(ratesScrollView.contentLayoutGuide)
            make.height.equalTo(ratesScrollView.frameLayoutGuide)
        }
        ratesScrollView.snp.makeConstraints { make in
            make.height.equalTo(128)
        }
        return ratesScrollView
    }

    private func makeRateCard(_ rate: ExchangeRate) -> UIView {
        let card = TappableCardView()
        card.onTap = { [weak self] in self?.presenter.didTapAllRates() }

        let badge = IconBadgeView(symbol: rate.symbolName, tint: rate.tintColor, size: 34)

        let codeLabel = UILabel()
        codeLabel.text = rate.code
        codeLabel.font = .preferredFont(forTextStyle: .subheadline).withWeight(.semibold)

        let valueLabel = UILabel()
        valueLabel.text = Format.rate(rate.rate)
        valueLabel.font = .rounded(size: 19, weight: .bold)

        let changeLabel = UILabel()
        changeLabel.text = Format.change(rate.changePercent)
        changeLabel.font = .preferredFont(forTextStyle: .caption1).withWeight(.semibold)
        changeLabel.textColor = Theme.Color.change(rate.changePercent)

        let topRow = UIStackView(arrangedSubviews: [badge, codeLabel])
        topRow.spacing = 8
        topRow.alignment = .center

        let stack = UIStackView(arrangedSubviews: [topRow, valueLabel, changeLabel])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 4
        stack.setCustomSpacing(12, after: topRow)
        stack.isUserInteractionEnabled = false

        card.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(14)
            make.centerY.equalToSuperview()
        }
        card.snp.makeConstraints { make in
            make.width.equalTo(128)
        }
        return card
    }

    private func makeConverterCard() -> UIView {
        let card = converterCardView

        let fromBadge = IconBadgeView(symbol: "dollarsign", tint: .systemBlue, size: 36)
        let fromCode = UILabel()
        fromCode.text = "USD"
        fromCode.font = .preferredFont(forTextStyle: .headline)

        converterAmountTextField.placeholder = "0"
        converterAmountTextField.font = .rounded(size: 26, weight: .semibold)
        converterAmountTextField.textAlignment = .right
        converterAmountTextField.keyboardType = .decimalPad
        converterAmountTextField.addTarget(self, action: #selector(didChangeConverterAmount), for: .editingChanged)
        converterAmountTextField.addTarget(self, action: #selector(didBeginConverterEditing), for: .editingDidBegin)

        let fromRow = UIStackView(arrangedSubviews: [fromBadge, fromCode, converterAmountTextField])
        fromRow.spacing = 10
        fromRow.alignment = .center
        fromCode.setContentHuggingPriority(.required, for: .horizontal)

        let divider = UIView()
        divider.backgroundColor = .separator
        divider.snp.makeConstraints { make in make.height.equalTo(1 / max(traitCollection.displayScale, 1)) }

        let toBadge = IconBadgeView(symbol: "banknote", tint: .systemGreen, size: 36)
        let toCode = UILabel()
        toCode.text = "BYN"
        toCode.font = .preferredFont(forTextStyle: .headline)
        toCode.setContentHuggingPriority(.required, for: .horizontal)

        converterResultLabel.font = .rounded(size: 26, weight: .semibold)
        converterResultLabel.textAlignment = .right
        converterResultLabel.textColor = .secondaryLabel
        converterResultLabel.adjustsFontSizeToFitWidth = true
        converterResultLabel.minimumScaleFactor = 0.5

        let toRow = UIStackView(arrangedSubviews: [toBadge, toCode, converterResultLabel])
        toRow.spacing = 10
        toRow.alignment = .center

        let stack = UIStackView(arrangedSubviews: [fromRow, divider, toRow])
        stack.axis = .vertical
        stack.spacing = 14

        card.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        return card
    }

    private func makeSection(header: UIView, content: UIView, insetContent: Bool) -> UIView {
        let stack = UIStackView(arrangedSubviews: [inset(header), insetContent ? inset(content) : content])
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }

    private func inset(_ view: UIView) -> UIView {
        let container = UIView()
        container.addSubview(view)
        view.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(Theme.Spacing.screen)
        }
        return container
    }

    private func observeKeyboard() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }

    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardInView = view.convert(keyboardFrame, from: nil)
        let overlap = max(0, view.bounds.maxY - keyboardInView.minY - view.safeAreaInsets.bottom)

        view.layoutIfNeeded()
        scrollView.contentInset.bottom = overlap
        scrollView.verticalScrollIndicatorInsets.bottom = overlap
        if overlap > 0, converterAmountTextField.isFirstResponder {
            scrollToConverter()
        } else if overlap == 0, navigationItem.largeTitleDisplayMode == .never {
            restoreLargeTitle()
        }
    }

    private func restoreLargeTitle() {
        navigationItem.largeTitleDisplayMode = .automatic
        UIView.animate(withDuration: 0.3) {
            self.navigationController?.navigationBar.sizeToFit()
            self.view.layoutIfNeeded()
            self.scrollView.contentOffset.y = -self.scrollView.adjustedContentInset.top
        }
    }

    private func scrollToConverter() {
        let cardFrame = converterCardView.convert(converterCardView.bounds, to: scrollView)
        let insets = scrollView.adjustedContentInset
        let visibleHeight = scrollView.bounds.height - insets.bottom
        let maxOffsetY = scrollView.contentSize.height + insets.bottom - scrollView.bounds.height
        let targetY = min(cardFrame.maxY + Theme.Spacing.screen - visibleHeight, maxOffsetY)
        guard targetY > scrollView.contentOffset.y else { return }
        scrollView.setContentOffset(CGPoint(x: 0, y: targetY), animated: true)
    }

    @objc private func didBeginConverterEditing() {
        navigationItem.largeTitleDisplayMode = .never
        scrollToConverter()
    }

    @objc private func didChangeConverterAmount() {
        presenter.didTapConverterAmount(converterAmountTextField.text ?? "")
    }
}

extension DashboardViewController: DashboardViewProtocol {
    func update(rates: [ExchangeRate]) {
        ratesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        rates.forEach { ratesStackView.addArrangedSubview(makeRateCard($0)) }
    }

    func setConverterResult(_ text: String) {
        converterResultLabel.text = text.replacingOccurrences(of: " BYN", with: "")
    }
}

private extension UIFont {
    func withTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(traits) else { return self }
        return UIFont(descriptor: descriptor, size: 0)
    }
}
