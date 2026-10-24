import Foundation

final class SettingsPresenter: SettingsPresenterProtocol {

    weak var view: SettingsViewProtocol?

    private let defaults = UserDefaults.standard
    private let notificationsKey = "settings.notificationsEnabled"
    private let faceIDKey = "settings.faceIDEnabled"

    var isNotificationsEnabled: Bool {
        defaults.bool(forKey: notificationsKey)
    }

    var isFaceIDEnabled: Bool {
        defaults.bool(forKey: faceIDKey)
    }

    func viewDidLoad() {}

    func setNotificationsEnabled(_ isEnabled: Bool) {
        defaults.set(isEnabled, forKey: notificationsKey)
    }

    func setFaceIDEnabled(_ isEnabled: Bool) {
        defaults.set(isEnabled, forKey: faceIDKey)
    }
}
