import Foundation

@MainActor
protocol RecentScrobblesPresenterProtocol: AnyObject {
    func attach(view: any RecentScrobblesViewProtocol)
    func presentUsername(_ username: String?)
    func presentUsernameInputEnabled(_ isEnabled: Bool)
    func presentLoading()
    func presentError(_ error: LastFmError)
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

    func presentUsernameInputEnabled(_ isEnabled: Bool) {
        view?.displayUsernameInputEnabled(isEnabled)
    }

    func presentLoading() {
        view?.displayLoading()
    }

    func presentError(_ error: LastFmError) {
        let message: String

        switch error {
        case .network:
            message = String(localized: .requestErrorNoConnectionError)
        case let .api(_, apiMessage):
            message = apiMessage
        default:
            message = String(localized: .recentScrobblesLoadError)
        }

        view?.displayError(
            message: message,
            retryTitle: String(localized: .requestErrorRetry)
        )
    }

    func presentScrobbles(_ scrobbles: [RecentScrobble]) {
        view?.displayScrobbles(scrobbles)
    }

    func finishRefreshing() {
        view?.finishRefreshing()
    }
}
