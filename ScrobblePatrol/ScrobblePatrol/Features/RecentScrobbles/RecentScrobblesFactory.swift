import UIKit

@MainActor
enum RecentScrobblesFactory {
    static func make(
        repository: any LastFmRepositoryProtocol,
        usernameStore: any UsernameStoreProtocol
    ) -> UIViewController {
        let presenter = RecentScrobblesPresenter()
        let interactor = RecentScrobblesInteractor(
            presenter: presenter,
            repository: repository,
            usernameStore: usernameStore
        )
        let router = AlbumDetailRouter(repository: repository)
        let viewController = RecentScrobblesViewController(interactor: interactor, albumDetailRouter: router)
        presenter.attach(view: viewController)
        return viewController
    }
}
