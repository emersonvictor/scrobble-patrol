import SnapKit
import UIKit

@MainActor
protocol AlbumGridViewProtocol: AnyObject {
    func displayUsername(_ username: String?)
    func displayLoading()
    func displayAlbums(_ albums: [TopAlbum])
    func displayError(message: String, retryTitle: String)
}

final class AlbumGridViewController: UIViewController {
    private let interactor: any AlbumGridInteractorProtocol
    private let albumDetailRouter: AlbumDetailRouter
    private let imageRenderer: any AlbumGridImageRendering
    private var albums: [TopAlbum] = []
    private var isShowingFeedback = false

    private lazy var usernameView: UsernameView = {
        let usernameView = UsernameView()
        usernameView.onSubmit = { [weak self] username in
            self?.interactor.updateUser(username: username)
        }
        return usernameView
    }()

    private lazy var periodTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.text = String(localized: .albumGridPeriod)
        return label
    }()

    private lazy var periodSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(
            items: [
                String(localized: .albumGridPeriodWeek),
                String(localized: .albumGridPeriodMonth),
                String(localized: .albumGridPeriodYear)
            ]
        )
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()

    private lazy var periodStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [periodTitleLabel, periodSegmentedControl])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 12
        return stackView
    }()

    private lazy var gridTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.text = String(localized: .albumGridGrid)
        return label
    }()

    private lazy var gridSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(
            items: [
                String(localized: .albumGridGrid3),
                String(localized: .albumGridGrid4),
                String(localized: .albumGridGrid5)
            ]
        )
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(gridSizeChanged), for: .valueChanged)
        return segmentedControl
    }()

    private lazy var gridStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [gridTitleLabel, gridSegmentedControl])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 12
        return stackView
    }()

    private lazy var generateButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = String(localized: .albumGridGenerate)
        let button = UIButton(configuration: configuration)
        button.addTarget(self, action: #selector(generate), for: .touchUpInside)
        return button
    }()

    private lazy var shareButton: UIButton = {
        var configuration = UIButton.Configuration.bordered()
        configuration.image = UIImage(systemName: "square.and.arrow.up")
        configuration.cornerStyle = .capsule
        let button = UIButton(configuration: configuration)
        button.isEnabled = false
        button.accessibilityLabel = String(localized: .albumGridShare)
        button.addTarget(self, action: #selector(share), for: .touchUpInside)
        return button
    }()

    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [generateButton, shareButton])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 12
        return stackView
    }()

    private lazy var controlsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            periodStackView,
            gridStackView,
            buttonsStackView
        ])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 16
        return stackView
    }()

    private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        return layout
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(AlbumGridCell.self, forCellWithReuseIdentifier: AlbumGridCell.reuseIdentifier)
        return collectionView
    }()

    private lazy var feedbackView: FeedbackView = {
        let feedbackView = FeedbackView()
        feedbackView.onRetry = { [weak self] in
            self?.interactor.retry()
        }
        return feedbackView
    }()

    private var gridSize: Int {
        gridSegmentedControl.selectedSegmentIndex + 3
    }

    init(
        interactor: any AlbumGridInteractorProtocol,
        albumDetailRouter: AlbumDetailRouter,
        imageRenderer: any AlbumGridImageRendering
    ) {
        self.interactor = interactor
        self.albumDetailRouter = albumDetailRouter
        self.imageRenderer = imageRenderer
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        interactor.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        interactor.viewWillAppear()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    @objc private func gridSizeChanged() {
        collectionView.reloadData()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    @objc private func generate() {
        interactor.generate(
            periodIndex: periodSegmentedControl.selectedSegmentIndex,
            gridSize: gridSize
        )
    }

    @objc private func share() {
        guard let image = imageRenderer.render(
            collectionView: collectionView,
            gridSize: gridSize
        ) else { return }

        let activityViewController = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        activityViewController.popoverPresentationController?.sourceView = shareButton
        activityViewController.popoverPresentationController?.sourceRect = shareButton.bounds
        present(activityViewController, animated: true)
    }
}

extension AlbumGridViewController: AlbumGridViewProtocol {
    func displayUsername(_ username: String?) {
        usernameView.setUsername(username ?? "")
    }

    func displayLoading() {
        setControlsEnabled(false)
        generateButton.configuration?.showsActivityIndicator = true
        isShowingFeedback = false
        collectionView.backgroundView = nil
        collectionView.reloadData()
    }

    func displayAlbums(_ albums: [TopAlbum]) {
        self.albums = albums
        isShowingFeedback = false
        finishLoading()
        shareButton.isEnabled = !albums.isEmpty
        collectionView.backgroundView = nil
        collectionView.reloadData()
    }

    func displayError(message: String, retryTitle: String) {
        finishLoading()
        isShowingFeedback = true
        feedbackView.displayError(message: message, retryTitle: retryTitle)
        collectionView.backgroundView = feedbackView
        collectionView.reloadData()
    }
}

extension AlbumGridViewController: ViewCode {
    func buildViewHierarchy() {
        view.addSubview(usernameView)
        view.addSubview(controlsStackView)
        view.addSubview(collectionView)
    }

    func setupConstraints() {
        usernameView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.trailing.equalTo(view.layoutMarginsGuide)
        }

        controlsStackView.snp.makeConstraints { make in
            make.top.equalTo(usernameView.snp.bottom).offset(24)
            make.leading.trailing.equalTo(view.layoutMarginsGuide)
        }

        shareButton.snp.makeConstraints { make in
            make.size.equalTo(44)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(controlsStackView.snp.bottom).offset(16)
            make.leading.trailing.equalTo(view.layoutMarginsGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    func setupAdditionalConfiguration() {
        navigationItem.title = String(localized: .tabBarGrid)
        view.backgroundColor = .systemBackground
    }
}

extension AlbumGridViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        isShowingFeedback ? 0 : gridSize * gridSize
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: AlbumGridCell.reuseIdentifier,
                for: indexPath
            ) as? AlbumGridCell
        else {
            return UICollectionViewCell()
        }

        let row = indexPath.item / gridSize
        let column = indexPath.item % gridSize
        let placeholderColor: UIColor = (row + column).isMultiple(of: 2)
            ? .systemGray4
            : .systemGray6

        let album = albums.indices.contains(indexPath.item) ? albums[indexPath.item] : nil
        cell.configure(album: album, placeholderColor: placeholderColor)
        return cell
    }
}

