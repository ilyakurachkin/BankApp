import UIKit
import SnapKit

class CardView: UIView {

    init() {
        super.init(frame: .zero)
        backgroundColor = Theme.Color.card
        layer.cornerRadius = Theme.Radius.card
        layer.cornerCurve = .continuous
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: 4)
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: CardView, _) in
            self.layer.shadowOpacity = self.traitCollection.userInterfaceStyle == .dark ? 0 : 0.06
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

final class TappableCardView: CardView {

    var onTap: (() -> Void)?

    override init() {
        super.init()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        animateScale(0.97)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        animateScale(1)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        animateScale(1)
    }

    private func animateScale(_ scale: CGFloat) {
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [.allowUserInteraction]) {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }

    @objc private func handleTap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onTap?()
    }
}

final class IconBadgeView: UIView {

    private let imageView = UIImageView()

    init(symbol: String, tint: UIColor, size: CGFloat = 40) {
        super.init(frame: .zero)
        layer.cornerRadius = size / 2
        imageView.contentMode = .scaleAspectFit
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: size * 0.42, weight: .semibold)
        addSubview(imageView)
        imageView.snp.makeConstraints { make in make.center.equalToSuperview() }
        snp.makeConstraints { make in make.size.equalTo(size) }
        configure(symbol: symbol, tint: tint)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(symbol: String, tint: UIColor) {
        imageView.image = UIImage(systemName: symbol)
        imageView.tintColor = tint
        backgroundColor = tint.withAlphaComponent(0.15)
    }
}

final class SectionHeaderView: UIView {

    init(title: String, actionTitle: String? = nil, action: UIAction? = nil) {
        super.init(frame: .zero)

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .preferredFont(forTextStyle: .title3).withWeight(.bold)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
        }

        if let actionTitle, let action {
            var config = UIButton.Configuration.plain()
            config.title = actionTitle
            config.image = UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold))
            config.imagePlacement = .trailing
            config.imagePadding = 4
            config.contentInsets = .zero
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
                var attributes = attributes
                attributes.font = .preferredFont(forTextStyle: .subheadline).withWeight(.semibold)
                return attributes
            }
            let button = UIButton(configuration: config, primaryAction: action)
            addSubview(button)
            button.snp.makeConstraints { make in
                make.trailing.equalToSuperview()
                make.centerY.equalTo(titleLabel)
            }
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

enum PrimaryButton {
    static func make(title: String, symbol: String? = nil, style: Style = .filled) -> UIButton {
        var config: UIButton.Configuration
        switch style {
        case .filled: config = .filled()
        case .tinted: config = .tinted()
        }
        config.title = title
        if let symbol {
            config.image = UIImage(systemName: symbol)
            config.imagePadding = 8
        }
        config.cornerStyle = .large
        config.buttonSize = .large
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var attributes = attributes
            attributes.font = .preferredFont(forTextStyle: .headline)
            return attributes
        }
        let button = UIButton(configuration: config)
        button.snp.makeConstraints { make in make.height.greaterThanOrEqualTo(52) }
        return button
    }

    enum Style { case filled, tinted }
}

extension UIFont {
    func withWeight(_ weight: UIFont.Weight) -> UIFont {
        let descriptor = fontDescriptor.addingAttributes([.traits: [UIFontDescriptor.TraitKey.weight: weight]])
        return UIFont(descriptor: descriptor, size: 0)
    }

    static func rounded(size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        guard let descriptor = base.fontDescriptor.withDesign(.rounded) else { return base }
        return UIFont(descriptor: descriptor, size: size)
    }
}

final class GradientView: UIView {

    override class var layerClass: AnyClass { CAGradientLayer.self }

    init(colors: [UIColor]) {
        super.init(frame: .zero)
        guard let gradient = layer as? CAGradientLayer else { return }
        gradient.colors = colors.map(\.cgColor)
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
