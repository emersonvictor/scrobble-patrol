import Foundation

@MainActor
protocol RecentScrobblesPresenterProtocol: AnyObject {
    func attach(view: any RecentScrobblesViewProtocol)
}

@MainActor
final class RecentScrobblesPresenter: RecentScrobblesPresenterProtocol {
    private weak var view: (any RecentScrobblesViewProtocol)?

    func attach(view: any RecentScrobblesViewProtocol) {
        self.view = view
    }
}
