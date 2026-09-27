import SnapKit
import UIKit

final class APIErrorViewController: UIViewController, ViewCode {
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.text = String(localized: .apiErrorMessage)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    func buildViewHierarchy() {
        view.addSubview(messageLabel)
    }

    func setupConstraints() {
        messageLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.layoutMarginsGuide)
            make.centerY.equalToSuperview()
        }
    }

    func setupAdditionalConfiguration() {
        view.backgroundColor = .systemBackground
    }
}
