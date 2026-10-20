import UIKit
import SnapKit

final class SettingsViewController: UIViewController {

    var presenter: SettingsPresenterProtocol!

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Настройки"
        view.backgroundColor = Theme.Color.background
        setupTableView()
        presenter.viewDidLoad()
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = makeProfileHeader()
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    private func makeProfileHeader() -> UIView {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 150))

        let avatar = GradientView(colors: Theme.Color.balanceGradient)
        avatar.layer.cornerRadius = 36
        avatar.clipsToBounds = true

        let initials = UILabel()
        initials.text = "ИК"
        initials.font = .rounded(size: 26, weight: .bold)
        initials.textColor = .white
        avatar.addSubview(initials)
        initials.snp.makeConstraints { make in make.center.equalToSuperview() }

        let nameLabel = UILabel()
        nameLabel.text = "Илья Курочкин"
        nameLabel.font = .preferredFont(forTextStyle: .title3).withWeight(.semibold)

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Клиент банка с 2026 года"
        subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        subtitleLabel.textColor = .secondaryLabel

        let stack = UIStackView(arrangedSubviews: [avatar, nameLabel, subtitleLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        stack.setCustomSpacing(10, after: avatar)

        header.addSubview(stack)
        avatar.snp.makeConstraints { make in make.size.equalTo(72) }
        stack.snp.makeConstraints { make in make.center.equalToSuperview() }
        return header
    }

    @objc private func didToggleNotifications(_ sender: UISwitch) {
        presenter.setNotificationsEnabled(sender.isOn)
    }

    @objc private func didToggleFaceID(_ sender: UISwitch) {
        presenter.setFaceIDEnabled(sender.isOn)
    }
}

extension SettingsViewController: SettingsViewProtocol {}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 2 }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Общие" : "Безопасность и уведомления"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "settingsCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) ?? UITableViewCell(style: .default, reuseIdentifier: identifier)
        cell.accessoryView = nil
        cell.accessoryType = .none
        cell.selectionStyle = .default

        var content = cell.defaultContentConfiguration()
        content.imageToTextPadding = 14

        if indexPath.section == 0 {
            let rows: [(String, String, UIColor)] = [
                ("Профиль", "person.fill", .systemBlue),
                ("О приложении", "info.circle.fill", .systemGray)
            ]
            let row = rows[indexPath.row]
            content.text = row.0
            content.image = Self.iconImage(symbol: row.1, color: row.2)
            cell.accessoryType = .disclosureIndicator
        } else {
            let switchView = UISwitch()
            switchView.onTintColor = Theme.Color.accent
            cell.selectionStyle = .none
            if indexPath.row == 0 {
                content.text = "Уведомления о курсах"
                content.image = Self.iconImage(symbol: "bell.badge.fill", color: .systemRed)
                switchView.isOn = presenter.isNotificationsEnabled
                switchView.addTarget(self, action: #selector(didToggleNotifications), for: .valueChanged)
            } else {
                content.text = "Вход по Face ID"
                content.image = Self.iconImage(symbol: "faceid", color: .systemGreen)
                switchView.isOn = presenter.isFaceIDEnabled
                switchView.addTarget(self, action: #selector(didToggleFaceID), for: .valueChanged)
            }
            cell.accessoryView = switchView
        }

        cell.contentConfiguration = content
        return cell
    }

    private static func iconImage(symbol: String, color: UIColor) -> UIImage {
        let size = CGSize(width: 30, height: 30)
        return UIGraphicsImageRenderer(size: size).image { _ in
            let rect = CGRect(origin: .zero, size: size)
            color.setFill()
            UIBezierPath(roundedRect: rect, cornerRadius: 7).fill()

            let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
            guard let glyph = UIImage(systemName: symbol, withConfiguration: config)?
                .withTintColor(.white, renderingMode: .alwaysOriginal) else { return }
            let glyphRect = CGRect(
                x: (size.width - glyph.size.width) / 2,
                y: (size.height - glyph.size.height) / 2,
                width: glyph.size.width,
                height: glyph.size.height
            )
            glyph.draw(in: glyphRect)
        }
    }
}
