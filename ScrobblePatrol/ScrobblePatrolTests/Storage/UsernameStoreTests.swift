import Combine
import Foundation
import XCTest
@testable import ScrobblePatrol

@MainActor
final class UsernameStoreTests: XCTestCase {
    func testUpdateTrimsAndPersistsUsername() throws {
        let context = try makeContext()
        defer { context.userDefaults.removePersistentDomain(forName: context.suiteName) }

        context.sut.update("  listener  ")

        XCTAssertEqual(context.sut.username, "listener")
        XCTAssertEqual(context.userDefaults.string(forKey: "lastFmUsername"), "listener")
    }

    func testEmptyUsernameRemovesPersistedValue() throws {
        let context = try makeContext(initialUsername: "listener")
        defer { context.userDefaults.removePersistentDomain(forName: context.suiteName) }

        context.sut.update("   \n  ")

        XCTAssertNil(context.sut.username)
        XCTAssertNil(context.userDefaults.string(forKey: "lastFmUsername"))
    }

    func testNilUsernameRemovesPersistedValue() throws {
        let context = try makeContext(initialUsername: "listener")
        defer { context.userDefaults.removePersistentDomain(forName: context.suiteName) }

        context.sut.update(nil)

        XCTAssertNil(context.sut.username)
        XCTAssertNil(context.userDefaults.string(forKey: "lastFmUsername"))
    }

    func testInitializationReadsPersistedUsername() throws {
        let context = try makeContext(initialUsername: "listener")
        defer { context.userDefaults.removePersistentDomain(forName: context.suiteName) }

        XCTAssertEqual(context.sut.username, "listener")
    }

    func testPublisherEmitsNormalizedUpdates() throws {
        let context = try makeContext()
        defer { context.userDefaults.removePersistentDomain(forName: context.suiteName) }
        var receivedUsernames: [String?] = []
        let cancellable = context.sut.usernamePublisher.sink {
            receivedUsernames.append($0)
        }

        context.sut.update("  listener  ")
        context.sut.update("")

        XCTAssertEqual(receivedUsernames.count, 3)
        XCTAssertNil(receivedUsernames[0])
        XCTAssertEqual(receivedUsernames[1], "listener")
        XCTAssertNil(receivedUsernames[2])
        withExtendedLifetime(cancellable) {}
    }

    private func makeContext(initialUsername: String? = nil) throws -> Context {
        let suiteName = "UsernameStoreTests.\(UUID().uuidString)"
        let userDefaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        userDefaults.removePersistentDomain(forName: suiteName)
        if let initialUsername {
            userDefaults.set(initialUsername, forKey: "lastFmUsername")
        }
        return Context(
            sut: UsernameStore(userDefaults: userDefaults),
            userDefaults: userDefaults,
            suiteName: suiteName
        )
    }

    private struct Context {
        let sut: UsernameStore
        let userDefaults: UserDefaults
        let suiteName: String
    }
}
