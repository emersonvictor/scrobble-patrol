import Foundation

@MainActor
protocol AlbumGridInteractorProtocol {
    func viewDidLoad()
}

@MainActor
final class AlbumGridInteractor: AlbumGridInteractorProtocol {
    private let presenter: any AlbumGridPresenterProtocol
    private let repository: any LastFmRepositoryProtocol

    init(presenter: any AlbumGridPresenterProtocol, repository: any LastFmRepositoryProtocol) {
        self.presenter = presenter
        self.repository = repository
    }

    func viewDidLoad() {}
}
