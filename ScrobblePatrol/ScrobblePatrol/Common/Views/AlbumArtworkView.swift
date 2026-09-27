import SnapKit
import UIKit

@MainActor
final class AlbumArtworkView: UIView, ViewCode {
    private let imageLoader: any ImageLoading
    private let placeholder = UIImage(systemName: "music.note")
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = placeholder
        imageView.tintColor = .secondaryLabel
        return imageView
    }()
    private var imageTask: Task<Void, Never>?
    private var representedURL: URL?

    override init(frame: CGRect) {
        self.imageLoader = ImageLoader.shared
        super.init(frame: frame)
        setupView()
    }

    init(frame: CGRect = .zero, imageLoader: any ImageLoading) {
        self.imageLoader = imageLoader
        super.init(frame: frame)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    func load(url: URL?) {
        cancel()
        representedURL = url

        guard let url else { return }

        imageTask = Task { [weak self] in
            do {
                guard let image = try await self?.imageLoader.load(url) else { return }

                guard
                    self?.representedURL == url
                else { return }

                self?.imageView.image = image
            } catch {
                return
            }
        }
    }

    func cancel() {
        imageTask?.cancel()
        imageTask = nil
        representedURL = nil
        imageView.image = placeholder
    }

    func buildViewHierarchy() {
        addSubview(imageView)
    }

    func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func setupAdditionalConfiguration() {
        backgroundColor = .secondarySystemBackground
        clipsToBounds = true
    }

    deinit {
        imageTask?.cancel()
    }
}
