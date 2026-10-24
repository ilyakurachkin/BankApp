import UIKit
import SnapKit

final class RatesViewController: UIViewController {

    var presenter: RatesPresenterProtocol!

    private let searchController = UISearchController(searchResultsController: nil)
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var sections: [RatesSection] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Курсы"
        view.backgroundColor = Theme.Color.background
        setupViews()
        setupConstraints()
        presenter.viewDidLoad()
    }

    private func setupViews() {
        searchController.searchBar.placeholder = "Поиск валюты"
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(RateCell.self, forCellReuseIdentifier: RateCell.reuseIdentifier)
        tableView.keyboardDismissMode = .onDrag
        tableView.rowHeight = 68
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)

        view.addSubview(tableView)
    }

    private func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @objc private func didPullToRefresh() {
        presenter.didRefresh()
    }
}

extension RatesViewController: RatesViewProtocol {
    func update(sections: [RatesSection]) {
        self.sections = sections
        tableView.reloadData()
        tableView.refreshControl?.endRefreshing()
    }
}

extension RatesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        presenter.didSearch(searchController.searchBar.text ?? "")
    }
}

extension RatesViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RateCell.reuseIdentifier, for: indexPath) as! RateCell
        cell.configure(with: sections[indexPath.section].items[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        false
    }
}

private final class RateCell: UITableViewCell {

    static let reuseIdentifier = "RateCell"

    private let badge = IconBadgeView(symbol: "dollarsign", tint: .systemBlue, size: 40)
    private let codeLabel = UILabel()
    private let nameLabel = UILabel()
    private let rateLabel = UILabel()
    private let changeLabel = PaddingLabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        codeLabel.font = .preferredFont(forTextStyle: .headline)
        nameLabel.font = .preferredFont(forTextStyle: .subheadline)
        nameLabel.textColor = .secondaryLabel

        rateLabel.font = .rounded(size: 17, weight: .semibold)
        rateLabel.textAlignment = .right

        changeLabel.font = .preferredFont(forTextStyle: .caption1).withWeight(.semibold)
        changeLabel.layer.cornerRadius = 7
        changeLabel.layer.masksToBounds = true

        let leftStack = UIStackView(arrangedSubviews: [codeLabel, nameLabel])
        leftStack.axis = .vertical
        leftStack.spacing = 2

        let rightStack = UIStackView(arrangedSubviews: [rateLabel, changeLabel])
        rightStack.axis = .vertical
        rightStack.alignment = .trailing
        rightStack.spacing = 4

        [badge, leftStack, rightStack].forEach { contentView.addSubview($0) }

        badge.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        leftStack.snp.makeConstraints { make in
            make.leading.equalTo(badge.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(rightStack.snp.leading).offset(-8)
        }
        rightStack.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        rightStack.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with rate: ExchangeRate) {
        badge.configure(symbol: rate.symbolName, tint: rate.tintColor)
        codeLabel.text = rate.code
        nameLabel.text = rate.name
        rateLabel.text = Format.rate(rate.rate)

        let color = Theme.Color.change(rate.changePercent)
        changeLabel.text = Format.change(rate.changePercent)
        changeLabel.textColor = color
        changeLabel.backgroundColor = color.withAlphaComponent(0.12)
    }
}

final class PaddingLabel: UILabel {

    var insets = UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6)

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + insets.left + insets.right, height: size.height + insets.top + insets.bottom)
    }
}
