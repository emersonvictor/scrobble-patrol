import UIKit

@MainActor
protocol RecentScrobblesViewProtocol: AnyObject {}

final class RecentScrobblesViewController: UIViewController, RecentScrobblesViewProtocol {
    private let interactor: any RecentScrobblesInteractorProtocol
    private let albumDetailRouter: AlbumDetailRouter

    init(interactor: any RecentScrobblesInteractorProtocol, albumDetailRouter: AlbumDetailRouter) {
        self.interactor = interactor
        self.albumDetailRouter = albumDetailRouter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Últimos scrobbles"
        view.backgroundColor = .systemBackground
        interactor.viewDidLoad()
    }
}
