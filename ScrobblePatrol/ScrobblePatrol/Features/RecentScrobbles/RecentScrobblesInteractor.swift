import Foundation

@MainActor
protocol RecentScrobblesInteractorProtocol {
    func viewDidLoad()
}

@MainActor
final class RecentScrobblesInteractor: RecentScrobblesInteractorProtocol {
    private let presenter: any RecentScrobblesPresenterProtocol
    private let repository: any LastFmRepositoryProtocol

    init(presenter: any RecentScrobblesPresenterProtocol, repository: any LastFmRepositoryProtocol) {
        self.presenter = presenter
        self.repository = repository
    }

    func viewDidLoad() {
        // Validate user
        // If existis
        // Load
        // If not
        // Nothing
    }
    
    func updateUser(username: String) {
        // Save user
        viewDidLoad()
    }
    
    // func load more (infinite scroll)
    // retry load
    // pullToRefresh
}

private extension RecentScrobblesInteractor {
    // Load acording to page
}
