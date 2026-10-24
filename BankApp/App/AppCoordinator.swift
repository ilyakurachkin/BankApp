import UIKit

final class AppCoordinator {

    private let window: UIWindow
    private weak var tabBarController: UITabBarController?
    private var mapNavigationController: UINavigationController?
    private var ratesNavigationController: UINavigationController?
    private var converterNavigationController: UINavigationController?

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        showMain()
    }

    func showMain() {
        let dashboardVC = makeDashboardViewController()
        let mapVC = makeMapViewController()
        let ratesVC = makeRatesViewController()
        let converterVC = makeConverterViewController()
        let settingsVC = makeSettingsViewController()

        dashboardVC.tabBarItem = UITabBarItem(title: "Главная", image: UIImage(systemName: "house.fill"), tag: 0)
        mapVC.tabBarItem = UITabBarItem(title: "Карта", image: UIImage(systemName: "map.fill"), tag: 1)
        ratesVC.tabBarItem = UITabBarItem(title: "Курсы", image: UIImage(systemName: "chart.line.uptrend.xyaxis"), tag: 2)
        converterVC.tabBarItem = UITabBarItem(title: "Конвертер", image: UIImage(systemName: "arrow.left.arrow.right"), tag: 3)
        settingsVC.tabBarItem = UITabBarItem(title: "Настройки", image: UIImage(systemName: "gearshape.fill"), tag: 4)

        let dashboardNav = UINavigationController(rootViewController: dashboardVC)
        let mapNav = UINavigationController(rootViewController: mapVC)
        let ratesNav = UINavigationController(rootViewController: ratesVC)
        let converterNav = UINavigationController(rootViewController: converterVC)
        let settingsNav = UINavigationController(rootViewController: settingsVC)

        [dashboardNav, mapNav, ratesNav, converterNav, settingsNav].forEach {
            $0.navigationBar.prefersLargeTitles = true
        }

        mapNavigationController = mapNav
        ratesNavigationController = ratesNav
        converterNavigationController = converterNav

        let tabBarController = UITabBarController()
        tabBarController.view.tintColor = Theme.Color.accent
        tabBarController.viewControllers = [dashboardNav, mapNav, ratesNav, converterNav, settingsNav]
        self.tabBarController = tabBarController

        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }

    func showATMDetail(_ point: ATMPoint) {
        let presenter = ATMDetailPresenter(point: point)
        let viewController = ATMDetailViewController()
        viewController.presenter = presenter
        presenter.view = viewController

        mapNavigationController?.pushViewController(viewController, animated: true)
    }

    func showRates() {
        guard let ratesNavigationController else { return }
        tabBarController?.selectedViewController = ratesNavigationController
    }

    func showConverter() {
        guard let converterNavigationController else { return }
        tabBarController?.selectedViewController = converterNavigationController
    }

    func showMap() {
        guard let mapNavigationController else { return }
        tabBarController?.selectedViewController = mapNavigationController
    }

    private func makeDashboardViewController() -> DashboardViewController {
        let presenter = DashboardPresenter(coordinator: self)
        let viewController = DashboardViewController()
        viewController.presenter = presenter
        presenter.view = viewController
        return viewController
    }

    private func makeMapViewController() -> MapViewController {
        let presenter = MapPresenter(coordinator: self)
        let viewController = MapViewController()
        viewController.presenter = presenter
        presenter.view = viewController
        return viewController
    }

    private func makeRatesViewController() -> RatesViewController {
        let presenter = RatesPresenter()
        let viewController = RatesViewController()
        viewController.presenter = presenter
        presenter.view = viewController
        return viewController
    }

    private func makeConverterViewController() -> ConverterViewController {
        let presenter = ConverterPresenter()
        let viewController = ConverterViewController()
        viewController.presenter = presenter
        presenter.view = viewController
        return viewController
    }

    private func makeSettingsViewController() -> SettingsViewController {
        let presenter = SettingsPresenter()
        let viewController = SettingsViewController()
        viewController.presenter = presenter
        presenter.view = viewController
        return viewController
    }
}
