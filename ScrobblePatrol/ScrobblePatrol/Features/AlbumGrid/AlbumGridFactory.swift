import UIKit

@MainActor
enum AlbumGridFactory {
    static func make(
        repository: any LastFmRepositoryProtocol,
        usernameStore: any UsernameStoreProtocol
    ) -> UIViewController {
        let presenter = AlbumGridPresenter()
        let interactor = AlbumGridInteractor(
            presenter: presenter,
            repository: repository,
            usernameStore: usernameStore
        )
        let router = AlbumDetailRouter(repository: repository)
        let imageRenderer = AlbumGridImageRenderer()
        let viewController = AlbumGridViewController(
            interactor: interactor,
            albumDetailRouter: router,
            imageRenderer: imageRenderer
        )
        presenter.attach(view: viewController)
        return viewController
    }
}