private extension AlbumGridViewController {
    func setControlsEnabled(_ isEnabled: Bool) {
        usernameView.isUserInteractionEnabled = isEnabled
        periodSegmentedControl.isEnabled = isEnabled
        gridSegmentedControl.isEnabled = isEnabled
        generateButton.isEnabled = isEnabled
        shareButton.isEnabled = isEnabled && !albums.isEmpty
    }

    func finishLoading() {
        generateButton.configuration?.showsActivityIndicator = false
        setControlsEnabled(true)
    }
}

extension AlbumGridViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard albums.indices.contains(indexPath.item) else { return }
        let album = albums[indexPath.item]
        albumDetailRouter.route(
            from: self,
            albumName: album.name,
            artistName: album.artistName
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let side = itemSide(in: collectionView)
        return CGSize(width: side, height: side)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        let side = itemSide(in: collectionView)
        let itemsSize = side * CGFloat(gridSize)
        let horizontalInset = max(4, floor((collectionView.bounds.width - itemsSize) / 2))
        let verticalInset = max(4, floor((collectionView.bounds.height - itemsSize) / 2))

        return UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }

    private func itemSide(in collectionView: UICollectionView) -> CGFloat {
        let availableWidth = collectionView.bounds.width - 8
        let availableHeight = collectionView.bounds.height - 8
        return max(0, floor(min(availableWidth, availableHeight) / CGFloat(gridSize)))
    }
}
