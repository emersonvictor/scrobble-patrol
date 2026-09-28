import Foundation
import XCTest
@testable import ScrobblePatrol

@MainActor
final class AlbumDetailPresenterTests: XCTestCase {
    func testPresentLoadingRequestsLoadingFromView() {
        let context = makeContext()

        context.sut.presentLoading()

        XCTAssertEqual(context.view.loadingCallCount, 1)
    }

    func testPresentAlbumForwardsAlbumToView() {
        let context = makeContext()
        let album = Album.fixture()

        context.sut.presentAlbum(album)

        XCTAssertEqual(context.view.displayedAlbums, [album])
    }

    func testPresentAPIErrorUsesAPIMessage() throws {
        let context = makeContext()

        context.sut.presentError(.api(code: 6, message: "Album not found"))

        let error = try XCTUnwrap(context.view.displayedErrors.last)
        XCTAssertEqual(error.message, "Album not found")
        XCTAssertFalse(error.retryTitle.isEmpty)
    }

    func testPresentNetworkErrorUsesLocalizedMessage() throws {
        let context = makeContext()

        context.sut.presentError(.network(URLError(.notConnectedToInternet)))

        let error = try XCTUnwrap(context.view.displayedErrors.last)
        XCTAssertEqual(error.message, String(localized: .requestErrorNoConnectionError))
    }

    func testPresentDefaultErrorUsesAlbumMessage() throws {
        let context = makeContext()

        context.sut.presentError(.httpStatus(500))

        let error = try XCTUnwrap(context.view.displayedErrors.last)
        XCTAssertEqual(error.message, String(localized: .albumDetailLoadError))
    }

    private func makeContext() -> Context {
        let sut = AlbumDetailPresenter()
        let view = AlbumDetailViewSpy()
        sut.attach(view: view)
        return Context(sut: sut, view: view)
    }

    private struct Context {
        let sut: AlbumDetailPresenter
        let view: AlbumDetailViewSpy
    }
}
