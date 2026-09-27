import SnapKit
import UIKit

final class AlbumTagsView: UIView, ViewCode {
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 16
        return stackView
    }()

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 32)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    func setTags(_ tags: [String]) {
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        tags.forEach { tag in
            stackView.addArrangedSubview(AlbumTagView(text: tag))
        }
    }

    func buildViewHierarchy() {
        addSubview(scrollView)
        scrollView.addSubview(stackView)
    }

    func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.height.equalTo(scrollView.frameLayoutGuide)
        }
    }
}

private final class AlbumTagView: UIView, ViewCode {
    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        return label
    }()

    init(text: String) {
        super.init(frame: .zero)
        label.text = text
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    func buildViewHierarchy() {
        addSubview(label)
    }

    func setupConstraints() {
        snp.makeConstraints { make in
            make.height.equalTo(32)
        }

        label.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }
    }

    func setupAdditionalConfiguration() {
        layer.borderColor = UIColor.separator.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 16
    }
}
