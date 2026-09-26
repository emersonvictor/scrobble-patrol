import SnapKit
import UIKit

final class UsernameView: UIView, ViewCode {
    var onSubmit: ((String) -> Void)?

    private let textField: UITextField = {
        let textField = UITextField()
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.clearButtonMode = .whileEditing
        textField.placeholder = String(localized: .usernamePlaceholder)
        textField.returnKeyType = .done
        return textField
    }()

    private let confirmButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = String(localized: .usernameConfirm)
        let button = UIButton(configuration: configuration)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    func setUsername(_ username: String) {
        textField.text = username
    }

    func buildViewHierarchy() {
        addSubview(textField)
        addSubview(confirmButton)
    }

    func setupConstraints() {
        textField.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
        }
        
        confirmButton.snp.makeConstraints { make in
            make.leading.equalTo(textField.snp.trailing).offset(8)
            make.trailing.top.bottom.equalToSuperview()
            make.width.equalTo(56)
            make.height.equalTo(44)
        }
    }

    func setupAdditionalConfiguration() {
        textField.delegate = self
        confirmButton.addTarget(self, action: #selector(submit), for: .touchUpInside)
    }

    @objc private func submit() {
        let username = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        onSubmit?(username)
        textField.resignFirstResponder()
    }
}

extension UsernameView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        submit()
        return true
    }
}
