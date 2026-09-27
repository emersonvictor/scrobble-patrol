import SnapKit
import UIKit

final class TableBackgroundView: UIView, ViewCode {
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .secondaryLabel
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [activityIndicator, imageView, titleLabel, messageLabel]
        )
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    func displayLoading(message: String? = nil) {
        imageView.isHidden = true
        titleLabel.isHidden = true
        messageLabel.text = message
        messageLabel.isHidden = message == nil
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }

    func displayEmpty(
        title: String,
        message: String? = nil,
        image: UIImage? = UIImage(systemName: "music.note.list")
    ) {
        displayMessage(title: title, message: message, image: image)
    }

    func displayError(
        title: String,
        message: String? = nil,
        image: UIImage? = UIImage(systemName: "exclamationmark.triangle")
    ) {
        displayMessage(title: title, message: message, image: image)
    }

    func buildViewHierarchy() {
        addSubview(contentStackView)
    }

    func setupConstraints() {
        contentStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualTo(layoutMarginsGuide)
            make.trailing.lessThanOrEqualTo(layoutMarginsGuide)
        }

        imageView.snp.makeConstraints { make in
            make.size.equalTo(32)
        }
    }

    private func displayMessage(title: String, message: String?, image: UIImage?) {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        imageView.image = image
        imageView.isHidden = image == nil
        titleLabel.text = title
        titleLabel.isHidden = false
        messageLabel.text = message
        messageLabel.isHidden = message == nil
    }
}
