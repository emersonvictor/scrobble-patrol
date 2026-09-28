import Foundation

@MainActor
protocol AlbumGridPresenterProtocol: AnyObject {
    func attach(view: any AlbumGridViewProtocol)
    func presentUsername(_ username: String?)
    func presentLoading()
    func presentAlbums(_ albums: [TopAlbum])
    func presentError(_ error: LastFmError)
}

@MainActor
final class AlbumGridPresenter: AlbumGridPresenterProtocol {
    private weak var view: (any AlbumGridViewProtocol)?

    func attach(view: any AlbumGridViewProtocol) {
        self.view = view
    }

    func presentUsername(_ username: String?) {
        view?.displayUsername(username)
    }

    func presentLoading() {
        view?.displayLoading()
    }

    func presentAlbums(_ albums: [TopAlbum]) {
        view?.displayAlbums(albums)
    }

    func presentError(_ error: LastFmError) {
        let message: String

        switch error {
        case .network:
            message = String(localized: .requestErrorNoConnectionError)
        case let .api(_, apiMessage):
            message = apiMessage
        default:
            message = String(localized: .albumGridLoadError)
        }

        view?.displayError(
            message: message,
            retryTitle: String(localized: .requestErrorRetry)
        )
    }
}
