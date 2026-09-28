import Foundation
@testable import ScrobblePatrol

@MainActor
final class UsernameStoreMock: UsernameStoreProtocol {
    private(set) var username: String?

    init(username: String? = nil) {
        self.username = username
    }

    func update(_ username: String?) {
        let normalizedUsername = username?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        self.username = normalizedUsername?.isEmpty == false ? normalizedUsername : nil
    }
}
