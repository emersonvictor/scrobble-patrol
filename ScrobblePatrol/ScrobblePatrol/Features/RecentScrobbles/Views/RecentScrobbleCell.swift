import SnapKit
import UIKit

final class RecentScrobbleCell: UITableViewCell, ViewCode {
    static let reuseIdentifier = String(describing: RecentScrobbleCell.self)

    private lazy var artworkView = AlbumArtworkView()
    private lazy var trackLabel = UILabel()
    private lazy var artistLabel = UILabel()
    private lazy var albumLabel = UILabel()
    private lazy var timeLabel = UILabel()
    private lazy var nowPlayingImageView = UIImageView(image: UIImage(systemName: "chart.bar.fill"))
    private lazy var nowPlayingLabel = UILabel()
    private lazy var nowPlayingStackView = UIStackView(
        arrangedSubviews: [nowPlayingImageView, nowPlayingLabel]
    )

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

    func setupAdditionalConfiguration() {
        artworkView.layer.cornerRadius = 8

        trackLabel.font = .preferredFont(forTextStyle: .headline)
        trackLabel.numberOfLines = 1

        artistLabel.font = .preferredFont(forTextStyle: .subheadline)
        artistLabel.textColor = .secondaryLabel
        artistLabel.numberOfLines = 1

        albumLabel.font = .preferredFont(forTextStyle: .subheadline)
        albumLabel.textColor = .secondaryLabel
        albumLabel.numberOfLines = 1

        timeLabel.font = .preferredFont(forTextStyle: .caption1)
        timeLabel.textColor = .secondaryLabel

        nowPlayingStackView.axis = .horizontal
        nowPlayingStackView.alignment = .center
        nowPlayingStackView.spacing = 6
        nowPlayingStackView.isHidden = true

        nowPlayingImageView.contentMode = .scaleAspectFit
        nowPlayingImageView.tintColor = .secondaryLabel

        nowPlayingLabel.font = .preferredFont(forTextStyle: .caption1)
        nowPlayingLabel.textColor = .secondaryLabel
        nowPlayingLabel.text = String(localized: .recentScrobblesNowPlaying)
    }
}
