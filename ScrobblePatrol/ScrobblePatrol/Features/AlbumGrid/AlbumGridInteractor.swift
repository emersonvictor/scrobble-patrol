import Foundation

@MainActor
protocol AlbumGridInteractorProtocol {
    func viewDidLoad()
    func viewWillAppear()
    func updateUser(username: String)
}

@MainActor
final class AlbumGridInteractor: AlbumGridInteractorProtocol {
    private let presenter: any AlbumGridPresenterProtocol
    private let repository: any LastFmRepositoryProtocol
    private let usernameStore: any UsernameStoreProtocol
    private var currentUsername: String?

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
    }

    func updateUser(username: String) {
        usernameStore.update(username)
        currentUsername = usernameStore.username
        presenter.presentUsername(currentUsername)
    }
}
