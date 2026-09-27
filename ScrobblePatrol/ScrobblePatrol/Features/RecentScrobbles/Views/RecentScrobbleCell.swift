import SnapKit
import UIKit

final class RecentScrobbleCell: UITableViewCell, ViewCode {
    static let reuseIdentifier = String(describing: RecentScrobbleCell.self)

    private lazy var artworkView: AlbumArtworkView = {
        let artworkView = AlbumArtworkView()
        artworkView.layer.cornerRadius = 8
        return artworkView
    }()

    private lazy var trackLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.numberOfLines = 1
        return label
    }()

    private lazy var artistLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()

    private lazy var albumLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()

    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        return label
    }()

    private lazy var nowPlayingImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chart.bar.fill"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .secondaryLabel
        return imageView
    }()

    private lazy var nowPlayingLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        label.text = String(localized: .recentScrobblesNowPlaying)
        return label
    }()

    private lazy var nowPlayingStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [nowPlayingImageView, nowPlayingLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 6
        stackView.isHidden = true
        return stackView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()
        artworkView.cancel()
        trackLabel.text = nil
        artistLabel.text = nil
        albumLabel.text = nil
        timeLabel.text = nil
        nowPlayingStackView.isHidden = true
    }

    func configure(with scrobble: RecentScrobble) {
        artworkView.load(url: scrobble.imageURL)
        trackLabel.text = scrobble.trackName
        artistLabel.text = scrobble.artistName
        albumLabel.text = scrobble.albumName
        albumLabel.isHidden = scrobble.albumName == nil
        timeLabel.text = scrobble.formattedPlayedAt
        timeLabel.isHidden = scrobble.formattedPlayedAt == nil
        nowPlayingStackView.isHidden = !scrobble.isNowPlaying
    }

    func buildViewHierarchy() {
        contentView.addSubview(artworkView)
        contentView.addSubview(trackLabel)
        contentView.addSubview(artistLabel)
        contentView.addSubview(albumLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(nowPlayingStackView)
    }

    func setupConstraints() {
        artworkView.snp.makeConstraints { make in
            make.leading.equalTo(contentView.layoutMarginsGuide)
            make.top.bottom.equalToSuperview().inset(12)
            make.size.equalTo(88)
        }

        trackLabel.snp.makeConstraints { make in
            make.top.equalTo(artworkView)
            make.leading.equalTo(artworkView.snp.trailing).offset(12)
            make.trailing.equalTo(contentView.layoutMarginsGuide)
        }

        artistLabel.snp.makeConstraints { make in
            make.top.equalTo(trackLabel.snp.bottom).offset(3)
            make.leading.trailing.equalTo(trackLabel)
        }

        albumLabel.snp.makeConstraints { make in
            make.top.equalTo(artistLabel.snp.bottom).offset(3)
            make.leading.trailing.equalTo(trackLabel)
        }

        timeLabel.snp.makeConstraints { make in
            make.leading.equalTo(trackLabel)
            make.bottom.equalTo(artworkView)
        }

        nowPlayingStackView.snp.makeConstraints { make in
            make.leading.equalTo(trackLabel)
            make.bottom.equalTo(artworkView)
        }

        nowPlayingImageView.snp.makeConstraints { make in
            make.width.equalTo(16)
        }
    }

}
