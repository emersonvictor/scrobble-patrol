import SnapKit
import UIKit

@MainActor
protocol AlbumGridViewProtocol: AnyObject {
    func displayUsername(_ username: String?)
}

final class AlbumGridViewController: UIViewController, AlbumGridViewProtocol, ViewCode {
    private let interactor: any AlbumGridInteractorProtocol
    private let albumDetailRouter: AlbumDetailRouter
    private lazy var usernameView: UsernameView = {
        let usernameView = UsernameView()
        usernameView.onSubmit = { [weak self] username in
            self?.interactor.updateUser(username: username)
        }
        return usernameView
    }()

    init(interactor: any AlbumGridInteractorProtocol, albumDetailRouter: AlbumDetailRouter) {
        self.interactor = interactor
        self.albumDetailRouter = albumDetailRouter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        interactor.viewDidLoad()
    }

    func displayUsername(_ username: String?) {
        usernameView.setUsername(username ?? "")
    }

    func buildViewHierarchy() {
        view.addSubview(usernameView)
    }

    func setupConstraints() {
        usernameView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.trailing.equalTo(view.layoutMarginsGuide)
        }
    }

    func setupAdditionalConfiguration() {
        title = "Semaninha"
        view.backgroundColor = .systemBackground
    }
}
