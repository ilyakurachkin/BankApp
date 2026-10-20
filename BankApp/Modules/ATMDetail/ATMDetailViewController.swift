import UIKit
import MapKit
import SnapKit

final class ATMDetailViewController: UIViewController {

    var presenter: ATMDetailPresenterProtocol!

    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()

    private let previewMapView = MKMapView()
    private let addressLabel = UILabel()
    private let hoursLabel = UILabel()
    private let servicesStackView = UIStackView()
    private let routeButton = PrimaryButton.make(title: "Построить маршрут", symbol: "arrow.triangle.turn.up.right.diamond.fill")
    private let callButton = PrimaryButton.make(title: "Позвонить", symbol: "phone.fill", style: .tinted)
    private let copyAddressButton = PrimaryButton.make(title: "Адрес", symbol: "doc.on.doc", style: .tinted)

    private var coordinate: CLLocationCoordinate2D?
    private var phone: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = Theme.Color.background
        setupViews()
        setupConstraints()
        presenter.viewDidLoad()
    }

    private func setupViews() {
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)

        contentStackView.axis = .vertical
        contentStackView.spacing = 16
        scrollView.addSubview(contentStackView)

        previewMapView.isUserInteractionEnabled = false
        previewMapView.pointOfInterestFilter = .excludingAll
        previewMapView.layer.cornerRadius = Theme.Radius.card
        previewMapView.layer.cornerCurve = .continuous
        previewMapView.snp.makeConstraints { make in make.height.equalTo(180) }

        addressLabel.font = .preferredFont(forTextStyle: .title3).withWeight(.semibold)
        addressLabel.numberOfLines = 0

        hoursLabel.font = .preferredFont(forTextStyle: .subheadline)
        hoursLabel.textColor = .secondaryLabel

        servicesStackView.axis = .vertical
        servicesStackView.alignment = .leading
        servicesStackView.spacing = 8

        let infoCard = CardView()
        let infoStack = UIStackView(arrangedSubviews: [
            makeIconRow(symbol: "mappin.circle.fill", tint: .systemRed, view: addressLabel),
            makeIconRow(symbol: "clock.fill", tint: .systemBlue, view: hoursLabel)
        ])
        infoStack.axis = .vertical
        infoStack.spacing = 14
        infoCard.addSubview(infoStack)
        infoStack.snp.makeConstraints { make in make.edges.equalToSuperview().inset(16) }

        let servicesCard = CardView()
        let servicesTitle = UILabel()
        servicesTitle.text = "Услуги"
        servicesTitle.font = .preferredFont(forTextStyle: .headline)
        let servicesStack = UIStackView(arrangedSubviews: [servicesTitle, servicesStackView])
        servicesStack.axis = .vertical
        servicesStack.spacing = 12
        servicesCard.addSubview(servicesStack)
        servicesStack.snp.makeConstraints { make in make.edges.equalToSuperview().inset(16) }

        routeButton.addTarget(self, action: #selector(didTapRoute), for: .touchUpInside)
        callButton.addTarget(self, action: #selector(didTapCall), for: .touchUpInside)
        copyAddressButton.addTarget(self, action: #selector(didTapCopyAddress), for: .touchUpInside)

        let secondaryButtons = UIStackView(arrangedSubviews: [callButton, copyAddressButton])
        secondaryButtons.spacing = 12
        secondaryButtons.distribution = .fillEqually

        [previewMapView, infoCard, servicesCard, routeButton, secondaryButtons].forEach {
            contentStackView.addArrangedSubview($0)
        }
        contentStackView.setCustomSpacing(Theme.Spacing.section, after: servicesCard)
        contentStackView.setCustomSpacing(12, after: routeButton)
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

    private func makeIconRow(symbol: String, tint: UIColor, view: UIView) -> UIView {
        let badge = IconBadgeView(symbol: symbol, tint: tint, size: 36)
        let row = UIStackView(arrangedSubviews: [badge, view])
        row.spacing = 12
        row.alignment = .center
        return row
    }

    private func makeServiceChip(_ service: String) -> UIView {
        var config = UIButton.Configuration.tinted()
        config.title = service
        config.image = UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .bold))
        config.imagePadding = 6
        config.cornerStyle = .capsule
        config.baseForegroundColor = Theme.Color.positive
        config.baseBackgroundColor = Theme.Color.positive
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
        let chip = UIButton(configuration: config)
        chip.isUserInteractionEnabled = false
        return chip
    }

    @objc private func didTapCopyAddress() {
        UIPasteboard.general.string = addressLabel.text
        UINotificationFeedbackGenerator().notificationOccurred(.success)

        var config = copyAddressButton.configuration
        let original = config
        config?.title = "Скопировано"
        config?.image = UIImage(systemName: "checkmark")
        copyAddressButton.configuration = config
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.copyAddressButton.configuration = original
        }
    }

    @objc private func didTapCall() {
        guard let phone, let url = URL(string: "tel://\(phone)") else { return }
        UIApplication.shared.open(url)
    }

    @objc private func didTapRoute() {
        guard let coordinate else { return }
        let mapItem = MKMapItem(location: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude), address: nil)
        mapItem.name = title
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}

extension ATMDetailViewController: ATMDetailViewProtocol {
    func display(_ point: ATMPoint) {
        title = point.name
        addressLabel.text = point.address
        hoursLabel.text = point.workingHours
        coordinate = point.coordinate
        phone = point.phone

        previewMapView.removeAnnotations(previewMapView.annotations)
        previewMapView.addAnnotation(ATMAnnotation(point: point))
        previewMapView.setRegion(MKCoordinateRegion(center: point.coordinate, latitudinalMeters: 600, longitudinalMeters: 600), animated: false)

        servicesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        point.services.forEach { servicesStackView.addArrangedSubview(makeServiceChip($0)) }
    }
}
