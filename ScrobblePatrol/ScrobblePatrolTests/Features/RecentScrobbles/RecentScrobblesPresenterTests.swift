import Foundation
import XCTest
@testable import ScrobblePatrol

@MainActor
final class RecentScrobblesPresenterTests: XCTestCase {
    func testPresentUsernameForwardsUsernameToView() {
        let context = makeContext()

        context.sut.presentUsername("listener")

        XCTAssertEqual(context.view.displayedUsernames, ["listener"])
    }

    func testPresentLoadingRequestsLoadingFromView() {
        let context = makeContext()

        context.sut.presentLoading()

        XCTAssertEqual(context.view.loadingCallCount, 1)
    }

    func testPresentScrobblesForwardsScrobblesToView() {
        let context = makeContext()
        let scrobbles = [RecentScrobble.fixture()]

        context.sut.presentScrobbles(scrobbles)

        XCTAssertEqual(context.view.displayedScrobbles, [scrobbles])
    }

    func testPresentAPIErrorUsesAPIMessage() throws {
        let context = makeContext()

        context.sut.presentError(.api(code: 6, message: "User not found"))

        let error = try XCTUnwrap(context.view.displayedErrors.last)
        XCTAssertEqual(error.message, "User not found")
        XCTAssertFalse(error.retryTitle.isEmpty)
    }

    func testPresentNetworkErrorUsesLocalizedMessage() throws {
        let context = makeContext()

        context.sut.presentError(.network(URLError(.notConnectedToInternet)))

        let error = try XCTUnwrap(context.view.displayedErrors.last)
        XCTAssertEqual(error.message, String(localized: .requestErrorNoConnectionError))
    }

    func testFinishRefreshingRequestsFinishFromView() {
        let context = makeContext()

        context.sut.finishRefreshing()

        XCTAssertEqual(context.view.finishRefreshingCallCount, 1)
    }

    private func makeContext() -> Context {
        let sut = RecentScrobblesPresenter()
        let view = RecentScrobblesViewSpy()
        sut.attach(view: view)
        return Context(sut: sut, view: view)
    }

    private struct Context {
        let sut: RecentScrobblesPresenter
        let view: RecentScrobblesViewSpy
    }
}
