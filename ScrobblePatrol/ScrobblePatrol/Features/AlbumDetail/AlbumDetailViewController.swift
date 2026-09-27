import SnapKit
import UIKit

@MainActor
protocol AlbumDetailViewProtocol: AnyObject {
    func displayLoading()
    func displayAlbum(_ album: Album)
    func displayError(message: String, retryTitle: String)
}

final class AlbumDetailViewController: UIViewController, AlbumDetailViewProtocol, ViewCode {
    private let albumName: String
    private let interactor: any AlbumDetailInteractorProtocol
    private var lastFMURL: URL?

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    private lazy var contentView = UIView()

    private lazy var feedbackView: FeedbackView = {
        let feedbackView = FeedbackView()
        feedbackView.isHidden = true
        feedbackView.onRetry = { [weak self] in
            self?.interactor.retry()
        }
        return feedbackView
    }()

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

    private lazy var tagsView = AlbumTagsView()

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
        button.addTarget(self, action: #selector(openLastFM), for: .touchUpInside)
        return button
    }()

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            artworkContainerView,
            albumHeaderStackView,
            tagsView,
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
        interactor.viewDidLoad()
    }

    func displayLoading() {
        scrollView.isHidden = true
        feedbackView.displayLoading()
    }

    func displayAlbum(_ album: Album) {
        navigationItem.title = album.name
        lastFMURL = album.lastFMURL
        lastFMButton.isEnabled = album.lastFMURL != nil
        artworkView.load(url: album.imageURL)
        albumNameLabel.text = album.name
        artistNameLabel.text = album.artistName
        tracksCountLabel.text = "\(album.tracks.count) faixas"
        listenersCountLabel.text = album.listeners.map {
            "\($0.formatted(.number.notation(.compactName))) ouvintes"
        }

        tagsView.setTags(album.tags)
        configureTracks(album.tracks)

        feedbackView.hide()
        scrollView.isHidden = false
    }

    func displayError(message: String, retryTitle: String) {
        scrollView.isHidden = true
        feedbackView.displayError(message: message, retryTitle: retryTitle)
    }

    func buildViewHierarchy() {
        view.addSubview(scrollView)
        view.addSubview(feedbackView)
        scrollView.addSubview(contentView)
        contentView.addSubview(contentStackView)
        artworkContainerView.addSubview(artworkView)
    }

    func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.snp.edges)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        contentStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(24)
            make.leading.trailing.equalTo(contentView.layoutMarginsGuide).inset(16)
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

        feedbackView.snp.makeConstraints { make in
            make.center.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalTo(view.layoutMarginsGuide)
            make.height.greaterThanOrEqualTo(96)
        }
    }

    func setupAdditionalConfiguration() {
        navigationItem.title = albumName
        view.backgroundColor = .systemBackground
    }

    @objc private func openLastFM() {
        guard let lastFMURL else { return }
        UIApplication.shared.open(lastFMURL)
    }
}

private extension AlbumDetailViewController {
    func configureTracks(_ tracks: [AlbumTrack]) {
        tracksStackView.arrangedSubviews.forEach {
            tracksStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        tracks.enumerated().forEach { index, track in
            let positionLabel = UILabel()
            positionLabel.font = .preferredFont(forTextStyle: .body)
            positionLabel.text = "\(index + 1)."
            positionLabel.setContentHuggingPriority(.required, for: .horizontal)

            let nameLabel = UILabel()
            nameLabel.font = .preferredFont(forTextStyle: .body)
            nameLabel.numberOfLines = 0
            nameLabel.text = track.name

            let durationLabel = UILabel()
            durationLabel.font = .preferredFont(forTextStyle: .body)
            durationLabel.textColor = .secondaryLabel
            durationLabel.text = track.formattedDuration
            durationLabel.setContentHuggingPriority(.required, for: .horizontal)

            let stackView = UIStackView(arrangedSubviews: [positionLabel, nameLabel, durationLabel])
            stackView.axis = .horizontal
            stackView.alignment = .firstBaseline
            stackView.spacing = 8
            tracksStackView.addArrangedSubview(stackView)
        }
    }

}
