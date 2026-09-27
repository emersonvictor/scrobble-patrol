import Combine
import Foundation
@testable import ScrobblePatrol

@MainActor
final class UsernameStoreMock: UsernameStoreProtocol {
    private let subject: CurrentValueSubject<String?, Never>

    var username: String? {
        subject.value
    }

    var usernamePublisher: AnyPublisher<String?, Never> {
        subject.eraseToAnyPublisher()
    }

    init(username: String? = nil) {
        subject = CurrentValueSubject(username)
    }

    func update(_ username: String?) {
        let normalizedUsername = username?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        subject.send(normalizedUsername?.isEmpty == false ? normalizedUsername : nil)
    }
}
