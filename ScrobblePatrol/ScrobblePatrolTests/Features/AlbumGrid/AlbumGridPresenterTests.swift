import Foundation
import XCTest
@testable import ScrobblePatrol

@MainActor
final class AlbumGridPresenterTests: XCTestCase {
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

    func testPresentAlbumsForwardsAlbumsToView() {
        let context = makeContext()
        let albums = [TopAlbum.fixture()]

        context.sut.presentAlbums(albums)

        XCTAssertEqual(context.view.displayedAlbums, [albums])
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

    func testPresentDefaultErrorUsesGridMessage() throws {
        let context = makeContext()

        context.sut.presentError(.httpStatus(500))

        let error = try XCTUnwrap(context.view.displayedErrors.last)
        XCTAssertEqual(error.message, String(localized: .albumGridLoadError))
    }

    private func makeContext() -> Context {
        let sut = AlbumGridPresenter()
        let view = AlbumGridViewSpy()
        sut.attach(view: view)
        return Context(sut: sut, view: view)
    }

    private struct Context {
        let sut: AlbumGridPresenter
        let view: AlbumGridViewSpy
    }
}
