import SnapKit
import UIKit

@MainActor
protocol RecentScrobblesViewProtocol: AnyObject {
    func displayUsername(_ username: String?)
    func displayScrobbles(_ scrobbles: [RecentScrobble])
    func finishRefreshing()
}

final class RecentScrobblesViewController: UIViewController, ViewCode {
    private let interactor: any RecentScrobblesInteractorProtocol
    private let albumDetailRouter: AlbumDetailRouter
    
    private lazy var usernameView: UsernameView = {
        let usernameView = UsernameView()
        usernameView.onSubmit = { [weak self] username in
            self?.interactor.updateUsername(username)
        }
        return usernameView
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.refreshControl = refreshControl
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 112
        tableView.register(
            RecentScrobbleCell.self,
            forCellReuseIdentifier: RecentScrobbleCell.reuseIdentifier
        )
        return tableView
    }()
    private var scrobbles: [RecentScrobble] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    init(interactor: any RecentScrobblesInteractorProtocol, albumDetailRouter: AlbumDetailRouter) {
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

    func buildViewHierarchy() {
        view.addSubview(usernameView)
        view.addSubview(tableView)
    }

    func setupConstraints() {
        usernameView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.trailing.equalTo(view.layoutMarginsGuide)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(usernameView.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    func setupAdditionalConfiguration() {
        navigationItem.title = String(localized: .recentScrobblesTitle)
        view.backgroundColor = .systemBackground
    }

    @objc private func refresh() {
        interactor.refresh()
    }
}

// MARK: - UITableViewDataSource
extension RecentScrobblesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        scrobbles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: RecentScrobbleCell.reuseIdentifier,
                for: indexPath
            ) as? RecentScrobbleCell
        else {
            return UITableViewCell()
        }

        cell.configure(with: scrobbles[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension RecentScrobblesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: Route to the selected album details.
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        interactor.loadNextPage()
    }
}

// MARK: - RecentScrobblesViewProtocol
extension RecentScrobblesViewController: RecentScrobblesViewProtocol {
    func displayUsername(_ username: String?) {
        usernameView.setUsername(username ?? "")
    }

    func displayScrobbles(_ scrobbles: [RecentScrobble]) {
        self.scrobbles = scrobbles
    }

    func finishRefreshing() {
        refreshControl.endRefreshing()
    }
}
