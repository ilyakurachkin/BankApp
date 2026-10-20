import Foundation

final class ATMDetailPresenter: ATMDetailPresenterProtocol {

    weak var view: ATMDetailViewProtocol?
    private let point: ATMPoint

    init(point: ATMPoint) {
        self.point = point
    }

    func viewDidLoad() {
        view?.display(point)
    }
}
