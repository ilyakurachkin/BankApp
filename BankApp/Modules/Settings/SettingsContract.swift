import Foundation

protocol SettingsViewProtocol: AnyObject {}

protocol SettingsPresenterProtocol: Presenter {
    var isNotificationsEnabled: Bool { get }
    var isFaceIDEnabled: Bool { get }
    func setNotificationsEnabled(_ isEnabled: Bool)
    func setFaceIDEnabled(_ isEnabled: Bool)
}
