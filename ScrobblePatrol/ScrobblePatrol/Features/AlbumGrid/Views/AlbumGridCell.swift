import SnapKit
import UIKit

final class AlbumGridCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: AlbumGridCell.self)

    private lazy var artworkView = AlbumArtworkView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()
        artworkView.cancel()
    }

    func configure(album: TopAlbum?, placeholderColor: UIColor) {
        artworkView.backgroundColor = placeholderColor
        artworkView.load(url: album?.imageURL)
    }
}

extension AlbumGridCell: ViewCode {
    func buildViewHierarchy() {
        contentView.addSubview(artworkView)
    }

    func setupConstraints() {
        artworkView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
