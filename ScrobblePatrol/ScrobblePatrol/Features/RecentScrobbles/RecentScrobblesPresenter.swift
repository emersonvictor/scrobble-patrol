import Foundation

@MainActor
protocol RecentScrobblesPresenterProtocol: AnyObject {
    func attach(view: any RecentScrobblesViewProtocol)
    func presentUsername(_ username: String?)
    func presentLoading()
    func presentScrobbles(_ scrobbles: [RecentScrobble])
    func finishRefreshing()
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

    func presentLoading() {
        view?.displayLoading()
    }

    func presentScrobbles(_ scrobbles: [RecentScrobble]) {
        view?.displayScrobbles(scrobbles)
    }

    func finishRefreshing() {
        view?.finishRefreshing()
    }
}
