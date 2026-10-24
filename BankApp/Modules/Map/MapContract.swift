import Foundation

protocol MapViewProtocol: AnyObject {
    func showPoints(_ points: [ATMPoint])
}

protocol MapPresenterProtocol: Presenter {
    func didSelectPoint(_ point: ATMPoint)
}
