import Foundation

@MainActor
protocol AlbumDetailInteractorProtocol {
    func viewDidLoad()
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

    func viewDidLoad() {}
}
