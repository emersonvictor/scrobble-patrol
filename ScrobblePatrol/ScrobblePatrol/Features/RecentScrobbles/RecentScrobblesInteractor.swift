import Combine
import Foundation

@MainActor
protocol RecentScrobblesInteractorProtocol {
    func viewDidLoad()
    func updateUser(username: String)
    func loadNextPage()
}

@MainActor
final class RecentScrobblesInteractor: RecentScrobblesInteractorProtocol {
    private let presenter: any RecentScrobblesPresenterProtocol
    private let repository: any LastFmRepositoryProtocol
    private let usernameStore: any UsernameStoreProtocol
    private var currentPage = 1
    private var totalPages = 1
    private var currentUsername: String?
    private var isLoading = false
    private var requestGeneration = 0
    private var cancellables = Set<AnyCancellable>()
    private var requestTask: Task<Void, Never>?

    init(
        presenter: any RecentScrobblesPresenterProtocol,
        repository: any LastFmRepositoryProtocol,
        usernameStore: any UsernameStoreProtocol
    ) {
        self.presenter = presenter
        self.repository = repository
        self.usernameStore = usernameStore
    }

    func viewDidLoad() {
        cancellables.removeAll()
        usernameStore.usernamePublisher
            .sink { [weak self] username in
                self?.usernameDidChange(username)
            }
            .store(in: &cancellables)
    }
    
    func updateUser(username: String) {
        usernameStore.update(username)
    }

    func loadNextPage() {
        guard
            currentUsername != nil,
            !isLoading,
            currentPage < totalPages
        else { return }

        currentPage += 1
        loadCurrentPage(appending: true)
    }

    
}

private extension RecentScrobblesInteractor {
    func usernameDidChange(_ username: String?) {
        requestGeneration += 1
        requestTask?.cancel()
        requestTask = nil
        isLoading = false
        currentPage = 1
        totalPages = 1
        currentUsername = username
        presenter.presentUsername(username)

        guard let username else {
            presenter.presentScrobbles([], appending: false)
            return
        }

        currentUsername = username
        loadCurrentPage(appending: false)
    }

    func loadCurrentPage(appending: Bool) {
        guard let username = currentUsername, !isLoading else { return }

        let requestedPage = currentPage
        let generation = requestGeneration
        isLoading = true
        requestTask = repository.getRecentTracks(
            username: username,
            page: requestedPage
        ) { [weak self] result in
            guard
                let self,
                requestGeneration == generation,
                currentUsername == username,
                currentPage == requestedPage
            else { return }

            isLoading = false

            switch result {
            case let .success(page):
                totalPages = page.totalPages
                presenter.presentScrobbles(page.scrobbles, appending: appending)
            case .failure:
                if appending {
                    currentPage -= 1
                }
            }
        }
    }
}
