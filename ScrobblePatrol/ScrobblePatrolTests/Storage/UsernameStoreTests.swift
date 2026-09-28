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
