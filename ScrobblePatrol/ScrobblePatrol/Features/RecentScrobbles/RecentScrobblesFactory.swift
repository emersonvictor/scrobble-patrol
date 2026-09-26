import UIKit

@MainActor
enum RecentScrobblesFactory {
    static func make(
        repository: any LastFmRepositoryProtocol
    ) -> UIViewController {
        let presenter = RecentScrobblesPresenter()
        let interactor = RecentScrobblesInteractor(presenter: presenter, repository: repository)
        let router = AlbumDetailRouter(repository: repository)
        let viewController = RecentScrobblesViewController(interactor: interactor, albumDetailRouter: router)
        presenter.attach(view: viewController)
        return viewController
    }
}
