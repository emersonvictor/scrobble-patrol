import Foundation

@MainActor
protocol AlbumGridInteractorProtocol {
    func viewDidLoad()
    func viewWillAppear()
    func updateUser(username: String)
    func generate(periodIndex: Int, gridSize: Int)
    func retry()
}

@MainActor
final class AlbumGridInteractor: AlbumGridInteractorProtocol {
    private let presenter: any AlbumGridPresenterProtocol
    private let repository: any LastFmRepositoryProtocol
    private let usernameStore: any UsernameStoreProtocol
    private var currentUsername: String?
    private var isLoading = false
    private var lastPeriod: TopAlbumsPeriod?
    private var lastGridSize: Int?

    init(
        presenter: any AlbumGridPresenterProtocol,
        repository: any LastFmRepositoryProtocol,
        usernameStore: any UsernameStoreProtocol
    ) {
        self.presenter = presenter
        self.repository = repository
        self.usernameStore = usernameStore
    }

    func viewDidLoad() {
        currentUsername = usernameStore.username
        presenter.presentUsername(currentUsername)
    }

    func viewWillAppear() {
        let storedUsername = usernameStore.username
        guard storedUsername != currentUsername else { return }

        currentUsername = storedUsername
        presenter.presentUsername(currentUsername)
        presenter.presentAlbums([])
    }

    func updateUser(username: String) {
        usernameStore.update(username)
        currentUsername = usernameStore.username
        presenter.presentUsername(currentUsername)
        presenter.presentAlbums([])
    }

    func generate(periodIndex: Int, gridSize: Int) {
        guard let period = TopAlbumsPeriod(selectedIndex: periodIndex) else { return }
        lastPeriod = period
        lastGridSize = gridSize
        loadAlbums(period: period, gridSize: gridSize)
    }

    func retry() {
        guard let lastPeriod, let lastGridSize else { return }
        loadAlbums(period: lastPeriod, gridSize: lastGridSize)
    }

}

private extension AlbumGridInteractor {
    func loadAlbums(period: TopAlbumsPeriod, gridSize: Int) {
        guard let currentUsername, !isLoading else { return }

        let requestedUsername = currentUsername
        isLoading = true
        presenter.presentLoading()

        repository.getTopAlbums(
            username: requestedUsername,
            period: period,
            page: 1,
            limit: gridSize * gridSize
        ) { [weak self] result in
            guard let self else { return }
            isLoading = false

            guard currentUsername == requestedUsername else {
                presenter.presentAlbums([])
                return
            }

            switch result {
            case let .success(page):
                presenter.presentAlbums(page.albums)
            case let .failure(error):
                presenter.presentError(error)
            }
        }
    }
}
