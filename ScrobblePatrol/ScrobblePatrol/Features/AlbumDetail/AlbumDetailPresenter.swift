import Foundation

@MainActor
protocol AlbumDetailPresenterProtocol: AnyObject {
    func attach(view: any AlbumDetailViewProtocol)
    func presentLoading()
    func presentAlbum(_ album: Album)
    func presentError(_ error: LastFmError)
}

@MainActor
final class AlbumDetailPresenter: AlbumDetailPresenterProtocol {
    private weak var view: (any AlbumDetailViewProtocol)?

    func attach(view: any AlbumDetailViewProtocol) {
        self.view = view
    }

    func presentLoading() {
        view?.displayLoading()
    }

    func presentAlbum(_ album: Album) {
        view?.displayAlbum(album)
    }

    func presentError(_ error: LastFmError) {
        let message: String

        switch error {
        case .network:
            message = String(localized: .requestErrorNoConnectionError)
        case let .api(_, apiMessage):
            message = apiMessage
        default:
            message = String(localized: .albumDetailLoadError)
        }

        view?.displayError(
            message: message,
            retryTitle: String(localized: .requestErrorRetry)
        )
    }
}
