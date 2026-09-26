import SnapKit
import UIKit

@MainActor
protocol RecentScrobblesViewProtocol: AnyObject {}

final class RecentScrobblesViewController: UIViewController, RecentScrobblesViewProtocol {
    private let interactor: any RecentScrobblesInteractorProtocol
    private let albumDetailRouter: AlbumDetailRouter
    
    private lazy var usernameView = UsernameView()
    private lazy var tableView = UITableView(frame: .zero, style: .plain)

    init(interactor: any RecentScrobblesInteractorProtocol, albumDetailRouter: AlbumDetailRouter) {
        self.interactor = interactor
        self.albumDetailRouter = albumDetailRouter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = String(localized: .recentScrobblesTitle)
        view.backgroundColor = .systemBackground
        setupView()
        interactor.viewDidLoad()
    }

    private func setupView() {
        view.addSubview(usernameView)
        view.addSubview(tableView)

        usernameView.onSubmit = { [weak self] username in
            self?.interactor.updateUser(username: username)
        }

        usernameView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.trailing.equalTo(view.layoutMarginsGuide)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(usernameView.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}
