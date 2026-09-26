import UIKit

@MainActor
protocol AlbumDetailViewProtocol: AnyObject {}

final class AlbumDetailViewController: UIViewController, AlbumDetailViewProtocol {
    private let interactor: any AlbumDetailInteractorProtocol

    init(interactor: any AlbumDetailInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Detalhes do álbum"
        view.backgroundColor = .systemBackground
        interactor.viewDidLoad()
    }
}
