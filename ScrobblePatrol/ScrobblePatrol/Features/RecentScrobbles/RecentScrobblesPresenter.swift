import Foundation

@MainActor
protocol RecentScrobblesPresenterProtocol: AnyObject {
    func attach(view: any RecentScrobblesViewProtocol)
    func presentUsername(_ username: String?)
    func presentScrobbles(_ scrobbles: [RecentScrobble], appending: Bool)
}

@MainActor
final class RecentScrobblesPresenter: RecentScrobblesPresenterProtocol {
    private weak var view: (any RecentScrobblesViewProtocol)?

    func attach(view: any RecentScrobblesViewProtocol) {
        self.view = view
    }

    func presentUsername(_ username: String?) {
        view?.displayUsername(username)
    }

    func presentScrobbles(_ scrobbles: [RecentScrobble], appending: Bool) {
        view?.displayScrobbles(scrobbles, appending: appending)
    }
}
