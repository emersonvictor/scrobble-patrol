import UIKit

@MainActor
enum AlbumGridFactory {
    static func make(
        repository: any LastFmRepositoryProtocol
    ) -> UIViewController {
        let presenter = AlbumGridPresenter()
        let interactor = AlbumGridInteractor(presenter: presenter, repository: repository)
        let router = AlbumDetailRouter(repository: repository)
        let viewController = AlbumGridViewController(interactor: interactor, albumDetailRouter: router)
        presenter.attach(view: viewController)
        return viewController
    }
}
