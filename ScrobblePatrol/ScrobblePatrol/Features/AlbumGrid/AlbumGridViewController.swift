import UIKit

@MainActor
protocol AlbumGridViewProtocol: AnyObject {}

final class AlbumGridViewController: UIViewController, AlbumGridViewProtocol {
    private let interactor: any AlbumGridInteractorProtocol
    private let albumDetailRouter: AlbumDetailRouter

    init(interactor: any AlbumGridInteractorProtocol, albumDetailRouter: AlbumDetailRouter) {
        self.interactor = interactor
        self.albumDetailRouter = albumDetailRouter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Semaninha"
        view.backgroundColor = .systemBackground
        interactor.viewDidLoad()
    }
}
