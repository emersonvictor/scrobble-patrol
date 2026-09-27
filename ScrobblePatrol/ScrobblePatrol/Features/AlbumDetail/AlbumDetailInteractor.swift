import Foundation

@MainActor
protocol AlbumDetailInteractorProtocol {
    func viewDidLoad()
    func retry()
}

@MainActor
final class AlbumDetailInteractor: AlbumDetailInteractorProtocol {
    private let albumName: String
    private let artistName: String
    private let presenter: any AlbumDetailPresenterProtocol
    private let repository: any LastFmRepositoryProtocol

    init(
        albumName: String,
        artistName: String,
        presenter: any AlbumDetailPresenterProtocol,
        repository: any LastFmRepositoryProtocol
    ) {
        self.albumName = albumName
        self.artistName = artistName
        self.presenter = presenter
        self.repository = repository
    }

    func viewDidLoad() {
        loadAlbum()
    }

    func retry() {
        loadAlbum()
    }
}

private extension AlbumDetailInteractor {
    func loadAlbum() {
        presenter.presentLoading()

        repository.getAlbumInfo(artist: artistName, album: albumName) { [weak self] result in
            guard let self else { return }

            switch result {
            case let .success(album):
                presenter.presentAlbum(album)
            case let .failure(error):
                debugPrint(error)
                presenter.presentError(error)
            }
        }
    }
}
