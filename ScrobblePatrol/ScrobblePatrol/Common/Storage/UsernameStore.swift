import Combine
import Foundation

@MainActor
protocol UsernameStoreProtocol: AnyObject {
    var username: String? { get }
    var usernamePublisher: AnyPublisher<String?, Never> { get }

    func update(_ username: String?)
}

@MainActor
final class UsernameStore: UsernameStoreProtocol {
    private enum Keys {
        static let username = "lastFmUsername"
    }

    private let userDefaults: UserDefaults
    private let subject: CurrentValueSubject<String?, Never>

    var username: String? {
        subject.value
    }

    var usernamePublisher: AnyPublisher<String?, Never> {
        subject
            .eraseToAnyPublisher()
    }

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        subject = CurrentValueSubject(userDefaults.string(forKey: Keys.username))
    }

    func update(_ username: String?) {
        let normalizedUsername = username?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let newUsername = normalizedUsername?.isEmpty == false ? normalizedUsername : nil

        if let newUsername {
            userDefaults.set(newUsername, forKey: Keys.username)
        } else {
            userDefaults.removeObject(forKey: Keys.username)
        }
        subject.send(newUsername)
    }
}
