import Foundation

@MainActor
protocol UsernameStoreProtocol: AnyObject {
    var username: String? { get }

    func update(_ username: String?)
}

@MainActor
final class UsernameStore: UsernameStoreProtocol {
    private enum Keys {
        static let username = "lastFmUsername"
    }

    private let userDefaults: UserDefaults

    var username: String? {
        userDefaults.string(forKey: Keys.username)
    }

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
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
    }
}
