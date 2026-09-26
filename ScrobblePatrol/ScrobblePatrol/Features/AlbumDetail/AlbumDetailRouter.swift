import UIKit

@MainActor
final class AlbumDetailRouter {
    private let repository: any LastFmRepositoryProtocol

    init(repository: any LastFmRepositoryProtocol) {
        self.repository = repository
    }

    func route(
        from source: UIViewController,
        albumName: String,
        artistName: String
    ) {
        let viewController = AlbumDetailFactory.make(
            albumName: albumName,
            artistName: artistName,
            repository: repository
        )
        source.navigationController?.pushViewController(viewController, animated: true)
    }
}
