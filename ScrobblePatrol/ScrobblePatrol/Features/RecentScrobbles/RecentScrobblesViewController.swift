import SnapKit
import UIKit

@MainActor
protocol RecentScrobblesViewProtocol: AnyObject {
    func displayUsername(_ username: String?)
    func displayScrobbles(_ scrobbles: [RecentScrobble], appending: Bool)
}

final class RecentScrobblesViewController: UIViewController, RecentScrobblesViewProtocol {
    private let interactor: any RecentScrobblesInteractorProtocol
    private let albumDetailRouter: AlbumDetailRouter
    
    private lazy var usernameView = UsernameView()
    private lazy var tableView = UITableView(frame: .zero, style: .plain)
    private var scrobbles: [RecentScrobble] = []

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

    func displayUsername(_ username: String?) {
        usernameView.setUsername(username ?? "")
    }

    func displayScrobbles(_ scrobbles: [RecentScrobble], appending: Bool) {
        if appending {
            self.scrobbles.append(contentsOf: scrobbles)
        } else {
            self.scrobbles = scrobbles
        }
        tableView.reloadData()
    }

    private func setupView() {
        view.addSubview(usernameView)
        view.addSubview(tableView)

        usernameView.onSubmit = { [weak self] username in
            self?.interactor.updateUser(username: username)
        }
        tableView.dataSource = self
        tableView.delegate = self

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

extension RecentScrobblesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row == scrobbles.count - 1 else { return }
        interactor.loadNextPage()
    }
}

extension RecentScrobblesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        scrobbles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "RecentScrobbleCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: identifier)
        let scrobble = scrobbles[indexPath.row]
        cell.textLabel?.text = scrobble.trackName
        cell.detailTextLabel?.text = scrobble.artistName
        cell.accessoryType = scrobble.albumName == nil ? .none : .disclosureIndicator
        return cell
    }
}
