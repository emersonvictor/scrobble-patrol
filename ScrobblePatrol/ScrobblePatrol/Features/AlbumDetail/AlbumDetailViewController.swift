import SnapKit
import UIKit

@MainActor
protocol AlbumDetailViewProtocol: AnyObject {}

final class AlbumDetailViewController: UIViewController, AlbumDetailViewProtocol, ViewCode {
    private let albumName: String
    private let interactor: any AlbumDetailInteractorProtocol

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    private lazy var contentView = UIView()

    private lazy var artworkContainerView = UIView()

    private lazy var artworkView: AlbumArtworkView = {
        let artworkView = AlbumArtworkView()
        artworkView.layer.cornerRadius = 12
        return artworkView
    }()

    private lazy var albumNameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var artistNameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var albumHeaderStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [albumNameLabel, artistNameLabel])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 8
        return stackView
    }()

    private lazy var tagsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 12
        return stackView
    }()

    private lazy var tracksCountLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var listenersCountLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var statisticsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [tracksCountLabel, listenersCountLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        return stackView
    }()

    private lazy var tracklistTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title3)
        label.text = String(localized: .albumDetailTracklist)
        return label
    }()

    private lazy var tracksStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 8
        return stackView
    }()

    private lazy var tracklistStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [tracklistTitleLabel, tracksStackView])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 12
        return stackView
    }()

    private lazy var lastFMButton: UIButton = {
        var configuration = UIButton.Configuration.bordered()
        configuration.title = String(localized: .albumDetailOpenLastFM)
        let button = UIButton(configuration: configuration)
        return button
    }()

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            artworkContainerView,
            albumHeaderStackView,
            tagsStackView,
            statisticsStackView,
            tracklistStackView,
            lastFMButton
        ])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 24
        return stackView
    }()

    init(albumName: String, interactor: any AlbumDetailInteractorProtocol) {
        self.albumName = albumName
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    func buildViewHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(contentStackView)
        artworkContainerView.addSubview(artworkView)
    }

    func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        contentStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(24)
            make.leading.trailing.equalTo(contentView.layoutMarginsGuide)
        }

        artworkContainerView.snp.makeConstraints { make in
            make.height.equalTo(180)
        }

        artworkView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(180)
        }

        lastFMButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
    }

    func setupAdditionalConfiguration() {
        navigationItem.title = albumName
        view.backgroundColor = .systemBackground
    }
}
