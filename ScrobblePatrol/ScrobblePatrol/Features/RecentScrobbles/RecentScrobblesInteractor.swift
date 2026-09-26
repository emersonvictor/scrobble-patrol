import Foundation

@MainActor
protocol RecentScrobblesInteractorProtocol {
    func viewDidLoad()
    func updateUser(username: String)
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
        // TODO: - Validate user and load screen
    }
    
    func updateUser(username: String) {
        // TODO: - Save user
        viewDidLoad()
    }
}

private extension RecentScrobblesInteractor {
    // TODO: Load using current page
}
