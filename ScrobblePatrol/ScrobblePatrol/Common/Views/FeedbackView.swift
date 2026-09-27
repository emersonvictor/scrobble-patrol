import SnapKit
import UIKit

final class FeedbackView: UIView, ViewCode {
    var onRetry: (() -> Void)?

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    private lazy var retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(retry), for: .touchUpInside)
        return button
    }()

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [activityIndicator, messageLabel, retryButton]
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

    func displayLoading() {
        isHidden = false
        messageLabel.isHidden = true
        retryButton.isHidden = true
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }

    func displayError(message: String, retryTitle: String) {
        isHidden = false
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        messageLabel.text = message
        messageLabel.isHidden = false
        retryButton.setTitle(retryTitle, for: .normal)
        retryButton.isHidden = false
    }

    func hide() {
        activityIndicator.stopAnimating()
        isHidden = true
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
    }

    @objc private func retry() {
        onRetry?()
    }
}
