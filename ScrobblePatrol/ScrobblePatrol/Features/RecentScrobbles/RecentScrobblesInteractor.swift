import Foundation

@MainActor
protocol RecentScrobblesInteractorProtocol {
    func viewDidLoad()
    func viewWillAppear()
    func updateUsername(_ username: String)
    func refresh()
    func loadNextPage()
    func retry()
}

@MainActor
final class RecentScrobblesInteractor: RecentScrobblesInteractorProtocol {
    private let presenter: any RecentScrobblesPresenterProtocol
    private let repository: any LastFmRepositoryProtocol
    private let usernameStore: any UsernameStoreProtocol
    private var currentUsername: String?
    private var currentPage = 1
    private var hasNextPage = false
    private var isLoading = false
    private var scrobbles: [RecentScrobble] = []

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
        currentUsername = usernameStore.username
        presenter.presentUsername(currentUsername)
        loadScrobbles()
    }

    func viewWillAppear() {
        let storedUsername = usernameStore.username
        guard storedUsername != currentUsername else { return }

        currentUsername = storedUsername
        currentPage = 1
        hasNextPage = false
        scrobbles = []

        presenter.presentUsername(currentUsername)
        presenter.presentScrobbles(scrobbles)

        guard !isLoading else { return }
        loadScrobbles()
    }

    func updateUsername(_ username: String) {
        guard !isLoading else { return }

        usernameStore.update(username)
        currentUsername = usernameStore.username
        currentPage = 1
        hasNextPage = false
        scrobbles = []

        presenter.presentUsername(currentUsername)
        presenter.presentScrobbles(scrobbles)
        loadScrobbles()
    }

    func refresh() {
        guard !isLoading, currentUsername != nil else {
            presenter.finishRefreshing()
            return
        }

        currentPage = 1
        hasNextPage = false
        scrobbles = []
        presenter.presentScrobbles(scrobbles)
        loadScrobbles(isRefreshing: true)
    }

    func loadNextPage() {
        guard hasNextPage, !isLoading else { return }

        currentPage += 1
        loadScrobbles()
    }

    func retry() {
        guard !isLoading else { return }

        if scrobbles.isEmpty {
            loadScrobbles()
        } else {
            loadNextPage()
        }
    }
}

private extension RecentScrobblesInteractor {
    func loadScrobbles(isRefreshing: Bool = false) {
        guard let currentUsername, !isLoading else { return }

        isLoading = true
        if !isRefreshing {
            presenter.presentLoading()
        }

        repository.getRecentTracks(
            username: currentUsername,
            page: currentPage
        ) { [weak self] result in
            guard let self else { return }
            isLoading = false

            if isRefreshing {
                presenter.finishRefreshing()
            }

            switch result {
            case let .success(page):
                hasNextPage = page.page < page.totalPages

                if currentPage == 1 {
                    scrobbles = page.scrobbles
                } else {
                    scrobbles.append(contentsOf: page.scrobbles)
                }

                presenter.presentScrobbles(scrobbles)
            case let .failure(error):
                if currentPage > 1 {
                    currentPage -= 1
                }
                presenter.presentError(error)
            }
        }
    }
}
