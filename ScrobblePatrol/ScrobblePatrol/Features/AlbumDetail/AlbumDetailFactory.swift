import UIKit

@MainActor
enum AlbumDetailFactory {
    static func make(
        albumName: String,
        artistName: String,
        repository: any LastFmRepositoryProtocol
    ) -> UIViewController {
        let presenter = AlbumDetailPresenter()
        let interactor = AlbumDetailInteractor(
            albumName: albumName,
            artistName: artistName,
            presenter: presenter,
            repository: repository
        )
        let viewController = AlbumDetailViewController(interactor: interactor)
        presenter.attach(view: viewController)
        return viewController
    }
}
