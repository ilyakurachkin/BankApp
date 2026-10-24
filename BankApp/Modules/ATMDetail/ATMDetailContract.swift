import Foundation

protocol ATMDetailViewProtocol: AnyObject {
    func display(_ point: ATMPoint)
}

protocol ATMDetailPresenterProtocol: Presenter {}
