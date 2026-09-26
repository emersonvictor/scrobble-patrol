import Combine
import Foundation

@MainActor
protocol AlbumGridInteractorProtocol {
    func viewDidLoad()
    func updateUser(username: String)
}

@MainActor
final class AlbumGridInteractor: AlbumGridInteractorProtocol {
    private let presenter: any AlbumGridPresenterProtocol
    private let repository: any LastFmRepositoryProtocol
    private let usernameStore: any UsernameStoreProtocol
    private var cancellables = Set<AnyCancellable>()

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
        usernameStore.usernamePublisher
            .sink { [weak self] username in
                self?.presenter.presentUsername(username)
            }
            .store(in: &cancellables)
    }

    func updateUser(username: String) {
        usernameStore.update(username)
    }
}
